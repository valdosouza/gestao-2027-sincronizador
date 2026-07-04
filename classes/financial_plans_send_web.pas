unit financial_plans_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerPlanoContas,
     ObjFinancialPlans;

Type
  TFinancialPlansSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPlanoContas;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFinancialPlansSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPlanoContas.Create(nil);
end;

destructor TFinancialPlansSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TFinancialPlansSendWeb.GenerateJson;
Var
  LcObj: TObjFinancialPlans;

begin
  inherited;
   FCtrl.Registro.Codigo := FCodigo;
   FCtrl.clear;
   FCtrl.getbyId;
   if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
//    FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.FillDataObjeto(FCtrl.Registro, FCtrl.Obj);
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
//
  End;
end;


end.

