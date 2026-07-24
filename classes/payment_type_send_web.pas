unit payment_type_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerFormaPagamento,
     System.JSON;

Type
  TPaymentTypeSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFormaPagamento;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;


  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TPaymentTypeSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFormaPagamento.Create(nil);
end;



destructor TPaymentTypeSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;


procedure TPaymentTypeSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // Contrato /payment-type/sincronize: SEM id, SEM institution — catálogo
    // central + atributos do vínculo (idNfce só entra na CRIAÇÃO da linha
    // central). Controller já lê FPT_TIPO_NFCE/FPT_APP_DELIVERY/FPT_TEF/
    // FPT_PARCELAS do Firebird — antes simplesmente não eram usados aqui.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('idNfce', FCtrl.Registro.FormaPagamentoNFCE);
      LcJson.AddPair('enable', FCtrl.Registro.Ativo);
      LcJson.AddPair('appMobile', FCtrl.Registro.DisponivelDElivery);
      // TODO: TFormaPagamento/TB_FORMAPAGTO não tem campos equivalentes a
      // bloqueio por cliente bloqueado/sem limite — 'N' fixo.
      LcJson.AddPair('blockForCustomerBlocked', 'N');
      LcJson.AddPair('blockForCustomerNoLimit', 'N');
      LcJson.AddPair('maxParcels', TJSONNumber.Create(FCtrl.Registro.ParcelamentoMaximo));
      LcJson.AddPair('tef', FCtrl.Registro.HabilitaTEF);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_FORMAPAGTO', 'FPT_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

