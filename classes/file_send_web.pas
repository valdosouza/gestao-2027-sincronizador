unit file_send_web;

interface

uses System.SysUtils,general_web,System.JSON,
     ControllerArquivo;

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
Var
  LcJson        : TJSONObject;
  LcDtReference : String;
begin
  inherited;
  FCtrl.Clear;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    // Reaproveita a leitura do blob + EncodeBase64 ja feita em
    // TControllerArquivo.FillDataObjeto (preenche Obj.Filename/Obj.Content
    // conforme o tipo do arquivo) — so muda o payload para o contrato novo.
    FCtrl.fillDataObjeto(FCtrl.Registro);

    // TODO: idealmente usar a data de emissao do documento vinculado, nao a
    // data de sincronizacao. TArquivo (Registro/TB_ARQUIVOS) nao tem nenhum
    // campo de data proprio — o vinculo (ARQ_CODVCL) aponta para tabelas
    // diferentes conforme o tipo (NFe/CCe/NFCe/NFSe/MDFe) e cruzar cada uma
    // exigiria alterar ControllerArquivo (fora do escopo desta entrega).
    LcDtReference := FormatDateTime('yyyy-mm-dd', Now);

    // Contrato /filexml/sincronize (CONTRATOS_SYNC.md, Onda 6): payload é só
    // {fileName, contentBase64, dtReference} — SEM Estabelecimento/Terminal/
    // FolderName (a pasta <cnpj>/<ano>/<mes> é resolvida no servidor pela
    // API key + dtReference).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('fileName',      FCtrl.Obj.Filename);
      LcJson.AddPair('contentBase64', FCtrl.Obj.Content);
      LcJson.AddPair('dtReference',   LcDtReference);
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;

    //Fluxo SOAP antigo (nao usado mais):
    //FDataCM.SMServicesClient.setXMLFile(FStrJson);
  End;
end;


end.
