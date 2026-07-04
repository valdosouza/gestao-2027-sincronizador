unit order_sale_send_web;


interface

uses System.SysUtils,general_web,REST.Json, ControllerPedidoVenda,
     ObjOrderSale;

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
  LcObj: TObjOrderSale;
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
      FCtrl.fillDataObjeto(FCtrl.Registro);

      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
  End;
end;


end.

