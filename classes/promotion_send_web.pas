unit promotion_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerDskPromotion,
     ObjPromotion, System.JSON;

Type
  TPromotionSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskPromotion;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TPromotionSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskPromotion.Create(nil);
end;

destructor TPromotionSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPromotionSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
  LcItems: TJSONArray;
  LcItem: TJSONObject;
  I: Integer;
  LcDeleted: String;
begin
  inherited;

  FCtrl.Registro.Codigo          := FCodigo;
  FCtrl.Registro.Estabelecimento := FInstitutionOrigem;
  FCtrl.getbyId;
  if FCtrl.exist then

    Begin

    FCtrl.Obj.Estabelecimento := FInstitutionDestino;
    FCtrl.Obj.Terminal:= FTerminal;
    // Mantida a técnica de resolução via FillDataObjeto (monta FCtrl.Obj.Promocao
    // + FCtrl.Obj.Items) — só os NOMES das chaves do JSON mudam para o contrato
    // novo, que é FLAT (sem aninhar em "Promocao") e usa camelCase.
    FCtrl.FillDataObjeto(FCtrl.Registro, FCtrl.Obj);

    LcJson := TJSONObject.Create;
    try
      // Contrato /promotion/sincronize: id = registro local ✅; Estabelecimento
      // NÃO viaja (D12). items = SNAPSHOT (itens fora da lista viram deleted='S'
      // no servidor); 409 PRODUCT_NOT_SYNCED é normal durante a carga.
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Obj.Promocao.Codigo));
      LcJson.AddPair('description', FCtrl.Obj.Promocao.Descricao);
      LcJson.AddPair('priceTag', TJSONNumber.Create(FCtrl.Obj.Promocao.Preco));
      LcJson.AddPair('quantity', TJSONNumber.Create(FCtrl.Obj.Promocao.Quantidade));
      LcJson.AddPair('active', FCtrl.Obj.Promocao.Ativo);
      // TODO: Firebird (TB_PROMOTION) não tem campo equivalente a "oper" — null.
      LcJson.AddPair('oper', TJSONNull.Create);
      // decisao 8: le o DELETED real da tabela
      LcDeleted := DM.GetDeletedFlag('TB_PROMOTION', 'ID', FCodigo);
      LcJson.AddPair('deleted', LcDeleted);

      LcItems := TJSONArray.Create;
      for I := 0 to FCtrl.Obj.Items.Count - 1 do
      Begin
        LcItem := TJSONObject.Create;
        LcItem.AddPair('productId', TJSONNumber.Create(FCtrl.Obj.Items[I].Produto));
        // TODO: TPromotionItems/tb_promotion_items não tem campo "oper" — null.
        LcItem.AddPair('oper', TJSONNull.Create);
        // decisao 8: item herda o DELETED do registro pai
        LcItem.AddPair('deleted', LcDeleted);
        LcItems.Add(LcItem);
      End;
      LcJson.AddPair('items', LcItems);

      FStrJSon := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;

  End;
end;


end.

