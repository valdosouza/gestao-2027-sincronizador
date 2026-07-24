unit financial_send_web;

interface

uses System.SysUtils, System.JSON, general_web,
     ControllerFinanceiro, objFinancial, un_dm;

Type
  TFinancialSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFinanceiro;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFinancialSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFinanceiro.Create(nil);
end;

destructor TFinancialSendWeb.Destroy;
begin
  FCtrl.DisposeOf;
  inherited;
end;

procedure TFinancialSendWeb.GenerateJson;
Var
  LcJson    : TJSONObject;
  LcPayment : TJSONObject;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getById;
    if FCtrl.exist then
    Begin
      // Descrição da forma de pagamento (reaproveita o lookup do controller).
      FCtrl.FormaPagto.Registro.Codigo := FCtrl.Registro.FormaPagamento;
      FCtrl.FormaPagto.getById;

      LcJson := TJSONObject.Create;
      Try
        // SEMÂNTICA DE ESPELHO (D revisão): PK NATURAL — FIN_CODIGO NÃO
        // viaja mais. orderId é o pedido/nota vinculado (FIN_CODNFL).
        LcJson.AddPair('orderId', TJSONNumber.Create(FCtrl.Registro.CodigoNota));
        LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
        LcJson.AddPair('parcel', TJSONNumber.Create(FCtrl.Registro.NumeroParcela));
        LcJson.AddPair('dtExpiration', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.DataVencimento));
        LcJson.AddPair('tagValue', TJSONNumber.Create(FCtrl.Registro.ValorParcela));
        LcJson.AddPair('paymentTypeDescription', FCtrl.FormaPagto.Registro.Descricao);
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_FINANCEIRO', 'FIN_CODIGO', FCodigo)); // decisao 8: le o DELETED real da tabela

        // payment só entra quando o título está baixado (FIN_BAIXA='S') —
        // baixa espelhada como evento único; histórico de estornos do
        // legado não viaja (imutabilidade plena só para eventos nascidos na web).
        if FCtrl.Registro.DocumentoBaixado = 'S' then
        Begin
          LcPayment := TJSONObject.Create;
          LcPayment.AddPair('paidValue', TJSONNumber.Create(FCtrl.Registro.ValorPago));
          if FCtrl.Registro.DataPagamento = 0 then
            LcPayment.AddPair('dtPayment', TJSONNull.Create)
          else
            LcPayment.AddPair('dtPayment', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.DataPagamento));
          if FCtrl.Registro.DataBaixa = 0 then
            LcPayment.AddPair('dtRealPayment', TJSONNull.Create)
          else
            LcPayment.AddPair('dtRealPayment', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.DataBaixa));
          LcPayment.AddPair('interestValue', TJSONNumber.Create(FCtrl.Registro.ValorJuros));
          LcPayment.AddPair('lateValue', TJSONNumber.Create(FCtrl.Registro.ValorMora));
          LcPayment.AddPair('discountAliquot', TJSONNumber.Create(FCtrl.Registro.AliquotaDesconto));
          LcPayment.AddPair('settledCode', TJSONNumber.Create(FCtrl.Registro.CodigoQuitacao));
          LcPayment.AddPair('financialPlansId', TJSONNumber.Create(FCtrl.Registro.ContaResultado));
          LcJson.AddPair('payment', LcPayment);
        End;

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;


end.
