unit order_purchase_send_web;

interface

uses System.SysUtils, System.JSON, general_web, ControllerPedidoCompra,
     ObjOrderPurchase, un_dm;

Type
  TOrderPurchaseSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPedidoCompra;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TOrderPurchaseSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPedidoCompra.Create(nil);
end;

destructor TOrderPurchaseSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TOrderPurchaseSendWeb.GenerateJson;
Var
  LcJson        : TJSONObject;
  LcOrder       : TJSONObject;
  LcPurchase    : TJSONObject;
  LcItems       : TJSONArray;
  LcItem        : TJSONObject;
  LcTotalizer   : TJSONObject;
  LcProviderDoc : String;
  I             : Integer;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.Registro.Tipo := 2;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
      FCtrl.ClearDataObjecto;
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal        := FTerminal;
      FCtrl.Obj.CodigoWeb       := FCtrl.Registro.CodigoWeb;
      // Efeito colateral: popula FCtrl.Itens.Lista — ver nota em order_sale_send_web.
      FCtrl.fillDataObjeto(FCtrl.Registro);

      // Achado transversal: ProviderExternalCode do Obj legado carrega o
      // CODIGO INTERNO do fornecedor (emp_codigo), não o documento.
      LcProviderDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.Empresa);

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

        LcPurchase := TJSONObject.Create;
        LcPurchase.AddPair('number', TJSONNumber.Create(FCtrl.Registro.Numero));
        if LcProviderDoc <> '' then
          LcPurchase.AddPair('providerDocument', LcProviderDoc);
        LcPurchase.AddPair('approved', FCtrl.Registro.Aprovado);
        LcJson.AddPair('purchase', LcPurchase);

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

        LcTotalizer := TJSONObject.Create;
        LcTotalizer.AddPair('itemsQtde', TJSONNumber.Create(FCtrl.Itens.Lista.Count));
        LcTotalizer.AddPair('productQtde', TJSONNumber.Create(FCtrl.Registro.QtdeProdutos));
        LcTotalizer.AddPair('productValue', TJSONNumber.Create(FCtrl.Registro.ValorProdutos));
        LcTotalizer.AddPair('ipiValue', TJSONNumber.Create(FCtrl.Registro.ValorIPI));
        LcTotalizer.AddPair('discountAliquot', TJSONNumber.Create(FCtrl.Registro.AliqDesconto));
        LcTotalizer.AddPair('discountValue', TJSONNumber.Create(FCtrl.Registro.ValorDesconto));
        LcTotalizer.AddPair('expensesValue', TJSONNumber.Create(FCtrl.Registro.ValorOutrasDEspesas));
        LcTotalizer.AddPair('totalValue', TJSONNumber.Create(FCtrl.Registro.ValorPedido));
        LcJson.AddPair('totalizer', LcTotalizer);

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;

end.
