unit brand_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerMarcaProduto,json_brand;

Type
  TBrandSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMarcaProduto;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TBrandSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMarcaProduto.Create(nil);
end;

destructor TBrandSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TBrandSendWeb.GenerateJson;
Var
  LcObj: TJsonBrand;
begin
  inherited;
      FCtrl.Registro.Codigo := FCodigo;
      FCtrl.getbyId;
      if FCtrl.exist then
  Begin
      LcObj                   := TJsonBrand.Create;
      LcObj.tb_institution_id := FInstitutionDestino;
      LcObj.id                := FCtrl.Registro.Codigo;
      LcObj.description       := FCtrl.Registro.Descricao;

      FStrJSon              := TJson.ObjectToJsonString(LcObj);

  End;
end;


end.

