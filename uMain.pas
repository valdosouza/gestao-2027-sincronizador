unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Vcl.ImgList, Vcl.Menus, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  StrUtils, Gauges, System.ImageList, Rtti,
  un_dm, tas_config, un_sistema,listatrigger,
  ControllerBase, ControllerEmpresa, ControllerEndereco,ControllerColaborador,
  ControllerProduto, ControllerCliente, ControllerContaBancaria,
  ControllerPlanoContas,ControllerSyncTable,
  ObjMerchandise,objSalesMan,  objCustomer,ObjBrand,
  objBankAccount, objFinancialPlans,
  objFinancialStatement, Vcl.AppEvnts,
  customer_send_web,
  un_sincroniza, UnFunctions, Winapi.ShellAPI, IBX.IBQuery, Vcl.Dialogs,
  payment_type_send_web,bank_account_send_web, cashier_send_web,
  category_send_web,file_send_web,financial_plans_send_web,financial_statement_send_web,
  financial_send_web,invoice_send_web,invoice_merchandise_send_web,
  invoice_rectification_send_web,invoice_return_55_send_web,invoice_return_65_send_web,
  order_purchase_send_web,order_sale_send_web,order_stock_adjust_send_web,
   promotion_send_web, rest_group_send_web,
  rest_group_has_attribute_send_web,rest_group_has_measure_send_web,rest_group_has_optional_send_web,
  rest_menu_send_web,rest_menu_has_ingrediente_send_web,rest_subgroup_send_web,salesman_send_web,
  stock_balance_send_web,stock_statement_send_web, brand_send_web,
  measure_send_web, merchandise_send_web, price_send_web,price_list_send_web,
  package_send_web,provider_send_web;
type

  TFuncoes = class
    class procedure CriarForm<F: TForm>;
  end;

  TPrincipal = class(TForm)
    PopupMenu1: TPopupMenu;
    MnuRestaurar: TMenuItem;
    MnuFechar: TMenuItem;
    MnuSincronizar: TMenuItem;
    Img_Lista: TImageList;
    Tm_Sync_At_Minut: TTimer;
    MainMenu: TMainMenu;
    arefas1: TMenuItem;
    MnuConfiguraes: TMenuItem;
    pnl_Botao: TPanel;
    Sb_Ocultar: TSpeedButton;
    Sb_Sair: TSpeedButton;
    Gg_Progresso: TGauge;
    TmHide: TTimer;
    MnuPreparaLocal: TMenuItem;
    AppEvents: TApplicationEvents;
    Pnl_Top: TPanel;
    Sb_Sincronizar: TSpeedButton;
    Lb_Processamento: TLabel;
    Dtp_Inicio: TDateTimePicker;
    Dtp_Hora: TDateTimePicker;
    chbx_setTimeTo: TCheckBox;
    Tm_Sync_Interval: TTimer;
    pg_processo: TPageControl;
    tbs_send: TTabSheet;
    tbs_Receive: TTabSheet;
    Lst_Process_Send: TListBox;
    Lst_Process_Receive: TListBox;
    rdg_Top_Right: TRadioGroup;
    pnl_top_Left: TPanel;
    Sb_Enviar: TSpeedButton;
    Sb_Receber: TSpeedButton;
    rayAtualizartoken1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MnuRestaurarClick(Sender: TObject);
    procedure MnuFecharClick(Sender: TObject);
    procedure Sb_SairClick(Sender: TObject);
    procedure Sb_OcultarClick(Sender: TObject);
    procedure TmHideTimer(Sender: TObject);
    procedure MnuPreparaLocalClick(Sender: TObject);
    procedure MnuConfiguraesClick(Sender: TObject);
    procedure Sb_SincronizarClick(Sender: TObject);
    procedure Tm_Sync_At_MinutTimer(Sender: TObject);
    procedure Tm_Sync_IntervalTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    It_TrayIconData: TNotifyIconData;
    NoMinuto : String;
    Interval : Integer;

    FSincronia  : TSincroniza;


    function  VerificarInternet:boolean;
    function validaAcesso:Boolean;
    procedure execShorCutKeyF5;
    procedure execShorCutKeyF6;
    procedure execShorCutKeyF7;
    procedure execShorCutKeyF10;
    procedure execShorCutEsc;

    procedure DefineTimerAtivo;
    procedure DesativaTimer;
    procedure finalizarSync(Sender: TObject);
    procedure tryExecIBSQL;

    function existTabela(Tabela : String):Boolean;
    function existTriguer(Trigger : String):Boolean;
    function existField(Tabela,campo : String):Boolean;
    function existGenerator(Gerador : String):Boolean;

    procedure execTableSincronia;

    procedure execTrigger;
    procedure execGenerator;

    procedure geraSequenciaTB_CRP_ITENS;


    procedure changeServer;
    procedure changeLocal;



    procedure RunScript(Script:String);

    procedure UpdateDadosServidor;
    procedure UpdateDadosLocal;

    procedure VerificaModoSincronia;

    procedure AtivaInterface(Ativado:Boolean);

    procedure InicializarSincronia;
    procedure ExecutaSincronia;
    procedure FinalizarSincronia(Sender: TObject);




    procedure FinalizarEnviar(Sender: TObject);




    procedure FinalizarReceber(Sender: TObject);

    protected procedure WndProc(var Msg: TMessage); override;
  public
    { Public declarations }
    procedure InitVariable;

    Function AjustaGenerator:boolean;
    Function AjustaFaturamento:boolean;

  end;

var
  Principal: TPrincipal;

  const
    WM_ICONTRAY = WM_USER + 1;

implementation

{TFuncoes}

uses  un_funcoes,  tblDevices, stock_list_send_web;



class procedure TFuncoes.CriarForm<F>;
var
  form: F;
begin
  Application.CreateForm(F,form);
  try
    form.ShowModal;
  finally
    FreeAndNil(form);
  end;
end;

{$R *.dfm}






function TPrincipal.existField(Tabela, campo: String): Boolean;
Var
  LcTatelas : TIBQuery;
begin
  Try
    LcTatelas := TIBQuery.Create(nil);
    with LcTatelas do
    Begin
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      sql.Clear;
      sql.Add(concat(
                'select 1 ',
                'from rdb$relation_fields ',
                'where RDB$RELATION_FIELDS.rdb$relation_name =:TABELA AND ',
                'RDB$RELATION_FIELDS.RDB$FIELD_NAME =:CAMPO '
        ));
      ParamByName('TABELA').AsString := Tabela;
      ParamByName('CAMPO').AsString := campo;
      Active := True;
      FetchAll;
      result := (recordCount > 0);
    End;
  Finally
    LcTatelas.Close;
    LcTatelas.DisposeOf;
  end;
end;

function TPrincipal.existGenerator(Gerador: String): Boolean;
Var
  Lc_Qry : TIBQuery;
begin
  Try
    Lc_Qry := TIBQuery.Create(Self);
    with Lc_Qry do
    Begin
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      sql.Clear;

      sql.Add(concat(
                'select rdb$generator_name from rdb$generatorS ',
                'where rdb$generator_name = :nomedogenerator '
      ));
      ParamByName('nomedogenerator').AsString := Gerador;
      IF not Transaction.InTransaction then Transaction.StartTransaction;
      Active := True;
      IF Transaction.InTransaction then Transaction.CommitRetaining;
      FetchAll;
      result := (recordCount > 0);

    End;
  Finally
    Lc_Qry.Close;
    Lc_Qry.DisposeOf;
  End;

end;

function TPrincipal.existTabela(Tabela : String):Boolean;
Var
  LcTatelas : TIBQuery;
begin
  LcTatelas := TIBQuery.Create(Self);
  with LcTatelas do
  Begin
    Database    := DM.Qr_Crud.Database;
    Transaction := DM.Qr_Crud.Transaction;
    ForcedRefresh := True;
    sql.Clear;
    sql.Add(concat(
              'select rdb$relation_name ',
              'from rdb$relations ',
              'where rdb$view_blr is null ',
              'and (rdb$system_flag is null or rdb$system_flag = 0) ',
              ' and (rdb$relation_name=:rdb$relation_name); '
      ));
    ParamByName('rdb$relation_name').AsString := Tabela;
    Active := True;
    FetchAll;
    result := (recordCount > 0);
  End;
end;
function TPrincipal.existTriguer(Trigger: String): Boolean;
Var
  LcTatelas : TIBQuery;
begin
  LcTatelas := TIBQuery.Create(Self);
  with LcTatelas do
  Begin
    Database    := DM.Qr_Crud.Database;
    Transaction := DM.Qr_Crud.Transaction;
    ForcedRefresh := True;
    sql.Clear;
    sql.Add(concat(
              'SELECT RDB$TRIGGER_NAME ',
              'FROM RDB$TRIGGERS ',
              'where RDB$TRIGGER_NAME =:Trigger '
      ));
    ParamByName('Trigger').AsString := Trigger;
    Active := True;
    FetchAll;
    result := (recordCount > 0);
  End;
end;


procedure TPrincipal.finalizarSync(Sender: TObject);
begin

end;


procedure TPrincipal.DefineTimerAtivo;
Var
  LcInterval : String;
begin
  if Interval > 0 then
  Begin
    Tm_Sync_At_Minut.Enabled := False;
    Tm_Sync_Interval.Interval := (Interval * 1000);
    LcInterval := TimeToStr( ( Time + Interval ) );
    Lb_Processamento.Caption :=  (Concat('Processo parado e a próxima sincronia será  às : ',LcInterval));
    Tm_Sync_Interval.Enabled := True;
  End
  else
  Begin
    Tm_Sync_Interval.Enabled := false;
    Tm_Sync_At_Minut.Enabled := True;
    Lb_Processamento.Caption :=  (Concat('Processo parado e a próxima sincronia será no minuto : ',NoMinuto));
  End;
end;


procedure TPrincipal.DesativaTimer;
begin
  Tm_Sync_At_Minut.Enabled := False;
  Tm_Sync_Interval.Enabled := False;
  TmHide.Enabled := False;
end;

function TPrincipal.AjustaFaturamento: boolean;
begin
end;

function TPrincipal.AjustaGenerator: boolean;
Var
  LcEmpresa:TControllerEmpresa;
begin
  try
    try
      LcEmpresa := TControllerEmpresa.Create(Self);
      LcEmpresa.Registro.Codigo := 0;
      LcEmpresa.SetSequencia;
      LcEmpresa.Endereco.Registro.Codigo := 0;
      LcEmpresa.Endereco.SetSequencia;
    finally
      FreeAndNil(LcEmpresa);
    end;
  except
    ShowMessage('Problemas ao Ajustar generator!');
  end;
end;

procedure TPrincipal.AtivaInterface(Ativado: Boolean);
begin
  Try
    Sb_Sincronizar.Enabled  := Ativado;
    Sb_Receber.Enabled      := Ativado;
    Sb_Enviar.Enabled       := Ativado;
    Sb_Sair.Enabled         := Ativado;
    Pnl_Top.Enabled         := Ativado;
    Tm_Sync_Interval.Enabled := Ativado;
    Tm_Sync_At_Minut.Enabled := Ativado;
    if not Ativado then
    BEgin
      Gg_Progresso.Progress := 0;
      Gg_Progresso.MaxValue := 0;
      Gg_Progresso.MinValue := 0;
    end;
  finally
    Self.Update;
  end;
end;

procedure TPrincipal.execGenerator;
Var
  LcBase : TControllerBase;
  LcMax : Integer;
begin
  LcBase := TControllerBase.Create(Self);
  with DM.Qr_Acao do
  Begin
    //TB_PEDIDO
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'select max(PED_CODIGO) SEQ ',
            'FROM TB_PEDIDO '
    ));
    try
      Active := True;
      LcMax := FieldByname('SEQ').AsInteger;
      LcBase.setGenerator('GN_PEDIDO',IntToStr(LcMax));
    except
      Active := False;
    end;
    //TB_NOTA_FISCAL
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'select max(NFL_CODIGO) SEQ ',
            'FROM TB_NOTA_FISCAL '
    ));
    try
      Active := True;
      LcMax := FieldByname('SEQ').AsInteger;
      LcBase.setGenerator('GN_NOTA_FISCAL',IntToStr(LcMax));
    except
      Active := False;
    end;
  End;
end;

procedure TPrincipal.execShorCutEsc;
begin
  if Sb_Sair.Enabled then  Sb_SairClick(Self);
end;

procedure TPrincipal.execShorCutKeyF10;
begin
  Sb_OcultarClick(Self);
end;

procedure TPrincipal.execShorCutKeyF5;
begin
  if Sb_Sincronizar.Enabled then  Sb_SincronizarClick(Self);
end;

procedure TPrincipal.execShorCutKeyF6;
begin

end;

procedure TPrincipal.execShorCutKeyF7;
begin

end;

procedure TPrincipal.execTableSincronia;
begin
  with DM.IBSQL do
  Begin
    if not existTabela('TB_SINCRONIA') then
    Begin
      sql.Clear;
      sql.Add(concat(
              'CREATE TABLE TB_SINCRONIA ( ',
              '  SRC_CODIGO    INTEGER NOT NULL PRIMARY KEY , ',
              '  SRC_TABELA    VARCHAR(30) CHARACTER SET WIN1252 COLLATE WIN_PTBR, ',
              '  SRC_CHAVE     VARCHAR(30) CHARACTER SET WIN1252 COLLATE WIN_PTBR, ',
              '  SRC_OPER      CHAR(1) CHARACTER SET WIN1252 COLLATE WIN_PTBR, ',
              '  SRC_TIME      TIMESTAMP, ',
              '  SRC_REGISTRO  INTEGER);'
      ));
      tryExecIBSQL;
    End;
    if not existTriguer('TG_SINCRONIA') then
    Begin
      sql.Clear;
      sql.Add(concat(
                'CREATE OR ALTER TRIGGER TG_SINCRONIA FOR TB_SINCRONIA ',
                'ACTIVE BEFORE INSERT POSITION 0 ',
                'AS BEGIN NEW.SRC_CODIGO = GEN_ID(GN_SINCRONIA, 1); END '
      ));
      tryExecIBSQL;
    End;
    if not existTabela('TB_SYNC_TABLE') then
    Begin
      sql.Clear;
      sql.Add(concat(
                'CREATE TABLE TB_SYNC_TABLE ( ',
                '    ID         VARCHAR(100) CHARACTER SET WIN1252 NOT NULL COLLATE WIN_PTBR, ',
                '    DT_UPDATE  DATE, ',
                '    TM_UPDATE  TIME, ',
                '    OPERATOR   INTEGER, ',
                '   UPDATE_AT  TIMESTAMP, ',
                '    WAY        CHAR(1) NOT NULL  );'
      ));
      tryExecIBSQL;
      sql.Clear;
      sql.Add(concat(
                'ALTER TABLE TB_SYNC_TABLE ADD CONSTRAINT PK_TB_SYNC_TABLE PRIMARY KEY ( ID, WAY );'
      ));
      tryExecIBSQL;
    End;
    if not existField('TB_SYNC_TABLE','WAY') then
    Begin
      sql.Clear;
      sql.Add(concat(
                'ALTER TABLE TB_SYNC_TABLE ADD  WAY CHAR(1);'
      ));
      tryExecIBSQL;
    End;
  End;
end;

procedure TPrincipal.execTrigger;
Var
  LcTrigger : TTrigger;
  LcListaTrigger : TControllerTrigger;
  I : Integer;
  LcInsertSincronia : String;
begin
  LcInsertSincronia := ' INSERT INTO TB_SINCRONIA(SRC_CODIGO, SRC_TABELA, SRC_CHAVE, SRC_OPER,SRC_REGISTRO, SRC_TIME) VALUES( ';
  LcListaTrigger := TControllerTrigger.Create(nil);
  LcListaTrigger.getlist;
  Gg_Progresso.Progress := 0;
  Gg_Progresso.MinValue := 0;
  Gg_Progresso.MaxValue := LcListaTrigger.Lista.Count;
  Gg_Progresso.Update;
  for I := 0 to LcListaTrigger.Lista.Count - 1 do
  Begin
    LcTrigger := LcListaTrigger.Lista[I];
    if Trim(LcTrigger.Tabela)<> '' then
    Begin
      DM.IBSQL.sql.Clear;
      DM.IBSQL.sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_DEL_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER DELETE POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''D'',OLD.',LcTrigger.Campo,',CURRENT_TIMESTAMP);end '
      ));
      tryExecIBSQL;
      //UPDATE
      DM.IBSQL.sql.Clear;
      DM.IBSQL.sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_EDI_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER UPDATE POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''U'',OLD.',LcTrigger.Campo,',CURRENT_TIMESTAMP);end '
      ));
      tryExecIBSQL;
      //insert
      DM.IBSQL.sql.Clear;
      DM.IBSQL.sql.Add(concat(
              'CREATE OR ALTER TRIGGER TG_SRC_INS_',LcTrigger.Tabela, ' FOR TB_',LcTrigger.Tabela,
              ' ACTIVE AFTER INSERT POSITION 0 ',
              'AS begin ',LcInsertSincronia,'0,','''TB_',LcTrigger.Tabela,''',''',LcTrigger.Campo,''',''I'',NEW.',LcTrigger.Campo,',CURRENT_TIMESTAMP);end '
      ));
      tryExecIBSQL;
      Gg_Progresso.Progress := Gg_Progresso.Progress + 1;
      Gg_Progresso.Update;
    End;
  End;
end;


procedure TPrincipal.changeLocal;
Var
  I : Integer;
  LcDateTime : TDateTime;
begin
  RunScript('UPDATE tb_medida SET MED_ESPECIAL = ''PIZZA'' WHERE MED_ESPECIAL = ''PIZZAS'' ;');
  RunScript('UPDATE tb_medida SET MED_ESPECIAL = ''BEBIDA'' WHERE MED_ESPECIAL = ''BEBIDAS'' ;');
  RunScript('UPDATE tb_medida SET MED_ESPECIAL = ''BORDA'' WHERE MED_ESPECIAL = ''BORDAS'' ;');

  if not existTabeLA('TB_CRP_ITENS') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add(concat(
                'CREATE TABLE TB_CRP_ITENS ( ',
                '    CPI_SABOR      VARCHAR(100), ',
                '    CPI_SEQUENCIA  INTEGER, ',
                '    CPI_CODPRO     INTEGER NOT NULL, ',
                '    CPI_QTDE       NUMERIC(10,3), ',
                '    CPI_VALOR      NUMERIC(10,3), ',
                '    CPI_TIPO       VARCHAR(1), ',
                '    CPI_CODIGO     INTEGER, ',
                '    CPI_CODGRP     INTEGER); '
      ));
      Try
        tryExecIBSQL;
        RunScript('ALTER TABLE TB_CRP_ITENS ADD CONSTRAINT PK_TB_CRP_ITENS PRIMARY KEY (CPI_SABOR, CPI_CODPRO);');
        RunScript('ALTER TABLE TB_CRP_ITENS ADD CONSTRAINT FK_TB_CRP_ITENS_1 FOREIGN KEY (CPI_CODPRO) REFERENCES TB_PRODUTO (PRO_CODIGO);');
      except
        sql.Clear;
      End;
    End;
  End;

  if not existField('TB_CRP_ITENS','CPI_CODIGO') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_CRP_ITENS ADD CPI_CODIGO INTEGER;');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

  if not existField('TB_RETORNO_NFC','NFC_NUMERO') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_RETORNO_NFC ADD NFC_NUMERO INTEGER;');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

  if not existField('TB_PEDIDO','PED_TERMINAL') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_PEDIDO ADD PED_TERMINAL INTEGER;');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

  if not existField('TB_RETORNO_NFC','NFC_SERIE') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_RETORNO_NFC ADD NFC_SERIE integer;');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

  if not existField('TB_RETORNO_NFE','NFE_SERIE') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_RETORNO_NFE ADD NFE_SERIE integer;');
      Try
        tryExecIBSQL;
      except
        sql.Clear;
      End;
    End;
  End;

  if not existTabeLA('TB_GESTAO_WEB') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add(concat(
              'CREATE TABLE TB_GESTAO_WEB ( ',
              '    TABELA  VARCHAR(50) NOT NULL, ',
              '    ID      INTEGER NOT NULL, ',
              '    WEB_ID  INTEGER );'
      ));
      Try
        tryExecIBSQL;
      except
        sql.Clear;
      End;
    End;
  End;


  if existTabeLA('TB_GESTAO_WEB') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add(concat(
              'ALTER TABLE TB_GESTAO_WEB ADD PRIMARY KEY (TABELA, ID);'
      ));
      Try
        tryExecIBSQL;
      except
        sql.Clear;
      End;
    End;
  End;


  if not existField('TB_FORMAPAGTO','FPT_APP_DELIVERY') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_FORMAPAGTO ADD FPT_APP_DELIVERY  CHAR(1);');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

  if not existField('TB_GRUPOS','GRP_SHOW_MENU') then
  Begin
    with DM.IBSQL do
    Begin
      sql.Clear;
      sql.Add('ALTER TABLE TB_GRUPOS ADD GRP_SHOW_MENU CHAR(1);');
      try
        tryExecIBSQL;
      except
        sql.Clear;
      end;
    End;
  End;

end;

procedure TPrincipal.changeServer;
begin
  if not existField('TB_RETORNO_NFC','NFC_SERIE') then
  Begin
    with DM.IBSQL do
    Begin
      Database    := DM.IBD_Servidor;
      Transaction := DM.IBT_Servidor;
      sql.Clear;
      sql.Add('ALTER TABLE TB_RETORNO_NFC ADD NFC_SERIE integer;');
      tryExecIBSQL;
    End;
  End;

  if not existField('TB_RETORNO_NFE','NFC_SERIE') then
  Begin
    with DM.IBSQL do
    Begin
        sql.Clear;
        sql.Add('ALTER TABLE tb_retorno_nfe ADD NFE_SERIE integer;');
        tryExecIBSQL;
    End;
  End;

  if not existField('TB_RETORNO_NFC','NFC_NUMERO') then
  Begin
    with DM.IBSQL do
    Begin
        sql.Clear;
        sql.Add('ALTER TABLE TB_RETORNO_NFC ADD NFC_NUMERO INTEGER;');
        tryExecIBSQL;
    End;
  End;

  with DM.IBSQL do
  Begin
    sql.Clear;
    sql.Add(concat(
              'update RDB$RELATION_FIELDS set ',
              'RDB$NULL_FLAG = 1 ',
              'where (RDB$FIELD_NAME = ''NFC_CODMHA'') and ',
              '(RDB$RELATION_NAME = ''TB_RETORNO_NFC'') '
    ));
    tryExecIBSQL;
  End;

  with DM.IBSQL do
  Begin
    sql.Clear;
    sql.Add('DROP TRIGGER TG_RETORNO_NFC;');
    tryExecIBSQL;
  End;

end;




procedure TPrincipal.InitVariable;
Var
  Lc_DLabel : Array[0..11] of Char;
  ipbuffer : string;
  nsize : dword;
begin
  GeralogFile('TPrincipal.InitVariable','Roteador - Abertura');
  Dtp_Inicio.DateTime := Now;
  Dtp_Hora.DateTime := Now;
  Sb_Receber.Visible  := ( Fc_Aq_Geral('L','SISWEB', 'ReceiveWebServer','S') = 'S');
  Sb_Enviar.Visible   := ( Fc_Aq_Geral('L','SISWEB', 'SendToWebServer','S') = 'S');
  with It_TrayIconData do
  begin
    cbSize := Sizeof;//(It_TrayIconData);
    Wnd := Handle;
    uID := 0;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := Application.Icon.Handle;
    StrPCopy(SzTip, Application.Title);
  end;
  Shell_NotifyIcon(NIM_ADD, @It_TrayIconData);
  TmHide.Enabled := (Fc_Aq_Geral('L', 'SINCRONIA', 'AutoMinimize','S') = 'S');
  Interval := 0;
  NoMinuto := '';
  Interval := StrToIntDef(Fc_Aq_Geral('L','SINCRONIA', 'intervalo','21'),21);
  if (Interval = 0) then
    NoMinuto := FormatFloat('00',StrtoIntDef( Fc_Aq_Geral('L', 'SINCRONIA', 'nominuto','05'),5));
  pg_processo.ActivePage := tbs_Send;
  DefineTimerAtivo;
  //Prepara os componente

end;


procedure TPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  case Application.MessageBox('Finalizar o Sistema!', 'Atenção', MB_YESNO or MB_APPLMODAL or MB_ICONINFORMATION) of
    mrYes:
      begin
        GeralogFile('TPrincipal.FormClose','Roteador - Encerramento');
        Shell_NotifyIcon(NIM_DELETE, @It_TrayIconData);

        Application.OnMessage := nil;
        Application.OnException := nil;
        Application.Terminate;
        //Halt;
      end;
    mrNo: CanClose := False;
  end;

end;

procedure TPrincipal.FormCreate(Sender: TObject);
begin
  InitVariable;
end;

procedure TPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (shift = []) then
  begin
    case Key of
      VK_F5:execShorCutKeyF5;
      VK_F6:execShorCutKeyF6;
      VK_F10:execShorCutKeyF10;
      VK_Escape:execShorCutEsc;
    end;
  end;
end;

procedure TPrincipal.geraSequenciaTB_CRP_ITENS;
var
  Lc_Qry : TIBQuery;
  Lc_Upt: TIBQuery;
  Lc_aux :String;
  Lc_ItensId : Integer;
begin
  try
    Lc_Upt := TIBQuery.Create(Self);
    with Lc_Upt do
    Begin
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      sql.Clear;

      SQL.Clear;
      SQL.Add('UPDATE TB_CRP_ITENS SET CPI_CODIGO =:CPI_CODIGO WHERE (CPI_SABOR = :CPI_SABOR) AND (CPI_CODPRO =:CPI_CODPRO);  ' );
    end;
    Lc_Qry := TIBQuery.Create(Self);
    with Lc_Qry do
    Begin
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      SQL.Clear;
      SQL.Add('SELECT CPI_SABOR,CPI_CODPRO FROM  TB_CRP_ITENS  WHERE (CPI_CODIGO IS NULL) or (CPI_CODIGO = 0)  ' );
      active := True;
    end;
    Lc_ItensId := 0;
    Lc_Qry.First;
    while not Lc_Qry.eof do
    Begin
      Lc_Upt.close;
      Lc_ItensId := Lc_ItensId + 1;
      Lc_Upt.paramByName('CPI_CODIGO').AsInteger  := Lc_ItensId;
      Lc_Upt.paramByName('CPI_SABOR').AsString    := Lc_Qry.FieldByName('CPI_SABOR').AsString;
      Lc_Upt.paramByName('CPI_CODPRO').AsInteger  := Lc_Qry.FieldByName('CPI_CODPRO').AsInteger;
      if not Lc_Upt.Transaction.InTransaction then Lc_Upt.Transaction.StartTransaction;
      Lc_Upt.ExecSQL;
      if Lc_Upt.Transaction.InTransaction then Lc_Upt.Transaction.commit;
      Lc_Qry.Next;
    End;
    RunScript(concat('set generator GN_CRP_ITENS TO ',Lc_ItensId.ToString,';'));
  finally
    Lc_Qry.close;
    Lc_Qry.DisposeOf;
    Lc_Upt.close;
    Lc_Upt.DisposeOf;
  end;
end;

procedure TPrincipal.WndProc(var Msg: TMessage);
var
  Lc_P: TPoint;
begin
  case Msg.Msg of
  WM_USER + 1:
  case Msg.lParam of
    WM_RBUTTONDOWN:begin
                   SetForegroundWindow(Handle);
                   GetCursorPos(Lc_P);
                   PopupMenu1.Popup(Lc_P.x,Lc_P.y);
                   PostMessage(Handle, WM_NULL, 0, 0);
                   end;
    WM_LBUTTONDBLCLK:begin
                     MnuFechar.Click;
                    end;
    end;
  end;
  inherited;
end;



procedure TPrincipal.MnuRestaurarClick(Sender: TObject);
begin
  Principal.Show;
  ShowWindow(Application.Handle, SW_NORMAL);
end;

procedure TPrincipal.RunScript(Script: String);
VAr
  Lc_Upt : TIBQuery;
begin
  try
    Lc_Upt := TIBQuery.Create(Self);
    with Lc_Upt do
    Begin
      if (not DM.Qr_Crud.Transaction.InTransaction) then DM.Qr_Crud.Transaction.StartTransaction;
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      SQL.Clear;
      SQL.Add('UPDATE TB_CRP_ITENS SET CPI_CODIGO =:CPI_CODIGO WHERE (CPI_SABOR = :CPI_SABOR) AND (CPI_CODPRO =:CPI_CODPRO);  ' );
      if (DM.Qr_Crud.Transaction.InTransaction) then DM.Qr_Crud.Transaction.Commit;
    end;
  Finally
    Lc_Upt.Close;
    Lc_Upt.DisposeOf;
  end;
end;

{
 Terminal = 0 - É o servidor Web
 Terminal = 1 - É o servidor Local
 Terminal = x - PDVs e Disposivos moveis
}



procedure TPrincipal.MnuConfiguraesClick(Sender: TObject);
Var
  Form : TTasConfig;
begin
  if validaAcesso then
  Begin
    Try
      DesativaTimer;
      Form := TTasConfig.Create(nil);
      Form.ShowModal;
    Finally
      Form.DisposeOf;
      DefineTimerAtivo;
    End;
  end;
end;

procedure TPrincipal.MnuPreparaLocalClick(Sender: TObject);
begin
  if validaAcesso then
  Begin
    Try
      DM  := TDM.Create(Application);
      if VerificaConectaBanco(True,Fc_Aq_Geral('L','SINCRONIA', 'BDPathBDLocal','')) then
      Begin
        dm.setBDCrud(dm.IBD_Gestao);
        if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
        changeLocal;
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

        if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
        execTableSincronia;
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

        if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
        AjustaGenerator;
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

        if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
        execTrigger;
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

        if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
        execGenerator;
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;



        ShowMessage('Ajustes executados no Local com sucesso!!');
      End;
    Finally
      if DM.IBD_Gestao.Connected then
        DM.IBD_Gestao.Connected := False;
      if DM.IBD_Servidor.Connected then
        DM.IBD_Servidor.Connected := False;
      DM.DisposeOf;
    End;
  end;
end;


procedure TPrincipal.MnuFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure comando(wCOMANDO:String);
var
  Lc_pi: TProcessInformation;
  Lc_si: TStartupInfo;
  Lc_RESULT:boolean;
begin
  FillMemory( @Lc_si, sizeof( Lc_si ), 0 );
  FillChar ( Lc_si, Sizeof (Lc_si), #0);
  Lc_si.cb := sizeof( Lc_si );
  Lc_si.dwFlags := STARTF_USESHOWWINDOW;
  Lc_si.wShowWindow:=SW_HIDE;
  if Lc_Result then
    begin
    WaitForSingleObject(Lc_PI.hProcess, INFINITE);
    //Libera os Handles
    CloseHandle(Lc_pi.hProcess);
    CloseHandle(Lc_pi.hThread);
    end;
end;

procedure TPrincipal.FinalizarEnviar(Sender: TObject);
begin
  Try
    AtivaInterface(True);
    chbx_setTimeTo.Checked := False;
    Lb_Processamento.Caption := 'Processo de Envio - Aguarde parando a execução.....';
    Lb_Processamento.Update;
  except
    on E: Exception do
      GeralogCrashlytics('Roteador.FinalizarEnviar',E.Message);
  end;
end;

procedure TPrincipal.FinalizarReceber(Sender: TObject);
begin
  Try
    AtivaInterface(True);
    chbx_setTimeTo.Checked := False;
    Lb_Processamento.Caption := 'Processo de Sincronia - Aguarde parando a execução.....';
    Lb_Processamento.Update;
  except
    on E: Exception do
      GeralogCrashlytics('Roteador.FinalizarReceber',E.Message);
  end;
end;

procedure TPrincipal.FinalizarSincronia(Sender: TObject);
begin
  Try
    AtivaInterface(True);
    FSincronia.DisposeOf;
    chbx_setTimeTo.Checked := False;
    Lb_Processamento.Caption := 'Processo de Sincronia - Aguarde parando a execução.....';
    Lb_Processamento.Update;
  except
    on E: Exception do
      GeralogCrashlytics('Roteador.FinalizarSincronia',E.Message);
  end;
end;


procedure TPrincipal.TmHideTimer(Sender: TObject);
begin
  principal.Hide;
  if TmHide.Enabled  then
  Begin
    TmHide.Enabled := FAlse;
  End;
end;

procedure TPrincipal.Tm_Sync_At_MinutTimer(Sender: TObject);
Var
  LcMinuto : String;
begin
  if VerificarInternet then
  Begin;
    LcMinuto := Copy(TimeToStr(Now),4,2);
    if LcMinuto = NoMinuto then
    Begin
      GeralogFile('TPrincipal.Tm_Sync_At_Minut','Evento acionado pelo Timer No Minuto');
      InicializarSincronia;
      VerificaModoSincronia;
      ExecutaSincronia;
    End
    else
    Begin
      Lb_Processamento.Caption :=  (Concat('Processo parado e a próxima sincronia é no minuto : ',NoMinuto));
      Lb_Processamento.Update;
    End;
  end;
end;

procedure TPrincipal.Tm_Sync_IntervalTimer(Sender: TObject);
begin
  if VerificarInternet then
  Begin;
    GeralogFile('TPrincipal.Tm_Sync_Interval','Evento acionado pelo Timer Intervalo');
    InicializarSincronia;
    VerificaModoSincronia;
    ExecutaSincronia;
  end;
end;

procedure TPrincipal.tryExecIBSQL;
begin
  with dm.IBSQL do
  Begin
    try
      Prepare;
      ExecQuery;
    except
    on E : Exception do
      Begin
        ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
        DM.IBSQL.Unprepare;
        DM.IBSQL.Close;
      End;
    end;
  End;
end;

procedure TPrincipal.UpdateDadosLocal;
begin
  with DM.Qr_Acao do
  Begin
    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE TB_FORMAPAGTO SET ',
            ' FPT_LIMITE  = ''N'' '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;

    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE TB_COLABORADOR SET ',
            ' CLB_SITUACAO  = ''N'' '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;

    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE TB_PRODUTO SET ',
            ' PRO_CODRVT  = 0 '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;

    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE TB_CLIENTE SET ',
            ' CLI_ISS_NR_PROCESSO = 0 '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;

    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE TB_CONTABANCARIA  SET ',
            ' CTB_VL_LIMITE = 0 '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;

    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
              'UPDATE TB_PLANOCONTAS SET ',
              'PLC_DESCRICAO = PLC_DESCRICAO ||  '' '' '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;


    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE tb_movim_financeiro M SET ',
            ' M.MVF_ID_ECF = 1 '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;
  End;
end;

procedure TPrincipal.UpdateDadosServidor;
begin
  with DM.Qr_Acao do
  Begin
    if not DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.StartTransaction;
    Active := False;
    sql.Clear;
    sql.Add(concat(
            'UPDATE tb_movim_financeiro M SET ',
            ' M.MVF_ID_ECF = 1 '
    ));
    ExecSQL;
    if DM.Qr_Acao.Transaction.InTransaction then DM.Qr_Acao.Transaction.Commit;
  End;
end;

function TPrincipal.validaAcesso: Boolean;
Var
  LcCodigo : String;
begin
  REsult := True;
  {$IFNDEF DEBUG}
  REsult := False;
  if (InputQuery('Autorização da Acesso ', 'Digite o Codigo de Acessso', LcCodigo)) then
  Begin
    if LcCodigo ='eqpm50m$' then
      Result := True
    else
    Begin
      ShowMessage('Codigo incorreto Acesso Negado');
    end;
  end;
  {$ENDIF}

end;

procedure TPrincipal.VerificaModoSincronia;
Var
  LcSync : TControllerSyncTable;
begin
  if chbx_setTimeTo.Checked then
  Begin
    try
      LcSync := TcontrollerSyncTable.Create(nil);
      LcSync.Registro.Data := Dtp_Inicio.DateTime;
      LcSync.Registro.Hora := Dtp_Hora.DateTime;
      case rdg_Top_Right.ItemIndex of
        0:LcSync.Registro.Sentido := 'W';
        1:LcSync.Registro.Sentido := 'D';
        2:LcSync.Registro.Sentido := 'A';
      end;
      LcSync.setTimeToWEb;
    finally
      LcSync.DisposeOf;
    end;
  End;
end;

function TPrincipal.VerificarInternet: boolean;
begin
  Result := True;
  if Fc_PingConectadoSetes then
  Begin
    Lst_Process_Send.Items.Add('Computador sem conexão com a Internet');
    Lb_Processamento.Caption := 'Processo de Sincronia - Aguardando conexão com a Internet...';
    Application.ProcessMessages;
  end;

end;

procedure TPrincipal.Sb_SairClick(Sender: TObject);
begin
  Self.Close;
end;



procedure TPrincipal.Sb_SincronizarClick(Sender: TObject);
begin
  if VerificarInternet then
  Begin
    InicializarSincronia;
    VerificaModoSincronia;
    ExecutaSincronia;
  end;
end;

procedure TPrincipal.ExecutaSincronia;
Var
  LcSinc : TThread;
begin
  LcSinc := TThread.CreateAnonymousThread(
  procedure
  begin
    FSincronia                 := TSincroniza.Create(self);
    FSincronia.ListBoxSend     := Lst_Process_Send;
    FSincronia.ListBoxReceive  := Lst_Process_Receive;
    FSincronia.Progresso       := Gg_Progresso;
    FSincronia.execute;
  end);
  LcSinc.FreeOnTerminate := True;
  LcSinc.OnTerminate := FinalizarSincronia;
  LcSinc.start();
end;


procedure TPrincipal.InicializarSincronia;
begin
  Lst_Process_Send.Items.Clear;
  Lst_Process_Receive.Items.Clear;
  Lb_Processamento.Caption := 'Processo de Sincronia - Executando...';
  AtivaInterface(False);
  Self.Update;
end;

procedure TPrincipal.Sb_OcultarClick(Sender: TObject);
begin
  Principal.Show;
  ShowWindow(Application.Handle, SW_NORMAL);
  principal.Hide;
end;


initialization

  RegisterClass(TCustomerSendWeb);
  RegisterClass(TPaymentTypeSendWeb);
  RegisterClass(TBankAccountSendWeb);
  RegisterClass(TBrandSendWeb);
  RegisterClass(TCashierSendWeb);
  RegisterClass(TCategorySendWeb);
  RegisterClass(TFileSendWeb);
  RegisterClass(TFinancialPlansSendWeb);
  RegisterClass(TFinancialStatementSendWeb);
  RegisterClass(TFinancialSendWeb);
  RegisterClass(TInvoiceSendWeb);
  RegisterClass(TInvoiceMerchandiseSendWeb);
  RegisterClass(TInvoiceRectificationSendWeb);
  RegisterClass(TInvoiceReturn55SendWeb);
  RegisterClass(TInvoiceReturn65SendWeb);
  //RegisterClass(TInvoiceReturnServiceSendWeb);
  RegisterClass(TMeasureSendWeb);
  RegisterClass(TMerchandiseSendWeb);
  RegisterClass(TOrderPurchaseSendWeb);
  RegisterClass(TOrderSaleSendWeb);
  RegisterClass(TOrderStockAdjustSendWeb);
  RegisterClass(TPackageSendWeb);
  RegisterClass(TPriceSendWeb);
  RegisterClass(TPriceListSendWeb);
  RegisterClass(TPromotionSendWeb);
  RegisterClass(TProviderSendWeb);
  RegisterClass(TSalesManSendWeb);
  RegisterClass(TStockBalanceSendWeb);
  RegisterClass(TStockListSendWeb);
  RegisterClass(TStockStatementSendWeb);
  RegisterClass(TRestGroupSendWeb);
  RegisterClass(TRestSubGroupSendWeb);
  RegisterClass(TRestMenuSendWeb);
  RegisterClass(TRestGroupHasAttributeSendWeb);
  RegisterClass(TRestGroupHasMeasureSendWeb);
  RegisterClass(TRestGroupHasOptionalSendWeb);
  RegisterClass(TRestMenuHasIngredienteSendWeb);


finalization

  UnRegisterClass(TCustomerSendWeb);
  UnRegisterClass(TPaymentTypeSendWeb);
  UnRegisterClass(TBankAccountSendWeb);
  UnRegisterClass(TBrandSendWeb);
  UnRegisterClass(TCashierSendWeb);
  UnRegisterClass(TCategorySendWeb);
  UnRegisterClass(TFileSendWeb);
  UnRegisterClass(TFinancialPlansSendWeb);
  UnRegisterClass(TFinancialStatementSendWeb);
  UnRegisterClass(TFinancialSendWeb);
  UnRegisterClass(TInvoiceSendWeb);
  UnRegisterClass(TInvoiceMerchandiseSendWeb);
  UnRegisterClass(TInvoiceRectificationSendWeb);
  UnRegisterClass(TInvoiceReturn55SendWeb);
  UnRegisterClass(TInvoiceReturn65SendWeb);
  //UnRegisterClass(TInvoiceReturnServiceSendWeb);
  UnRegisterClass(TMeasureSendWeb);
  UnRegisterClass(TMerchandiseSendWeb);
  UnRegisterClass(TOrderPurchaseSendWeb);
  UnRegisterClass(TOrderSaleSendWeb);
  UnRegisterClass(TOrderStockAdjustSendWeb);
  UnRegisterClass(TPackageSendWeb);
  UnRegisterClass(TPriceSendWeb);
  UnRegisterClass(TPriceListSendWeb);
  UnRegisterClass(TPromotionSendWeb);
  UnRegisterClass(TProviderSendWeb);
  UnRegisterClass(TRestGroupSendWeb);
  UnRegisterClass(TRestGroupHasAttributeSendWeb);
  UnRegisterClass(TRestGroupHasMeasureSendWeb);
  UnRegisterClass(TRestGroupHasOptionalSendWeb);
  UnRegisterClass(TRestMenuSendWeb);
  UnRegisterClass(TRestMenuHasIngredienteSendWeb);
  UnRegisterClass(TRestSubGroupSendWeb);
  UnRegisterClass(TSalesManSendWeb);
  UnRegisterClass(TStockBalanceSendWeb);
  UnRegisterClass(TStockListSendWeb);
  UnRegisterClass(TStockStatementSendWeb);


end.





