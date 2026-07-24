unit customer_send_web;

interface

uses System.SysUtils,general_web,ControllerCliente, REST.Json, System.JSON;

Type
  TCustomerSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCliente;
      function ValidaDocFiscal: Boolean;
      // Onda revisão sincronizador (D3/D4): documento real do vendedor/
      // transportador — resolvido via DM.GetDocumentByEmpCodigo (nunca o
      // EMP_CODIGO interno). Retorna '' quando o código é 0 ou o lookup
      // não encontra o CPF/CNPJ (nesse caso o campo é OMITIDO do payload).
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
  objCustomer,UnFunctions, Un_DM, IBX.IBQuery;


{ TGeneralWeb }

constructor TCustomerSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCliente.Create(nil);
end;


destructor TCustomerSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

function TCustomerSendWeb.OnlyDigits(pTexto: String): String;
begin
  Result := unMaskField(Trim(pTexto));
end;

function TCustomerSendWeb.DateToIso(pData: TDate): String;
begin
  if pData <= 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', pData);
end;

// Lê TB_EMPRESA.EXTERNALCODE diretamente (coluna nova — D4/D14 — ainda não
// mapeada em tblEmpresa.pas). Só faz sentido reenviar quando já existir.
function TCustomerSendWeb.GetExternalCodeEmpresa: String;
Var
  Lc_Qry : TIBQuery;
begin
  Result := '';
  Lc_Qry := FCtrl.Empresa.GeraQuery;
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
    FCtrl.Empresa.FinalizaQuery(Lc_Qry);
  End;
end;

procedure TCustomerSendWeb.GenerateJson;
Var
  LcJson        : TJSONObject;
  LcEntity      : TJSONObject;
  LcCustomer    : TJSONObject;
  LcEntityTax   : TJSONObject;
  LcAddresses   : TJSONArray;
  LcAddress     : TJSONObject;
  LcPhones      : TJSONArray;
  LcPhone       : TJSONObject;
  LcMailings    : TJSONArray;
  LcMailing     : TJSONObject;
  LcDoc         : String;
  LcPersonType  : String;
  LcExternalCode: String;
  LcSalesmanDoc : String;
  LcCarrierDoc  : String;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    FCtrl.Empresa.Registro.Codigo := FCodigo;
    FCtrl.Empresa.getAllBykey;
    if ValidaDocFiscal then
    Begin
      LcJson := TJSONObject.Create;
      Try
        // entity
        LcDoc := OnlyDigits(FCtrl.Empresa.Registro.CpfCNPJ);
        // Sentinela do legado (TControllerEmpresa.criarEmpresaSemCPFCNPJ) — cliente
        // sem documento vira personType 'N' (D4)
        if (LcDoc = '') or (LcDoc = '12345677654321') then
          LcPersonType := 'N'
        else
          LcPersonType := FCtrl.Empresa.Registro.TipoPessoa;

        LcEntity := TJSONObject.Create;
        LcEntity.AddPair('nameCompany', FCtrl.Empresa.Registro.NomeRazaoSocial);
        LcEntity.AddPair('nickTrade',   FCtrl.Empresa.Registro.ApelidoFantasia);
        if DateToIso(FCtrl.Empresa.Registro.DataFundacao) <> '' then
          LcEntity.AddPair('aniversary', DateToIso(FCtrl.Empresa.Registro.DataFundacao))
        else
          LcEntity.AddPair('aniversary', TJSONNull.Create);
        LcJson.AddPair('entity', LcEntity);

        LcJson.AddPair('personType', LcPersonType);

        if LcPersonType = 'F' then
        Begin
          LcJson.AddPair('person', TJSONObject.Create
            .AddPair('cpf', LcDoc)
            .AddPair('rg', FCtrl.Empresa.Registro.InscricaoEstadual)
            .AddPair('birthday', DateToIso(FCtrl.Empresa.Registro.DataFundacao)));
        End
        else if LcPersonType = 'J' then
        Begin
          LcJson.AddPair('company', TJSONObject.Create
            .AddPair('cnpj', LcDoc)
            .AddPair('ie', FCtrl.Empresa.Registro.InscricaoEstadual)
            .AddPair('im', FCtrl.Empresa.Registro.InscricaoMunicipal)
            .AddPair('dtFoundation', DateToIso(FCtrl.Empresa.Registro.DataFundacao)));
        End;

        // externalCode — só quando já sincronizado antes (reenvio, D4)
        LcExternalCode := GetExternalCodeEmpresa;
        if LcExternalCode <> '' then
          LcJson.AddPair('externalCode', LcExternalCode);

        // addresses
        if FCtrl.Empresa.Endereco.Registro.Codigo > 0 then
        Begin
          LcAddresses := TJSONArray.Create;
          LcAddress := TJSONObject.Create;
          LcAddress.AddPair('kind', 'COMERCIAL');
          LcAddress.AddPair('street', FCtrl.Empresa.Endereco.Registro.Logradouro);
          LcAddress.AddPair('nmbr', FCtrl.Empresa.Endereco.Registro.NumeroPredial);
          LcAddress.AddPair('complement', FCtrl.Empresa.Endereco.Registro.Complemento);
          LcAddress.AddPair('neighborhood', FCtrl.Empresa.Endereco.Registro.Bairro);
          LcAddress.AddPair('zipCode', OnlyDigits(FCtrl.Empresa.Endereco.Registro.Cep));
          LcAddress.AddPair('tbCountryId', TJSONNumber.Create(FCtrl.Empresa.Endereco.Registro.CodigoPais));
          LcAddress.AddPair('tbStateId', TJSONNumber.Create(FCtrl.Empresa.Endereco.Registro.CodigoEstado));
          LcAddress.AddPair('tbCityId', TJSONNumber.Create(FCtrl.Empresa.Endereco.Registro.CodigoCidade));
          LcAddress.AddPair('main', 'S');
          LcAddresses.Add(LcAddress);
          LcJson.AddPair('addresses', LcAddresses);

          // phones — bug conhecido do fluxo antigo misturava fone/celular;
          // aqui cada kind lê o campo correto
          LcPhones := TJSONArray.Create;
          if Trim(FCtrl.Empresa.Endereco.Registro.Fone) <> '' then
          Begin
            LcPhone := TJSONObject.Create;
            LcPhone.AddPair('kind', 'FONE');
            LcPhone.AddPair('contact', FCtrl.Empresa.Endereco.Registro.Contato);
            LcPhone.AddPair('number', OnlyDigits(FCtrl.Empresa.Endereco.Registro.Fone));
            LcPhones.Add(LcPhone);
          End;
          if Trim(FCtrl.Empresa.Endereco.Registro.Celular) <> '' then
          Begin
            LcPhone := TJSONObject.Create;
            LcPhone.AddPair('kind', 'CELULAR');
            LcPhone.AddPair('contact', FCtrl.Empresa.Endereco.Registro.Contato);
            LcPhone.AddPair('number', OnlyDigits(FCtrl.Empresa.Endereco.Registro.Celular));
            LcPhones.Add(LcPhone);
          End;
          if LcPhones.Count > 0 then
            LcJson.AddPair('phones', LcPhones)
          else
            LcPhones.Free;
        End;

        // mailings
        if Trim(FCtrl.Empresa.Registro.Email) <> '' then
        Begin
          LcMailings := TJSONArray.Create;
          LcMailing := TJSONObject.Create;
          LcMailing.AddPair('email', Trim(FCtrl.Empresa.Registro.Email));
          LcMailing.AddPair('groupId', TJSONNumber.Create(1));
          LcMailings.Add(LcMailing);
          LcJson.AddPair('mailings', LcMailings);
        End;

        // customer
        LcCustomer := TJSONObject.Create;

        LcSalesmanDoc := '';
        if FCtrl.Empresa.Registro.CodigoVendedor > 0 then
          LcSalesmanDoc := OnlyDigits(DM.GetDocumentByEmpCodigo(FCtrl.Empresa.Registro.CodigoVendedor));
        if LcSalesmanDoc <> '' then
          LcCustomer.AddPair('salesmanDocument', LcSalesmanDoc);
        // omitido quando o código é 0 ou o lookup não encontra o documento —
        // o servidor devolve 409 SALESMAN_NOT_SYNCED só quando o campo É enviado

        LcCarrierDoc := '';
        if FCtrl.Empresa.Registro.CodigoTransportadora > 0 then
          LcCarrierDoc := OnlyDigits(DM.GetDocumentByEmpCodigo(FCtrl.Empresa.Registro.CodigoTransportadora));
        if LcCarrierDoc <> '' then
          LcCustomer.AddPair('carrierDocument', LcCarrierDoc);

        LcCustomer.AddPair('creditStatus', FCtrl.Empresa.Registro.SituacaoCredito);
        LcCustomer.AddPair('creditValue', TJSONNumber.Create(FCtrl.Empresa.Registro.ValorCredito));
        // Wallet do legado (EMP_CODFPG > 0 = venda em carteira) — mantém a
        // regra existente, mas agora expressa como descrição do catálogo central
        if FCtrl.Empresa.Registro.VendaEmCarteira > 0 then
          LcCustomer.AddPair('paymentTypeDescription', 'CARTEIRA');
        LcCustomer.AddPair('multiplier', TJSONNumber.Create(FCtrl.Empresa.Registro.Multiplicador));
        LcCustomer.AddPair('active', FCtrl.Registro.Ativo);
        LcJson.AddPair('customer', LcCustomer);

        // entityTax — campos fiscais existentes no Firebird (CLI_ISS*/CLI_IND_IE_DEST/
        // CLI_ENVEMAILAUT/CLI_ENVSOMENTEXML) que hoje não eram enviados
        LcEntityTax := TJSONObject.Create;
        LcEntityTax.AddPair('consumer', FCtrl.Empresa.Registro.ConsumidorFinal);
        // TODO: não há campo Firebird equivalente a taxRegime (regime tributário
        // da relação comercial) mapeado nesta cadeia — enviado nulo até decisão
        LcEntityTax.AddPair('taxRegime', TJSONNull.Create);
        LcEntityTax.AddPair('byPassSt', FCtrl.Empresa.Registro.IgnorarCalculoST);
        LcEntityTax.AddPair('indIeDest', FCtrl.Registro.IndicadorIE_Dest);
        LcEntityTax.AddPair('issExigibilidade', FCtrl.Registro.IssExigibilidade);
        LcEntityTax.AddPair('issProcessNr', FCtrl.Registro.IssNumeroProcesso);
        LcEntityTax.AddPair('issRetido', FCtrl.Registro.IssRetido);
        LcEntityTax.AddPair('issIndIncFiscal', FCtrl.Registro.IssIncentivoFiscal);
        LcEntityTax.AddPair('autoSendInvoice', FCtrl.Registro.EnviaEmailNFeAuto);
        LcEntityTax.AddPair('autoSendInvoiceJustXml', FCtrl.Registro.EnviarSomenteXML);
        LcJson.AddPair('entityTax', LcEntityTax);

        // decisao 8: le o DELETED real da tabela
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_CLIENTE', 'CLI_CODEMP', FCodigo));

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
    End
  End;
end;

function TCustomerSendWeb.ValidaDocFiscal: Boolean;
begin
  {Retirada a valida��o pois estamos tratando documentos com numero invalidos
  if (Length(FCtrl.Empresa.Registro.CpfCNPJ) = 11) then
    Result := calculoCpf(FCtrl.Empresa.Registro.CpfCNPJ)
  else
    Result := calculoCnpj(FCtrl.Empresa.Registro.CpfCNPJ)}
  Result := true;
end;

end.
