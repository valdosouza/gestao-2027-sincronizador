unit financial_plans_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerPlanoContas,
     ObjFinancialPlans, System.JSON;

Type
  TFinancialPlansSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPlanoContas;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TFinancialPlansSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPlanoContas.Create(nil);
end;

destructor TFinancialPlansSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TFinancialPlansSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;

begin
  inherited;
   // BUG corrigido: FCtrl.clear vinha DEPOIS de setar Registro.Codigo, e
   // ClearObj(Registro) zera o registro inteiro (inclusive o Codigo) — o
   // getbyId seguinte perdia a chave de busca. clear agora vem ANTES.
   FCtrl.clear;
   FCtrl.Registro.Codigo := FCodigo;
   FCtrl.getbyId;
   if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
      // Mantida a técnica de resolução via FillDataObjeto (monta
      // FCtrl.Obj.PlanoContas) — só os nomes das chaves do JSON mudam para o
      // contrato novo, que é FLAT (sem aninhar em "PlanoContas") e camelCase.
      FCtrl.FillDataObjeto(FCtrl.Registro, FCtrl.Obj);

      LcJson := TJSONObject.Create;
      try
        // Contrato /financial-plans/sincronize: id = PLC_CODIGO local ✅;
        // Estabelecimento NÃO viaja (D12); posit_level recalculado no
        // servidor — NUNCA enviar PLC_CODPLANO/NivelPosicao como parentId.
        LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Obj.PlanoContas.Codigo));
        LcJson.AddPair('description', FCtrl.Obj.PlanoContas.Descricao);
        // TODO: Firebird (TB_PLANOCONTAS) não tem FK de plano pai — só
        // PLC_CODPLANO (string hierárquica tipo posit_level) — usando raiz.
        LcJson.AddPair('parentId', TJSONNumber.Create(0));
        LcJson.AddPair('source', FCtrl.Obj.PlanoContas.Fonte);
        LcJson.AddPair('kind', FCtrl.Obj.PlanoContas.Tipo);
        LcJson.AddPair('cluster', FCtrl.Obj.PlanoContas.Agrupador);
        LcJson.AddPair('active', FCtrl.Obj.PlanoContas.Ativo);
        // decisao 8: le o DELETED real da tabela
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_PLANOCONTAS', 'PLC_CODIGO', FCodigo));
        FStrJSon := LcJson.ToJSON;
      finally
        LcJson.Free;
      end;
  End;
end;


end.

