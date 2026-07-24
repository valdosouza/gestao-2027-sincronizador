unit provider_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerFornecedor, System.JSON;


Type
  TProviderSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerFornecedor;
      function ValidaDocFiscal: Boolean;
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

  unFunctions,ObjProvider, IBX.IBQuery, un_dm;


{ TGeneralWeb }

constructor TProviderSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerFornecedor.Create(nil);
end;


destructor TProviderSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

function TProviderSendWeb.OnlyDigits(pTexto: String): String;
begin
  Result := unMaskField(Trim(pTexto));
end;

function TProviderSendWeb.DateToIso(pData: TDate): String;
begin
  if pData <= 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', pData);
end;

// Lê TB_EMPRESA.EXTERNALCODE diretamente (coluna nova — D4/D14 — ainda não
// mapeada em tblEmpresa.pas). FCodigo = FOR_CODEMP = EMP_CODIGO (mesma PK).
function TProviderSendWeb.GetExternalCodeEmpresa: String;
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

procedure TProviderSendWeb.GenerateJson;
Var
  LcJson         : TJSONObject;
  LcEntity       : TJSONObject;
  LcProvider     : TJSONObject;
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
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    FCtrl.Empresa.Registro.Codigo := FCodigo;
    FCtrl.Empresa.getAllBykey;
    if ValidaDocFiscal then
    Begin
      LcJson := TJSONObject.Create;
      Try
        LcDoc := OnlyDigits(FCtrl.Empresa.Registro.CpfCNPJ);
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

        LcExternalCode := GetExternalCodeEmpresa;
        if LcExternalCode <> '' then
          LcJson.AddPair('externalCode', LcExternalCode);

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

        if Trim(FCtrl.Empresa.Registro.Email) <> '' then
        Begin
          LcMailings := TJSONArray.Create;
          LcMailing := TJSONObject.Create;
          LcMailing.AddPair('email', Trim(FCtrl.Empresa.Registro.Email));
          LcMailing.AddPair('groupId', TJSONNumber.Create(1));
          LcMailings.Add(LcMailing);
          LcJson.AddPair('mailings', LcMailings);
        End;

        LcProvider := TJSONObject.Create;
        LcProvider.AddPair('active', FCtrl.Registro.Ativo);
        LcJson.AddPair('provider', LcProvider);

        // decisao 8: le o DELETED real da tabela
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_FORNECEDOR', 'FOR_CODEMP', FCodigo));

        FStrJson := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
    End;
  End;
end;

function TProviderSendWeb.ValidaDocFiscal: Boolean;
begin
  {Retirada a valida��o pois estamos tratando documentos com numero invalidos
  if (Length(FCtrl.Empresa.Registro.CpfCNPJ) = 11) then
    Result := calculoCpf(FCtrl.Empresa.Registro.CpfCNPJ)
  else
    Result := calculoCnpj(FCtrl.Empresa.Registro.CpfCNPJ)}
  Result := true;
end;

end.
