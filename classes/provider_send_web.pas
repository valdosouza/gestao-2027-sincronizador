unit provider_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerFornecedor;


Type
  TProviderSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFornecedor;
      function ValidaDocFiscal: Boolean;
    protected
      procedure GenerateJson;Override;
    public
      constructor Create;override;
      destructor Destroy;override;


  end;

implementation

uses

  unFunctions,ObjProvider;


{ TGeneralWeb }

constructor TProviderSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFornecedor.Create(nil);
end;


destructor TProviderSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;


procedure TProviderSendWeb.GenerateJson;
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
      FCtrl.Obj.Fiscal.Entidade.Terminal := FTerminal;
      FCtrl.FillDataObjeto(FCtrl.Registro,FCtrl.Obj);

      FStrJson := TJson.ObjectToJsonString(FCtrl.Obj);
    End
  End;
end;

function TProviderSendWeb.ValidaDocFiscal: Boolean;
begin
  {Retirada a valida��o pois estamos tratando documentos com numero invalidos
  if (Length(FCtrl.Empresa.Registro.CpfCNPJ) = 11) then
    Result := calculoCpf(FCtrl.Empresa.Registro.CpfCNPJ)
  else
    Result := calculoCnpj(FCtrl.Empresa.Registro.CpfCNPJ)}
  Result := true;
end;

end.

