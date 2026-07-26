unit user_send_web;

{ Usuario do sistema (TB_USUARIO) -> /user/sincronize
  (prompt_indexacao_usuario_firebird.md, decisoes 1-3).

  O usuario do legado vira entity + tb_user SEM credencial na central
  (decisao 1) para os movimentos (pedidos/caixa/extrato) indexarem o
  AUTOR real. Cascata de indexacao (decisao 2):
    - colaborador vinculado (CLB_CODUSU) com CPF/CNPJ valido -> DOCUMENTO
      (mesma entity do colaborador - nunca duplica);
    - colaborador vinculado sem documento -> REUSA
      TB_COLABORADOR.EXTERNALCODE; se ainda vazio NAO envia neste ciclo
      (auto-heal: o /salesman roda antes e preenche);
    - sem colaborador (ex-funcionario inclusive, decisao 7) ->
      TB_USUARIO.EXTERNALCODE proprio (1o ciclo cria e faz write-back).
  Classe roda SO no servidor (seed desliga Seq 39 no perfil PDV -
  decisao 8: EXTERNALCODE nao e replicado pela retaguarda). }

interface

uses System.SysUtils, System.JSON, general_web, ControllerUsuario, un_dm;

Type
  TUserSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerUsuario;
      // Colaborador vinculado ao usuario (CLB_CODUSU): devolve True quando
      // existe; pDoc/pExternalCode saem SEM mascara/trim.
      function GetColaborador(var pDoc, pExternalCode: String): Boolean;
      function GetExternalCodeUsuario: String;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
    // decisao 1: write-back do externalCode devolvido pela API no proprio
    // TB_USUARIO (mesmo ciclo do TB_EMPRESA/TB_COLABORADOR)
    function ExternalCodeTable: String; override;
    function ExternalCodeKeyField: String; override;
  end;

implementation

{ TUserSendWeb }

uses UnFunctions, IBX.IBQuery;

function TUserSendWeb.ExternalCodeTable: String;
begin
  Result := 'TB_USUARIO';
end;

function TUserSendWeb.ExternalCodeKeyField: String;
begin
  Result := 'USU_CODIGO';
end;

constructor TUserSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerUsuario.Create(nil);
end;

destructor TUserSendWeb.Destroy;
begin
  FCtrl.DisposeOf;
  inherited;
end;

function TUserSendWeb.GetColaborador(var pDoc, pExternalCode: String): Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Result := False;
  pDoc := '';
  pExternalCode := '';
  Lc_Qry := FCtrl.GeraQuery;
  Try
    with Lc_Qry do
    Begin
      Active := False;
      Sql.Clear;
      Sql.Add('SELECT CLB_CPF, EXTERNALCODE FROM TB_COLABORADOR WHERE CLB_CODUSU = :CLB_CODUSU');
      ParamByName('CLB_CODUSU').AsInteger := FCodigo;
      Active := True;
      FetchAll;
      if (RecordCount > 0) then
      Begin
        Result := True;
        pDoc := unMaskField(Trim(FieldByName('CLB_CPF').AsString));
        pExternalCode := Trim(FieldByName('EXTERNALCODE').AsString);
      End;
    end;
  Finally
    FCtrl.FinalizaQuery(Lc_Qry);
  End;
end;

function TUserSendWeb.GetExternalCodeUsuario: String;
Var
  Lc_Qry : TIBQuery;
begin
  Result := '';
  Lc_Qry := FCtrl.GeraQuery;
  Try
    with Lc_Qry do
    Begin
      Active := False;
      Sql.Clear;
      Sql.Add('SELECT EXTERNALCODE FROM TB_USUARIO WHERE USU_CODIGO = :USU_CODIGO');
      ParamByName('USU_CODIGO').AsInteger := FCodigo;
      Active := True;
      FetchAll;
      if (RecordCount > 0) then
        Result := Trim(FieldByName('EXTERNALCODE').AsString);
    end;
  Finally
    FCtrl.FinalizaQuery(Lc_Qry);
  End;
end;

procedure TUserSendWeb.GenerateJson;
Var
  LcJson          : TJSONObject;
  LcEntity        : TJSONObject;
  LcUser          : TJSONObject;
  LcDoc           : String;
  LcExternalCode  : String;
  LcPersonType    : String;
  LcAtivo         : String;
  LcTemColaborador: Boolean;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    LcTemColaborador := GetColaborador(LcDoc, LcExternalCode);
    // decisao 2 da revisao de entidades: branco/invalido -> 'N'
    LcPersonType := DerivePersonType(LcDoc);

    if (LcPersonType = 'N') then
    Begin
      if LcTemColaborador then
      Begin
        // colaborador sem doc: REUSA o externalCode dele (mesma entity);
        // vazio = /salesman ainda nao rodou -> segura este ciclo (auto-heal)
        if LcExternalCode = '' then Exit;
      End
      else
        // sem colaborador: ciclo proprio do TB_USUARIO.EXTERNALCODE
        // (vazio no 1o ciclo -> API cria e devolve -> write-back)
        LcExternalCode := GetExternalCodeUsuario;
    End;

    LcJson := TJSONObject.Create;
    Try
      LcEntity := TJSONObject.Create;
      LcEntity.AddPair('nameCompany', FCtrl.Registro.Nome);
      LcEntity.AddPair('nickTrade',   FCtrl.Registro.Login);
      LcJson.AddPair('entity', LcEntity);

      LcJson.AddPair('personType', LcPersonType);

      if LcPersonType = 'F' then
        LcJson.AddPair('person', TJSONObject.Create.AddPair('cpf', LcDoc))
      else if LcPersonType = 'J' then
        LcJson.AddPair('company', TJSONObject.Create.AddPair('cnpj', LcDoc));

      if LcExternalCode <> '' then
        LcJson.AddPair('externalCode', LcExternalCode);

      // decisao 7: USU_ATIVO vai para o active do VINCULO institution x user
      // (credencial nao nasce do sync - tb_user fica password NULL/active N)
      if Trim(FCtrl.Registro.Ativo) = 'S' then
        LcAtivo := 'S'
      else
        LcAtivo := 'N';
      LcUser := TJSONObject.Create;
      LcUser.AddPair('active', LcAtivo);
      LcJson.AddPair('user', LcUser);

      // decisao 8 da revisao do sincronizador: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_USUARIO', 'USU_CODIGO', FCodigo));

      FStrJSon := LcJson.ToJSON;
    Finally
      LcJson.Free;
    End;
  End;
end;

end.
