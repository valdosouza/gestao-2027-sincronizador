unit ControllerPrePaidCard;

interface

uses IBX.IBDatabase,Classes, Vcl.Grids,IBQuery, SysUtils,ControllerBase,
      tblPrePaidCard ,Un_MSg,Generics.Collections,prmbase, prm_pre_paid_card;

Type
  TListaPrePaidCard = TObjectList<TPrePaidCard>;

  TControllerPrePaidCard = Class(TControllerBase)
  private
    function getNextNumero:Integer;
  public
    Registro : TPrePaidCard;
    Lista : TListaPrePaidCard;
    Parametros : TPrmPrePaidCard;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function salva:boolean;
    procedure getbyId;
    procedure clear;
    function insert:boolean;
    function update:boolean;
    Function delete:boolean;
    Function deleteByOrder:boolean;
    function getList:Boolean;
    function getCredito:Real;
    function getDebito:Real;
    function getSaldo:Real;
    function getbyNumber:Boolean;
    function getLasData:TDate;

  End;

implementation

uses Un_sistema, Un_funcoes,Un_Regra_Negocio;

procedure TControllerPrePaidCard.clear;
begin
  clearObj(Registro);
end;

constructor TControllerPrePaidCard.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TPrePaidCard.Create;
  Lista := TListaPrePaidCard.Create;
  Parametros := TPrmPrePaidCard.create;
end;

function TControllerPrePaidCard.delete: boolean;
begin
  Try
    DeleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerPrePaidCard.deleteByOrder: boolean;
var
  Lc_Qry : TIBQuery;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'DELETE  ',
                  'FROM TB_PAY_BACK ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) ',
                  ' AND ( TB_ORDER_ID =:TB_ORDER_ID ) '
      ));
      ParamByName('TB_INSTITUTION_ID').AsInteger := Parametros.PrePago.Estabelecimento;
      ParamByName('TB_ORDER_ID').AsInteger := Parametros.PrePago.Ordem;
      ExecSQL;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

destructor TControllerPrePaidCard.Destroy;
begin
  Parametros.Destroy;
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;

function TControllerPrePaidCard.insert: boolean;
begin
  Try
    if Registro.Codigo = 0 then
      Registro.Codigo := Generator('GN_PRE_PAID_CARD');

    if Registro.Numero = 0 then
      Registro.Numero := getNextNumero;

    InsertObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerPrePaidCard.salva: boolean;
begin
  Try
    if Registro.Codigo = 0 then
      Registro.Codigo := Generator('GN_PRE_PAID_CARD');

    if Registro.Numero = 0 then
      Registro.Numero := getNextNumero;

    SaveObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

function TControllerPrePaidCard.update: boolean;
begin
  Try
    UpdateObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

procedure TControllerPrePaidCard.getById;
begin
  _getByKey(Registro);
end;

function TControllerPrePaidCard.getbyNumber: Boolean;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT * ',
                  'FROM TB_PRE_PAID_CARD  ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) ',
                  ' AND ( NUMBER =:NUMBER ) '
      ));
      ParamByName('TB_INSTITUTION_ID').AsInteger  :=  Parametros.PrePago.Estabelecimento;
      ParamByName('NUMBER').AsInteger             :=  Parametros.PrePago.Numero;
      Active := True;
      FetchAll;
      exist := (RecordCount > 0);
      if exist then
        get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getCredito: Real;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT SUM(credit_value) CREDITO ',
                  'FROM TB_PRE_PAID_CARD ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) '
      ));

      if Parametros.PrePago.Numero > 0 then
        sql.add(' AND ( NUMBER =:NUMBER ) ');

      if Parametros.Periodo then
        sql.add(' AND ( DT_RECORD BETWEEN :DATAINI AND :DATAFIM ) ');

      ParamByName('TB_INSTITUTION_ID').AsInteger := Parametros.PrePago.Estabelecimento;

      if Parametros.PrePago.Numero > 0 then
        ParamByName('NUMBER').AsInteger := Parametros.PrePago.Numero;

      if Parametros.Periodo then
      Begin
        ParamByName('DATAINI').AsDateTime := Parametros.DataInicial;
        ParamByName('DATAFIM').AsDateTime := Parametros.DataFinal;
      End;

      Active := True;
      FetchAll;
      First;
      Result := FieldByName('CREDITO').AsFloat;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getDebito: Real;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT SUM(debit_value) DEBITO ',
                  'FROM TB_PRE_PAID_CARD ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) '
      ));

      if Parametros.PrePago.Numero > 0 then
        sql.add(' AND ( NUMBER =:NUMBER ) ');

      if Parametros.Periodo then
        sql.add(' AND ( DT_RECORD BETWEEN :DATAINI AND :DATAFIM ) ');

      ParamByName('TB_INSTITUTION_ID').AsInteger := Parametros.PrePago.Estabelecimento;

      if Parametros.PrePago.Numero > 0 then
        ParamByName('NUMBER').AsInteger := Parametros.PrePago.Numero;

      if Parametros.Periodo then
      Begin
        ParamByName('DATAINI').AsDateTime := Parametros.DataInicial;
        ParamByName('DATAFIM').AsDateTime := Parametros.DataFinal;
      End;

      Active := True;
      FetchAll;
      First;
      Result := FieldByName('DEBITO').AsFloat;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getLasData: TDate;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT MAX(DT_RECORD) DATA ',
                  'FROM TB_PRE_PAID_CARD ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) '
      ));

      if Parametros.PrePago.Numero > 0 then
        sql.add(' AND ( NUMBER =:NUMBER ) ');

      ParamByName('TB_INSTITUTION_ID').AsInteger := Parametros.PrePago.Estabelecimento;

      if Registro.Numero > 0 then
        ParamByName('NUMBER').AsInteger := Parametros.PrePago.Numero;

      Active := True;
      FetchAll;
      First;
      Result := FieldByName('DATA').AsDateTime;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getList: Boolean;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_PRE_PAID_CARD '));
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TPrePaidCard.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getNextNumero: Integer;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT MAX(NUMBER) NUMERO ',
                  'FROM TB_PRE_PAID_CARD ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) '
      ));

      ParamByName('TB_INSTITUTION_ID').AsInteger := Registro.Estabelecimento;

      Active := True;
      FetchAll;
      First;
      Result := StrToIntDef(FieldByName('NUMERO').AsString,0) + 1;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerPrePaidCard.getSaldo: Real;
var
  Lc_Qry : TIBQuery;
  LITem : TPrePaidCard;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                  'SELECT SUM(credit_value - debit_value) SALDO ',
                  'FROM TB_PRE_PAID_CARD  ',
                  'WHERE ( TB_INSTITUTION_ID =:TB_INSTITUTION_ID ) '
      ));

      if Parametros.PrePago.Numero > 0 then
        sql.add(' AND ( NUMBER =:NUMBER ) ');

      if Parametros.Periodo then
        sql.add(' AND ( DT_RECORD BETWEEN :DATAINI AND :DATAFIM ) ');

      ParamByName('TB_INSTITUTION_ID').AsInteger := Parametros.PrePago.Estabelecimento;

      if Parametros.PrePago.Numero > 0 then
        ParamByName('NUMBER').AsInteger := Parametros.PrePago.Numero;

      if Parametros.Periodo then
      Begin
        ParamByName('DATAINI').AsDateTime := Parametros.DataInicial;
        ParamByName('DATAFIM').AsDateTime := Parametros.DataFinal;
      End;

      Active := True;
      FetchAll;
      First;
      Result := FieldByName('SALDO').AsFloat;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
