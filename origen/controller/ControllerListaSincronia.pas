unit ControllerListaSincronia;

interface

uses
  System.Classes,Generics.Collections, IBX.IBDatabase,tblListaSincronia,
  IBX.IBQuery, ControllerBase, IBX.IBScript, System.SysUtils;

Type

  TListaListaParaSincronizar = TObjectList<TListaSincronia>;

  TControllerListaSincronia = Class(TControllerBase)
  private
    FTempoMinimo: TDateTime;


    procedure _getListaReceber;
    procedure _getListaEnviar;
    procedure setFTempoMinimo(const Value: TDateTime);


  public
    registro : TListaSincronia;
    ListaReceber :TListaListaParaSincronizar;
    ListaEnviar :TListaListaParaSincronizar;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure getListaReceber;
    procedure getListaEnviar;


    function SincronizaTabela:Boolean;

    // Checkpoint LAST_UPDATE (decisoes 1 e 3): substitui a antiga TB_SYNC_TABLE.
    // pKind = '' considera todas as linhas de (WAY, DESC_TABELA).
    function GetLastUpdate(pWay, pTabela, pKind: String): TDateTime;
    procedure SetLastUpdate(pWay, pTabela, pKind: String; pDtUpdate: TDateTime);
    // Reposiciona o checkpoint de TODAS as linhas de um sentido (usado pelo
    // ajuste manual de data/hora na tela principal).
    procedure SetLastUpdateAll(pWay: String; pDtUpdate: TDateTime);
    // Grava o nome da trigger criada pelo bootstrap (decisao 6).
    procedure SetTriggerName(pWay, pTabela, pKind, pTrigger: String);

    property TempoMinimo : TDateTime read FTempoMinimo write setFTempoMinimo;



  End;

implementation

uses ControllerSincronia;

{ TControllerListaSincronia }

constructor TControllerListaSincronia.Create(AOwner: TComponent);
begin
  inherited;
  registro := TListaSincronia.Create;
  ListaReceber := TListaListaParaSincronizar.create;
  ListaEnviar  := TListaListaParaSincronizar.create;
end;

destructor TControllerListaSincronia.Destroy;
begin
  Registro.Disposeof;
  ListaReceber.DisposeOf;
  ListaEnviar.DisposeOf;
  inherited;
end;



procedure TControllerListaSincronia.getListaEnviar;
Begin
  _getListaEnviar;
end;

procedure TControllerListaSincronia.getListaReceber;
Begin
  _getListaReceber;
end;




procedure TControllerListaSincronia.setFTempoMinimo(const Value: TDateTime);
begin
  FTempoMinimo := Value;
end;


function TControllerListaSincronia.GetLastUpdate(pWay, pTabela, pKind: String): TDateTime;
var
  Lc_Qry : TIBQuery;
begin
  // Sentinela: sem checkpoint ainda -> processa tudo desde essa data (mesmo
  // fallback usado no restante do projeto).
  Result := StrToDateTime('01/01/2016 00:00:00');
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT MIN(LAST_UPDATE) LAST_UPDATE ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE ( WAY = :WAY ) ',
                '  and ( DESC_TABELA = :DESC_TABELA ) '
      ));
      if pKind <> '' then
        sql.add('  and ( KIND = :KIND ) ');
      ParamByName('WAY').AsString         := pWay;
      ParamByName('DESC_TABELA').AsString := pTabela;
      if pKind <> '' then
        ParamByName('KIND').AsString := pKind;
      Active := True;
      FetchAll;
      if (RecordCount > 0) and (not FieldByName('LAST_UPDATE').IsNull) then
        Result := FieldByName('LAST_UPDATE').AsDateTime;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia.SetLastUpdate(pWay, pTabela, pKind: String; pDtUpdate: TDateTime);
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'UPDATE TB_LISTA_SINCRONIA ',
                'SET LAST_UPDATE = :LAST_UPDATE ',
                'WHERE ( WAY = :WAY ) ',
                '  and ( DESC_TABELA = :DESC_TABELA ) '
      ));
      if pKind <> '' then
        sql.add('  and ( KIND = :KIND ) ');
      ParamByName('LAST_UPDATE').AsDateTime := pDtUpdate;
      ParamByName('WAY').AsString           := pWay;
      ParamByName('DESC_TABELA').AsString   := pTabela;
      if pKind <> '' then
        ParamByName('KIND').AsString := pKind;
      ExecSQL;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia.SetLastUpdateAll(pWay: String; pDtUpdate: TDateTime);
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'UPDATE TB_LISTA_SINCRONIA ',
                'SET LAST_UPDATE = :LAST_UPDATE ',
                'WHERE ( WAY = :WAY ) '
      ));
      ParamByName('LAST_UPDATE').AsDateTime := pDtUpdate;
      ParamByName('WAY').AsString           := pWay;
      ExecSQL;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia.SetTriggerName(pWay, pTabela, pKind, pTrigger: String);
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'UPDATE TB_LISTA_SINCRONIA ',
                'SET DESC_TRIGGER = :DESC_TRIGGER ',
                'WHERE ( WAY = :WAY ) ',
                '  and ( DESC_TABELA = :DESC_TABELA ) ',
                '  and ( KIND = :KIND ) '
      ));
      ParamByName('DESC_TRIGGER').AsString := pTrigger;
      ParamByName('WAY').AsString          := pWay;
      ParamByName('DESC_TABELA').AsString  := pTabela;
      ParamByName('KIND').AsString         := pKind;
      ExecSQL;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


function TControllerListaSincronia.SincronizaTabela: Boolean;
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE ( DESC_TABELA =:DESC_TABELA ) ',
                '  and ( WAY = ''E'' ) ',
                '  and ( SET_ON = ''S'') ' //Enviar do PDV para Retaguarda
      ));
      ParamByName('DESC_TABELA').AsString := Registro.Tabela;
      Active := True;
      FetchAll;
      Result := RecordCount > 0;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia._getListaEnviar;
var
  Lc_Qry : TIBQuery;
  LITem : TListaSincronia;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE WAY = ''E'' ',
                ' and (SET_ON = ''S'') ',//Enviar do PDV para Retaguarda
                'ORDER BY seq '
      ));
      Active := True;
      FetchAll;
      First;
      ListaEnviar.Clear;
      while not eof do
      Begin
        LITem := TListaSincronia.Create;
        get(Lc_Qry,LITem);
        ListaEnviar.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia._getListaReceber;
var
  Lc_Qry : TIBQuery;
  LITem : TListaSincronia;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE WAY = ''R'' ', //Receber da Retaguarda
                ' AND SET_ON = ''S'' ',
                'ORDER BY seq '
      ));
      Active := True;
      FetchAll;
      First;
      ListaReceber.Clear;
      while not eof do
      Begin
        LITem := TListaSincronia.Create;
        get(Lc_Qry,LITem);
        ListaReceber.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
