unit un_sincronia_seed;

{ =====================================================================
  Catalogo de seed da TB_LISTA_SINCRONIA (Onda 0 da revisao do sync).

  Fonte dos dados: uMain.pas (RegisterClass) + controller/
  ControllerTrigger.pas (tabelas/campos confirmados no codigo) +
  Infra-IA/setes-sync/CONTRATOS_SYNC.md (endpoints que existem hoje na
  setes-sync, pos Ondas 1-6). Modulo restaurante (7 linhas TB_REST_*)
  REMOVIDO do catalogo em 2026-07-26 (Valdo) - Seqs 31-37 reservados.

  WAY: 'E' = Enviar (local -> web/retaguarda), 'R' = Receber (web ->
  local, fase futura D16) - convencao do motor (ControllerListaSincronia:
  getListaEnviar WHERE WAY='E' / getListaReceber WHERE WAY='R').

  Texto SEM acentuacao de proposito: o restante do projeto usa encoding
  ANSI/Windows-1252 (ver mojibake em general_web.pas) e este arquivo
  evita depender de encoding para compilar em qualquer maquina.

  DESC_TRIGGER fica sempre vazio (NULL) - nenhum nome real de trigger
  foi encontrado no codigo-fonte do Sincronizador; preencher a mao se
  o motor de fato exigir o nome (ver MAPA_INDEXACAO.md).
  ===================================================================== }

interface

type
  TSincroniaSeedRow = record
    Seq:         Integer;
    Way:         String;
    DescTabela:  String;
    Kind:        String;
    DescProcess: String;
    DescField:   String;  // '' = NULL (nenhum campo-chave confirmado)
    Note:        String;
    SetOn:       String;  // 'S' ou 'N'
    ClassName:   String;
    EndPoint:    String;  // '' = NULL (endpoint ainda nao existe)
  end;

const
  SINCRONIA_SEED: array[0..31] of TSincroniaSeedRow = (
    // ---- 1-12: cadastros (ordem de prioridade D8) ----
    (Seq: 1;  Way: 'E'; DescTabela: 'TB_MARCA_PRODUTO'; Kind: 'CADASTRO';
     DescProcess: 'Marca de produto (catalogo central)'; DescField: 'MRC_CODIGO';
     Note: 'Onda 3 - dedupe por descricao na setes_central (D5/D17)';
     SetOn: 'S'; ClassName: 'TBrandSendWeb'; EndPoint: '/brand/sincronize'),

    (Seq: 2;  Way: 'E'; DescTabela: 'TB_CATEGORY'; Kind: 'CADASTRO';
     DescProcess: 'Categoria de produto/servico (arvore)'; DescField: 'ID';
     Note: 'Onda 3 - id local, posit_level recalculado no servidor';
     SetOn: 'S'; ClassName: 'TCategorySendWeb'; EndPoint: '/category/sincronize'),

    (Seq: 3;  Way: 'E'; DescTabela: 'TB_MEDIDA'; Kind: 'CADASTRO';
     DescProcess: 'Unidade de medida (catalogo central)'; DescField: 'MED_CODIGO';
     Note: 'Onda 3 - endpoint NOVO (nao existia na setes-sync)';
     SetOn: 'S'; ClassName: 'TMeasureSendWeb'; EndPoint: '/measure/sincronize'),

    (Seq: 4;  Way: 'E'; DescTabela: 'TB_EMBALAGEM'; Kind: 'CADASTRO';
     DescProcess: 'Embalagem (catalogo central)'; DescField: 'EMB_CODIGO';
     Note: 'Onda 3 - dedupe por descricao';
     SetOn: 'S'; ClassName: 'TPackageSendWeb'; EndPoint: '/package/sincronize'),

    (Seq: 5;  Way: 'E'; DescTabela: 'TB_PRODUTO'; Kind: 'CADASTRO';
     DescProcess: 'Produto (product+merchandise+stock)'; DescField: 'PRO_CODIGO';
     Note: 'Onda 3 - id local; brand/package/measure por descricao; categoria por id (409 se ausente)';
     SetOn: 'S'; ClassName: 'TMerchandiseSendWeb'; EndPoint: '/merchandise/sincronize'),

    (Seq: 6;  Way: 'E'; DescTabela: 'TB_TABELA_PRECO'; Kind: 'CADASTRO';
     DescProcess: 'Tabela de preco'; DescField: 'TPR_CODIGO';
     Note: 'Onda 3 - id local';
     SetOn: 'S'; ClassName: 'TPriceListSendWeb'; EndPoint: '/price-list/sincronize'),

    (Seq: 7;  Way: 'E'; DescTabela: 'TB_PRECO'; Kind: 'PRECO';
     DescProcess: 'Preco por tabela/produto'; DescField: 'PRC_CODIGO';
     Note: 'Onda 3 - 409 se tabela/produto ainda nao sincronizados';
     SetOn: 'S'; ClassName: 'TPriceSendWeb'; EndPoint: '/price/sincronize'),

    (Seq: 8;  Way: 'E'; DescTabela: 'TB_ESTOQUES'; Kind: 'CADASTRO';
     DescProcess: 'Lista de estoques (depositos)'; DescField: 'ETS_CODIGO';
     Note: 'Onda 3 - id local; ETS_PRINCIPAL vira coluna main';
     SetOn: 'S'; ClassName: 'TStockListSendWeb'; EndPoint: '/stock-list/sincronize'),

    (Seq: 9;  Way: 'E'; DescTabela: 'TB_ESTOQUE'; Kind: 'ESTOQUE';
     DescProcess: 'Saldo de estoque'; DescField: 'EST_CODIGO';
     Note: 'Onda 3 - achado: alvo real e tb_stock_balance (tabela propria, nao tb_stock)';
     SetOn: 'S'; ClassName: 'TStockBalanceSendWeb'; EndPoint: '/stock-balance/sincronize'),

    (Seq: 10; Way: 'E'; DescTabela: 'TB_PROMOTION'; Kind: 'CADASTRO';
     DescProcess: 'Promocao + itens'; DescField: 'ID';
     Note: 'Onda 3 - items = snapshot (fora da lista = soft delete)';
     SetOn: 'S'; ClassName: 'TPromotionSendWeb'; EndPoint: '/promotion/sincronize'),

    (Seq: 11; Way: 'E'; DescTabela: 'TB_PLANOCONTAS'; Kind: 'CADASTRO';
     DescProcess: 'Plano de contas (arvore unica)'; DescField: 'PLC_CODIGO';
     Note: 'Onda 3 - id local; posit_level recalculado';
     SetOn: 'S'; ClassName: 'TFinancialPlansSendWeb'; EndPoint: '/financial-plans/sincronize'),

    (Seq: 12; Way: 'E'; DescTabela: 'TB_FORMAPAGTO'; Kind: 'CADASTRO';
     DescProcess: 'Forma de pagamento (catalogo central)'; DescField: 'FPT_CODIGO';
     Note: 'Onda 3 - idNfce so na criacao; attrs do vinculo nao sobrescrevem config web';
     SetOn: 'S'; ClassName: 'TPaymentTypeSendWeb'; EndPoint: '/payment-type/sincronize'),

    // ---- 13-16: papeis de entidade (reindexacao por documento/UUID) ----
    (Seq: 13; Way: 'E'; DescTabela: 'TB_CLIENTE'; Kind: 'CADASTRO';
     DescProcess: 'Cliente (cadeia central + papel)'; DescField: 'CLI_CODEMP';
     Note: 'Onda 4 - reindexado por CPF/CNPJ ou externalCode; vendedor/transportador por documento (409 se ausente)';
     SetOn: 'S'; ClassName: 'TCustomerSendWeb'; EndPoint: '/customer/sincronize'),

    (Seq: 14; Way: 'E'; DescTabela: 'TB_FORNECEDOR'; Kind: 'CADASTRO';
     DescProcess: 'Fornecedor (cadeia central + papel)'; DescField: 'FOR_CODEMP';
     Note: 'Onda 4 - mesmo CNPJ de um cliente cai na MESMA entity (D3)';
     SetOn: 'S'; ClassName: 'TProviderSendWeb'; EndPoint: '/provider/sincronize'),

    (Seq: 15; Way: 'E'; DescTabela: 'TB_COLABORADOR'; Kind: 'CADASTRO';
     DescProcess: 'Colaborador/Vendedor (precedencia Collaborator->Salesman)'; DescField: 'CLB_CODIGO';
     Note: 'Onda 4 - grava collaborator SEMPRE + salesman quando o bloco vem';
     SetOn: 'S'; ClassName: 'TSalesManSendWeb'; EndPoint: '/salesman/sincronize'),

    (Seq: 16; Way: 'E'; DescTabela: 'TB_CONTABANCARIA'; Kind: 'CADASTRO';
     DescProcess: 'Conta bancaria'; DescField: 'CTB_CODIGO';
     Note: 'Onda 4 - bankNumber (FEBRABAN) resolvido na central; 409 se banco desconhecido. Corrige bug C1 (payload vazio)';
     SetOn: 'S'; ClassName: 'TBankAccountSendWeb'; EndPoint: '/bank-account/sincronize'),

    // ---- 17-19: pedidos (mesma origem, 3 fluxos - KIND diferencia) ----
    (Seq: 17; Way: 'E'; DescTabela: 'TB_PEDIDO'; Kind: 'PEDIDO_VENDA';
     DescProcess: 'Pedido de venda completo'; DescField: 'PED_CODIGO';
     Note: 'Onda 5 - cliente/vendedor por documento (409); tb_user_id fallback = menor usuario do institution (Rodada 4)';
     SetOn: 'S'; ClassName: 'TOrderSaleSendWeb'; EndPoint: '/order-sale/sincronize'),

    (Seq: 18; Way: 'E'; DescTabela: 'TB_PEDIDO'; Kind: 'PEDIDO_COMPRA';
     DescProcess: 'Pedido de compra'; DescField: 'PED_CODIGO';
     Note: 'Onda 5 - fornecedor por documento (409 PROVIDER_NOT_SYNCED)';
     SetOn: 'S'; ClassName: 'TOrderPurchaseSendWeb'; EndPoint: '/order-purchase/sincronize'),

    (Seq: 19; Way: 'E'; DescTabela: 'TB_PEDIDO'; Kind: 'AJUSTE_ESTOQUE';
     DescProcess: 'Ajuste de estoque'; DescField: 'PED_CODIGO';
     Note: 'Onda 5 - entityDocument opcional (ausente = sentinela 0)';
     SetOn: 'S'; ClassName: 'TOrderStockAdjustSendWeb'; EndPoint: '/order-stock-adjust/sincronize'),

    // ---- 20-22: nota fiscal e estoque ----
    (Seq: 20; Way: 'E'; DescTabela: 'TB_NOTA_FISCAL'; Kind: 'NOTA_AVULSA';
     DescProcess: 'Nota fiscal avulsa (tipo EM)'; DescField: 'NFL_CODIGO';
     Note: 'Onda 5 - destinatario por documento; CFOP = id da central (409 se desconhecido)';
     SetOn: 'S'; ClassName: 'TInvoiceSendWeb'; EndPoint: '/invoice/sincronize'),

    (Seq: 21; Way: 'E'; DescTabela: 'TB_NOTA_FISCAL'; Kind: 'NOTA_MERCADORIA';
     DescProcess: 'Nota fiscal de mercadoria'; DescField: 'NFL_CODIGO';
     Note: 'Onda 5 - orderId validado mas NAO persiste vinculo (tb_invoice sem coluna de pedido - Rodada 4)';
     SetOn: 'S'; ClassName: 'TInvoiceMerchandiseSendWeb'; EndPoint: '/invoice-merchandise/sincronize'),

    (Seq: 22; Way: 'E'; DescTabela: 'TB_CTRL_ESTOQUE'; Kind: 'MOVIMENTO';
     DescProcess: 'Movimentacao de estoque'; DescField: 'CET_CODIGO';
     Note: 'Onda 5 - achado: PK fisica so id AUTO_INCREMENT no destino, pode colidir entre institutions (Rodada 4)';
     SetOn: 'S'; ClassName: 'TStockStatementSendWeb'; EndPoint: '/stock-statement/sincronize'),

    // ---- 23-25: financeiro e caixa ----
    (Seq: 23; Way: 'E'; DescTabela: 'TB_FINANCEIRO'; Kind: 'FINANCEIRO';
     DescProcess: 'Titulo financeiro (formato NOVO 5.5)'; DescField: 'FIN_CODIGO';
     Note: 'Onda 5 - PK NATURAL no destino (pedido+terminal+parcela); FIN_CODIGO NAO vira id - semantica de ESPELHO (baixa=evento unico N)';
     SetOn: 'S'; ClassName: 'TFinancialSendWeb'; EndPoint: '/financial/sincronize'),

    (Seq: 24; Way: 'E'; DescTabela: 'TB_MOVIM_FINANCEIRO'; Kind: 'FINANCEIRO';
     DescProcess: 'Movimento financeiro (extrato)'; DescField: 'MVF_CODIGO';
     Note: 'Onda 5 - id local; conta/historico ausentes = sentinela 0';
     SetOn: 'S'; ClassName: 'TFinancialStatementSendWeb'; EndPoint: '/financial-statement/sincronize'),

    (Seq: 25; Way: 'E'; DescTabela: 'TB_CASHIER'; Kind: 'FINANCEIRO';
     DescProcess: 'Abertura/fechamento de caixa'; DescField: 'ID';
     Note: 'Onda 5 - tb_userid fica NULL; items do caixa removidos do contrato (endpoint proprio futuro)';
     SetOn: 'S'; ClassName: 'TCashierSendWeb'; EndPoint: '/cashier/sincronize'),

    // ---- 26-28: retornos de NF-e / NFS-e ----
    (Seq: 26; Way: 'E'; DescTabela: 'TB_RETORNO_NFE'; Kind: 'RETORNO_55';
     DescProcess: 'Retorno de autorizacao NF-e modelo 55'; DescField: 'NFE_CODIGO';
     Note: 'Onda 6 - statusCode/fileName; upsert por id+institution+terminal';
     SetOn: 'S'; ClassName: 'TInvoiceReturn55SendWeb'; EndPoint: '/invoice-return-55/sincronize'),

    (Seq: 27; Way: 'E'; DescTabela: 'TB_RETORNO_NFC'; Kind: 'RETORNO_65';
     DescProcess: 'Retorno de autorizacao NFC-e modelo 65'; DescField: 'NFC_CODIGO';
     Note: 'Onda 6';
     SetOn: 'S'; ClassName: 'TInvoiceReturn65SendWeb'; EndPoint: '/invoice-return-65/sincronize'),

    (Seq: 28; Way: 'E'; DescTabela: 'TB_RETORNO_NFS'; Kind: 'RETORNO_NFSE';
     DescProcess: 'Retorno de autorizacao NFS-e'; DescField: 'NFS_CODNFL';
     Note: 'Patch 04 (C3) APLICADO 2026-07-25: classe criada (invoice_return_service_send_web.pas + ControllerRetornoNFS, molde 55/65) e registrada no uMain. Endpoint Onda 6';
     SetOn: 'S'; ClassName: 'TInvoiceReturnServiceSendWeb'; EndPoint: '/invoice-return-service/sincronize'),

    // ---- 29: arquivo XML (disco, nao mais banco) ----
    (Seq: 29; Way: 'E'; DescTabela: 'TB_ARQUIVOS'; Kind: 'ARQUIVO';
     DescProcess: 'XML da nota fiscal (conteudo completo em Base64)'; DescField: 'ARQ_CODIGO';
     Note: 'C7: enviar contentBase64 completo (nao so metadados). Grava em disco <cnpj>/<ano>/<mes> no servidor (D9/D20)';
     SetOn: 'S'; ClassName: 'TFileSendWeb'; EndPoint: '/filexml/sincronize'),

    // ---- 30: carta de correcao - GAP encontrado na Onda 0, NAO ATIVAR ----
    (Seq: 30; Way: 'E'; DescTabela: 'TB_CARTA_CORRECAO'; Kind: 'RETIFICACAO';
     DescProcess: 'Carta de Correcao Eletronica (CC-e)'; DescField: 'CCE_CODIGO';
     Note: 'ACHADO DA ONDA 0: classe existe no Delphi mas o endpoint NAO foi implementado nas Ondas 1-6 - fica para a Rodada 4';
     SetOn: 'N'; ClassName: 'TInvoiceRectificationSendWeb'; EndPoint: '/invoice-rectification/sincronize'),

    // ---- 31-37: modulo restaurante (D23) - REMOVIDO DO SEED (Valdo,
    // 2026-07-26): as 7 linhas TB_REST_* nao serao utilizadas; alem de nao
    // semear, o bootstrap DELETA as linhas de bancos ja semeados
    // (un_dm.SeedListaSincroniaIfEmpty). Seqs 31-37 ficam RESERVADOS.

    // ---- 38: transportadora (decisao 4 da revisao de entidades 2026-07-25) ----
    (Seq: 38; Way: 'E'; DescTabela: 'TB_TRANSPORTADORA'; Kind: 'CADASTRO';
     DescProcess: 'Transportadora (cadeia central + papel)'; DescField: 'TRP_CODEMP';
     Note: 'Decisao 4 (2026-07-25) - fecha o 409 CARRIER_NOT_SYNCED eterno do customer; sincronizar ANTES do cliente';
     SetOn: 'S'; ClassName: 'TCarrierSendWeb'; EndPoint: '/carrier/sincronize'),

    // ---- 39: usuario/autor (prompt_indexacao_usuario_firebird.md 2026-07-26) ----
    (Seq: 39; Way: 'E'; DescTabela: 'TB_USUARIO'; Kind: 'CADASTRO';
     DescProcess: 'Usuario do sistema (autor das operacoes)'; DescField: 'USU_CODIGO';
     Note: 'Decisoes 1-3 (2026-07-26) - entity + tb_user sem credencial; cascata colaborador->externalCode; perfil PDV desliga (decisao 8)';
     SetOn: 'S'; ClassName: 'TUserSendWeb'; EndPoint: '/user/sincronize')
  );

implementation

end.
