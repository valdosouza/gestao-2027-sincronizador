unit invoice_return_service_send_web;

interface

uses System.SysUtils,general_web,System.JSON,
     ControllerRetornoNFS;

Type
  TInvoiceReturnServiceSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerRetornoNFS;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TInvoiceReturnServiceSendWeb }

constructor TInvoiceReturnServiceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerRetornoNFS.Create(nil);
end;

destructor TInvoiceReturnServiceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceReturnServiceSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Clear;
  FCtrl.Registro.CodigoNotaFiscal := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    // Contrato /invoice-return-service/sincronize (CONTRATOS_SYNC.md, Onda 6):
    // payload FLAT — sem bloco aninhado e sem Estabelecimento/tb_institution_id
    // (a API key resolve institution+schema no servidor).
    // nrRps/nrLot/statusCode sao INTEIROS (0 = sem valor); fileName liga ao
    // XML enviado pelo /filexml.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id',          TJSONNumber.Create(FCtrl.Registro.CodigoNotaFiscal));
      LcJson.AddPair('terminal',    TJSONNumber.Create(FTerminal));
      LcJson.AddPair('number',      FCtrl.Registro.Numero);
      LcJson.AddPair('nrRps',       TJSONNumber.Create(FCtrl.Registro.ReciboProvisorios));
      LcJson.AddPair('nrLot',       TJSONNumber.Create(FCtrl.Registro.Lote));
      LcJson.AddPair('protocol',    FCtrl.Registro.Protocolo);
      LcJson.AddPair('codeVerif',   FCtrl.Registro.CodigoVerificacao);
      LcJson.AddPair('kind',        FCtrl.Registro.Tipo);
      LcJson.AddPair('synchronous', FCtrl.Registro.Sincrono);
      LcJson.AddPair('statusCode',  TJSONNumber.Create(FCtrl.Registro.CodigoSituacao));
      LcJson.AddPair('fileName',    FCtrl.Registro.Arquivo);
      LcJson.AddPair('motive',      FCtrl.Registro.Motivo);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted',     DM.GetDeletedFlag('TB_RETORNO_NFS', 'NFS_CODNFL', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.
