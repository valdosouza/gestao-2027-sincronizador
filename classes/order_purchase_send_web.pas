unit order_purchase_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerPedidoCompra,ObjOrderPurchase;

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
  LcObj: TObjOrderPurchase;

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
      FCtrl.fillDataObjeto(FCtrl.Registro);

      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);

  End;
end;

end.

