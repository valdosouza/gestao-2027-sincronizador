unit general_web;

interface

uses System.Classes,System.TypInfo, prm_retorno, System.SysUtils, REST.Client,
     REST.Types, REST.Json,System.StrUtils,System.Rtti,IPPeerAPI,IdHTTP,
     IpPeerClient,IdComponent,ControllerSincronia, Vcl.StdCtrls,
     System.JSON ;

Type
  TGeneralWeb = class(TPersistent)
  private
    RESTClient   : TRESTClient;
    RESTRequest  : TRESTRequest;
    RESTResponse : TRESTResponse;

    FURL:       String;
    FMetodo:    String;
    FEndPoint:  String;
    FApiKey:    String;
    FExternalCode: String;
    FClearExternalCode: Boolean;
    FSincronia   : TControllerSincronia;

    //RESTResponseDSA: TRESTResponseDataSetAdapter;
    procedure setFCodigo             (const Value: Integer);
    procedure setFRetorno            (const Value: TPrmRetorno);
    procedure setFURL                (const Value: String);
    procedure setFMetodo             (const Value: String);
    procedure setFEndPoint           (const Value: String);
    procedure setFApiKey             (const Value: String);
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
    procedure GetSincronize;
    // Onda 1 da revisão do sincronizador (Delphi) — interpreta o envelope
    // novo {ok,id,externalCode}/{ok:false,error,fields,code} e traduz para
    // o TPrmRetorno já consumido por un_send_to_web_server/un_receive_from_
    // web_server (ID = status HTTP, Code = id do registro devolvido,
    // Mensagem = mensagem/erro) — não quebra os chamadores existentes.
    procedure ParseRetornoEnvelope;
    // Decisao 2 da revisao de entidades (2026-07-25): documento branco,
    // sentinela do legado ou INVALIDO (digito verificador) vira 'N' e segue
    // pelo fluxo externalCode — nada encalha por 400 na API. 11 digitos
    // validos = 'F'; 14 validos = 'J'.
    function DerivePersonType(const pDoc: String): String;
  public
    constructor Create;Virtual;
    destructor  Destroy;override;
    procedure   Inicializa;Virtual;
    procedure send;
    procedure receive;Virtual;
    // Decisao 1 da revisao de entidades: alvo do write-back do externalCode
    // devolvido pela API (D4). Padrao TB_EMPRESA/EMP_CODIGO; classes cuja
    // fonte nao e TB_EMPRESA (salesman -> TB_COLABORADOR) sobrescrevem.
    function ExternalCodeTable: String; virtual;
    function ExternalCodeKeyField: String; virtual;
    property Codigo      : Integer     read FCodigo   write setFCodigo;
    property Retorno     : TPrmRetorno read FRetorno  write setFRetorno;
    property URL         : String      read FURL      write setFURL;
    property Metodo      : String      read FMetodo   write setFMetodo;
    property EndPoint    : String      read FEndPoint write setFEndPoint;
    property ApiKey      : String      read FApiKey   write setFApiKey;
    property Terminal    : Integer     read FTerminal write setFTerminal;
    // D4/D14: UUID devolvido pela setes-sync quando o registro não tem
    // CPF/CNPJ (personType 'N') — quem chama send() lê esta propriedade
    // depois e grava em TB_EMPRESA.EXTERNALCODE (ver un_send_to_web_server).
    property ExternalCode: String      read FExternalCode;
    // Graduacao do sem-doc (decisao 1 de prompt_correcao_documento_entidade.md):
    // true = o documento corrigido virou o indice; limpar o EXTERNALCODE no
    // Firebird (tabela/campo de ExternalCodeTable/KeyField).
    property ClearExternalCode: Boolean read FClearExternalCode;
    property InstitutionOrigem:Integer  Read FInstitutionOrigem  write setFInstitutionOrigem;
    property InstitutionDestino:Integer Read FInstitutionDestino write setFInstitutionDestino;

  end;

  TGeneralSendFactory = class
  public
      class function Instanciar(classname: string): TGeneralWeb;
  end;

implementation

{ TGeneralWeb }

uses customer_send_web, UnFunctions;

function TGeneralWeb.DerivePersonType(const pDoc: String): String;
begin
  // decisao 3: sentinela de criarEmpresaSemCPFCNPJ mantida como dupla protecao
  if (pDoc = '') or (pDoc = '12345677654321') then Exit('N');
  if (Length(pDoc) = 11) and CalculoCpf(pDoc)  then Exit('F');
  if (Length(pDoc) = 14) and CalculoCnpj(pDoc) then Exit('J');
  Result := 'N';
end;

function TGeneralWeb.ExternalCodeTable: String;
begin
  Result := 'TB_EMPRESA';
end;

function TGeneralWeb.ExternalCodeKeyField: String;
begin
  Result := 'EMP_CODIGO';
end;

procedure TGeneralWeb.configComponents;
Var
  LcUrl          : String;

begin
  RESTClient.ResetToDefaults;
  RESTRequest.ResetToDefaults;
  RESTResponse.ResetToDefaults;

  LcUrl := concat( FUrl,FEndPoint);
  RESTClient.ContentType := 'application/json';
  RESTClient.BaseURL := LcUrl;

  // D12 (revisão do sincronizador): NÃO existe mais chave global concatenada
  // na URL — cada instalação tem a própria chave (registro do Windows,
  // SISWEB\FApiKey), enviada como header X-Api-Key. O servidor resolve
  // institution/schema pela chave; o payload NÃO manda mais tb_institution_id.
  RESTRequest.Params.AddItem('X-Api-Key', FApiKey,
    TRESTRequestParameterKind.pkHTTPHEADER,
    [TRESTRequestParameterOption.poDoNotEncode]);

  case AnsiIndexStr(UpperCase(FMetodo), ['POST', 'PUT','DELETE','GET']) of
    0:Begin
        RESTRequest.Method := rmPOST;
      End;
    1:Begin
        RESTRequest.Method := rmPUT;
      End;
    2:Begin
        RESTRequest.Method := rmDELETE;
      End;
    3:Begin
        RESTRequest.Method := rmGET;
      End;
  end;
end;

constructor TGeneralWeb.Create;
begin
  inherited;
  FRetorno := TPrmRetorno.Create;
  FExternalCode := '';
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

procedure TGeneralWeb.ParseRetornoEnvelope;
Var
  LcJson    : TJSONObject;
  LcOk      : Boolean;
  LcError   : String;
  LcId      : Integer;
begin
  FExternalCode := '';
  FClearExternalCode := False;
  FRetorno.Clear;

  // D14: sucesso/erro é decidido pelo STATUS HTTP (200 = ok), não só pelo
  // corpo — mantém o `case Retorno.ID of 200:` já usado pelos chamadores.
  FRetorno.ID := RESTResponse.StatusCode;

  LcJson := nil;
  try
    if RESTResponse.Content <> '' then
      LcJson := TJSONObject.ParseJSONValue(RESTResponse.Content) as TJSONObject;

    if Assigned(LcJson) then
    Begin
      LcOk := False;
      if Assigned(LcJson.GetValue('ok')) then
        LcOk := LcJson.GetValue('ok').Value = 'true';

      if LcOk then
      Begin
        LcId := 0;
        if Assigned(LcJson.GetValue('id')) then
          LcId := StrToIntDef(LcJson.GetValue('id').Value, 0);
        FRetorno.Code     := LcId;
        FRetorno.Mensagem := 'OK';

        if Assigned(LcJson.GetValue('externalCode')) then
          FExternalCode := LcJson.GetValue('externalCode').Value;

        // graduacao (decisao 1): sinal explicito de limpar o vinculo
        if Assigned(LcJson.GetValue('clearExternalCode')) then
          FClearExternalCode := LcJson.GetValue('clearExternalCode').Value = 'true';
      End
      else
      Begin
        LcError := 'Erro desconhecido';
        if Assigned(LcJson.GetValue('error')) then
          LcError := LcJson.GetValue('error').Value;
        FRetorno.Mensagem := LcError;
      End;
    End
    else
      // corpo vazio ou não-JSON (ex.: erro de rede/timeout antes do servidor
      // responder) — mensagem genérica, ID já reflete o status HTTP real
      FRetorno.Mensagem := RESTResponse.Content;
  finally
    if Assigned(LcJson) then LcJson.Free;
  end;
end;

procedure TGeneralWeb.send;
begin
  try
    FRetorno.Clear;
    GenerateJson;
    if FStrJson <> '' then
    Begin
      RESTResponse.RootElement := '';
      RESTRequest.ClearBody;
      RESTRequest.Body.Add(FStrJson, TRESTContentType.ctAPPLICATION_JSON);
      RESTRequest.Execute;
      ParseRetornoEnvelope;
    End
    else
      raise Exception.Create('N�o foi possivel gerar json');
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

procedure TGeneralWeb.setFApiKey(const Value: String);
begin
  FApiKey := Value;
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

procedure TGeneralWeb.GetSincronize;
begin
  try
    RESTResponse.RootElement := '';
    RESTRequest.ClearBody;
    RESTRequest.Body.Add(FStrJson, TRESTContentType.ctAPPLICATION_JSON);
    RESTRequest.Execute;
    ParseRetornoEnvelope;
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
