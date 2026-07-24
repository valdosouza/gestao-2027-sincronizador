unit order_stock_adjust_send_web;


interface

uses System.SysUtils, System.JSON, general_web,
     ControllerPedidoAjuste, objOrderStockAdjust, un_dm;

Type
  TOrderStockAdjustSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPedidoAjuste;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TOrderStockAdjustSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPedidoAjuste.Create(nil);
end;

destructor TOrderStockAdjustSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TOrderStockAdjustSendWeb.GenerateJson;
Var
  LcJson       : TJSONObject;
  LcOrder      : TJSONObject;
  LcAdjust     : TJSONObject;
  LcItems      : TJSONArray;
  LcItem       : TJSONObject;
  LcEntityDoc  : String;
  I            : Integer;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.Registro.Tipo := 3;
  FCtrl.getSincronia;
  if FCtrl.exist  then
  Begin
    FCtrl.ClearDataObjecto;
    FCtrl.Obj.Estabelecimento := FInstitutionDestino;
    FCtrl.Obj.Terminal := FTerminal;
    FCtrl.Obj.CodigoWeb := FCtrl.Registro.CodigoWeb;
    // Efeito colateral: popula FCtrl.Itens.Lista — ver nota em order_sale_send_web.
    FCtrl.fillDataObjeto(FCtrl.Registro);

    // Achado transversal: EntityExternalCode do Obj legado carrega o
    // CODIGO INTERNO (emp_codigo), não o documento. Campo opcional no
    // contrato — omitido quando o lookup não encontra documento.
    LcEntityDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.Empresa);

    LcJson := TJSONObject.Create;
    Try
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_PEDIDO', 'PED_CODIGO', FCodigo)); // decisao 8: le o DELETED real da tabela

      LcOrder := TJSONObject.Create;
      LcOrder.AddPair('dtRecord', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.Data));
      LcOrder.AddPair('note', FCtrl.Registro.Observacao);
      LcOrder.AddPair('status', FCtrl.Registro.Faturado);
      LcOrder.AddPair('origin', 'D');
      LcJson.AddPair('order', LcOrder);

      LcAdjust := TJSONObject.Create;
      LcAdjust.AddPair('number', TJSONNumber.Create(FCtrl.Registro.Numero));
      if LcEntityDoc <> '' then
        LcAdjust.AddPair('entityDocument', LcEntityDoc);
      // TODO (achado): TPedido/TB_PEDIDO não tem um campo de sentido
      // (Entrada/Saida) para o ajuste de estoque no Firebird atual — o
      // contrato exige "direction" (E/S) mas não há fonte local confiável.
      // Omitido até decisão de DDL (ver Rodada 4 do MAPA_INDEXACAO).
      LcJson.AddPair('adjust', LcAdjust);

      LcItems := TJSONArray.Create;
      for I := 0 to FCtrl.Itens.Lista.Count - 1 do
      Begin
        LcItem := TJSONObject.Create;
        LcItem.AddPair('id', TJSONNumber.Create(FCtrl.Itens.Lista[I].Codigo));
        LcItem.AddPair('productId', TJSONNumber.Create(FCtrl.Itens.Lista[I].CodigoProduto));
        LcItem.AddPair('quantity', TJSONNumber.Create(FCtrl.Itens.Lista[I].Quantidade));
        LcItem.AddPair('unitValue', TJSONNumber.Create(FCtrl.Itens.Lista[I].ValorUnitario));
        LcItems.AddElement(LcItem);
      End;
      LcJson.AddPair('items', LcItems);

      FStrJson := LcJson.ToJSON;
    Finally
      LcJson.Free;
    End;
  End;
end;


end.
