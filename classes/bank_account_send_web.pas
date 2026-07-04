unit bank_account_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerContaBancaria,ObjBankAccount;

Type
  TBankAccountSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerContaBancaria;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TBankAccountSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerContaBancaria.Create(nil);
end;

destructor TBankAccountSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TBankAccountSendWeb.GenerateJson;
Var
  LcObj: TObjBankAccount;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getbyId;
    if FCtrl.exist then
  Begin
    LcObj := TObjBankAccount.Create;
    LcObj.Estabelecimento := FInstitutionDestino;
    LcObj.Terminal := FTerminal;

    FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj);

    FStrJSon := TJson.ObjectToJsonString(LcObj);
  End;

end;


end.
