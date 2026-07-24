unit invoice_return_65_send_web;


interface

uses System.SysUtils,general_web,System.JSON,
     ControllerRetornoNFCe,UnFunctions;

Type
  TInvoiceReturn65SendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerRetornoNFCe;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TInvoiceReturn65SendWeb.Create;
begin
  inherited;
  FCtrl := TControllerRetornoNFCe.Create(nil);
end;

destructor TInvoiceReturn65SendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceReturn65SendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.clear;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    // Contrato /invoice-return-65/sincronize (CONTRATOS_SYNC.md, Onda 6):
    // payload FLAT — sem bloco aninhado "Retorno:{}" e sem Estabelecimento/
    // tb_institution_id (a API key resolve institution+schema no servidor).
    // Campos ja coletados hoje por getSincronia — so renomear e achatar.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id',           TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('terminal',     TJSONNumber.Create(FTerminal));
      LcJson.AddPair('number',       StrZero(FCtrl.Registro.Codigo,6,0));
      LcJson.AddPair('serie',        FCtrl.Registro.Serie.ToString);
      LcJson.AddPair('nrLot',        TJSONNumber.Create(FCtrl.Registro.Lote));
      LcJson.AddPair('synchronous',  FCtrl.Registro.Sincrono);
      LcJson.AddPair('emissiType',   FCtrl.Registro.TipoEmissao);
      LcJson.AddPair('formatType',   FCtrl.Registro.Formato);
      LcJson.AddPair('presenIndi',   FCtrl.Registro.IndicacaoPresenca);
      LcJson.AddPair('statusCode',   TJSONNumber.Create(FCtrl.Registro.Situacao));
      LcJson.AddPair('fileName',     FCtrl.Registro.NomeArquivo);
      LcJson.AddPair('motive',       FCtrl.Registro.Motivo);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted',      DM.GetDeletedFlag('TB_RETORNO_NFC', 'NFC_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  end;
end;


end.
