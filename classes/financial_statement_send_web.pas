unit financial_statement_send_web;


interface

uses System.SysUtils, System.JSON, general_web,
     ControllerMovimentoFinanceiro, objFinancialStatement, un_dm;

Type
  TFinancialStatementSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMovimentoFinanceiro;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TFinancialStatementSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMovimentoFinanceiro.Create(nil);
end;

destructor TFinancialStatementSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TFinancialStatementSendWeb.GenerateJson;
Var
  LcJson    : TJSONObject;
  LcUser    : TJSONObject;
  LcFuture  : String;
  LcUserDoc : String;
  LcUserExt : String;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // Descrição da forma de pagamento (reaproveita o lookup do controller).
    FCtrl.FormaPagto.Registro.Codigo := FCtrl.Registro.FormaPagto;
    FCtrl.FormaPagto.getById;

    if FCtrl.Registro.ValorFuturo > 0 then
      LcFuture := 'S'
    else
      LcFuture := 'N';

    LcJson := TJSONObject.Create;
    Try
      // Contrato FLAT (não aninhado em "Movimento"). id=MVF_CODIGO (local).
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
      LcJson.AddPair('bankAccountId', TJSONNumber.Create(FCtrl.Registro.ContaCorrente));
      LcJson.AddPair('dtRecord', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.Data));
      LcJson.AddPair('bankHistoricId', TJSONNumber.Create(FCtrl.Registro.HistoricoBancario));
      LcJson.AddPair('creditValue', TJSONNumber.Create(FCtrl.Registro.ValorCredito));
      LcJson.AddPair('debitValue', TJSONNumber.Create(FCtrl.Registro.ValorDebito));
      LcJson.AddPair('manualHistory', FCtrl.Registro.Historico);
      LcJson.AddPair('kind', FCtrl.Registro.Tipo);
      LcJson.AddPair('settledCode', TJSONNumber.Create(FCtrl.Registro.Quitacao));
      LcJson.AddPair('future', LcFuture);
      if FCtrl.Registro.DataOriginal = 0 then
        LcJson.AddPair('dtOriginal', TJSONNull.Create)
      else
        LcJson.AddPair('dtOriginal', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.DataOriginal));
      LcJson.AddPair('docReference', FCtrl.Registro.NrDocumento);
      LcJson.AddPair('conferred', FCtrl.Registro.Conferido);
      LcJson.AddPair('paymentTypeDescription', FCtrl.FormaPagto.Registro.Descricao);
      LcJson.AddPair('financialPlansIdCre', TJSONNumber.Create(FCtrl.Registro.PL_Credito));
      LcJson.AddPair('financialPlansIdDeb', TJSONNumber.Create(FCtrl.Registro.PL_Debito));
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_MOVIM_FINANCEIRO', 'MVF_CODIGO', FCodigo)); // decisao 8: le o DELETED real da tabela

      // AUTOR (prompt_indexacao_usuario_firebird.md, decisao 6): MVF_CODUSU
      // resolvido pela cascata; sem referencia o bloco nao viaja
      // (tb_user_id fica 0 sentinela na web).
      if DM.GetUserSyncRef(FCtrl.Registro.Usuario, LcUserDoc, LcUserExt) then
      Begin
        LcUser := TJSONObject.Create;
        if LcUserDoc <> '' then
          LcUser.AddPair('userDocument', LcUserDoc)
        else
          LcUser.AddPair('userExternalCode', LcUserExt);
        LcJson.AddPair('user', LcUser);
      End;

      FStrJSon := LcJson.ToJSON;
    Finally
      LcJson.Free;
    End;
  end;

end;

end.
