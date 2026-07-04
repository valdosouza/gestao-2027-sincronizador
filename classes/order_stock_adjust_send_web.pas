unit order_stock_adjust_send_web;


interface

uses System.SysUtils,general_web,REST.Json,
     ControllerPedidoAjuste,objOrderStockAdjust;

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
    FCtrl.fillDataObjeto(FCtrl.Registro);
    FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
  End;
end;


end.

