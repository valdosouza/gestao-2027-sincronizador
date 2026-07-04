unit stock_balance_send_web;


interface

uses System.SysUtils,general_web,REST.Json, ControllerEstoque,tblStockBalance;

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
  LcObj: TStockBalance;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getByCodigo;
    if FCtrl.exist then
  Begin
    LcObj                  := TStockBalance.Create;
    LcObj.Estabelecimento  := FInstitutionDestino;
    LcObj.Tabela           := FCtrl.Registro.CodigoEstoque;
    LcObj.Mercadoria       := FCtrl.Registro.CodigoProduto;
    LcObj.Quantidade       := FCtrl.Registro.QtdeDisp;
    LcObj.Minimo           := FCtrl.Registro.QtdeMinima;
  //  FCtrl.fillDataObjeto(FCtrl.Registro);
    FStrJSon               := TJson.ObjectToJsonString(LcObj);

  End;
end;


end.

