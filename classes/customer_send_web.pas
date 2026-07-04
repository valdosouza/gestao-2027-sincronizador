unit customer_send_web;

interface

uses System.SysUtils,general_web,ControllerCliente, REST.Json;

Type
  TCustomerSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCliente;
      function ValidaDocFiscal: Boolean;
    protected
      procedure GenerateJson;Override;
    public
      constructor Create;override;
      destructor Destroy;override;


  end;

implementation

uses
  objCustomer,UnFunctions;


{ TGeneralWeb }

constructor TCustomerSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCliente.Create(nil);
end;


destructor TCustomerSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;


procedure TCustomerSendWeb.GenerateJson;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    FCtrl.Empresa.Registro.Codigo := FCodigo;
    FCtrl.Empresa.getById;
    if ValidaDocFiscal then
    Begin
      FCtrl.Obj.Fiscal.Entidade.Estabelecimento := FInstitutionDestino;

      FCtrl.fillDataObjeto;

      FStrJson := TJson.ObjectToJsonString(FCtrl.Obj);
    End
  End;
end;

function TCustomerSendWeb.ValidaDocFiscal: Boolean;
begin
  {Retirada a valida��o pois estamos tratando documentos com numero invalidos
  if (Length(FCtrl.Empresa.Registro.CpfCNPJ) = 11) then
    Result := calculoCpf(FCtrl.Empresa.Registro.CpfCNPJ)
  else
    Result := calculoCnpj(FCtrl.Empresa.Registro.CpfCNPJ)}
  Result := true;
end;

end.

