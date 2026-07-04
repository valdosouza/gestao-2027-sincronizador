unit file_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerArquivo,objFile;

Type
  TFileSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerArquivo;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFileSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerArquivo.Create(nil);
end;

destructor TFileSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TFileSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
      //FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.fillDataObjeto(FCtrl.Registro);
      FStrJson := TJson.ObjectToJsonString(FCtrl.Obj);
      // Envia para o servidor e pega o retorno
      //FStrJSon := EncodeBase64( TJson.ObjectToJsonString(FCtrl.Obj) );
      //FStrJSon := FDataCM.SMServicesClient.setXMLFile(FStrJSon);
      //Result := TJson.JsonToObject<TResult>(FStrJSon);;
  End;
end;


end.

