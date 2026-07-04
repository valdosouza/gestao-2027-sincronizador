unit general_send_web;

interface

uses System.Classes,System.TypInfo, prm_retorno, System.SysUtils, REST.Client,
     REST.Types, REST.Json,System.StrUtils,System.Rtti,IPPeerAPI,IdHTTP, IpPeerClient,IdComponent;

Type
  TGeneralSendWeb = class(TPersistent)
  private
    RESTClient   : TRESTClient;
    RESTRequest  : TRESTRequest;
    RESTResponse : TRESTResponse;

    FURL:       String;
    FMetodo:    String;
    FEndPoint:  String;

    //RESTResponseDSA: TRESTResponseDataSetAdapter;
    procedure setFCodigo             (const Value: Integer);
    procedure setFRetorno            (const Value: TPrmRetorno);
    procedure setFURL                (const Value: String);
    procedure setFMetodo             (const Value: String);
    procedure setFEndPoint           (const Value: String);
    procedure setFInstitutionDestino (const Value: Integer);
    procedure setFInstitutionOrigem  (const Value: Integer);
    procedure configComponents;
    procedure setFTerminal           (const Value: Integer);

  protected
    FCodigo              : Integer;
    FStrJson             : String;
    FRetorno             : TPrmRetorno;
    FInstitutionDestino  : Integer;
    FInstitutionOrigem   : Integer;
    FTerminal            : Integer;

    procedure createComponents;Virtual;
    procedure GenerateJson;Virtual;

  public
    constructor Create;Virtual;
    destructor  Destroy;override;
    procedure   Inicializa;Virtual;

    procedure send;
    property Codigo      : Integer     read FCodigo   write setFCodigo;
    property Retorno     : TPrmRetorno read FRetorno  write setFRetorno;
    property URL         : String      read FURL      write setFURL;
    property Metodo      : String      read FMetodo   write setFMetodo;
    property EndPoint    : String      read FEndPoint write setFEndPoint;
    property Terminal    : Integer     read FTerminal write setFTerminal;
    property InstitutionOrigem:Integer  Read FInstitutionOrigem  write setFInstitutionOrigem;
    property InstitutionDestino:Integer Read FInstitutionDestino write setFInstitutionDestino;

  end;

  TGeneralSendFactory = class
  public
      class function Instanciar(classname: string): TGeneralSendWeb;
  end;

implementation

{ TGeneralSendWeb }

uses customer_send_web;

procedure TGeneralSendWeb.configComponents;
Var
  LcContentType  : TRESTContentType;
  LcUrl          : String;
  LcAccessToKen  : String;
  Lc_Institution : String;

begin
  RESTClient.ResetToDefaults;
  RESTRequest.ResetToDefaults;
  RESTResponse.ResetToDefaults;

  LcUrl := concat( FUrl,FEndPoint);
  RESTClient.ContentType := 'application/json';

  RESTClient.BaseURL := LcUrl;
  case AnsiIndexStr(UpperCase(FMetodo), ['POST', 'PUT','DELETE','GET']) of
    0:Begin
        RESTClient.BaseURL := concat(LcUrl,LcAccessToKen);
        RESTRequest.Method := rmPOST;
      End;
    1:Begin
        RESTClient.BaseURL := LcUrl;
        RESTRequest.Method := rmPUT;
      End;
    2:Begin
        RESTClient.BaseURL := LcUrl;
        RESTRequest.Method := rmDELETE;
      End;
    3:Begin
        RESTClient.BaseURL := LcUrl;
        RESTRequest.Method := rmGET;
      End;
  end;
end;

constructor TGeneralSendWeb.Create;
begin
  inherited;
  FRetorno := TPrmRetorno.Create;
end;

procedure TGeneralSendWeb.createComponents;
begin
  RESTClient             := TRESTClient.Create(FURL);
  RESTRequest            := TRESTRequest.Create(nil);
  RESTResponse           := TRESTResponse.Create(nil);
  //RESTResponseDSA      := TRESTResponseDataSetAdapter.Create(Self);
  //Configura
  RESTClient.ContentType := 'Content-Type: application/json';
  RESTRequest.Client     := RESTClient;
  RESTRequest.Response   := RESTResponse;
end;

destructor TGeneralSendWeb.Destroy;
begin
  if Assigned(RESTClient)   then RESTClient.DisposeOf;
  if Assigned(RESTRequest)  then RESTRequest.DisposeOf;
  if Assigned(RESTResponse) then RESTResponse.DisposeOf;
  FRetorno.DisposeOf;
  inherited;
end;

procedure TGeneralSendWeb.send;
Var
  LcStrJSon: String;
begin
  try
    FRetorno.clear;
    GenerateJson;
    if FStrJson <> '' then
    Begin
      RESTResponse.RootElement := '';
      RESTRequest.ClearBody;
      RESTRequest.Body.Add(FStrJson, TRESTContentType.ctAPPLICATION_JSON);
      RESTRequest.Execute;
      FRetorno := TJson.JsonToObject<TPrmRetorno>(RESTResponse.Content);
    End
    else
      raise Exception.Create('Não foi possivel gerar json');
  Except
    on e: Exception do
      FRetorno.Mensagem := e.Message;
  end;
end;

procedure TGeneralSendWeb.setFCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TGeneralSendWeb.setFEndPoint(const Value: String);
begin
  FEndPoint := Value;
end;

procedure TGeneralSendWeb.setFInstitutionDestino(const Value: Integer);
begin
  FInstitutionDestino := Value;
end;

procedure TGeneralSendWeb.setFInstitutionOrigem(const Value: Integer);
begin
  FInstitutionOrigem := Value;
end;

procedure TGeneralSendWeb.setFMetodo(const Value: String);
begin
  FMetodo := Value;
end;

procedure TGeneralSendWeb.setFRetorno(const Value: TPrmRetorno);
begin
  FRetorno := Value;
end;

procedure TGeneralSendWeb.setFTerminal(const Value: Integer);
begin
  FTerminal := Value;
end;

procedure TGeneralSendWeb.setFURL(const Value: String);
begin
  FURL := Value;
end;

procedure TGeneralSendWeb.GenerateJson;
begin
  FStrJson := '';

end;

procedure TGeneralSendWeb.Inicializa;
begin
  createComponents;
  configComponents;
end;

{ TGeneralSendFactory }

class function TGeneralSendFactory.Instanciar(classname: string): TGeneralSendWeb;
var
  Lc_classe: TClass;
begin
  Lc_classe := GetClass(classname);
  Result := Lc_classe.Create as TGeneralSendWeb;
  Result.Create;
end;

end.
