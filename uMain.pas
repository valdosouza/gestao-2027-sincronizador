unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Vcl.ImgList, Vcl.Menus, Vcl.Buttons, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  StrUtils, Gauges, System.ImageList, Rtti,
  un_dm, tas_config, un_sistema,
  ControllerBase, ControllerEmpresa, ControllerEndereco,ControllerColaborador,
  ControllerProduto, ControllerCliente, ControllerContaBancaria,
  ControllerPlanoContas,ControllerSincronia,ControllerListaSincronia,
  ObjMerchandise,objSalesMan,  objCustomer,ObjBrand,
  objBankAccount, objFinancialPlans,
  objFinancialStatement, Vcl.AppEvnts,
  customer_send_web,
  un_sincroniza, un_base_setes, UnFunctions, Winapi.ShellAPI, IBX.IBQuery, Vcl.Dialogs,
  payment_type_send_web,bank_account_send_web, cashier_send_web,
  category_send_web,file_send_web,financial_plans_send_web,financial_statement_send_web,
  financial_send_web,invoice_send_web,invoice_merchandise_send_web,
  invoice_rectification_send_web,invoice_return_55_send_web,invoice_return_65_send_web,
  invoice_return_service_send_web,carrier_send_web,
  order_purchase_send_web,order_sale_send_web,order_stock_adjust_send_web,
   promotion_send_web,
  salesman_send_web,
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
    // Limpeza diaria da fila (decisao 9): data da ultima execucao nesta
    // sessao - roda no primeiro ciclo de cada dia.
    FUltimaLimpeza : TDate;
    // Parada graciosa ao fechar: sincronia em andamento + fechamento adiado
    // ate o registro atual concluir (ver FormCloseQuery/FinalizarSincronia).
    FSincronizando   : Boolean;
    FFecharAposSync  : Boolean;


    function  VerificarInternet:boolean;
    function validaAcesso:Boolean;
    procedure execShorCutKeyF5;
    procedure execShorCutKeyF6;
    procedure execShorCutKeyF10;
    procedure execShorCutEsc;

    procedure DefineTimerAtivo;
    procedure DesativaTimer;
    procedure tryExecIBSQL;

    function existTabela(Tabela : String):Boolean;
    function existField(Tabela,campo : String):Boolean;

    procedure ExecutaLimpezaDiaria;
    procedure FinalizarAplicacao;
    procedure execGenerator;



    procedure changeLocal;



    procedure RunScript(Script:String);


    procedure VerificaModoSincronia;

    procedure AtivaInterface(Ativado:Boolean);

    procedure InicializarSincronia;
    procedure ExecutaSincronia;
    procedure FinalizarSincronia(Sender: TObject);









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
  LcTatelas := TIBQuery.Create(nil);
  Try
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
  Result := True;
end;

function TPrincipal.AjustaGenerator: boolean;
Var
  LcEmpresa:TControllerEmpresa;
begin
  Result := True;
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

procedure TPrincipal.ExecutaLimpezaDiaria;
Var
  LcSincronia : TControllerSincronia;
begin
  // Decisao 9: 1x por dia remove da TB_SINCRONIA o que ja foi processado
  // com sucesso (SRC_LOG='OK') ha mais de 48 horas.
  if FUltimaLimpeza = Date then Exit;
  LcSincronia := TControllerSincronia.Create(nil);
  Try
    LcSincronia.DeleteProcessadosAntigos;
    FUltimaLimpeza := Date;
  Finally
    LcSincronia.DisposeOf;
  End;
end;


procedure TPrincipal.changeLocal;
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
        // MORTO (Patch 04/C4, decisao do Valdo 2026-07-25): estas constraints
        // NUNCA rodaram (RunScript nao executava) e o modulo restaurante foi
        // aposentado (D23). Criar PK/FK agora em bancos com dados sujos
        // quebraria o Preparar Local — nao reativar.
        //RunScript('ALTER TABLE TB_CRP_ITENS ADD CONSTRAINT PK_TB_CRP_ITENS PRIMARY KEY (CPI_SABOR, CPI_CODPRO);');
        //RunScript('ALTER TABLE TB_CRP_ITENS ADD CONSTRAINT FK_TB_CRP_ITENS_1 FOREIGN KEY (CPI_CODPRO) REFERENCES TB_PRODUTO (PRO_CODIGO);');
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

procedure TPrincipal.InitVariable;
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
  TmHide.Enabled := (Fc_Aq_Geral('L', 'SISWEB', 'AutoMinimize','S') = 'S');
  Interval := 0;
  NoMinuto := '';
  Interval := StrToIntDef(Fc_Aq_Geral('L','SISWEB', 'intervalo','21'),21);
  if (Interval = 0) then
    NoMinuto := FormatFloat('00',StrtoIntDef( Fc_Aq_Geral('L', 'SISWEB', 'nominuto','05'),5));
  pg_processo.ActivePage := tbs_Send;
  DefineTimerAtivo;
  //Prepara os componente

end;


procedure TPrincipal.FinalizarAplicacao;
begin
  GeralogFile('TPrincipal.FormClose','Roteador - Encerramento');
  Shell_NotifyIcon(NIM_DELETE, @It_TrayIconData);

  Application.OnMessage := nil;
  Application.OnException := nil;
  Application.Terminate;
  //Halt;
end;

procedure TPrincipal.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Fechamento ja autorizado e adiado pela parada graciosa: a sincronia
  // terminou (FinalizarSincronia chamou Close) - finaliza sem perguntar.
  if FFecharAposSync then
  Begin
    if FSincronizando then
      CanClose := False   // ainda aguardando o registro atual - segura
    else
      FinalizarAplicacao;
    Exit;
  End;

  case Application.MessageBox('Finalizar o Sistema!', 'Aten��o', MB_YESNO or MB_APPLMODAL or MB_ICONINFORMATION) of
    mrYes:
      begin
        if FSincronizando then
        Begin
          // Parada graciosa: sinaliza os loops de envio/recebimento (checam
          // entre registros), termina o registro atual com checkpoint e
          // SRC_LOG gravados, e fecha sozinho em FinalizarSincronia.
          TBaseSetes.PararSolicitado := True;
          FFecharAposSync := True;
          DesativaTimer;
          Lb_Processamento.Caption := 'Finalizando - aguardando o registro atual concluir...';
          Lb_Processamento.Update;
          CanClose := False;
        End
        else
          FinalizarAplicacao;
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
                     // Duplo-clique no icone da bandeja RESTAURA a janela
                     // (antes chamava MnuFechar e tentava ENCERRAR o app).
                     MnuRestaurar.Click;
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
  Lc_Upt := TIBQuery.Create(Self);
  try
    with Lc_Upt do
    Begin
      if (not DM.Qr_Crud.Transaction.InTransaction) then DM.Qr_Crud.Transaction.StartTransaction;
      Database    := DM.Qr_Crud.Database;
      Transaction := DM.Qr_Crud.Transaction;
      ForcedRefresh := True;
      SQL.Clear;
      SQL.Add(Script);
      // Patch 04 (C4): faltava executar — o metodo montava o SQL e commitava
      // sem rodar nada, entao NENHUM script dos chamadores jamais foi aplicado.
      ExecSQL;
      if (DM.Qr_Crud.Transaction.InTransaction) then DM.Qr_Crud.Transaction.Commit;
    end;
  Finally
    Lc_Upt.Close;
    Lc_Upt.DisposeOf;
  end;
end;

{
 Terminal = 0 - � o servidor Web
 Terminal = 1 - � o servidor Local
 Terminal = x - PDVs e Disposivos moveis
}



procedure TPrincipal.MnuConfiguraesClick(Sender: TObject);
Var
  Form : TTasConfig;
begin
  if validaAcesso then
  Begin
    Form := TTasConfig.Create(nil);
    Try
      DesativaTimer;
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
    // Usa o DM GLOBAL (criado no .dpr). A versao antiga criava um segundo
    // TDM por cima da variavel global e o destruia no Finally - o resto do
    // app (timers/sincronia) ficava com o DataModule morto e tudo falhava
    // depois de "Preparar Local".
    if not DM.IBD_Gestao.Connected then DM.ConectaBancoLocal;
    if not DM.IBD_Gestao.Connected then
    Begin
      ShowMessage('Nao foi possivel conectar no banco local.' + sLineBreak +
                  'Configure o caminho do banco em Tarefas > Configuracoes e tente novamente.');
      Exit;
    End;
    DM.setBDCrud(DM.IBD_Gestao);
    Try
      if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
      changeLocal;
      if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

      // Bootstrap completo (tabelas de controle, DELETED universal,
      // EXTERNALCODE e triggers TG_SRC_*) - mesmo caminho do start
      // automatico (decisoes 1-10 do prompt de construcao do banco).
      // Erros aparecem aqui (no start automatico vao para o log).
      DM.EnsureSincronia;

      if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
      AjustaGenerator;
      if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

      if not DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.StartTransaction;
      execGenerator;
      if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Commit;

      ShowMessage('Banco preparado com sucesso!');
    Except
      on E: Exception do
      Begin
        if DM.IBT_Atualiza.InTransaction then DM.IBT_Atualiza.Rollback;
        ShowMessage('Falha ao preparar o banco: ' + E.Message);
      End;
    End;
  end;
end;


procedure TPrincipal.MnuFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TPrincipal.FinalizarSincronia(Sender: TObject);
begin
  Try
    AtivaInterface(True);
    FSincronia.DisposeOf;
    chbx_setTimeTo.Checked := False;
    Lb_Processamento.Caption := 'Processo de Sincronia - Aguarde parando a execu��o.....';
    Lb_Processamento.Update;
  except
    on E: Exception do
      GeralogCrashlytics('Roteador.FinalizarSincronia',E.Message);
  end;
  FSincronizando := False;
  // Parada graciosa concluida: o usuario pediu para fechar durante a
  // sincronia - agora fecha de verdade (FormCloseQuery ve FFecharAposSync).
  if FFecharAposSync then Close;
end;


procedure TPrincipal.TmHideTimer(Sender: TObject);
begin
  // Some tambem da barra de tarefas (a janela da Application e a dona do
  // botao) - o app fica so no icone da bandeja; MnuRestaurar reverte.
  ShowWindow(Application.Handle, SW_HIDE);
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
      Lb_Processamento.Caption :=  (Concat('Processo parado e a pr�xima sincronia � no minuto : ',NoMinuto));
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

function TPrincipal.validaAcesso: Boolean;
{$IFNDEF DEBUG}
Var
  LcCodigo : String;
{$ENDIF}
begin
  REsult := True;
  {$IFNDEF DEBUG}
  REsult := False;
  if (InputQuery('Autoriza��o da Acesso ', 'Digite o Codigo de Acessso', LcCodigo)) then
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
  LcLista    : TControllerListaSincronia;
  LcDateTime : TDateTime;
begin
  // Reposicionamento manual do checkpoint (agora em TB_LISTA_SINCRONIA.
  // LAST_UPDATE - decisoes 1 e 3): forca a proxima sincronia a reprocessar
  // a partir da data/hora escolhida na tela.
  if chbx_setTimeTo.Checked then
  Begin
    LcLista := TControllerListaSincronia.Create(nil);
    try
      LcDateTime := Trunc(Dtp_Inicio.DateTime) + Frac(Dtp_Hora.DateTime);
      case rdg_Top_Right.ItemIndex of
        0:LcLista.SetLastUpdateAll('E', LcDateTime);
        1:LcLista.SetLastUpdateAll('R', LcDateTime);
        2:Begin
            LcLista.SetLastUpdateAll('E', LcDateTime);
            LcLista.SetLastUpdateAll('R', LcDateTime);
          End;
      end;
    finally
      LcLista.DisposeOf;
    end;
  End;
end;

function TPrincipal.VerificarInternet: boolean;
begin
  Result := True;
  if Fc_PingConectadoSetes then
  Begin
    Lst_Process_Send.Items.Add('Computador sem conex�o com a Internet');
    Lb_Processamento.Caption := 'Processo de Sincronia - Aguardando conex�o com a Internet...';
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
  // Gate (criterio de sucesso 2): sincronizacao bloqueada ate o bootstrap
  // do banco completar sem erro (DM.EnsureSincronia no DataModuleCreate).
  if (DM = nil) or (not DM.BootstrapOk) then
  Begin
    Lst_Process_Send.Items.Add('Banco de dados nao preparado - sincronizacao bloqueada.');
    Lst_Process_Send.Items.Add('Verifique a conexao local e reinicie o Sincronizador.');
    Lb_Processamento.Caption := 'Processo de Sincronia - BLOQUEADO (banco nao preparado)';
    AtivaInterface(True);
    Exit;
  End;
  ExecutaLimpezaDiaria;
  TBaseSetes.PararSolicitado := False;
  FSincronizando := True;
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
  // Ocultar = so o icone da bandeja: esconde o form E o botao da barra de
  // tarefas (antes fazia SW_NORMAL, deixando o botao visivel).
  ShowWindow(Application.Handle, SW_HIDE);
  principal.Hide;
end;


initialization

  RegisterClass(TCustomerSendWeb);
  RegisterClass(TPaymentTypeSendWeb);
  RegisterClass(TBankAccountSendWeb);
  RegisterClass(TBrandSendWeb);
  RegisterClass(TCarrierSendWeb); // decisao 4 da revisao de entidades (2026-07-25)
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
  RegisterClass(TInvoiceReturnServiceSendWeb); // Patch 04 (C3): NFS-e reativada
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
  // Modulo restaurante APOSENTADO (decisao D23 da revisao do sincronizador,
  // Infra-IA/setes-sync/prompt_revisao_sincronizador_setes_sync.md) - os
  // 7 arquivos rest_*_send_web.pas nao existem mais no projeto (nem a
  // setes-sync tem os endpoints); RegisterClass/uses removidos para o
  // projeto voltar a compilar.

finalization

  UnRegisterClass(TCustomerSendWeb);
  UnRegisterClass(TPaymentTypeSendWeb);
  UnRegisterClass(TBankAccountSendWeb);
  UnRegisterClass(TBrandSendWeb);
  UnRegisterClass(TCarrierSendWeb); // decisao 4
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
  UnRegisterClass(TInvoiceReturnServiceSendWeb); // Patch 04 (C3)
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
  UnRegisterClass(TSalesManSendWeb);
  UnRegisterClass(TStockBalanceSendWeb);
  UnRegisterClass(TStockListSendWeb);
  UnRegisterClass(TStockStatementSendWeb);


end.





