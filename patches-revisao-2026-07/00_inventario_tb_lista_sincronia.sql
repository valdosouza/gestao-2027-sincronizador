/* =====================================================================
   Onda 0 — Inventário oficial da TB_LISTA_SINCRONIA (decisão D21 do
   prompt_revisao_sincronizador_setes_sync.md)

   Objetivo: fechar a lista REAL de classes/endpoints de sincronização
   configuradas no Firebird de produção, para conferir contra a ordem de
   prioridade D8 (25 classes + retornos NF-e/arquivo) do MAPA_INDEXACAO.md.

   Como rodar:
   - isql:        isql -i 00_inventario_tb_lista_sincronia.sql <alias_ou_caminho_do_banco> -user SYSDBA -password masterkey
   - IBExpert/FlameRobin: abrir e executar cada SELECT (aba de resultados)

   Cole de volta pra mim a saída dos DOIS selects abaixo (ou só o segundo,
   que já vem em uma linha por registro — mais fácil de copiar do console).
   ===================================================================== */

/* 1) Consulta normal — colunas separadas (melhor se o console tiver grid) */
SELECT
  CLASS_NAME,
  DESC_TABELA,
  END_POINT,
  WAY,        -- 'E' = Enviar (Firebird → web) / 'R' = Receber (web → Firebird)
  ATIVO,
  SET_ON
FROM TB_LISTA_SINCRONIA
ORDER BY CLASS_NAME;

/* 2) Mesma consulta em UMA LINHA POR REGISTRO — pipe-delimited, fácil de
      colar em texto puro (console sem grid, terminal, etc.) */
SELECT
  CLASS_NAME || ' | ' ||
  COALESCE(DESC_TABELA, '')  || ' | ' ||
  COALESCE(END_POINT, '')    || ' | ' ||
  COALESCE(WAY, '')          || ' | ' ||
  COALESCE(ATIVO, '')        || ' | ' ||
  COALESCE(SET_ON, '')       AS LINHA
FROM TB_LISTA_SINCRONIA
ORDER BY CLASS_NAME;

/* 3) Só as ATIVAS no sentido de envio (o que realmente roda hoje) —
      caso queira conferir rapidamente sem ruído das inativas/recebimento */
SELECT
  CLASS_NAME || ' -> ' || END_POINT AS ATIVAS_ENVIO
FROM TB_LISTA_SINCRONIA
WHERE SET_ON = 'S' AND WAY = 'E'
ORDER BY CLASS_NAME;

/* 4) Contagem total — confere contra "36 classes" da análise de 2026-05-31
      e as "25 + retornos/arquivo" da ordem de prioridade D8 */
SELECT COUNT(*) AS TOTAL_CLASSES,
       SUM(CASE WHEN SET_ON = 'S' THEN 1 ELSE 0 END) AS TOTAL_ATIVAS,
       SUM(CASE WHEN WAY = 'E' THEN 1 ELSE 0 END) AS TOTAL_ENVIO,
       SUM(CASE WHEN WAY = 'R' THEN 1 ELSE 0 END) AS TOTAL_RECEBIMENTO
FROM TB_LISTA_SINCRONIA;
