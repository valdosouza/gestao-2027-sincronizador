/* =====================================================================
   Revisão do Sincronizador — DDL Firebird 2.5 (decisões D2 e D4/D14)
   C12: tb_empresa.externalCode  ·  C10: DELETED nas tabelas sincronizadas
   Rodar no banco de CADA cliente (Gestao2016) ANTES de ativar o sync novo.
   ⚠️ Não testado em produção — validar em cópia primeiro.
   ===================================================================== */

/* D4/D14 — UUID devolvido pela web para cadastros SEM CPF/CNPJ.
   Gravado pelo Sincronizador ao receber o response {externalCode}.
   36 chars (UUID v4 com hífens). Indexado para o reenvio buscar rápido. */
ALTER TABLE TB_EMPRESA ADD EXTERNALCODE VARCHAR(36);
CREATE INDEX IDX_EMPRESA_EXTERNALCODE ON TB_EMPRESA (EXTERNALCODE);

/* D2 — soft delete: DELETED em cada tabela monitorada pela TB_SINCRONIA.
   O Gestao2016 passa a fazer UPDATE SET DELETED='S' em vez de DELETE;
   o trigger de UPDATE já alimenta a fila normalmente (SRC_OPER='U').
   Char(1) S/N para casar com o payload ("deleted":"S"|"N").
   >>> Ajustar a lista abaixo ao inventário real da TB_LISTA_SINCRONIA
   >>> (passo 0 da implementação — SELECT CLASS_NAME... em produção). */
ALTER TABLE TB_MARCA_PRODUTO  ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_CATEGORY       ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_MEDIDA         ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_EMBALAGEM      ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_PRODUTO        ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_TABELA_PRECO   ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_PRECO          ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_ESTOQUES       ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_ESTOQUE        ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_PROMOCAO       ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_PLANOCONTAS    ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_FORMAPAGTO     ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_CLIENTE        ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_FORNECEDOR     ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_COLABORADOR    ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_CONTABANCARIA  ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_PEDIDO         ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_ITENS_NFL      ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_NOTA_FISCAL    ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_CTRL_ESTOQUE   ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_FINANCEIRO     ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_MOVIM_FINANCEIRO ADD DELETED CHAR(1) DEFAULT 'N';
ALTER TABLE TB_CAIXA          ADD DELETED CHAR(1) DEFAULT 'N';

COMMIT;

/* Depois do ALTER, normalizar nulos (Firebird não aplica default no legado): */
UPDATE TB_MARCA_PRODUTO SET DELETED='N' WHERE DELETED IS NULL;
/* ... repetir para as demais tabelas ... */
COMMIT;
