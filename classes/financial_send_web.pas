unit financial_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerFinanceiro,objFinancial;

Type
  TFinancialSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFinanceiro;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFinancialSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFinanceiro.Create(nil);
end;

destructor TFinancialSendWeb.Destroy;
begin
  FCtrl.DisposeOf;
  inherited;
end;

procedure TFinancialSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getById;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
//    FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.fillDataObjeto(FCtrl.Registro);
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
//
  End;
end;


end.

