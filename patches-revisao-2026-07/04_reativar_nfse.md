# Patch 04 — uMain.pas: reativar NFS-e (C3) + alerta RunScript (C4)

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
