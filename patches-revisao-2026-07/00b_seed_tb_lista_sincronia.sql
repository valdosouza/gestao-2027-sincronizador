/* =====================================================================
   [FALLBACK/REFERÊNCIA] — o caminho AUTOMÁTICO agora é o patch 00:
   un_dm.pas (EnsureSincronia, chamada em DataModuleCreate) +
   function/un_sincronia_seed.pas. Este script serve para conferência
   manual ou para quem preferir rodar o seed direto pelo console.

   Onda 0 — Seed de TB_LISTA_SINCRONIA (tabela vazia em produção/teste)

   Gerado a partir do CÓDIGO REAL do Sincronizador (não é suposição):
   - uMain.pas (RegisterClass)         → CLASS_NAME (34 classes reais)
   - controller/ControllerTrigger.pas  → DESC_TABELA/DESC_FIELD confirmados
     (é a lista que o PRÓPRIO Delphi usa para configurar triggers — fonte
     mais confiável que a Documentacao.md, que é derivada/redigida)
   - Infra-IA/setes-sync/CONTRATOS_SYNC.md → END_POINT (rotas que EXISTEM
     hoje na setes-sync, pós Ondas 1-6)

   ⚠️ CONFIRA ANTES DE RODAR:
   - DESC_TRIGGER: NENHUM nome de trigger real foi encontrado no código-
     fonte do Sincronizador. Ficou NULL em TODAS as linhas — preencha com
     o nome real já existente no seu Firebird (ou deixe NULL se o motor
     não exige o nome, apenas SEQ/tabela para achar o registro pendente).
   - Linhas com SET_ON='N' e NOTA "endpoint não existe": NÃO ative até a
     Rodada 4 decidir/implementar — ativar quebraria com 404.
   - Linhas Rest* (D23): mantidas SET_ON='N' de propósito — a setes-sync
     não tem mais esses endpoints (aposentados, ver HISTORICO).
   - PK da tabela é (WAY, DESC_TABELA, KIND) — usei KIND para diferenciar
     fluxos que compartilham tabela (ex.: TB_NOTA_FISCAL serve Invoice E
     InvoiceMerchandise; TB_PEDIDO serve as 3 classes de pedido).
   ===================================================================== */

SET TERM ^ ;

/* ---------------------------------------------------------------------
   1-12: CADASTROS (ordem de prioridade D8)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_MARCA_PRODUTO', 'CADASTRO', 'Marca de produto (catálogo central)', 1,
   'MRC_CODIGO', NULL, 'Onda 3 — dedupe por descrição na setes_central (D5/D17)', 'S',
   'TBrandSendWeb', '/brand/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CATEGORY', 'CADASTRO', 'Categoria de produto/serviço (árvore)', 2,
   'ID', NULL, 'Onda 3 — id local, posit_level recalculado no servidor', 'S',
   'TCategorySendWeb', '/category/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_MEDIDA', 'CADASTRO', 'Unidade de medida (catálogo central)', 3,
   'MED_CODIGO', NULL, 'Onda 3 — endpoint NOVO (não existia na setes-sync)', 'S',
   'TMeasureSendWeb', '/measure/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_EMBALAGEM', 'CADASTRO', 'Embalagem (catálogo central)', 4,
   'EMB_CODIGO', NULL, 'Onda 3 — dedupe por descrição', 'S',
   'TPackageSendWeb', '/package/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PRODUTO', 'CADASTRO', 'Produto (product+merchandise+stock)', 5,
   'PRO_CODIGO', NULL, 'Onda 3 — id local; brand/package/measure por descrição; categoria por id (409 se ausente)', 'S',
   'TMerchandiseSendWeb', '/merchandise/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_TABELA_PRECO', 'CADASTRO', 'Tabela de preço', 6,
   'TPR_CODIGO', NULL, 'Onda 3 — id local', 'S',
   'TPriceListSendWeb', '/price-list/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PRECO', 'PRECO', 'Preço por tabela/produto', 7,
   'PRC_CODIGO', NULL, 'Onda 3 — 409 se tabela/produto ainda não sincronizados', 'S',
   'TPriceSendWeb', '/price/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_ESTOQUES', 'CADASTRO', 'Lista de estoques (depósitos)', 8,
   'ETS_CODIGO', NULL, 'Onda 3 — id local; ETS_PRINCIPAL vira coluna main', 'S',
   'TStockListSendWeb', '/stock-list/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_ESTOQUE', 'ESTOQUE', 'Saldo de estoque', 9,
   'EST_CODIGO', NULL, 'Onda 3 — achado: alvo real é tb_stock_balance (tabela própria, não tb_stock)', 'S',
   'TStockBalanceSendWeb', '/stock-balance/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PROMOTION', 'CADASTRO', 'Promoção + itens', 10,
   'ID', NULL, 'Onda 3 — items = snapshot (fora da lista = soft delete)', 'S',
   'TPromotionSendWeb', '/promotion/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PLANOCONTAS', 'CADASTRO', 'Plano de contas (árvore única)', 11,
   'PLC_CODIGO', NULL, 'Onda 3 — id local; posit_level recalculado', 'S',
   'TFinancialPlansSendWeb', '/financial-plans/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_FORMAPAGTO', 'CADASTRO', 'Forma de pagamento (catálogo central)', 12,
   'FPT_CODIGO', NULL, 'Onda 3 — idNfce só na criação; attrs do vínculo não sobrescrevem config web', 'S',
   'TPaymentTypeSendWeb', '/payment-type/sincronize')^

/* ---------------------------------------------------------------------
   13-16: PAPÉIS DE ENTIDADE (reindexação por documento/UUID — D3/D4)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CLIENTE', 'CADASTRO', 'Cliente (cadeia central + papel)', 13,
   'CLI_CODEMP', NULL, 'Onda 4 — reindexado por CPF/CNPJ ou externalCode; vendedor/transportador por documento (409 se ausente)', 'S',
   'TCustomerSendWeb', '/customer/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_FORNECEDOR', 'CADASTRO', 'Fornecedor (cadeia central + papel)', 14,
   'FOR_CODEMP', NULL, 'Onda 4 — mesmo CNPJ de um cliente cai na MESMA entity (D3)', 'S',
   'TProviderSendWeb', '/provider/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_COLABORADOR', 'CADASTRO', 'Colaborador/Vendedor (precedência Collaborator->Salesman)', 15,
   'CLB_CODIGO', NULL, 'Onda 4 — grava collaborator SEMPRE + salesman quando o bloco vem', 'S',
   'TSalesManSendWeb', '/salesman/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CONTABANCARIA', 'CADASTRO', 'Conta bancária', 16,
   'CTB_CODIGO', NULL, 'Onda 4 — bankNumber (FEBRABAN) resolvido na central; 409 se banco desconhecido. Corrige bug C1 (payload vazio)', 'S',
   'TBankAccountSendWeb', '/bank-account/sincronize')^

/* ---------------------------------------------------------------------
   17-19: PEDIDOS (mesma tabela de origem, 3 fluxos — KIND diferencia)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PEDIDO', 'PEDIDO_VENDA', 'Pedido de venda completo', 17,
   'PED_CODIGO', NULL, 'Onda 5 — cliente/vendedor por documento (409); tb_user_id fallback = menor usuário do institution (Rodada 4)', 'S',
   'TOrderSaleSendWeb', '/order-sale/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PEDIDO', 'PEDIDO_COMPRA', 'Pedido de compra', 18,
   'PED_CODIGO', NULL, 'Onda 5 — fornecedor por documento (409 PROVIDER_NOT_SYNCED)', 'S',
   'TOrderPurchaseSendWeb', '/order-purchase/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_PEDIDO', 'AJUSTE_ESTOQUE', 'Ajuste de estoque', 19,
   'PED_CODIGO', NULL, 'Onda 5 — entityDocument opcional (ausente = sentinela 0)', 'S',
   'TOrderStockAdjustSendWeb', '/order-stock-adjust/sincronize')^

/* ---------------------------------------------------------------------
   20-22: NOTA FISCAL E ESTOQUE (mesma origem NFL para 20/21)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_NOTA_FISCAL', 'NOTA_AVULSA', 'Nota fiscal avulsa (tipo EM)', 20,
   'NFL_CODIGO', NULL, 'Onda 5 — destinatário por documento; CFOP = id da central (409 se desconhecido)', 'S',
   'TInvoiceSendWeb', '/invoice/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_NOTA_FISCAL', 'NOTA_MERCADORIA', 'Nota fiscal de mercadoria', 21,
   'NFL_CODIGO', NULL, 'Onda 5 — orderId validado mas NÃO persiste vínculo (tb_invoice sem coluna de pedido — Rodada 4)', 'S',
   'TInvoiceMerchandiseSendWeb', '/invoice-merchandise/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CTRL_ESTOQUE', 'MOVIMENTO', 'Movimentação de estoque', 22,
   'CET_CODIGO', NULL, 'Onda 5 — achado: PK física só id AUTO_INCREMENT no destino, pode colidir entre institutions (Rodada 4)', 'S',
   'TStockStatementSendWeb', '/stock-statement/sincronize')^

/* ---------------------------------------------------------------------
   23-25: FINANCEIRO E CAIXA
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_FINANCEIRO', 'FINANCEIRO', 'Título financeiro (formato NOVO 5.5)', 23,
   'FIN_CODIGO', NULL, 'Onda 5 — PK NATURAL no destino (pedido+terminal+parcela); FIN_CODIGO NÃO vira id — semântica de ESPELHO (baixa=evento único N)', 'S',
   'TFinancialSendWeb', '/financial/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_MOVIM_FINANCEIRO', 'FINANCEIRO', 'Movimento financeiro (extrato)', 24,
   'MVF_CODIGO', NULL, 'Onda 5 — id local; conta/histórico ausentes = sentinela 0', 'S',
   'TFinancialStatementSendWeb', '/financial-statement/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CASHIER', 'FINANCEIRO', 'Abertura/fechamento de caixa', 25,
   'ID', NULL, 'Onda 5 — tb_userid fica NULL; items do caixa removidos do contrato (endpoint próprio futuro)', 'S',
   'TCashierSendWeb', '/cashier/sincronize')^

/* ---------------------------------------------------------------------
   26-28: RETORNOS DE NF-e / NFS-e (Onda 6)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_RETORNO_NFE', 'RETORNO_55', 'Retorno de autorização NF-e modelo 55', 26,
   'NFE_CODIGO', NULL, 'Onda 6 — statusCode/fileName; upsert por id+institution+terminal', 'S',
   'TInvoiceReturn55SendWeb', '/invoice-return-55/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_RETORNO_NFC', 'RETORNO_65', 'Retorno de autorização NFC-e modelo 65', 27,
   'NFC_CODIGO', NULL, 'Onda 6', 'S',
   'TInvoiceReturn65SendWeb', '/invoice-return-65/sincronize')^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_RETORNO_NFS', 'RETORNO_NFSE', 'Retorno de autorização NFS-e', 28,
   'NFS_CODNFL', NULL, 'C3: classe estava COMENTADA em uMain.pas (initialization) — reativar (patch 04) antes de ligar SET_ON=S. Endpoint já existe (Onda 6)', 'N',
   'TInvoiceReturnServiceSendWeb', '/invoice-return-service/sincronize')^

/* ---------------------------------------------------------------------
   29: ARQUIVO XML (Onda 6 — disco, não mais banco)
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_ARQUIVOS', 'ARQUIVO', 'XML da nota fiscal (conteúdo completo em Base64)', 29,
   'ARQ_CODIGO', NULL, 'C7: enviar contentBase64 completo (não só metadados). Grava em disco <cnpj>/<ano>/<mes> no servidor (D9/D20)', 'S',
   'TFileSendWeb', '/filexml/sincronize')^

/* ---------------------------------------------------------------------
   30: CARTA DE CORREÇÃO — GAP ENCONTRADO NESTA ONDA 0
   Classe registrada em uMain.pas mas SEM endpoint na setes-sync (não
   estava na ordem de prioridade D8 nem em nenhuma das 6 ondas).
   NÃO ATIVAR — decisão/implementação fica para a Rodada 4.
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_CARTA_CORRECAO', 'RETIFICACAO', 'Carta de Correção Eletrônica (CC-e)', 30,
   'CCE_CODIGO', NULL, 'ACHADO DA ONDA 0: classe existe no Delphi mas o endpoint NÃO foi implementado nas Ondas 1-6 — fica para a Rodada 4 (novo gap, distinto dos 3 já registrados no MAPA_INDEXACAO)', 'N',
   'TInvoiceRectificationSendWeb', '/invoice-rectification/sincronize')^

/* ---------------------------------------------------------------------
   31-37: MÓDULO RESTAURANTE — APOSENTADO (decisão D23)
   Mantidas aqui só para registro histórico/rastreabilidade; a setes-sync
   NÃO tem mais esses endpoints (removidos na Onda 1 — ver HISTORICO/
   endpoints_restaurante_setes_sync.md). NÃO ATIVAR.
   Tabelas de origem não confirmadas no ControllerTrigger.pas — DESC_TABELA
   abaixo é a MELHOR HIPÓTESE pelo nome da classe, não confirmada em código.
   --------------------------------------------------------------------- */

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_GROUP', 'RESTAURANTE', 'Grupo de cardápio', 31,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código (hipótese pelo nome da classe)', 'N',
   'TRestGroupSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_SUBGROUP', 'RESTAURANTE', 'Subgrupo de cardápio', 32,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestSubGroupSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_MENU', 'RESTAURANTE', 'Item de cardápio', 33,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestMenuSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_GROUP_HAS_ATTRIBUTE', 'RESTAURANTE', 'Atributo do grupo', 34,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestGroupHasAttributeSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_GROUP_HAS_MEASURE', 'RESTAURANTE', 'Medida do grupo', 35,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestGroupHasMeasureSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_GROUP_HAS_OPTIONAL', 'RESTAURANTE', 'Opcional do grupo', 36,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestGroupHasOptionalSendWeb', NULL)^

INSERT INTO TB_LISTA_SINCRONIA
  (WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT)
VALUES
  ('E', 'TB_REST_MENU_HAS_INGREDIENTE', 'RESTAURANTE', 'Ingrediente do item', 37,
   NULL, NULL, 'D23 — APOSENTADO. Tabela de origem NÃO confirmada em código', 'N',
   'TRestMenuHasIngredienteSendWeb', NULL)^

SET TERM ; ^

COMMIT;

/* ---------------------------------------------------------------------
   Conferência pós-INSERT
   --------------------------------------------------------------------- */
SELECT COUNT(*) AS TOTAL, SUM(CASE WHEN SET_ON='S' THEN 1 ELSE 0 END) AS ATIVAS
FROM TB_LISTA_SINCRONIA;
-- Esperado: TOTAL=37, ATIVAS=28
--   (12 cadastros + 4 papéis + 3 pedidos + 3 nota/estoque + 3 financeiro/caixa
--    + retorno-55 + retorno-65 + filexml = 28)
--   INATIVAS=9: retorno-NFSe (C3 pendente) + rectification (gap novo,
--   Rodada 4) + 7 do módulo restaurante (D23, aposentado)
