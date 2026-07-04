unit merchandise_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerProduto,ObjMerchandise;

Type
  TMerchandiseSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerProduto;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TMerchandiseSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerProduto.Create(nil);
end;

destructor TMerchandiseSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TMerchandiseSendWeb.GenerateJson;
Var
  LcObj: TObjMerchandise;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    LcObj := TObjMerchandise.Create;
    FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj, FInstitutionDestino);
    FStrJson := TJson.ObjectToJsonString(FCtrl.Obj);

  End;
end;


end.


