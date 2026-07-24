unit bank_account_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerContaBancaria,ObjBankAccount,
     System.JSON;

Type
  TBankAccountSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerContaBancaria;
      function DateToIso(pData: TDateTime): String;
      function OnlyDigits(pTexto: String): String;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses UnFunctions, un_dm;

{ TGeneralWeb }

constructor TBankAccountSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerContaBancaria.Create(nil);
end;

destructor TBankAccountSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

function TBankAccountSendWeb.OnlyDigits(pTexto: String): String;
begin
  Result := unMaskField(Trim(pTexto));
end;

function TBankAccountSendWeb.DateToIso(pData: TDateTime): String;
begin
  if pData <= 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', pData);
end;

procedure TBankAccountSendWeb.GenerateJson;
Var
  LcJson      : TJSONObject;
  LcBankNumber: String;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // BUG C1 (confirmado): a versão antiga criava um TObjBankAccount NOVO e
    // vazio (LcObj) e serializava ELE em vez do FCtrl.Obj que FillDataObjects
    // preenchia — o payload saía sempre vazio. Aqui o JSON é montado direto
    // a partir de FCtrl.Registro (o registro real lido do Firebird), então
    // o bug desaparece por construção — não existe mais objeto substituto.
    LcBankNumber := FCtrl.getNumeroBanco;

    LcJson := TJSONObject.Create;
    Try
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('bankNumber', LcBankNumber);
      if DateToIso(FCtrl.Registro.DataAbertura) <> '' then
        LcJson.AddPair('dtOpening', DateToIso(FCtrl.Registro.DataAbertura))
      else
        LcJson.AddPair('dtOpening', TJSONNull.Create);
      LcJson.AddPair('agency', FCtrl.Registro.Agencia);
      LcJson.AddPair('agencyDv', FCtrl.Registro.DigitoAgencia);
      LcJson.AddPair('number', FCtrl.Registro.Conta);
      LcJson.AddPair('numberDv', FCtrl.Registro.DigitoContaCorrente);
      LcJson.AddPair('phone', OnlyDigits(FCtrl.Registro.Fone));
      LcJson.AddPair('manager', FCtrl.Registro.Gerente);
      LcJson.AddPair('limitValue', TJSONNumber.Create(FCtrl.Registro.ValorLimite));
      if DateToIso(FCtrl.Registro.DataVencto) <> '' then
        LcJson.AddPair('dtContract', DateToIso(FCtrl.Registro.DataVencto))
      else
        LcJson.AddPair('dtContract', TJSONNull.Create);

      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_CONTABANCARIA', 'CTB_CODIGO', FCodigo));

      FStrJSon := LcJson.ToJSON;
    Finally
      LcJson.Free;
    End;
  End;

end;


end.
