unit un_dm;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IBX.IBCustomDataSet, IBX.IBQuery,
  IBX.IBDatabase, IBX.IBSQL, FireDAC.Stan.Intf,IniFiles,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type

  TDM = class(TDataModule)
    Qr_Crud: TIBQuery;
    IBT_Crud: TIBTransaction;
    IBT_Consulta: TIBTransaction;
    IBD_Gestao: TIBDatabase;
    IBT_Atualiza: TIBTransaction;
    IBD_Servidor: TIBDatabase;
    IBT_Servidor: TIBTransaction;
    IBSQL: TIBSQL;
    Qr_Acao: TIBQuery;
    Qr_Consulta: TIBQuery;
    IB_Transacao: TIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure setBDCrud(BD:TIBDatabase);
    procedure ExecConsulta(SqlTxt: String);
    procedure ExecComando(SqlTxt: String);
    procedure AtivaTrigger(op: Boolean);
    procedure ConectaBancoLocal;
    procedure ConectaBancoServidor;
    // Bootstrap do banco do cliente (Infra-IA/Sincronizador/prompt_construcao_
    // banco_cliente.md, decisoes 1-10) - prepara o Firebird inteiro sem SQL
    // manual: TB_SINCRONIA + generator/trigger, TB_LISTA_SINCRONIA + seed +
    // LAST_UPDATE, DELETED universal, EXTERNALCODE e triggers TG_SRC_*.
    // Todo DDL usa apenas sintaxe valida no Firebird 2.5 E 5.0 (decisao 10).
    function  TabelaExiste(const ANomeTabela: String): Boolean;
    function  TabelaVazia(const ANomeTabela: String): Boolean;
    function  CampoExiste(const ANomeTabela, ANomeCampo: String): Boolean;
    function  GeneratorExiste(const ANomeGenerator: String): Boolean;
    procedure EnsureSincroniaTable;
    procedure EnsureListaSincroniaTable;
    procedure SeedListaSincroniaIfEmpty;
    procedure EnsureDeletedColumns;
    procedure EnsureExternalCode;
    procedure EnsureTriggers;
    procedure EnsureSincronia;
    // Motor de reindexação (D3/D4): resolve o CPF/CNPJ real a partir do
    // código interno do Firebird (EMP_CODIGO) — usado por toda classe de
    // envio que hoje só manda o código local onde o contrato novo exige
    // *Document (customerDocument/salesmanDocument/providerDocument/...).
    // '' quando o código é 0/inexistente/sem documento cadastrado.
    function GetDocumentByEmpCodigo(pCodigoEmpresa: Integer): String;
    // Le o flag DELETED real do registro (decisao 8) - usado pelas classes
    // *_send_web para montar o payload; 'N' quando registro/coluna ausente.
    function GetDeletedFlag(const pTabela, pCampoChave: String; pCodigo: Integer): String;
    // Indexacao do AUTOR (prompt_indexacao_usuario_firebird.md, decisao 2):
    // resolve USU_CODIGO para a referencia do bloco `user` dos movimentos.
    // Cascata: colaborador vinculado com CPF/CNPJ VALIDO -> pDocumento;
    // colaborador sem doc -> TB_COLABORADOR.EXTERNALCODE; sem colaborador ->
    // TB_USUARIO.EXTERNALCODE. Decisao 8 (PDV): com GbTerminal <> 0 so
    // resolve por DOCUMENTO (EXTERNALCODE nao e replicado pela retaguarda) -
    // sem doc o movimento viaja SEM bloco user (fallback da web).
    // False = sem referencia disponivel neste ciclo (auto-heal).
    function GetUserSyncRef(pUsuCodigo: Integer; var pDocumento, pExternalCode: String): Boolean;
  public
    // Gate (criterio de sucesso 2): a sincronizacao so e liberada quando o
    // bootstrap completou sem erro nesta execucao.
    BootstrapOk : Boolean;
    // Indexador terminal (prompt_indexador_terminal_pdv.md, decisoes 1-3):
    // numero do terminal desta instalacao, lido de SISWEB\TERMINAL no start.
    // Convencao: 0 = Servidor Local/Base unica; 1..N = PDVs. Vai em TODOS os
    // payloads de movimento (LcSendWeb.Terminal em un_send_to_web_server).
    GbTerminal  : Integer;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uMain, un_funcoes, un_sistema, un_sincronia_seed, UnFunctions;

{$R *.dfm}

procedure TDM.AtivaTrigger(op: Boolean);
begin
  if op then
  Begin
    DM.ExecComando(concat(
          'update RDB$TRIGGERS set RDB$TRIGGER_INACTIVE = 0 ',
          'where rdb$trigger_source is not null and ((rdb$system_flag = 0) or ',
          '(rdb$system_flag is null)) '
    ));
  End
  else
  Begin
    DM.ExecComando(concat(
          'update rdb$triggers ',
          'set rdb$trigger_inactive = 1 ',
          'where ',
          '    rdb$trigger_source is not null ',
          '   and (coalesce(rdb$system_flag,0) = 0) ',
          '    and rdb$trigger_source not starting with ''CHECK''  '
    ));
  End;
end;

procedure TDM.ConectaBancoLocal;
var
   LcPAth : String;
begin
  // Secao unificada com a tela de configuracao (tas_config grava em [SISWEB];
  // a leitura antiga em [SINCRONIA] fazia o path vir vazio no start)
  LcPAth := Fc_Aq_Geral('L','SISWEB', 'BDPathBDLocal','');
  IBD_Gestao.Connected := False;
  IBD_Gestao.Params.Clear;
  IBD_Gestao.Params.Add('user_name=SYSDBA');
  IBD_Gestao.Params.Add('password=masterkey');
  IBD_Gestao.Params.Add('lc_ctype=WIN1252');
  IBD_Gestao.DatabaseName := LcPAth;
  Try
    IBD_Gestao.Connected := True;
  except
    BEgin
      IBD_Gestao.Connected := FAlse;
    End;
  End;
end;

procedure TDM.ConectaBancoServidor;
var
   Lc_Arq_Ini: TIniFile;
   LcPAth : String;
begin
  Lc_Arq_Ini := TIniFile.Create(getPathExe + 'config.ini');
  Try
    if ( Fc_Aq_Geral('L','SINCRONIA', 'ReceiveLocalServer','S') = 'S')  then
    Begin
      LcPAth := Lc_Arq_Ini.ReadString('SINCRONIA', 'BDPathBDServidor','');
      if FileExists(LcPAth) then
      Begin
        IBD_Servidor.Connected := False;
        IBD_Servidor.Params.Clear;
        IBD_Servidor.Params.Add('user_name=SYSDBA');
        IBD_Servidor.Params.Add('password=masterkey');
        IBD_Servidor.Params.Add('lc_ctype=WIN1252');
        IBD_Servidor.DatabaseName := LcPAth;
        Try
          IBD_Servidor.Connected := True
        Except
          IBD_Servidor.Connected := False;
        End;
      End;
    End;
  Finally
    Lc_Arq_Ini.DisposeOf;
  End;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  BootstrapOk := False;
  // Decisao 1 do indexador terminal: fonte = registro SISWEB\TERMINAL
  // (mesma secao de FApiKey/FPathURL; tela de config ja grava a chave).
  GbTerminal := StrToIntDef(Fc_Aq_Geral('L', 'SISWEB', 'TERMINAL', '0'), 0);
  ConectaBancoLocal;
  ConectaBancoServidor;
  // Bootstrap completo do banco do cliente sem SQL manual (decisoes 1-10) -
  // so roda se o banco local conectou; falha mantem BootstrapOk = False e a
  // sincronizacao fica bloqueada (gate no uMain), sem derrubar o app.
  if IBD_Gestao.Connected then
  Begin
    try
      EnsureSincronia;
    except
      on E: Exception do
        GeralogCrashlytics('TDM.EnsureSincronia', E.Message);
    end;
  End;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  IBD_Gestao.Close;
  IBD_Servidor.Close;
end;

procedure TDM.ExecComando(SqlTxt: String);
begin
  with Qr_Crud do
  Begin
    if not Transaction.InTransaction then Transaction.StartTransaction;
    active := False;
    sql.Clear;
    SQL.Add(SqlTxt);
    ExecSQL;
    if Transaction.InTransaction then Transaction.Commit;
    Close;
  End;
end;

procedure TDM.ExecConsulta(SqlTxt: String);
begin
  with Qr_Crud do
  Begin
    if Transaction.InTransaction then Transaction.CommitRetaining;
    close;
    sql.Clear;
    SQL.Add(SqlTxt);
    Active := True;
    FetchAll;
    First;
  End;
end;


{ ---------------------------------------------------------------------
  Bootstrap do banco do cliente (prompt_construcao_banco_cliente.md).
  Roda a cada start do Sincronizador (DataModuleCreate); idempotente:
  cada passo verifica os metadados (RDB$) antes de agir.
  Compatibilidade: todo DDL e valido no Firebird 2.5 E 5.0 (decisao 10) -
  sem IDENTITY, sem BOOLEAN, generator via GEN_ID.
  --------------------------------------------------------------------- }

function TDM.TabelaExiste(const ANomeTabela: String): Boolean;
begin
  ExecConsulta(
    'SELECT COUNT(*) AS QTDE FROM RDB$RELATIONS ' +
    'WHERE UPPER(RDB$RELATION_NAME) = ''' + UpperCase(ANomeTabela) + ''' ' +
    'AND RDB$SYSTEM_FLAG = 0'
  );
  Result := Qr_Crud.FieldByName('QTDE').AsInteger > 0;
end;

function TDM.TabelaVazia(const ANomeTabela: String): Boolean;
begin
  ExecConsulta('SELECT COUNT(*) AS QTDE FROM ' + ANomeTabela);
  Result := Qr_Crud.FieldByName('QTDE').AsInteger = 0;
end;

function TDM.CampoExiste(const ANomeTabela, ANomeCampo: String): Boolean;
begin
  ExecConsulta(
    'SELECT COUNT(*) AS QTDE FROM RDB$RELATION_FIELDS ' +
    'WHERE UPPER(TRIM(RDB$RELATION_NAME)) = ''' + UpperCase(ANomeTabela) + ''' ' +
    'AND UPPER(TRIM(RDB$FIELD_NAME)) = ''' + UpperCase(ANomeCampo) + ''''
  );
  Result := Qr_Crud.FieldByName('QTDE').AsInteger > 0;
end;

function TDM.GeneratorExiste(const ANomeGenerator: String): Boolean;
begin
  ExecConsulta(
    'SELECT COUNT(*) AS QTDE FROM RDB$GENERATORS ' +
    'WHERE UPPER(TRIM(RDB$GENERATOR_NAME)) = ''' + UpperCase(ANomeGenerator) + ''''
  );
  Result := Qr_Crud.FieldByName('QTDE').AsInteger > 0;
end;

{ Passo 1 - TB_SINCRONIA + GN_SINCRONIA + TG_SINCRONIA (decisao 2 - DDL
  autoritativa fornecida pelo Valdo). }
procedure TDM.EnsureSincroniaTable;
begin
  if not GeneratorExiste('GN_SINCRONIA') then
    ExecComando('CREATE GENERATOR GN_SINCRONIA');

  if not TabelaExiste('TB_SINCRONIA') then
    ExecComando(
      'CREATE TABLE TB_SINCRONIA (' +
      'SRC_CODIGO    INTEGER NOT NULL, ' +
      'SRC_TABELA    VARCHAR(30), ' +
      'SRC_CHAVE     VARCHAR(30), ' +
      'SRC_OPER      CHAR(1), ' +
      'SRC_TIME      TIMESTAMP, ' +
      'SRC_REGISTRO  INTEGER, ' +
      'SRC_LOG       VARCHAR(255), ' +
      'CONSTRAINT PK_TB_SINCRONIA PRIMARY KEY (SRC_CODIGO))'
    );

  // CREATE OR ALTER = idempotente nas duas versoes
  ExecComando(
    'CREATE OR ALTER TRIGGER TG_SINCRONIA FOR TB_SINCRONIA ' +
    'ACTIVE BEFORE INSERT POSITION 0 ' +
    'AS BEGIN NEW.SRC_CODIGO = GEN_ID(GN_SINCRONIA, 1); END'
  );
end;

{ TB_SYNC_TABLE: NUNCA tocar (decisao 4 do prompt_indexador_terminal_pdv.md,
  2026-07-26 — REVERTE a decisao 1 do bootstrap). Ela e checkpoint vivo da
  RETAGUARDA do Gestao2016 (ControllerRetaguardaSendToLocal/Un_Funcoes.
  updateTableSync); o Sincronizador nao a usa, mas dropa-la destruia a
  sincronia local Servidor x PDVs. O checkpoint DESTE processo segue em
  TB_LISTA_SINCRONIA.LAST_UPDATE. }

procedure TDM.EnsureListaSincroniaTable;
begin
  if not TabelaExiste('TB_LISTA_SINCRONIA') then
  Begin
    try
      ExecComando(
        'CREATE TABLE TB_LISTA_SINCRONIA (' +
        'WAY VARCHAR(1) NOT NULL, ' +
        'DESC_TABELA VARCHAR(60) NOT NULL, ' +
        'KIND VARCHAR(20) NOT NULL, ' +
        'DESC_PROCESS VARCHAR(100), ' +
        'SEQ INTEGER, ' +
        'DESC_FIELD VARCHAR(60), ' +
        'DESC_TRIGGER VARCHAR(60), ' +
        'NOTE VARCHAR(255), ' +
        'SET_ON VARCHAR(1), ' +
        'CLASS_NAME VARCHAR(100), ' +
        'END_POINT VARCHAR(200), ' +
        'LAST_UPDATE TIMESTAMP, ' +
        'CONSTRAINT PK_LISTA_SINCRONIA PRIMARY KEY (WAY, DESC_TABELA, KIND))'
      );
    except
      on E: Exception do
        // corrida entre instancias/terminais iniciando ao mesmo tempo: se
        // outro processo ja criou a tabela, ignora; qualquer outro erro sobe
        if Pos('already exist', LowerCase(E.Message)) = 0 then raise;
    end;
  End;
  // Bancos criados antes da decisao 3 ganham a coluna de checkpoint
  if not CampoExiste('TB_LISTA_SINCRONIA','LAST_UPDATE') then
    ExecComando('ALTER TABLE TB_LISTA_SINCRONIA ADD LAST_UPDATE TIMESTAMP');
end;

procedure TDM.SeedListaSincroniaIfEmpty;
Var
  I   : Integer;
  Row : TSincroniaSeedRow;
begin
  // Modulo restaurante REMOVIDO do catalogo (Valdo, 2026-07-26): alem de
  // nao semear, bancos ja semeados perdem as 7 linhas TB_REST_* aqui
  // (idempotente - roda a cada start, DELETE de 0 linhas e no-op).
  ExecComando('DELETE FROM TB_LISTA_SINCRONIA WHERE DESC_TABELA LIKE ''TB_REST_%''');

  if not TabelaVazia('TB_LISTA_SINCRONIA') then Exit;

  with Qr_Acao do
  Begin
    Database    := IBD_Gestao;
    Transaction := IBD_Gestao.DefaultTransaction;
    if not Transaction.InTransaction then Transaction.StartTransaction;
    try
      SQL.Text :=
        'INSERT INTO TB_LISTA_SINCRONIA ' +
        '(WAY, DESC_TABELA, KIND, DESC_PROCESS, SEQ, DESC_FIELD, DESC_TRIGGER, NOTE, SET_ON, CLASS_NAME, END_POINT) ' +
        'VALUES (:WAY, :DESC_TABELA, :KIND, :DESC_PROCESS, :SEQ, :DESC_FIELD, :DESC_TRIGGER, :NOTE, :SET_ON, :CLASS_NAME, :END_POINT)';
      Prepare;
      for I := Low(SINCRONIA_SEED) to High(SINCRONIA_SEED) do
      Begin
        Row := SINCRONIA_SEED[I];
        ParamByName('WAY').AsString          := Row.Way;
        ParamByName('DESC_TABELA').AsString  := Row.DescTabela;
        ParamByName('KIND').AsString         := Row.Kind;
        ParamByName('DESC_PROCESS').AsString := Row.DescProcess;
        ParamByName('SEQ').AsInteger         := Row.Seq;
        if Row.DescField <> '' then
          ParamByName('DESC_FIELD').AsString := Row.DescField
        else
          ParamByName('DESC_FIELD').Clear;
        // Nenhum nome real de trigger confirmado no codigo - ver MAPA_INDEXACAO.md
        ParamByName('DESC_TRIGGER').Clear;
        ParamByName('NOTE').AsString       := Row.Note;
        ParamByName('SET_ON').AsString     := Row.SetOn;
        ParamByName('CLASS_NAME').AsString := Row.ClassName;
        if Row.EndPoint <> '' then
          ParamByName('END_POINT').AsString := Row.EndPoint
        else
          ParamByName('END_POINT').Clear;
        ExecSQL;
      End;
      Transaction.Commit;
    except
      on E: Exception do
      Begin
        if Transaction.InTransaction then Transaction.Rollback;
        raise;
      End;
    end;
  End;

  // Perfil PDV (decisao 3 do indexador terminal): em terminal <> 0 os
  // CADASTROS nascem desligados - eles chegam ao PDV pela retaguarda e
  // seriam reenvio redundante; o PDV sincroniza so MOVIMENTO (Seq 17-29).
  // Aplicado apenas no seed inicial (base recem-preparada); reativacao
  // manual via UPDATE continua possivel.
  if GbTerminal <> 0 then
    ExecComando(
      'UPDATE TB_LISTA_SINCRONIA SET SET_ON = ''N'' ' +
      'WHERE (SEQ BETWEEN 1 AND 16) OR (SEQ IN (38, 39))'
    );
end;

{ Passo 5 - soft delete universal (decisao 8): DELETED CHAR(1) DEFAULT 'N'
  em TODAS as tabelas de usuario, exceto as 2 de controle. O backfill e
  necessario porque na 2.5 o DEFAULT nao retroage aos registros existentes. }
procedure TDM.EnsureDeletedColumns;
Var
  LcTabelas : TStringList;
  I         : Integer;
begin
  LcTabelas := TStringList.Create;
  try
    ExecConsulta(
      'SELECT TRIM(RDB$RELATION_NAME) AS NOME FROM RDB$RELATIONS ' +
      'WHERE COALESCE(RDB$SYSTEM_FLAG,0) = 0 AND RDB$VIEW_BLR IS NULL ' +
      'AND UPPER(TRIM(RDB$RELATION_NAME)) NOT IN (''TB_SINCRONIA'',''TB_LISTA_SINCRONIA'')'
    );
    while not Qr_Crud.Eof do
    Begin
      LcTabelas.Add(Trim(Qr_Crud.FieldByName('NOME').AsString));
      Qr_Crud.Next;
    End;
    for I := 0 to LcTabelas.Count - 1 do
    Begin
      if not CampoExiste(LcTabelas[I],'DELETED') then
      Begin
        ExecComando('ALTER TABLE ' + LcTabelas[I] + ' ADD DELETED CHAR(1) DEFAULT ''N''');
        ExecComando('UPDATE ' + LcTabelas[I] + ' SET DELETED = ''N'' WHERE DELETED IS NULL');
      End;
    End;
  finally
    LcTabelas.DisposeOf;
  end;
end;

{ EXTERNALCODE em TB_EMPRESA (D4/D14 da revisao do sincronizador - UUID
  devolvido pela setes-sync p/ registros sem CPF/CNPJ). Incorporado ao
  bootstrap pela decisao 8 (supera o patch manual 01_firebird_ddl.sql). }
procedure TDM.EnsureExternalCode;
begin
  if not CampoExiste('TB_EMPRESA','EXTERNALCODE') then
  Begin
    ExecComando('ALTER TABLE TB_EMPRESA ADD EXTERNALCODE VARCHAR(36)');
    ExecComando('CREATE INDEX IDX_EMPRESA_EXTERNALCODE ON TB_EMPRESA (EXTERNALCODE)');
  End;
  // Decisao 1 da revisao de entidades (2026-07-25): colaborador sem CPF
  // tambem fecha o ciclo do externalCode (TB_COLABORADOR e independente
  // da TB_EMPRESA).
  if not CampoExiste('TB_COLABORADOR','EXTERNALCODE') then
  Begin
    ExecComando('ALTER TABLE TB_COLABORADOR ADD EXTERNALCODE VARCHAR(36)');
    ExecComando('CREATE INDEX IDX_COLABORADOR_EXTERNALCODE ON TB_COLABORADOR (EXTERNALCODE)');
  End;
  // Decisao 1 da indexacao de usuarios (2026-07-26): usuario SEM colaborador
  // (ex-funcionario inclusive) fecha o ciclo pelo proprio TB_USUARIO.
  if not CampoExiste('TB_USUARIO','EXTERNALCODE') then
  Begin
    ExecComando('ALTER TABLE TB_USUARIO ADD EXTERNALCODE VARCHAR(36)');
    ExecComando('CREATE INDEX IDX_USUARIO_EXTERNALCODE ON TB_USUARIO (EXTERNALCODE)');
  End;
end;

{ Passo 6 - triggers de captura TG_SRC_* (decisoes 5, 6 e 7): UMA trigger
  multi-evento por tabela (AFTER INSERT OR UPDATE, sem DELETE - exclusao
  fisica nao existe mais), gerada a partir de TB_LISTA_SINCRONIA
  (DESC_TABELA + DESC_FIELD, WAY='E', SET_ON='S'). O nome criado e gravado
  de volta em DESC_TRIGGER. }
procedure TDM.EnsureTriggers;
Var
  LcTabela  : String;
  LcCampo   : String;
  LcTrigger : String;
  LcNomeBase: String;
  LcLista   : TStringList;
  I         : Integer;
begin
  // Materializa a lista antes de executar DDL (Qr_Crud e reutilizado)
  LcLista := TStringList.Create;
  try
    ExecConsulta(
      'SELECT DISTINCT DESC_TABELA, DESC_FIELD FROM TB_LISTA_SINCRONIA ' +
      'WHERE WAY = ''E'' AND SET_ON = ''S'' ' +
      'AND DESC_FIELD IS NOT NULL AND DESC_FIELD <> '''''
    );
    while not Qr_Crud.Eof do
    Begin
      LcLista.Add(
        Trim(Qr_Crud.FieldByName('DESC_TABELA').AsString) + '=' +
        Trim(Qr_Crud.FieldByName('DESC_FIELD').AsString));
      Qr_Crud.Next;
    End;

    for I := 0 to LcLista.Count - 1 do
    Begin
      LcTabela := LcLista.Names[I];
      LcCampo  := LcLista.ValueFromIndex[I];
      if not TabelaExiste(LcTabela) then Continue; // tabela ainda nao existe neste banco

      // TG_SRC_EMPRESA para TB_EMPRESA; identificadores Firebird <= 31 chars
      LcNomeBase := LcTabela;
      if Pos('TB_', LcNomeBase) = 1 then Delete(LcNomeBase, 1, 3);
      LcTrigger := Copy('TG_SRC_' + LcNomeBase, 1, 31);

      // Corpo conforme decisao 7: INSERT grava NEW.<chave> com 'I',
      // UPDATE grava OLD.<chave> com 'U'; SRC_CODIGO=0 (TG_SINCRONIA gera).
      ExecComando(
        'CREATE OR ALTER TRIGGER ' + LcTrigger + ' FOR ' + LcTabela + ' ' +
        'ACTIVE AFTER INSERT OR UPDATE POSITION 0 ' +
        'AS BEGIN ' +
        'IF (INSERTING) THEN ' +
        'INSERT INTO TB_SINCRONIA (SRC_CODIGO, SRC_TABELA, SRC_CHAVE, SRC_OPER, SRC_REGISTRO, SRC_TIME) ' +
        'VALUES (0, ''' + LcTabela + ''', ''' + LcCampo + ''', ''I'', NEW.' + LcCampo + ', CURRENT_TIMESTAMP); ' +
        'ELSE ' +
        'INSERT INTO TB_SINCRONIA (SRC_CODIGO, SRC_TABELA, SRC_CHAVE, SRC_OPER, SRC_REGISTRO, SRC_TIME) ' +
        'VALUES (0, ''' + LcTabela + ''', ''' + LcCampo + ''', ''U'', OLD.' + LcCampo + ', CURRENT_TIMESTAMP); ' +
        'END'
      );

      ExecComando(
        'UPDATE TB_LISTA_SINCRONIA SET DESC_TRIGGER = ''' + LcTrigger + ''' ' +
        'WHERE WAY = ''E'' AND DESC_TABELA = ''' + LcTabela + ''''
      );
    End;
  finally
    LcLista.DisposeOf;
  end;
end;

procedure TDM.EnsureSincronia;
begin
  BootstrapOk := False;
  EnsureSincroniaTable;        // passo 1 - fila + generator + trigger da PK
  // passo 2 (DropSyncTable) REMOVIDO - decisao 4 do indexador terminal:
  // TB_SYNC_TABLE pertence a retaguarda do Gestao2016 e fica intocada
  EnsureListaSincroniaTable;   // passo 3 - catalogo + LAST_UPDATE
  SeedListaSincroniaIfEmpty;
  EnsureDeletedColumns;        // passo 5 - decisao 8
  EnsureExternalCode;
  EnsureTriggers;              // passo 6 - decisoes 5/6/7
  BootstrapOk := True;
end;

function TDM.GetDeletedFlag(const pTabela, pCampoChave: String; pCodigo: Integer): String;
begin
  Result := 'N';
  if pCodigo <= 0 then Exit;
  try
    ExecConsulta(
      'SELECT DELETED FROM ' + pTabela +
      ' WHERE ' + pCampoChave + ' = ' + IntToStr(pCodigo)
    );
    if (not Qr_Crud.Eof) and (Trim(Qr_Crud.FieldByName('DELETED').AsString) = 'S') then
      Result := 'S';
  except
    // coluna/tabela ausente (banco ainda nao preparado): trata como ativo
    Result := 'N';
  end;
end;

function TDM.GetDocumentByEmpCodigo(pCodigoEmpresa: Integer): String;
begin
  Result := '';
  if pCodigoEmpresa <= 0 then Exit;
  ExecConsulta(
    'SELECT EMP_CNPJ FROM TB_EMPRESA WHERE EMP_CODIGO = ' + IntToStr(pCodigoEmpresa)
  );
  if not Qr_Crud.Eof then
    Result := Trim(Qr_Crud.FieldByName('EMP_CNPJ').AsString);
end;

function TDM.GetUserSyncRef(pUsuCodigo: Integer; var pDocumento, pExternalCode: String): Boolean;
Var
  LcDoc : String;
  LcExt : String;
begin
  Result := False;
  pDocumento := '';
  pExternalCode := '';
  if pUsuCodigo <= 0 then Exit;
  try
    // 1. Colaborador vinculado (TB_COLABORADOR.CLB_CODUSU)
    ExecConsulta(
      'SELECT CLB_CPF, EXTERNALCODE FROM TB_COLABORADOR ' +
      'WHERE CLB_CODUSU = ' + IntToStr(pUsuCodigo)
    );
    if not Qr_Crud.Eof then
    Begin
      LcDoc := unMaskField(Trim(Qr_Crud.FieldByName('CLB_CPF').AsString));
      if ((Length(LcDoc) = 11) and CalculoCpf(LcDoc)) or
         ((Length(LcDoc) = 14) and CalculoCnpj(LcDoc)) then
      Begin
        pDocumento := LcDoc;
        Exit(True);
      End;
      // Decisao 8 (PDV): EXTERNALCODE nao replica - so documento resolve la
      if GbTerminal <> 0 then Exit(False);
      LcExt := Trim(Qr_Crud.FieldByName('EXTERNALCODE').AsString);
      if LcExt <> '' then
      Begin
        pExternalCode := LcExt;
        Exit(True);
      End;
      // colaborador sem doc e ainda sem externalCode: segura o bloco ate o
      // /salesman sincronizar (auto-heal - decisao 2)
      Exit(False);
    End;
    // 2. Sem colaborador: EXTERNALCODE do proprio usuario (so no servidor)
    if GbTerminal <> 0 then Exit(False);
    ExecConsulta(
      'SELECT EXTERNALCODE FROM TB_USUARIO WHERE USU_CODIGO = ' + IntToStr(pUsuCodigo)
    );
    if not Qr_Crud.Eof then
    Begin
      LcExt := Trim(Qr_Crud.FieldByName('EXTERNALCODE').AsString);
      if LcExt <> '' then
      Begin
        pExternalCode := LcExt;
        Result := True;
      End;
    End;
  except
    // coluna/tabela ausente (banco ainda nao preparado): sem referencia
    Result := False;
  end;
end;

procedure TDM.setBDCrud(BD: TIBDatabase);
begin
  with Qr_Crud do
  Begin
    Active := False;
    Database := BD;
    Transaction := Bd.DefaultTransaction;
  End;
  with Qr_Acao do
  Begin
    Active := False;
    Database := BD;
    Transaction := Bd.DefaultTransaction;
  End;
  with IBSQL do
  Begin
    Database := BD;
    Transaction := Bd.DefaultTransaction;
  End;

end;

end.
