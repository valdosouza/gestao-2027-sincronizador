unit order_sale_receive_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerContaBancaria,ObjBankAccount;

Type
  TOrderSakeReceiveWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerContaBancaria;
    protected
      procedure GenerateJson;Override;
    public
    procedure receive;Override;
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TOrderSakeReceiveWeb.Create;
begin
  inherited;
  FCtrl := TControllerContaBancaria.Create(nil);
end;

destructor TOrderSakeReceiveWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TOrderSakeReceiveWeb.GenerateJson;
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

procedure TOrderSakeReceiveWeb.receive;
begin
  inherited;

end;

end.
