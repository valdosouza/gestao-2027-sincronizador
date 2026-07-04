unit rest_menu_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerDskRestMenu,ObjRestMenu;

Type
  TRestMenuSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskRestMenu;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestMenuSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskRestMenu.Create(nil);
end;

destructor TRestMenuSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestMenuSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.Registro.Tipo := 'A'; //essa marca��o e para pegar todos menos o produto automatico que � menu da pizzaria
    FCtrl.getMenuToSincronia;
    if FCtrl.exist then
  Begin
      FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj, FInstitutionDestino);
      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
//    FStrJSon := FDataCM.SMRestMenuClient.save(FStrJSon);
//    Result := TJson.JsonToObject<TResult>(FStrJSon);
  End;
end;


end.

