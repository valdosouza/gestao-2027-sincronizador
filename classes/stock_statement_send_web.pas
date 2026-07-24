unit stock_statement_send_web;


interface

uses System.SysUtils, System.JSON, general_web,
     ControllerCtrlEstoque, un_dm;

Type
   TStockStatementSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCtrlEstoque;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TStockStatementSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCtrlEstoque.Create(nil);
end;

destructor TStockStatementSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TStockStatementSendWeb.GenerateJson;
Var
  LcJson  : TJSONObject;
  LcLocal : String;
  LcOperation : String;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getbyId;
    if FCtrl.exist then
    Begin
      // D9/achado: bloco reativado — 'SERVER' quando é o terminal 0 (a
      // maquina servidora), senão identifica o terminal de origem.
      if FTerminal = 0 then
        LcLocal := 'SERVER'
      else
        LcLocal := concat('Terminal ', IntToStr(FTerminal));

      // TODO (achado): CET_TIPO hoje só guarda a categoria curta
      // (VENDA/COMPRA/AJUSTE) — mapeada para "kind". Não existe no
      // Firebird um campo equivalente à descrição livre de "operation"
      // do contrato novo (ex.: "SAIDA POR VENDA"); construído por
      // heurística a partir de direção + tipo até decisão de DDL.
      if FCtrl.Registro.operacao = 'S' then
        LcOperation := concat('SAIDA POR ', FCtrl.Registro.Tipo)
      else
        LcOperation := concat('ENTRADA POR ', FCtrl.Registro.Tipo);

      LcJson := TJSONObject.Create;
      Try
        LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
        LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
        LcJson.AddPair('orderId', TJSONNumber.Create(FCtrl.Registro.Ordem));
        LcJson.AddPair('orderItemId', TJSONNumber.Create(FCtrl.Registro.Item));
        LcJson.AddPair('stockListId', TJSONNumber.Create(FCtrl.Registro.Estoque));
        LcJson.AddPair('merchandiseId', TJSONNumber.Create(FCtrl.Registro.Produto));
        LcJson.AddPair('local', LcLocal);
        LcJson.AddPair('kind', FCtrl.Registro.Tipo);
        LcJson.AddPair('dtRecord', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.Data));
        LcJson.AddPair('direction', FCtrl.Registro.operacao);
        LcJson.AddPair('quantity', TJSONNumber.Create(FCtrl.Registro.Quantidade));
        LcJson.AddPair('operation', LcOperation);
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_CTRL_ESTOQUE', 'CET_CODIGO', FCodigo)); // decisao 8: le o DELETED real da tabela

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;


end.
