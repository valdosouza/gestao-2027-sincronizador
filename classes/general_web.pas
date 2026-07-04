unit general_web;

interface

uses System.Classes,System.TypInfo, prm_retorno, System.SysUtils, REST.Client,
     REST.Types, REST.Json,System.StrUtils,System.Rtti,IPPeerAPI,IdHTTP,
     IpPeerClient,IdComponent,TblSyncTable,ControllerSincronia, Vcl.StdCtrls ;

Type
  TGeneralWeb = class(TPersistent)
  private
    RESTClient   : TRESTClient;
    RESTRequest  : TRESTRequest;
    RESTResponse : TRESTResponse;

    FURL:       String;
    FMetodo:    String;
    FEndPoint:  String;
    FSincronia   : TControllerSincronia;

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
    function getLasUpdate:TSyncTable;
    procedure GenerateJson;Virtual;
    procedure GetSincronize;
  public
    constructor Create;Virtual;
    destructor  Destroy;override;
    procedure   Inicializa;Virtual;
    procedure send;
    procedure receive;Virtual;
    procedure PreparaListBox(Tipo:String);
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
      class function Instanciar(classname: string): TGeneralWeb;
  end;

implementation

{ TGeneralWeb }

uses customer_send_web;

procedure TGeneralWeb.configComponents;
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

constructor TGeneralWeb.Create;
begin
  inherited;
  //FRetorno := TPrmRetorno.Create;
end;

procedure TGeneralWeb.createComponents;
begin
  RESTClient             := TRESTClient.Create(FURL);
  RESTRequest            := TRESTRequest.Create(nil);
  RESTResponse           := TRESTResponse.Create(nil);
  //RESTResponseDSA      := TRESTResponseDataSetAdapter.Create(Self);
  //Configura
  RESTClient.ContentType := 'Content-Type: application/json';
  RESTRequest.Client     := RESTClient;
  RESTRequest.Response   := RESTResponse;

  FSincronia   := TControllerSincronia.Create(nil);
end;

destructor TGeneralWeb.Destroy;
begin
  if Assigned(RESTClient)   then RESTClient.DisposeOf;
  if Assigned(RESTRequest)  then RESTRequest.DisposeOf;
  if Assigned(RESTResponse) then RESTResponse.DisposeOf;
  if Assigned(FRetorno) THEN FreeAndNil(FRetorno);
  inherited;
end;

procedure TGeneralWeb.send;
Var
  LcStrJSon: String;
begin
  try
    //FRetorno.clear;
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

procedure TGeneralWeb.setFCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TGeneralWeb.setFEndPoint(const Value: String);
begin
  FEndPoint := Value;
end;

procedure TGeneralWeb.setFInstitutionDestino(const Value: Integer);
begin
  FInstitutionDestino := Value;
end;

procedure TGeneralWeb.setFInstitutionOrigem(const Value: Integer);
begin
  FInstitutionOrigem := Value;
end;

procedure TGeneralWeb.setFMetodo(const Value: String);
begin
  FMetodo := Value;
end;

procedure TGeneralWeb.setFRetorno(const Value: TPrmRetorno);
begin
  FRetorno := Value;
end;

procedure TGeneralWeb.setFTerminal(const Value: Integer);
begin
  FTerminal := Value;
end;

procedure TGeneralWeb.setFURL(const Value: String);
begin
  FURL := Value;
end;

procedure TGeneralWeb.GenerateJson;
begin
  FStrJson := '';

end;

function TGeneralWeb.getLasUpdate: TSyncTable;
begin
  Result := TSyncTable.Create;
  with FSincronia.SyncClient.Registro do
  Begin
    Codigo := FSincronia.Registro.Tabela;
    //R - Receber / E - Enviar
    Sentido := FSincronia.Registro.sentido;
    Tipo := FSincronia.Registro.Tipo;
  End;
  Result := FSincronia.SyncClient.getTime;
end;

procedure TGeneralWeb.GetSincronize;
begin
  try
    RESTResponse.RootElement := '';
    RESTRequest.ClearBody;
    RESTRequest.Body.Add(FStrJson, TRESTContentType.ctAPPLICATION_JSON);
    RESTRequest.Execute;
    FRetorno := TJson.JsonToObject<TPrmRetorno>(RESTResponse.Content);
  Except
    on e: Exception do
      FRetorno.Mensagem := e.Message;
  end;
end;

procedure TGeneralWeb.Inicializa;
begin
  createComponents;
  configComponents;
end;

procedure TGeneralWeb.receive;
begin

end;

{ TGeneralSendFactory }

class function TGeneralSendFactory.Instanciar(classname: string): TGeneralWeb;
var
  Lc_classe: TClass;
begin
  Lc_classe := GetClass(classname);
  Result := Lc_classe.Create as TGeneralWeb;
  Result.Create;
end;

end.
