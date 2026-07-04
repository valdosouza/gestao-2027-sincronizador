unit rest_group_has_measure_send_web;

interface
uses System.SysUtils,general_web,REST.Json,ControllerMedida,ObjRestGroupHasMeasure;

Type
  TRestGroupHasMeasureSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMedida;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestGroupHasMeasureSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMedida.Create(nil);
end;

destructor TRestGroupHasMeasureSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestGroupHasMeasureSendWeb.GenerateJson;
begin
  inherited;
     FCtrl.Registro.Codigo := FCodigo;
     FCtrl.getbyId;
     if FCtrl.exist then
  Begin
     FCtrl.FillDataRestGroupMeasure(FCtrl.Registro,FCtrl.ObjRest,FInstitutionDestino);
     // Envia para o servidor e pega o retorno
     FStrJSon := TJson.ObjectToJsonString( FCtrl.ObjRest );
//   FStrJSon := FDataCM.SMRestGroupHasMeasureClient.save(FStrJSon);
//   Result := TJson.JsonToObject<TResult>(FStrJSon);;
  End;

end;

end.

