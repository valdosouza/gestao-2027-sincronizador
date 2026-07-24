# Patch 03 — bank_account_send_web.pas: payload vazio (C1)

**Bug** (`classes/bank_account_send_web.pas:34-52`): `GenerateJson` preenche
`FCtrl.Obj` via `FillDataObjects`, mas serializa `LcObj` — uma variável local
recém-criada, VAZIA (só Estabelecimento/Terminal chegavam à API). Além disso
`LcObj` vaza (nunca é liberada).

**Correção mínima** (mantém o data object atual até a remodelagem C11):

```pascal
procedure TBankAccountSendWeb.GenerateJson;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj);
    FCtrl.Obj.Terminal := FTerminal;   // institution NÃO viaja mais (D12)
    FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
  End;
end;
```

**Correção definitiva (C11)**: remodelar para o contrato novo do
`/bank-account/sincronize` (CONTRATOS_SYNC.md — Onda 4):

```jsonc
{ "id": 3, "terminal": 0, "bankNumber": "001", "dtOpening": "2020-01-15",
  "agency": "1234", "agencyDv": "5", "number": "98765", "numberDv": "0",
  "phone": "6233330000", "manager": "FULANO", "limitValue": 50000,
  "dtContract": "2025-01-01", "deleted": "N" }
```

`bankNumber` = `getNumeroBanco(CTB_CODBCO)` que o controller JÁ calcula
(número FEBRABAN); o servidor resolve o banco na central (409 se não existir).
