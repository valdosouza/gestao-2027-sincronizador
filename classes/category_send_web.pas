unit category_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerDskCategory,
    json_category;

Type
  TCategorySendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskCategory;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TCategorySendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskCategory.Create(nil);
end;

destructor TCategorySendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TCategorySendWeb.GenerateJson;
Var
  LcObj: TJsonCategory;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getByKey;
  if FCtrl.exist then
  Begin
    LcObj                   := TJsonCategory.Create;
    LcObj.id                := FCtrl.Registro.Codigo;
    LcObj.tb_institution_id := FInstitutionDestino;
    LcObj.description       := FCtrl.Registro.Descricao;
    LcObj.posit_level       := FCtrl.Registro.NivelPosicao;
    LcObj.kind              := FCtrl.Registro.Tipo;
    LcObj.active            := FCtrl.Registro.Ativo;
    FStrJson                := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

