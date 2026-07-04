unit financial_statement_send_web;


interface

uses System.SysUtils,general_web,REST.Json,
     ControllerMovimentoFinanceiro,objFinancialStatement;

Type
  TFinancialStatementSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMovimentoFinanceiro;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFinancialStatementSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMovimentoFinanceiro.Create(nil);
end;

destructor TFinancialStatementSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TFinancialStatementSendWeb.GenerateJson;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    FCtrl.ClearDataObjecto;
    FCtrl.Obj.Estabelecimento := FInstitutionDestino;
    FCtrl.Obj.Terminal := FTerminal;
    FCtrl.fillDataObjeto(FCtrl.Registro);
    FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
  end;

end;

end.
