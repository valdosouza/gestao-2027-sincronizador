unit package_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerEmbalagem,json_package;

Type
  TPackageSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerEmbalagem;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TPackageSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerEmbalagem.Create(nil);
end;

destructor TPackageSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPackageSendWeb.GenerateJson;
Var
  LcObj: TJsonPackage;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    LcObj := TJsonPackage.Create;
    LcObj.id                := 0;
    LcObj.description       := FCtrl.Registro.Descricao;
    LcObj.abbreviation      := FCtrl.Registro.Abreviatura;
    LcObj.tb_institution_id := FInstitutionDestino;
    LcObj.active            := 'S';
    FStrJson := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

