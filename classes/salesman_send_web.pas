unit salesman_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerColaborador;

Type
  TSalesManSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerColaborador;
      function ValidaSendSalesman(): Boolean;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

uses UnFunctions;

constructor TSalesManSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerColaborador.Create(nil);
end;

destructor TSalesManSendWeb.Destroy;
begin
  FCtrl.DisposeOf;
  inherited;
end;

procedure TSalesManSendWeb.GenerateJson;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    if ValidaSendSalesman then
    Begin
      FCtrl.obj.clear;
      FCtrl.obj.objColaborador.Fiscal.Entidade.Estabelecimento := FInstitutionDestino;
      FCtrl.fillDataObjeto;

      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
    End;
  End;
 end;

function TSalesManSendWeb.ValidaSendSalesman: Boolean;
begin
  Result := True;
  if (Length(FCtrl.Registro.email) = 0) then
    Result := False;
  {Retirada a valida��o pois estamos tratando documentos com numero invalidos
  if (Length(FCtrl.Registro.CpfCNPJ) = 11) then
    Result := calculoCpf(FCtrl.Registro.CpfCNPJ)
  else
    Result := calculoCnpj(FCtrl.Registro.CpfCNPJ);}

end;

end.



