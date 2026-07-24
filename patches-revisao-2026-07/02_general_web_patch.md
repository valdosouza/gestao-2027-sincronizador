# Patch 02 — general_web.pas: auth X-Api-Key (C2) + envelope novo (C9)

**Alvo**: `sincronizador/classes/general_web.pas`
**Contrato do servidor** (D12/D14): header `X-Api-Key`; sucesso HTTP 200
`{ok:true, id, externalCode?}`; erro HTTP <> 200 `{ok:false, error}`.

## 1. Unit NOVA de resposta — `classes/sync_retorno.pas`

A `TPrmRetorno` antiga não conhece o envelope novo. Criar:

```pascal
unit sync_retorno;

interface

type
  TSyncRetorno = class
  private
    Fok:           Boolean;
    Fid:           Integer;
    FexternalCode: String;
    Ferror:        String;
  public
    property ok:           Boolean read Fok           write Fok;
    property id:           Integer read Fid           write Fid;
    property externalCode: String  read FexternalCode write FexternalCode;
    property error:        String  read Ferror        write Ferror;
  end;

implementation

end.
```

## 2. `configComponents` — enviar a X-Api-Key (C2)

O bug atual: `LcAccessToKen` é declarado e NUNCA preenchido (e era concatenado
na URL, o que nem é header). Trocar por parâmetro de header:

```pascal
procedure TGeneralWeb.configComponents;
Var
  LcUrl : String;
begin
  RESTClient.ResetToDefaults;
  RESTRequest.ResetToDefaults;
  RESTResponse.ResetToDefaults;

  LcUrl := concat(FUrl, FEndPoint);
  RESTClient.ContentType := 'application/json';
  RESTClient.BaseURL := LcUrl;

  // D12: chave da instalação, lida do registro do Windows (SISWEB\FApiKey)
  RESTRequest.Params.AddItem('X-Api-Key', FApiKey,
    TRESTRequestParameterKind.pkHTTPHEADER,
    [TRESTRequestParameterOption.poDoNotEncode]);

  case AnsiIndexStr(UpperCase(FMetodo), ['POST', 'PUT', 'DELETE', 'GET']) of
    0: RESTRequest.Method := rmPOST;
    1: RESTRequest.Method := rmPUT;
    2: RESTRequest.Method := rmDELETE;
    3: RESTRequest.Method := rmGET;
  end;
end;
```

Acrescentar na classe: campo `FApiKey: String` + property `ApiKey` (preenchida
pelo `TSendToWebServer` a partir do registro, como já faz com `FPathURL`).

## 3. `send` — tratar o envelope novo (C9)

```pascal
procedure TGeneralWeb.send;
begin
  FSuccess := False;
  try
    GenerateJson;
    if FStrJson <> '' then
    Begin
      RESTResponse.RootElement := '';
      RESTRequest.ClearBody;
      RESTRequest.Body.Add(FStrJson, TRESTContentType.ctAPPLICATION_JSON);
      RESTRequest.Execute;

      // D14: sucesso = HTTP 200 (o Delphi decide pelo STATUS, não pelo body)
      if RESTResponse.StatusCode = 200 then
      Begin
        FSyncRetorno := TJson.JsonToObject<TSyncRetorno>(RESTResponse.Content);
        FSuccess := FSyncRetorno.ok;
        // D4/D14: registro sem documento → gravar o UUID no Firebird
        if FSyncRetorno.externalCode <> '' then
          SaveExternalCode(FSyncRetorno.externalCode);
      End
      else
        // erro → texto vai para TB_SINCRONIA.SRC_LOG (fluxo existente)
        FLastError := Format('[%d] %s', [RESTResponse.StatusCode, RESTResponse.Content]);
    End
    else
      raise Exception.Create('Não foi possível gerar json');
  Except
    on e: Exception do
      FLastError := e.Message;
  end;
end;

/// D4: UPDATE TB_EMPRESA SET EXTERNALCODE = :uuid WHERE EMP_CODIGO = :codigo
/// Virtual — as classes de entidade (customer/provider/salesman) fazem o
/// update; as demais herdam o corpo vazio.
procedure TGeneralWeb.SaveExternalCode(const AUuid: String);
begin
end;
```

Campos novos na classe: `FSuccess: Boolean`, `FLastError: String`,
`FSyncRetorno: TSyncRetorno` (liberar no destructor). O `TSendToWebServer`
passa a decidir por `FSuccess`/`FLastError` (hoje decide por HTTP 200 direto
no retorno — comportamento equivalente, mas agora com a mensagem certa no log).

## 4. `GetSincronize` (recebimento)

Sentido inverso ficou para a fase própria (D16) — não mexer agora.
