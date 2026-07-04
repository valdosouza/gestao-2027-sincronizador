unit rest_group_has_attribute_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerDskRestGroupHasAttribute,ObjRestMenu;

Type
  TRestGroupHasAttributeSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskRestGroupHasAttribute;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestGroupHasAttributeSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskRestGroupHasAttribute.Create(nil);
end;

destructor TRestGroupHasAttributeSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestGroupHasAttributeSendWeb.GenerateJson;
begin
  inherited;
      FCtrl.Registro.Codigo := FCodigo;
      FCtrl.Registro.Tipo := 'A'; //essa marca��o e para pegar todos menos o produto automatico � Pizzque � menu da pizzaria
      FCtrl.getMenuToSincronia;
      if FCtrl.exist then
  Begin
      FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj, FInstitutionDestino);
      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
 
  End;
end;


end.

