unit measure_send_web;


interface

uses System.SysUtils,general_web,REST.Json, ControllerMedida,json_measure;

Type
  TMeasureSendWeb = class(TGeneralWeb)
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

constructor TMeasureSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMedida.Create(nil);
end;

destructor TMeasureSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TMeasureSendWeb.GenerateJson;
Var
  LcObj: TJsonMeasure;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    LcObj                   := TJsonMeasure.Create;
    LcObj.id                := 0;
    LcObj.description       := FCtrl.Registro.Descricao;
    LcObj.abbreviation      := FCtrl.Registro.Abreviatura;
    LcObj.escale            := FCtrl.Registro.Escala;
    LcObj.tb_institution_id := FInstitutionDestino;
    FStrJson                := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

