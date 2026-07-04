unit payment_type_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerFormaPagamento, json_payment_types;

Type
  TPaymentTypeSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFormaPagamento;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;


  end;

implementation


{ TGeneralWeb }

constructor TPaymentTypeSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFormaPagamento.Create(nil);
end;



destructor TPaymentTypeSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;


procedure TPaymentTypeSendWeb.GenerateJson;
Var
  LcObj: TJsonPaymentTypes;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    LcObj := TJsonPaymentTypes.Create;
    LcObj.tb_institution_id := FInstitutionDestino;
    LcObj.id := 0;
    LcObj.description := FCtrl.Registro.Descricao;
    LcObj.active := FCtrl.Registro.Ativo;


    FStrJson := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

