unit stock_balance_send_web;


interface

uses System.SysUtils,general_web,REST.Json, ControllerEstoque,tblStockBalance,
     System.JSON;

Type
  TStockBalanceSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerEstoque;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TStockBalanceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerEstoque.Create(nil);
end;

destructor TStockBalanceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TStockBalanceSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getByCodigo;
    if FCtrl.exist then
  Begin
    // Contrato /stock-balance/sincronize: SEM id (tb_stock_balance própria,
    // chave stockListId+merchandiseId); Estabelecimento NÃO viaja (D12).
    // 409 STOCK_LIST_NOT_SYNCED/MERCHANDISE_NOT_SYNCED são normais na carga.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('stockListId', TJSONNumber.Create(FCtrl.Registro.CodigoEstoque));
      LcJson.AddPair('merchandiseId', TJSONNumber.Create(FCtrl.Registro.CodigoProduto));
      LcJson.AddPair('quantity', TJSONNumber.Create(FCtrl.Registro.QtdeDisp));
      LcJson.AddPair('minimum', TJSONNumber.Create(FCtrl.Registro.QtdeMinima));
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_ESTOQUE', 'EST_CODIGO', FCodigo));
      FStrJSon := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

