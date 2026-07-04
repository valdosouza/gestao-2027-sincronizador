unit rest_menu_has_ingrediente_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerCrpItens,ObjRestMenuHasIngredient;

Type
  TRestMenuHasIngredienteSendWeb = class(TGeneralWeb)
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

constructor TRestMenuHasIngredienteSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCrpItens.Create(nil);
end;

destructor TRestMenuHasIngredienteSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TRestMenuHasIngredienteSendWeb.GenerateJson;
begin
  inherited;
     FCtrl.Registro.Codigo := FCodigo;
     FCtrl.Registro.Tipo := 'A'; //essa marca��o e para pegar todos menos o produto automatico que � menu da pizzaria
     FCtrl.getbyId;
     if FCtrl.exist then
  Begin
      FCtrl.FillDataRestIngredientes(FCtrl.Registro, FCtrl.ObjIngredientes, FInstitutionDestino);
      // Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.ObjIngredientes);
//    FStrJSon := FDataCM.SMRestMenuHasIngredientClient.save(FStrJSon);
//    Result := TJson.JsonToObject<TResult>(FStrJSon);
  End;
end;


end.

