unit rest_group_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerGrupos,tblRestGroup;

Type
  TRestGroupSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerGrupos;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestGroupSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerGrupos.Create(nil);
end;

destructor TRestGroupSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestGroupSendWeb.GenerateJson;
begin
  inherited;
      FCtrl.Registro.Codigo := FCodigo;
      FCtrl.Registro.Composicao := 'S'; //essa marca��o e para pegar O grupo que serve o restaurante
      FCtrl.getbyId;
      if FCtrl.exist then
  Begin
      FCtrl.FillDataRestGroup(FCtrl.Registro, FCtrl.Obj, FInstitutionDestino);
      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
//    FStrJSon := FDataCM.SMRestGroupClient.save(FStrJSon);
//    Result := TJson.JsonToObject<TResult>(FStrJSon);
  end;

end;

end.

