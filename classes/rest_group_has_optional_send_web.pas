unit rest_group_has_optional_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerCrpItens,ObjRestGroupHasOptional;

Type
  TRestGroupHasOptionalSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCrpItens;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TRestGroupHasOptionalSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCrpItens.Create(nil);
end;

destructor TRestGroupHasOptionalSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestGroupHasOptionalSendWeb.GenerateJson;
begin
  inherited;
     FCtrl.Registro.Codigo := FCodigo;
     FCtrl.Registro.Tipo := 'O'; //essa marca��o e para pegar todos menos o produto automatico que � menu da pizzaria
     FCtrl.getbyId;
     if FCtrl.exist then
    Begin
     FCtrl.FillDataRestIngredientes(FCtrl.Registro, FCtrl.ObjIngredientes, FInstitutionDestino);
     // Envia para o servidor e pega o retorno
     FStrJSon := TJson.ObjectToJsonString(FCtrl.ObjIngredientes);

    End;

    end;
    end.

