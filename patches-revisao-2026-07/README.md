# Kit de Patches — Revisão do Sincronizador (2026-07-19)

**Origem**: `Infra-IA/setes-sync/prompt_revisao_sincronizador_setes_sync.md` (24 decisões)
**Contratos que o Delphi deve produzir**: `Infra-IA/setes-sync/CONTRATOS_SYNC.md` (fonte da verdade)
**Indexação por entidade**: `Infra-IA/setes-sync/MAPA_INDEXACAO.md`

⚠️ **Código NÃO compilado** — escrito sem acesso ao Delphi/Firebird. Compilar, ajustar
uses/paths e testar é do Valdo. A setes-sync do outro lado JÁ está pronta e provada
(smokes das Ondas 1–6; ver seção "Como testar" abaixo).

## Ordem de aplicação

| # | Arquivo | Cobre | O quê |
|---|---------|-------|-------|
| 0 | `un_dm.pas` (edição) + `function/un_sincronia_seed.pas` (novo) | Onda 0 | **AUTOMÁTICO**: cria `TB_LISTA_SINCRONIA` se não existir e semeia os 37 registros se estiver vazia — roda sozinho a cada start do Sincronizador (`DataModuleCreate`). Não precisa mais rodar SQL manual por cliente |
| 1 | `01_firebird_ddl.sql` | C10, C12 | `tb_empresa.externalCode` + campo `DELETED` nas tabelas sincronizadas |
| 2 | `02_general_web_patch.md` | C2, C9 | Auth X-Api-Key + envelope novo `{ok,id,externalCode}` + gravação do externalCode |
| 3 | `03_bank_account_fix.md` | C1 | Bug do payload vazio (serializava objeto errado) |
| 4 | `04_reativar_nfse.md` | C3, C4 | RegisterClass da NFS-e + alerta do RunScript |
| 5 | `05_data_objects_guia.md` | C5–C8, C11 | Guia de remodelagem dos data objects (contrato novo, endpoint a endpoint, na ordem D8) |

### Onda 0 — bootstrap automático de TB_LISTA_SINCRONIA (NOVO)

`00_inventario_tb_lista_sincronia.sql` (consulta) e `00b_seed_tb_lista_sincronia.sql`
(INSERT manual) viram **fallback/referência** — o caminho principal agora é automático:

- `un_dm.pas` ganhou `EnsureListaSincroniaTable` (CREATE TABLE se `RDB$RELATIONS` não
  tiver a tabela) e `SeedListaSincroniaIfEmpty` (semeia os 37 registros se `COUNT(*)=0`),
  orquestrados por `EnsureSincronia`, chamada em `DataModuleCreate` logo após conectar
  no banco local — **todo cliente se autoconfigura no primeiro start após o patch**,
  sem precisar rodar SQL manual em cada instalação.
- Os dados do seed vivem em `function/un_sincronia_seed.pas` (novo arquivo — array de
  registros `TSincroniaSeedRow`), a MESMA fonte usada para gerar o `00b_...sql` (mantidas
  em paridade; se editar um, editar o outro).
- ⚠️ **Texto sem acentuação** em `un_sincronia_seed.pas` de propósito: o restante do
  projeto usa encoding ANSI/Windows-1252 (evidência: mojibake em `general_web.pas`),
  e este arquivo evita depender de encoding para compilar em qualquer máquina.
- `DESC_TRIGGER` fica sempre NULL (nenhum nome real de trigger foi encontrado no
  código-fonte) — preencher manualmente se o motor exigir.
- Endpoints que ainda NÃO existem no servidor (NFS-e antes do patch 04, Carta de
  Correção) nascem com `SET_ON='N'` — não ativar antes da Rodada 4/patch aplicado.
- Não precisa mexer no `.dproj`/`.dpr`: `function\` já é pasta de search path do
  projeto (outras units de `function\` são referenciadas sem entrada explícita no
  `.dpr`) — o compilador acha `un_sincronia_seed.pas` sozinho.

## Configuração nova no Sincronizador

- **API key por instalação** (D12): cadastrar a chave no registro do Windows junto com a
  `FPathURL` (seção `SISWEB`, chave nova `FApiKey`). Cada cliente recebe a SUA chave,
  criada em `setes_central.tb_sync_api_key` (a chave resolve institution + schema no
  servidor — **o payload NÃO envia mais tb_institution_id**).
- **URL base**: aponta para a setes-sync (porta 3001). Endpoints novos em
  `TB_LISTA_SINCRONIA.END_POINT` conforme os paths do CONTRATOS_SYNC.md
  (ex.: `/order-sale/sincronize`, `/invoice-return-55/sincronize`).

## Como testar (contra a setes-sync em dev)

1. `cd D:\Gestao2027\setes-sync && npm run dev` (porta 3001)
2. Criar chave de teste: INSERT em `setes_central.tb_sync_api_key`
   (id, api_key, tb_institution_id=1, establishment_code, active='S')
3. Sincronizar UMA entidade por vez na ordem D8 (brand → category → ... → customer...)
4. Conferir: HTTP 200 = `{ok:true, id}`; erro = HTTP <> 200 com `{ok:false, error}`
   → gravar `error` em `TB_SINCRONIA.SRC_LOG` (comportamento já existente)
5. Caso sem documento: response traz `externalCode` → conferir gravação em
   `tb_empresa.externalCode` e REENVIAR o registro → não pode duplicar

## O que o servidor faz agora (mudanças de comportamento relevantes)

- 409 com code `*_NOT_SYNCED` = dependência ainda não sincronizada → o registro
  fica com SRC_LOG e o próprio ciclo de 5 min reenvia (auto-cura da ordem).
- Marca/Embalagem/Medida/Forma de pagamento viajam por DESCRIÇÃO (id local morre).
- Financeiro: PK natural (pedido+terminal+parcela) — FIN_CODIGO não viaja.
- XMLs: conteúdo COMPLETO em Base64 → disco `<cnpj>/<ano>/<mes>/` no servidor.
