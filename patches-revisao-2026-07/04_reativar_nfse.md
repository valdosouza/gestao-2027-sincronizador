# Patch 04 — uMain.pas: reativar NFS-e (C3) + alerta RunScript (C4)

> ## ✅ APLICADO em 2026-07-25 (Claude Code + decisões do Valdo)
>
> **C3** era maior que descomentar: a classe `TInvoiceReturnServiceSendWeb` NÃO existia.
> Criados `classes/invoice_return_service_send_web.pas` (molde 55/65, contrato Onda 6:
> nrRps/nrLot/statusCode inteiros, payload flat) e `origen/controller/ControllerRetornoNFS.pas`
> (mínimo: Clear + getSincronia sobre TB_RETORNO_NFS por NFS_CODNFL; model `tblRetornoNFS.pas`
> já existia). uMain: uses + RegisterClass/UnRegisterClass reativados. Seed: Seq 28 → SET_ON='S'.
> ⚠️ Bancos JÁ semeados (o seed só roda com a tabela vazia) precisam de:
> `UPDATE TB_LISTA_SINCRONIA SET SET_ON='S' WHERE CLASS_NAME='TInvoiceReturnServiceSendWeb';`
> (a trigger TG_SRC_RETORNO_NFS nasce sozinha no start seguinte, via EnsureTriggers).
>
> **C4 (decisão do Valdo)**: o RunScript atual recebia o Script mas não chamava ExecSQL —
> nenhum chamador jamais executou. Corrigido com `ExecSQL` (os UPDATEs de tb_medida voltam
> a valer); as constraints PK/FK da TB_CRP_ITENS foram MARCADAS COMO MORTAS (comentadas —
> módulo restaurante aposentado D23; criar PK em dados sujos quebraria o Preparar Local).
>
> Pendente: Valdo compilar + teste ponta a ponta NFS-e (TB_RETORNO_NFS → /invoice-return-service).

## C3 — TInvoiceReturnServiceSendWeb comentada

No `initialization` do `uMain.pas`:

```pascal
// ANTES:
//RegisterClass(TInvoiceReturnServiceSendWeb);
// DEPOIS:
RegisterClass(TInvoiceReturnServiceSendWeb);
```

E cadastrar na `TB_LISTA_SINCRONIA`:
`CLASS_NAME='TInvoiceReturnServiceSendWeb'`, `END_POINT='/invoice-return-service/sincronize'`,
sentido 'E', ativo 'S'.

O endpoint do servidor JÁ EXISTE (Onda 6) — contrato em CONTRATOS_SYNC.md
(`nrRps`/`nrLot`/`statusCode` são INTEIROS; `fileName` liga ao XML do /filexml).

Endpoints irmãos (cadastrar também):
- `/invoice-return-55/sincronize` (retorno NF-e modelo 55)
- `/invoice-return-65/sincronize` (retorno NFC-e modelo 65)

## C4 — RunScript ignora o parâmetro

`uMain.pas`: `RunScript(Script: String)` descarta o parâmetro e SEMPRE executa
um UPDATE hardcoded em `TB_CRP_ITENS`. Todos os chamadores passam scripts que
nunca rodam. Corrigir para executar o `Script` recebido — ou, se o método for
morto, removê-lo e os chamadores. **Decisão do Valdo na revisão do código**
(pode haver efeito colateral intencional escondido).
