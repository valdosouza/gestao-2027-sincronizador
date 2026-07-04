unit rest_subgroup_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerSubGrupos,tblRestSubGroup;

Type
  TRestSubGroupSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerSubGrupos;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestSubGroupSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerSubGrupos.Create(nil);
end;

destructor TRestSubGroupSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestSubGroupSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.Registro.Abas := 'S'; //essa marca��o e para pegar O grupo que serve o restaurante
    FCtrl.getbyId;
    if FCtrl.exist then
  Begin
    FCtrl.FillDataRestSubGroup(FCtrl.Registro, FCtrl.ObjRestSubGroup, FInstitutionDestino);
    // Envia para o servidor e pega o retorno
    FStrJSon := TJson.ObjectToJsonString(FCtrl.ObjRestSubGroup);
//  FStrJSon := FDataCM.SMRestSubgroupClient.save(FStrJSon);
//  Result := TJson.JsonToObject<TResult>(FStrJSon);
End;

end;


end.

