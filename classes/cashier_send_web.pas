unit cashier_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerDskCashier,ObjCashier;

Type
  TCashierSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskCashier;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TCashierSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskCashier.Create(nil);
end;

destructor TCashierSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TCashierSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal  := FTerminal;
      FCtrl.fillDataObjeto(FCtrl.Registro);
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
  End;
end;


end.
