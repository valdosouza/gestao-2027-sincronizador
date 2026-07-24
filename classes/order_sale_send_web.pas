unit order_sale_send_web;


interface

uses System.SysUtils, System.JSON, general_web, ControllerPedidoVenda,
     ObjOrderSale, un_dm;

Type
  TOrderSaleSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPedidoVenda;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TOrderSaleSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPedidoVenda.Create(nil);
end;

destructor TOrderSaleSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TOrderSaleSendWeb.GenerateJson;
Var
  LcJson        : TJSONObject;
  LcOrder       : TJSONObject;
  LcSale        : TJSONObject;
  LcItems       : TJSONArray;
  LcItem        : TJSONObject;
  LcTotalizer   : TJSONObject;
  LcBilling     : TJSONObject;
  LcCustomerDoc : String;
  LcSalesmanDoc : String;
  LcPlots       : String;
  LcDeadline    : String;
  I             : Integer;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.Registro.Tipo := 1;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.ClearDataObjecto;
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
      FCtrl.Obj.CodigoWeb := FCtrl.Registro.CodigoWeb;
      // Efeito colateral: popula FCtrl.Itens.Lista (itens do pedido) e
      // FCtrl.FormaPagto.Registro (descricao da forma de pagamento) —
      // reaproveitamos essas listas/lookups já existentes, mas montamos
      // o JSON manualmente no formato do contrato novo (achado transversal:
      // CustomerExternalCode/SalesmanExternalCode do Obj legado carregam o
      // CODIGO INTERNO (emp_codigo/vdo_codigo), não o documento).
      FCtrl.fillDataObjeto(FCtrl.Registro);

      LcCustomerDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.Empresa);
      LcSalesmanDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.Vendedor);

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

        LcSale := TJSONObject.Create;
        LcSale.AddPair('number', TJSONNumber.Create(FCtrl.Registro.Numero));
        if LcCustomerDoc <> '' then
          LcSale.AddPair('customerDocument', LcCustomerDoc);
        if LcSalesmanDoc <> '' then
          LcSale.AddPair('salesmanDocument', LcSalesmanDoc);
        LcJson.AddPair('sale', LcSale);

        LcItems := TJSONArray.Create;
        for I := 0 to FCtrl.Itens.Lista.Count - 1 do
        Begin
          LcItem := TJSONObject.Create;
          LcItem.AddPair('id', TJSONNumber.Create(FCtrl.Itens.Lista[I].Codigo));
          LcItem.AddPair('productId', TJSONNumber.Create(FCtrl.Itens.Lista[I].CodigoProduto));
          LcItem.AddPair('quantity', TJSONNumber.Create(FCtrl.Itens.Lista[I].Quantidade));
          LcItem.AddPair('unitValue', TJSONNumber.Create(FCtrl.Itens.Lista[I].ValorUnitario));
          LcItem.AddPair('discountAliquot', TJSONNumber.Create(FCtrl.Itens.Lista[I].AliqDesconto));
          LcItem.AddPair('discountValue', TJSONNumber.Create(FCtrl.Itens.Lista[I].ValorDesconto));
          LcItem.AddPair('stockListId', TJSONNumber.Create(FCtrl.Itens.Lista[I].CodigoEstoque));
          LcItem.AddPair('priceListId', TJSONNumber.Create(FCtrl.Itens.Lista[I].CodigoTabela));
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

        LcBilling := TJSONObject.Create;
        LcBilling.AddPair('paymentTypeDescription', FCtrl.FormaPagto.Registro.Descricao);
        LcPlots    := Copy(FCtrl.Registro.Prazo, 1, 3);
        LcDeadline := Copy(FCtrl.Registro.Prazo, 7, Length(FCtrl.Registro.Prazo) - 6);
        LcBilling.AddPair('plots', LcPlots);
        LcBilling.AddPair('deadline', LcDeadline);
        LcJson.AddPair('billing', LcBilling);

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;


end.
