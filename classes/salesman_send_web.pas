unit salesman_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerColaborador, System.JSON,
     ControllerUf, ControllerCidade;

Type
  TSalesManSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerColaborador;
      function ValidaSendSalesman(): Boolean;
      function DateToIso(pData: TDate): String;
      function OnlyDigits(pTexto: String): String;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

uses UnFunctions, un_dm;

constructor TSalesManSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerColaborador.Create(nil);
end;

destructor TSalesManSendWeb.Destroy;
begin
  FCtrl.DisposeOf;
  inherited;
end;

function TSalesManSendWeb.OnlyDigits(pTexto: String): String;
begin
  Result := unMaskField(Trim(pTexto));
end;

function TSalesManSendWeb.DateToIso(pData: TDate): String;
begin
  if pData <= 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd', pData);
end;

procedure TSalesManSendWeb.GenerateJson;
Var
  LcJson         : TJSONObject;
  LcEntity       : TJSONObject;
  LcCollaborator : TJSONObject;
  LcSalesman     : TJSONObject;
  LcAddresses    : TJSONArray;
  LcAddress      : TJSONObject;
  LcPhones       : TJSONArray;
  LcPhone        : TJSONObject;
  LcMailings     : TJSONArray;
  LcMailing      : TJSONObject;
  LcDoc          : String;
  LcPersonType   : String;
  LcUF           : TControllerUf;
  LcCidade       : TControllerCidade;
  LcCodigoEstado : Integer;
  LcCodigoCidade : Integer;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    if ValidaSendSalesman then
    Begin
      LcJson := TJSONObject.Create;
      Try
        LcDoc := OnlyDigits(FCtrl.Registro.CPFCNPJ);
        if LcDoc = '' then
          LcPersonType := 'N'
        else if Length(LcDoc) = 11 then
          LcPersonType := 'F'
        else
          LcPersonType := 'J';

        LcEntity := TJSONObject.Create;
        LcEntity.AddPair('nameCompany', FCtrl.Registro.Nome);
        LcEntity.AddPair('nickTrade',   FCtrl.Registro.Nome);
        if DateToIso(FCtrl.Registro.NAscimento) <> '' then
          LcEntity.AddPair('aniversary', DateToIso(FCtrl.Registro.NAscimento))
        else
          LcEntity.AddPair('aniversary', TJSONNull.Create);
        LcJson.AddPair('entity', LcEntity);

        LcJson.AddPair('personType', LcPersonType);

        if LcPersonType = 'F' then
        Begin
          LcJson.AddPair('person', TJSONObject.Create
            .AddPair('cpf', LcDoc)
            .AddPair('rg', FCtrl.Registro.Identidade)
            .AddPair('birthday', DateToIso(FCtrl.Registro.NAscimento)));
        End
        else if LcPersonType = 'J' then
        Begin
          LcJson.AddPair('company', TJSONObject.Create
            .AddPair('cnpj', LcDoc)
            .AddPair('ie', FCtrl.Registro.Identidade)
            .AddPair('im', '')
            .AddPair('dtFoundation', DateToIso(FCtrl.Registro.NAscimento)));
        End;

        // TODO: TB_COLABORADOR não tem coluna EXTERNALCODE (só TB_EMPRESA —
        // D4/D14) — vendedor sem CPF/CNPJ (personType 'N') não tem como
        // persistir o UUID devolvido para reenvio; gap conhecido, pendente
        // de DDL (ver un_send_to_web_server.SaveExternalCode, que assume
        // TB_EMPRESA para qualquer classe).

        // addresses — endereço único do colaborador (UF/Cidade por
        // descrição, igual ao padrão já usado em ControllerColaborador.FillDataObjeto)
        if (Trim(FCtrl.Registro.Endereco) <> '') or (Trim(FCtrl.Registro.Cep) <> '') then
        Begin
          LcCodigoEstado := 0;
          LcCodigoCidade := 0;
          Try
            LcUF := TControllerUf.Create(nil);
            LcCidade := TControllerCidade.Create(nil);
            LcCodigoEstado := LcUF.BuscaCodigo(FCtrl.Registro.Estado);
            LcCodigoCidade := LcCidade.Buscacodigo(0, FCtrl.Registro.Cidade, FCtrl.Registro.Estado);
          Finally
            FreeAndNil(LcUF);
            FreeAndNil(LcCidade);
          End;

          LcAddresses := TJSONArray.Create;
          LcAddress := TJSONObject.Create;
          LcAddress.AddPair('kind', 'RESIDENCIAL');
          LcAddress.AddPair('street', FCtrl.Registro.Endereco);
          LcAddress.AddPair('nmbr', '');
          LcAddress.AddPair('complement', '');
          LcAddress.AddPair('neighborhood', FCtrl.Registro.Bairro);
          LcAddress.AddPair('zipCode', OnlyDigits(FCtrl.Registro.Cep));
          LcAddress.AddPair('tbCountryId', TJSONNumber.Create(1058));
          LcAddress.AddPair('tbStateId', TJSONNumber.Create(LcCodigoEstado));
          LcAddress.AddPair('tbCityId', TJSONNumber.Create(LcCodigoCidade));
          LcAddress.AddPair('main', 'S');
          LcAddresses.Add(LcAddress);
          LcJson.AddPair('addresses', LcAddresses);
        End;

        // phones — bug C5 do legado: TControllerColaborador.FillDataObjeto
        // grava Registro.Fone nos dois kinds (Fone e Celular). Aqui cada
        // kind lê o campo correto.
        LcPhones := TJSONArray.Create;
        if Trim(FCtrl.Registro.Fone) <> '' then
        Begin
          LcPhone := TJSONObject.Create;
          LcPhone.AddPair('kind', 'FONE');
          LcPhone.AddPair('contact', TJSONNull.Create);
          LcPhone.AddPair('number', OnlyDigits(FCtrl.Registro.Fone));
          LcPhones.Add(LcPhone);
        End;
        if Trim(FCtrl.Registro.Celular) <> '' then
        Begin
          LcPhone := TJSONObject.Create;
          LcPhone.AddPair('kind', 'CELULAR');
          LcPhone.AddPair('contact', TJSONNull.Create);
          LcPhone.AddPair('number', OnlyDigits(FCtrl.Registro.Celular));
          LcPhones.Add(LcPhone);
        End;
        if LcPhones.Count > 0 then
          LcJson.AddPair('phones', LcPhones)
        else
          LcPhones.Free;

        // mailings — e-mail NÃO é mais obrigatório (contrato novo); apenas
        // entra na lista quando presente
        if Trim(FCtrl.Registro.email) <> '' then
        Begin
          LcMailings := TJSONArray.Create;
          LcMailing := TJSONObject.Create;
          LcMailing.AddPair('email', Trim(FCtrl.Registro.email));
          LcMailing.AddPair('groupId', TJSONNumber.Create(1));
          LcMailings.Add(LcMailing);
          LcJson.AddPair('mailings', LcMailings);
        End;

        // collaborator — grava SEMPRE (precedência Collaborator→Salesman)
        LcCollaborator := TJSONObject.Create;
        LcCollaborator.AddPair('active', 'S');
        if DateToIso(FCtrl.Registro.Admissao) <> '' then
          LcCollaborator.AddPair('dtAdmission', DateToIso(FCtrl.Registro.Admissao))
        else
          LcCollaborator.AddPair('dtAdmission', TJSONNull.Create);
        if DateToIso(FCtrl.Registro.Demissao) <> '' then
          LcCollaborator.AddPair('dtResignation', DateToIso(FCtrl.Registro.Demissao))
        else
          LcCollaborator.AddPair('dtResignation', TJSONNull.Create);
        LcCollaborator.AddPair('salary', TJSONNumber.Create(FCtrl.Registro.Salario));
        LcCollaborator.AddPair('fathersName', FCtrl.Registro.NomePai);
        LcCollaborator.AddPair('mothersName', FCtrl.Registro.NomeMae);
        LcCollaborator.AddPair('voteNumber', FCtrl.Registro.TituloEleitor);
        LcCollaborator.AddPair('voteZone', FCtrl.Registro.TituloZona);
        LcCollaborator.AddPair('voteSection', FCtrl.Registro.SecaoZona);
        LcCollaborator.AddPair('militaryCertificate', FCtrl.Registro.CertificadoMilitar);
        LcCollaborator.AddPair('pis', FCtrl.Registro.PIS);
        LcJson.AddPair('collaborator', LcCollaborator);

        // salesman — quando o colaborador também é vendedor (cargo comercial);
        // como o Firebird não tem uma flag direta "é vendedor" nesta classe,
        // envia sempre junto com collaborator (precedência D13 é decidida
        // no servidor pela presença do bloco)
        LcSalesman := TJSONObject.Create;
        LcSalesman.AddPair('active', 'S');
        LcSalesman.AddPair('aliqKickback', TJSONNumber.Create(FCtrl.Registro.ComissaoAliqVenda));
        LcSalesman.AddPair('kickbackProduct', FCtrl.Registro.ComissaoPorProduto);
        // TODO: não há campo Firebird equivalente a flexValue — enviado 0
        LcSalesman.AddPair('flexValue', TJSONNumber.Create(0));
        LcJson.AddPair('salesman', LcSalesman);

        // decisao 8: le o DELETED real da tabela
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_COLABORADOR', 'CLB_CODIGO', FCodigo));

        FStrJSon := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
    End;
  End;
 end;

function TSalesManSendWeb.ValidaSendSalesman: Boolean;
begin
  // D15/D22: e-mail deixou de ser obrigatório para sincronizar o colaborador
  // (o legado descartava quem não tivesse e-mail — trava removida aqui).
  Result := True;
end;

end.
