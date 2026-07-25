unit carrier_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerTransportadora, System.JSON;

Type
  // Decisao 4 da revisao de entidades (2026-07-25): sem esta classe a
  // transportadora nunca era sincronizada e o /customer com carrierDocument
  // ficava em 409 CARRIER_NOT_SYNCED eterno. Molde do provider_send_web:
  // TB_TRANSPORTADORA especializa TB_EMPRESA (TRP_CODEMP = EMP_CODIGO).
  TCarrierSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerTransportadora;
      function GetExternalCodeEmpresa: String;
      function DateToIso(pData: TDate): String;
      function OnlyDigits(pTexto: String): String;
    protected
      procedure GenerateJson;Override;
    public
      constructor Create;override;
      destructor Destroy;override;
  end;

implementation

uses

  unFunctions, IBX.IBQuery, un_dm;


{ TCarrierSendWeb }

constructor TCarrierSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerTransportadora.Create(nil);
end;


destructor TCarrierSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

function TCarrierSendWeb.OnlyDigits(pTexto: String): String;
begin
  Result := unMaskField(Trim(pTexto));
end;

function TCarrierSendWeb.DateToIso(pData: TDate): String;
begin
  if pData <= 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', pData);
end;

// Le TB_EMPRESA.EXTERNALCODE diretamente (coluna do bootstrap - D4/D14).
// FCodigo = TRP_CODEMP = EMP_CODIGO (mesma PK da empresa).
function TCarrierSendWeb.GetExternalCodeEmpresa: String;
Var
  Lc_Qry : TIBQuery;
begin
  Result := '';
  Lc_Qry := FCtrl.Fornecedor.Empresa.GeraQuery;
  Try
    with Lc_Qry do
    Begin
      Active := False;
      Sql.Clear;
      Sql.Add('SELECT EXTERNALCODE FROM TB_EMPRESA WHERE EMP_CODIGO = :EMP_CODIGO');
      ParamByName('EMP_CODIGO').AsInteger := FCodigo;
      Active := True;
      FetchAll;
      if (RecordCount > 0) then
        Result := Trim(FieldByName('EXTERNALCODE').AsString);
    end;
  Finally
    FCtrl.Fornecedor.Empresa.FinalizaQuery(Lc_Qry);
  End;
end;

procedure TCarrierSendWeb.GenerateJson;
Var
  LcJson         : TJSONObject;
  LcEntity       : TJSONObject;
  LcCarrier      : TJSONObject;
  LcAddresses    : TJSONArray;
  LcAddress      : TJSONObject;
  LcPhones       : TJSONArray;
  LcPhone        : TJSONObject;
  LcMailings     : TJSONArray;
  LcMailing      : TJSONObject;
  LcDoc          : String;
  LcPersonType   : String;
  LcExternalCode : String;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getById;
  if FCtrl.exist then
  Begin
    FCtrl.Fornecedor.Empresa.Registro.Codigo := FCodigo;
    FCtrl.Fornecedor.Empresa.getAllBykey;
    Begin
      LcJson := TJSONObject.Create;
      Try
        LcDoc := OnlyDigits(FCtrl.Fornecedor.Empresa.Registro.CpfCNPJ);
        // decisao 2 da revisao de entidades: branco/sentinela/INVALIDO -> 'N'
        // (fluxo externalCode) — validacao de digito verificador reativada
        LcPersonType := DerivePersonType(LcDoc);

        LcEntity := TJSONObject.Create;
        LcEntity.AddPair('nameCompany', FCtrl.Fornecedor.Empresa.Registro.NomeRazaoSocial);
        LcEntity.AddPair('nickTrade',   FCtrl.Fornecedor.Empresa.Registro.ApelidoFantasia);
        if DateToIso(FCtrl.Fornecedor.Empresa.Registro.DataFundacao) <> '' then
          LcEntity.AddPair('aniversary', DateToIso(FCtrl.Fornecedor.Empresa.Registro.DataFundacao))
        else
          LcEntity.AddPair('aniversary', TJSONNull.Create);
        LcJson.AddPair('entity', LcEntity);

        LcJson.AddPair('personType', LcPersonType);

        if LcPersonType = 'F' then
        Begin
          LcJson.AddPair('person', TJSONObject.Create
            .AddPair('cpf', LcDoc)
            .AddPair('rg', FCtrl.Fornecedor.Empresa.Registro.InscricaoEstadual)
            .AddPair('birthday', DateToIso(FCtrl.Fornecedor.Empresa.Registro.DataFundacao)));
        End
        else if LcPersonType = 'J' then
        Begin
          LcJson.AddPair('company', TJSONObject.Create
            .AddPair('cnpj', LcDoc)
            .AddPair('ie', FCtrl.Fornecedor.Empresa.Registro.InscricaoEstadual)
            .AddPair('im', FCtrl.Fornecedor.Empresa.Registro.InscricaoMunicipal)
            .AddPair('dtFoundation', DateToIso(FCtrl.Fornecedor.Empresa.Registro.DataFundacao)));
        End;

        // externalCode — só quando já sincronizado antes (reenvio, D4)
        LcExternalCode := GetExternalCodeEmpresa;
        if LcExternalCode <> '' then
          LcJson.AddPair('externalCode', LcExternalCode);

        if FCtrl.Fornecedor.Empresa.Endereco.Registro.Codigo > 0 then
        Begin
          LcAddresses := TJSONArray.Create;
          LcAddress := TJSONObject.Create;
          LcAddress.AddPair('kind', 'COMERCIAL');
          LcAddress.AddPair('street', FCtrl.Fornecedor.Empresa.Endereco.Registro.Logradouro);
          LcAddress.AddPair('nmbr', FCtrl.Fornecedor.Empresa.Endereco.Registro.NumeroPredial);
          LcAddress.AddPair('complement', FCtrl.Fornecedor.Empresa.Endereco.Registro.Complemento);
          LcAddress.AddPair('neighborhood', FCtrl.Fornecedor.Empresa.Endereco.Registro.Bairro);
          LcAddress.AddPair('zipCode', OnlyDigits(FCtrl.Fornecedor.Empresa.Endereco.Registro.Cep));
          LcAddress.AddPair('tbCountryId', TJSONNumber.Create(FCtrl.Fornecedor.Empresa.Endereco.Registro.CodigoPais));
          LcAddress.AddPair('tbStateId', TJSONNumber.Create(FCtrl.Fornecedor.Empresa.Endereco.Registro.CodigoEstado));
          LcAddress.AddPair('tbCityId', TJSONNumber.Create(FCtrl.Fornecedor.Empresa.Endereco.Registro.CodigoCidade));
          LcAddress.AddPair('main', 'S');
          LcAddresses.Add(LcAddress);
          LcJson.AddPair('addresses', LcAddresses);

          LcPhones := TJSONArray.Create;
          if Trim(FCtrl.Fornecedor.Empresa.Endereco.Registro.Fone) <> '' then
          Begin
            LcPhone := TJSONObject.Create;
            LcPhone.AddPair('kind', 'FONE');
            LcPhone.AddPair('contact', FCtrl.Fornecedor.Empresa.Endereco.Registro.Contato);
            LcPhone.AddPair('number', OnlyDigits(FCtrl.Fornecedor.Empresa.Endereco.Registro.Fone));
            LcPhones.Add(LcPhone);
          End;
          if Trim(FCtrl.Fornecedor.Empresa.Endereco.Registro.Celular) <> '' then
          Begin
            LcPhone := TJSONObject.Create;
            LcPhone.AddPair('kind', 'CELULAR');
            LcPhone.AddPair('contact', FCtrl.Fornecedor.Empresa.Endereco.Registro.Contato);
            LcPhone.AddPair('number', OnlyDigits(FCtrl.Fornecedor.Empresa.Endereco.Registro.Celular));
            LcPhones.Add(LcPhone);
          End;
          if LcPhones.Count > 0 then
            LcJson.AddPair('phones', LcPhones)
          else
            LcPhones.Free;
        End;

        if Trim(FCtrl.Fornecedor.Empresa.Registro.Email) <> '' then
        Begin
          LcMailings := TJSONArray.Create;
          LcMailing := TJSONObject.Create;
          LcMailing.AddPair('email', Trim(FCtrl.Fornecedor.Empresa.Registro.Email));
          LcMailing.AddPair('groupId', TJSONNumber.Create(1));
          LcMailings.Add(LcMailing);
          LcJson.AddPair('mailings', LcMailings);
        End;

        LcCarrier := TJSONObject.Create;
        LcCarrier.AddPair('active', FCtrl.Registro.Ativo);
        LcJson.AddPair('carrier', LcCarrier);

        // decisao 8: le o DELETED real da tabela
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_TRANSPORTADORA', 'TRP_CODEMP', FCodigo));

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
    End;
  End;
end;

end.
