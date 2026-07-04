unit un_dm;

interface

uses
  System.SysUtils, System.Classes, Data.DB, IBX.IBCustomDataSet, IBX.IBQuery,
  IBX.IBDatabase, IBX.IBSQL, listatrigger, FireDAC.Stan.Intf,IniFiles,
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
    function ListTrigger:TListaTrigger;
    procedure execTrigger;
    procedure setBDCrud(BD:TIBDatabase);
    procedure ExecConsulta(SqlTxt: String);
    procedure ExecComando(SqlTxt: String);
    procedure AtivaTrigger(op: Boolean);
    procedure ConectaBancoLocal;
    procedure ConectaBancoServidor;
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses uMain, un_funcoes, un_sistema;

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
  LcPAth := Fc_Aq_Geral('L','SINCRONIA', 'BDPathBDLocal','');
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
  Try
    Lc_Arq_Ini          := TIniFile.Create(getPathExe + 'config.ini');
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
  ConectaBancoLocal;
  ConectaBancoServidor;
end;

procedure TDM.DataModuleDestroy(Sender: TObject);
begin
  IBD_Gestao.Close;
  IBD_Servidor.Close;
end;

procedure TDM.ExecComando(SqlTxt: String);
Var
  I:Integer;
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
Var
I:Integer;
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


procedure TDM.execTrigger;
Var
  LcTrigger : TTrigger;
  LcListaTrigger : TListaTrigger;
  I : Integer;
  LcInsertSincronia : String;
begin
  LcInsertSincronia := ' INSERT INTO TB_SINCRONIA(SRC_CODIGO, SRC_TABELA, SRC_CHAVE, SRC_OPER,SRC_REGISTRO, SRC_TIME) VALUES( ';
  LcTrigger := TTrigger.Create;
  LcListaTrigger := ListTrigger;
  with IBSQL do
  Begin
    Database := IBD_GEstao;
    for I := 0 to LcListaTrigger.Count - 1 do
    Begin
      //DELETE
      if not Transaction.InTransaction then Transaction.StartTransaction;
      sql.Clear;
      LcTrigger := LcListaTrigger.Items[I];
      sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_DEL_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER DELETE POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''D'',''OLD.','',LcTrigger.Campo,'',''',CURRENT_TIMESTAMP);end '
      ));
      Prepare;
      ExecQuery;
      if Transaction.InTransaction then Transaction.Commit;
      //UPDATE
      if not Transaction.InTransaction then Transaction.StartTransaction;
      sql.Clear;
      sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_EDI_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER UPDATE POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''U'',''OLD.','',LcTrigger.Campo,'',''',CURRENT_TIMESTAMP);end '
      ));
      Prepare;
      ExecQuery;
      if Transaction.InTransaction then Transaction.Commit;
      //insert
      if not Transaction.InTransaction then Transaction.StartTransaction;
      sql.Clear;
      sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_INS_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER INSERT POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''I'',''NEW.','',LcTrigger.Campo,'',''',CURRENT_TIMESTAMP);end '
      ));
      Prepare;
      ExecQuery;
      if Transaction.InTransaction then Transaction.Commit;

    End;
  End;
end;

function TDM.ListTrigger: TListaTrigger;
Var
  LcTrigger : TTrigger;
begin
  Result := TListaTrigger.create;
  Result.Clear;
  //Lista Tabelas e Campos
  LcTrigger.Tabela := 'TB_USUARIO';
  LcTrigger.Campo := 'USU_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'CARGO';
  LcTrigger.Campo := 'CRG_CARGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_COLABORADOR';
  LcTrigger.Campo := 'CLB_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_EMPRESA';
  LcTrigger.Campo := 'EMP_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_ENDERECO';
  LcTrigger.Campo := 'END_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_FORMAPAGTO';
  LcTrigger.Campo := 'FPT_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_GRUPOS';
  LcTrigger.Campo := 'GRP_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_SUBGRUPOS';
  LcTrigger.Campo := 'SBG_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_MARCA_PRODUTO';
  LcTrigger.Campo := 'MRC_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_MEDIDA';
  LcTrigger.Campo := 'MED_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_EMBALAGEM';
  LcTrigger.Campo := 'EMB_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_PRODUTO';
  LcTrigger.Campo := 'PRO_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_ESTOQUES';
  LcTrigger.Campo := 'ETS_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_ESTOQUE';
  LcTrigger.Campo := 'EST_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_TABELA_PRECO';
  LcTrigger.Campo := 'TPR_CODIGO';
  Result.Add(LcTrigger);
  LcTrigger.Tabela := 'TB_PRECO';
  LcTrigger.Campo := 'PRC_CODIGO';
  Result.Add(LcTrigger);
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
