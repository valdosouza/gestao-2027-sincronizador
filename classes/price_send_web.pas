unit price_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerPreco,tblPrice,
     System.JSON;

Type
  TPriceSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPreco;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TPriceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPreco.Create(nil);
end;

destructor TPriceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPriceSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getByCodigo;
    if FCtrl.exist then
  Begin
    // Contrato /price/sincronize: chave composta priceListId+productId — SEM
    // id próprio, SEM institution (D12). 409 PRICE_LIST_NOT_SYNCED/
    // PRODUCT_NOT_SYNCED são normais durante a carga (reenvio no próximo ciclo).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('priceListId', TJSONNumber.Create(FCtrl.Registro.CodigoTabela));
      LcJson.AddPair('productId', TJSONNumber.Create(FCtrl.Registro.CodigoProduto));
      LcJson.AddPair('priceTag', TJSONNumber.Create(FCtrl.Registro.Valor));
      LcJson.AddPair('aliqProfit', TJSONNumber.Create(FCtrl.Registro.MargemLucro));
      LcJson.AddPair('aliqKickback', TJSONNumber.Create(FCtrl.Registro.AliComissao));
      LcJson.AddPair('quantity', TJSONNumber.Create(FCtrl.Registro.QtdeMinima));
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_PRECO', 'PRC_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;

end;

end.


