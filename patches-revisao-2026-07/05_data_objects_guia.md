# Patch 05 — Guia de remodelagem dos data objects (C11, cobre também C5–C8)

**Decisão D15/D22**: o Delphi monta o JSON JÁ NO FORMATO do servidor — "o sistema
que será aposentado se adapta ao formato novo, nunca o contrário". A especificação
de CADA payload é o `Infra-IA/setes-sync/CONTRATOS_SYNC.md` (fonte da verdade,
mantido em par com o Swagger em http://localhost:3001/docs).

## Regras transversais (valem para TODAS as classes)

1. **`tb_institution_id` NÃO viaja** — a API key resolve institution+schema (D12).
2. **`deleted`** ('S'/'N') em todo payload — ler o campo novo do Firebird (patch 01).
3. **camelCase** exato do contrato; datas `YYYY-MM-DD`; CPF/CNPJ/CEP/fones SEM máscara.
4. **Referências a entidades por DOCUMENTO** (D3): onde o legado mandava código local
   (vendedor, cliente, transportador, fornecedor), o data object novo envia o
   CPF/CNPJ lido da TB_EMPRESA local (`salesmanDocument`, `customerDocument`...).
5. **Sem documento** (D4): enviar `externalCode` = TB_EMPRESA.EXTERNALCODE quando
   preenchido; vazio = primeiro envio (a web devolve o UUID e o patch 02 grava).
6. **Marca/Embalagem/Medida/Forma de pagamento por DESCRIÇÃO** (D5): `nameBrand`,
   `namePackage`, `nameMeasure`, `paymentTypeDescription` — os ids locais morrem.
7. **Validação de CPF/CNPJ reativada** (C6): o servidor REJEITA dígito verificador
   inválido (400) — reativar a validação comentada em customer/provider_send_web
   evita ciclos de erro; documento inválido no legado → enviar como `personType:'N'`
   (sem documento) para não perder o histórico.
8. **Celular do colaborador** (C5): no contrato novo os fones são a lista `phones`
   com `kind` distinto — enviar DOIS itens: `{kind:'FONE', number: CLB_FONE}` e
   `{kind:'CELULAR', number: CLB_CELULAR}` (corrige o bug do Registro.Fone duplicado).
9. **Package active fixo** (C8): o contrato novo tem `deleted` — enviar o real.
10. **XML completo** (C7): `/filexml` agora recebe `contentBase64` com o CONTEÚDO —
    descomentar a leitura do blob e enviar Base64 + `dtReference` (data de emissão).

## Ordem de conversão = prioridade D8

1–12 cadastros (brand→paymenttype) · 13–15 entidades (customer/provider/salesman)
· 16 bank-account · 17–25 movimento · retornos 55/65/NFS-e + filexml.

## Exemplo 1 — o mais simples (TBrandSendWeb)

```pascal
procedure TBrandSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('deleted', IfThen(FCtrl.Registro.Deleted = 'S', 'S', 'N'));
      FStrJSon := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;
```
> Endpoint: `/brand/sincronize`. Repare: SEM id, SEM institution — só descrição.
> Measure/Package idênticos (+ abbreviation/escale).

## Exemplo 2 — entidade completa (TCustomerSendWeb)

Estrutura do JSON (ver seção "Bloco entity" + "/customer/sincronize" no CONTRATOS_SYNC.md):

```
{ entity:{nameCompany, nickTrade, aniversary},
  personType: 'F'|'J'|'N',
  person:{cpf,...} | company:{cnpj,...},        // XOR pelo personType
  externalCode: TB_EMPRESA.EXTERNALCODE,        // só quando preenchido
  addresses:[{kind,street,nmbr,neighborhood,zipCode,tbCountryId,tbStateId,tbCityId,main}],
  phones:[{kind:'FONE',number},{kind:'CELULAR',number}],
  mailings:[{email, groupId:1}],
  customer:{salesmanDocument, carrierDocument, creditStatus, creditValue,
            paymentTypeDescription, multiplier, active},
  entityTax:{consumer, byPassSt, indIeDest, issExigibilidade, issProcessNr,
             issRetido, issIndIncFiscal, autoSendInvoice, autoSendInvoiceJustXml},
  deleted:'N' }
```

Mapeamento dos campos que o legado NÃO enviava e agora têm casa:
`CLI_ENVEMAILAUT → entityTax.autoSendInvoice` · `CLI_ENVSOMENTEXML → entityTax.autoSendInvoiceJustXml`
`CLI_INDIEDEST → entityTax.indIeDest` · ISS_* → entityTax.iss*.
`EMP_VENDEMC > 0 → paymentTypeDescription:'CARTEIRA'`.

## Respostas 409 são NORMAIS durante a carga

`*_NOT_SYNCED` = dependência ainda não chegou (ex.: cliente antes do vendedor).
O registro fica com SRC_LOG e o ciclo de 5 min reenvia — a ordem se cura sozinha.
Não tratar como erro fatal.
