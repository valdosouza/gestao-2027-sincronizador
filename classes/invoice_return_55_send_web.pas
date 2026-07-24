unit invoice_return_55_send_web;

interface

uses System.SysUtils,general_web,System.JSON,
     ControllerRetornoNFe;

Type
  TInvoiceReturn55SendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerRetornoNFe;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TInvoiceReturn55SendWeb.Create;
begin
  inherited;
  FCtrl := TControllerRetornoNFe.Create(nil);
end;

destructor TInvoiceReturn55SendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceReturn55SendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Clear;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    // Contrato /invoice-return-55/sincronize (CONTRATOS_SYNC.md, Onda 6):
    // payload FLAT — sem bloco aninhado "Retorno:{}" e sem Estabelecimento/
    // tb_institution_id (a API key resolve institution+schema no servidor).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id',         TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('terminal',   TJSONNumber.Create(FTerminal));
      LcJson.AddPair('number',     FCtrl.Registro.NumeroInicial);
      LcJson.AddPair('serie',      FCtrl.Registro.Serie.ToString);
      LcJson.AddPair('statusCode', TJSONNumber.Create(FCtrl.Registro.Situacao));
      LcJson.AddPair('fileName',   FCtrl.Registro.NomeArquivo);
      LcJson.AddPair('motive',     FCtrl.Registro.Motivo);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted',    DM.GetDeletedFlag('TB_RETORNO_NFE', 'NFE_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.
