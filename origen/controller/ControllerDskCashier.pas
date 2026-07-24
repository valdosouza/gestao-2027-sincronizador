unit ControllerDskCashier;

interface

uses IBX.IBDatabase,Classes, IBQuery,Vcl.Grids ,SysUtils,ControllerBase,objCashier,
      Un_sistema,Un_funcoes,Un_Regra_Negocio,  tblDskCashier, tblDskCashierItems ,
      Un_MSg, Generics.Collections, ControllerDskCashierItems, tblCashierItems,
      ControllerFormaPagamento;

Type
  TListaDskCashier = TObjectList<TDskCashier>;

  TControllerDskCashier = Class(TControllerBase)
  private

  public
    Registro : TDskCashier;
    Items : TControllerDskCashierItems;
    Lista : TListaDskCashier;
    Obj: TObjCashier;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    procedure getbyId;
    procedure getSincronia;
    procedure getList;
    procedure update;
    function atualiza:Boolean;
    function VerificaCaixaAberto:Boolean;Overload;
    function VerificaCaixaFechadoAtual(Data:TDate): Boolean;
    function AbrirCaixa:Boolean;
    function FecharCaixa(ListaValores:TStringGrid):Boolean;
    procedure FillDataObjeto(PcRegistro:TDskCashier);
  published

  End;

implementation

{ TControllerDskCashier }

uses UnFunctions;

function TControllerDskCashier.atualiza: Boolean;
begin
  Try
    updateObj(Registro);
    Result := True;
  Except
    Result := FAlse;
  End;
end;

procedure TControllerDskCashier.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerDskCashier.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TDskCashier.Create;
  Obj := TObjCashier.create;
  Lista := TListaDskCashier.Create;
  Items := TControllerDskCashierItems.Create(self);
end;

destructor TControllerDskCashier.Destroy;
begin
  Lista.DisposeOf;
  Obj.Destroy;
  Registro.DisposeOf;
  Items.DisposeOf;
  inherited;
end;


function TControllerDskCashier.AbrirCaixa:boolean;
begin
  Result := True;
  Registro.Codigo := Fc_Generator('GN_CASHIER','TB_CASHIER','ID');
  Registro.Data := Date;
  Registro.Usuario := Registro.Usuario;
  Registro.Abertura := Now;
  insertObj(Registro);
end;

function TControllerDskCashier.VerificaCaixaAberto: Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add('select id,dt_record  from tb_cashier '+
              'where ( tb_user_id=:tb_user_id ) and '+
              ' ( HR_END is null) ');
      ParamByName('tb_user_id').AsInteger := Registro.Usuario;
      Active := True;
      FetchAll;
      if (recordCount > 0) then
      Begin
        Registro.Codigo := FieldByName('id').AsInteger;
        Registro.Data := FieldByName('dt_record').AsDateTime;
        Result := True;
      End
      else
      Begin
        Result := False;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


function TControllerDskCashier.VerificaCaixaFechadoAtual(Data:TDate): Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.Add('select id,dt_record,HR_END  from tb_cashier '+
              'where ( tb_user_id=:tb_user_id ) '+
              ' and ( dt_record =:dt_record ) '+
              ' and ( HR_END is not null) ' );
      ParamByName('tb_user_id').AsInteger := Registro.Usuario;
      ParamByName('dt_record').AsDate := Data;
      Active := True;
      FetchAll;
      if (recordCount > 0) then
      Begin
        Registro.Codigo     := FieldByName('id').AsInteger;
        Registro.Data       := FieldByName('dt_record').AsDateTime;
        Registro.Fechamento := FieldByName('HR_END').AsDateTime;
        Result := True;
      End
      else
      Begin
        Result := False;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerDskCashier.FecharCaixa(ListaValores:TStringGrid):Boolean;
Var
  lc_cashierItems : TDskCashierItems;
  I : Integer;
begin
  //Informa os valores que estavam no caixa no fechamento
  lc_cashierItems := TDskCashierItems.Create;
  try
    Try
      Result := True;
      lc_cashierItems.CodigoCaixa   := Registro.Codigo;
      lc_cashierItems.CodigoUsuario := Registro.Usuario;
      //Faz o loop na grade de valores informados
      with ListaValores do
      Begin
        for I := 1 to ( RowCount - 1 ) do
        Begin
          lc_cashierItems.TipoFormaPagamento := StrToIntDef( Cells[1,I],1);
          lc_cashierItems.Valor := StrToFloatDef( RemoveCaracterInformado( Cells[4,I],['.']) ,0);
          lc_cashierItems.Tipo  := 'C';
          SaveObj(lc_cashierItems);
        End;
      end;

      //Encerra Caixa
      getbyId;
      with Registro do
      Begin
        Fechamento := Now;
      End;
      SaveObj(Registro);
    Except
      Result := False;
    End;
  finally
    lc_cashierItems.DisposeOf;
  end;
end;
procedure TControllerDskCashier.FillDataObjeto(PcRegistro: TDskCashier);
Var
  Lc_item: TCashierItems;
  I : Integer;
  Lc_forma_pagamento : TControllerFormaPagamento;
begin
  with Obj do
  Begin
    Codigo          := PcRegistro.Codigo;
    Estabelecimento := Obj.Estabelecimento;
    Terminal        := Obj.Terminal;
    Data            := PcRegistro.Data;
    Usuario         := PcRegistro.Usuario;
    Abertura        := PcRegistro.Abertura;
    Fechamento      := PcRegistro.Fechamento;

    //items
    Items.Registro.CodigoCaixa := PcRegistro.Codigo;
    Items.getList;

    if Items.Lista.Count > 0 then
    Begin
      Lc_forma_pagamento := TControllerFormaPagamento.Create(self);
      try
        Obj.setArrayItems(Items.Lista.Count);
        for I := 0 to Items.Lista.Count-1 do
        Begin
          Lc_item := TCashierItems.Create;
          Lc_item.Codigo          := Items.Lista[I].CodigoCaixa;
          Lc_item.Estabelecimento := obj.Estabelecimento;
          Lc_item.Terminal        := obj.Terminal;
          Lc_item.Caixa           := Items.Lista[I].CodigoCaixa;
          Lc_item.Tipo            := Items.Lista[I].Tipo;
          Lc_item.TipoPagamento   := Items.Lista[I].TipoFormaPagamento;

          // name_payment removido: TCashierItems (destiny/model) não tem essa
          // propriedade (era só descrição de exibição, não coluna real).
          // Também irrelevante agora: o contrato /cashier/sincronize REMOVEU
          // o bloco "items" por completo (cashier_send_web.pas não chama mais
          // este FillDataObjeto — método sem uso no fluxo de envio atual).
          Lc_forma_pagamento.Registro.Codigo := Items.Lista[I].TipoFormaPagamento;
          Lc_forma_pagamento.getById;
          Lc_item.Valor           := Items.Lista[I].Valor;
          Obj.ListaItems[I]       := Lc_item;
        End;
      finally
        Lc_forma_pagamento.DisposeOf;
      end;

    End;
  End;

end;

procedure TControllerDskCashier.getbyId;
Begin
  _getByKey(Registro);
End;


procedure TControllerDskCashier.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TDskCashier;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_CASHIER ',
                      'WHERE ID IS NOT NULL '
                    ));
      if FPeriodo then
        sql.add(' AND ( DT_RECORD BETWEEN :DATAINI AND :DATAFIM ) ');

      if FPeriodo then
      Begin
        ParamByName('DATAINI').AsDateTime := FDataInicial;
        ParamByName('DATAFIM').AsDateTime := FDataFinal;
      End;

      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TDskCashier.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;

    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;


end;

procedure TControllerDskCashier.getSincronia;
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_CASHIER ',
                      'WHERE ID=:ID '
                    ));
      ParamByName('ID').AsInteger := Registro.Codigo;
      Active := True;
      FetchAll;
      First;
      exist := (RecordCount > 0);
      if exist then
        get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerDskCashier.update;
begin
  updateObj(Registro)
end;

end.
