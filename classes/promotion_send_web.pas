unit promotion_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerDskPromotion,
     ObjPromotion;

Type
  TPromotionSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskPromotion;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TPromotionSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskPromotion.Create(nil);
end;

destructor TPromotionSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPromotionSendWeb.GenerateJson;
Var
  LcObj: TObjPromotion;
begin
  inherited;

  FCtrl.Registro.Codigo          := FCodigo;
  FCtrl.Registro.Estabelecimento := FInstitutionOrigem;
  FCtrl.getbyId;
  if FCtrl.exist then

    Begin

    FCtrl.Obj.Estabelecimento := FInstitutionDestino;
    FCtrl.Obj.Terminal:= FTerminal;
//  Promocao.Obj.Descricao := FDESCRICAO;
    FCtrl.FillDataObjeto(FCtrl.Registro, FCtrl.Obj);
    FStrJSon:= TJson.ObjectToJsonString(FCtrl.Obj);
//  LcStrJSon:= FDataCM.SMPromotionClient.save(LcStrJSon);
//  Result:= TJson.JsonToObject<TResult>(LcStrJSon);

  End;
end;


end.

