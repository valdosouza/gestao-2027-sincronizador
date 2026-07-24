unit invoice_merchandise_send_web;


interface

uses System.SysUtils, System.JSON, general_web, ControllerNotaFiscal,
     ObjInvoiceMerchandise, un_dm;

Type
  TInvoiceMerchandiseSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerNotaFiscal;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TInvoiceMerchandiseSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerNotaFiscal.Create(nil);
end;

destructor TInvoiceMerchandiseSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceMerchandiseSendWeb.GenerateJson;
Var
  LcJson       : TJSONObject;
  LcEntityDoc  : String;
  LcIssuer     : String;
begin
  inherited;
    FCtrl.NotaAvulsa := False;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.ClearDataObjecto;
      FCtrl.ObjInvoice.Estabelecimento := FInstitutionDestino;
      FCtrl.ObjInvoice.Terminal := FTerminal;
      // SIMPLIFICAÇÃO INTENCIONAL (contrato /invoice-merchandise = mesmo
      // shape do /invoice + orderId; a web NÃO persiste ICMS/IPI/PIS/
      // COFINS/II/transporte/observações por item). Reaproveitamos apenas
      // o bloco "Nota" (mesma rotina do invoice_send_web, com resolução de
      // CFOP), em vez de FillDataObjetoMerchandise (que monta os blocos
      // fiscais detalhados descartados pelo contrato novo).
      FCtrl.FillDataObjetoDetached(FCtrl.Registro);

      // Achado transversal: EntityExternalCode/IssuerExternalCode do Obj
      // legado carregam o CODIGO INTERNO (NFL_CODEMP), não o documento.
      LcEntityDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.CodigoEmpresa);

      if (FCtrl.Registro.Tipo = 'EE') OR (FCtrl.Registro.Tipo = 'EM') then
        LcIssuer := 'S'
      else
        LcIssuer := 'N';

      LcJson := TJSONObject.Create;
      Try
        LcJson.AddPair('id', TJSONNumber.Create(FCtrl.ObjInvoice.Nota.Codigo));
        LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
        LcJson.AddPair('issuer', LcIssuer);
        LcJson.AddPair('kindEmis', FCtrl.ObjInvoice.Nota.TipoEmissao);
        LcJson.AddPair('finality', FCtrl.ObjInvoice.Nota.Finalidade);
        LcJson.AddPair('number', FCtrl.ObjInvoice.Nota.Numero);
        LcJson.AddPair('serie', FCtrl.ObjInvoice.Nota.Serie);
        LcJson.AddPair('cfopId', FCtrl.ObjInvoice.Nota.Cfop);
        if LcEntityDoc <> '' then
          LcJson.AddPair('entityDocument', LcEntityDoc);
        LcJson.AddPair('dtEmission', FormatDateTime('yyyy-mm-dd', FCtrl.ObjInvoice.Nota.Data_emissao));
        LcJson.AddPair('value', TJSONNumber.Create(FCtrl.ObjInvoice.Nota.Valor));
        LcJson.AddPair('model', FCtrl.ObjInvoice.Nota.Modelo);
        LcJson.AddPair('status', FCtrl.ObjInvoice.Nota.Status);
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_NOTA_FISCAL', 'NFL_CODIGO', FCodigo)); // decisao 8: le o DELETED real da tabela

        // ⚠️ ACHADO (CONTRATOS_SYNC.md): tb_invoice não tem coluna de
        // pedido — orderId é apenas VALIDADO no servidor (409 ORDER_NOT_SYNCED)
        LcJson.AddPair('orderId', TJSONNumber.Create(FCtrl.Registro.CodigoPedido));

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;


end.
