unit invoice_send_web;


interface

uses System.SysUtils, System.JSON, general_web,
     ControllerNotaFiscal, ObjInvoiceMerchandise, un_dm;

Type
  TInvoiceSendWeb = class(TGeneralWeb)
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

constructor TInvoiceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerNotaFiscal.Create(nil);
end;

destructor TInvoiceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceSendWeb.GenerateJson;
Var
  LcJson       : TJSONObject;
  LcEntityDoc  : String;
  LcIssuer     : String;
begin
  inherited;
  FCtrl.NotaAvulsa := True;
  FCtrl.Registro.Tipo := 'EM';
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    FCtrl.ClearDataObjecto;
    FCtrl.ObjInvoice.Estabelecimento := FInstitutionDestino;
    FCtrl.ObjInvoice.Terminal := FTerminal;
    // FillDataObjetoDetached resolve CFOP (join TB_NATUREZA) e mantém a
    // mesma lógica de emitente/destinatário do legado — reaproveitado.
    FCtrl.FillDataObjetoDetached(FCtrl.Registro);

    // Achado transversal: EntityExternalCode/IssuerExternalCode do Obj
    // legado carregam o CODIGO INTERNO (NFL_CODEMP), não o documento.
    LcEntityDoc := DM.GetDocumentByEmpCodigo(FCtrl.Registro.CodigoEmpresa);

    // D: issuer='S' quando a própria institution emite (NFL_TIPO EE/EM);
    // 'N' quando é destinatário (documento vira o do emitente terceiro).
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

      FStrJson := LcJson.ToJSON;
    Finally
      LcJson.Free;
    End;
  End;
end;


end.
