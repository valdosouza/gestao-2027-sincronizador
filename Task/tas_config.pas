unit tas_config;

interface

{$WARN UNIT_PLATFORM OFF}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,   StdCtrls, Spin, ComCtrls, ExtCtrls, DB, ADODB, IniFiles,
  Mask, DBCtrls, Grids, Buttons, ShellAPI, Menus, registry, OleCtrls,
  SHDocVw,   TabNotBk, jpeg, DBGrids, FileCtrl, ImgList, base_form,
  StrUtils, Gauges, IBDatabase, IBServices, System.ImageList,  Un_Msg,
  ControllerDskCategory,ControllerMarcaProduto,ControllerMedida,
  ControllerEmbalagem,ControllerEstoques,ControllerEstoque,ControllerTabelaPreco,
  ControllerPreco,ControllerCliente,ControllerFornecedor,ControllerColaborador,
  ControllerFormaPagamento,ControllerProduto,Vcl.CheckLst, ControllerMovimentoFinanceiro,
  ControllerDskCashier,ControllerREtornoNfe,ControllerREtornoNFCe,ControllerArquivo,
  ControllerFinanceiro,controllerCartaCorrecao,
  IBX.IBQuery,ControllerPedido,ControllerNotaFiscal,ControllerDskPromotion,
  ControllerContaBancaria,ControllerHistoricoBancario,ControllerCrpItens,ControllerGrupos,
  ControllerSubGrupos;


type

  TTasConfig = class(TBaseForm)
    pnl_rodape: TPanel;
    SpeedButton1: TSpeedButton;
    Sb_Close: TSpeedButton;
    pg_Principal: TPageControl;
    tbs_conexao: TTabSheet;
    pnl_config: TPanel;
    Label4: TLabel;
    Label1: TLabel;
    Label5: TLabel;
    ChBx_IniciarWindows: TCheckBox;
    E_institution_origem: TEdit;
    E_CNPJ: TEdit;
    Label2: TLabel;
    E_Path_BD_Local: TEdit;
    Label3: TLabel;
    E_Intervalo: TEdit;
    E_NoMinuto: TEdit;
    UpD_Intervalor: TUpDown;
    tbs_sistema_web: TTabSheet;
    GG_Web_Process: TGauge;
    Pg_Sistema_web: TPageControl;
    tbs_sistema_web_send: TTabSheet;
    tbs_ExcecoesEnvio: TTabSheet;
    Lb_Web_Process: TLabel;
    ChLBx_First_Charge: TCheckListBox;
    ChLBx_Excecoes_Envio: TCheckListBox;
    Sb_IntoQuue: TSpeedButton;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    Panel2: TPanel;
    tbs_process_export: TTabSheet;
    Lst_Process_Export: TListBox;
    tbs_ExcecoesReceber: TTabSheet;
    ChLBx_Excecoes_Recebo: TCheckListBox;
    TabSheet3: TTabSheet;
    pnl_valida: TPanel;
    Cb_Validacao: TComboBox;
    Label8: TLabel;
    Sb_Valida_Inicia: TSpeedButton;
    Chbx_AutoMinimize: TCheckBox;
    tbs_SistemaWeb_Geral: TTabSheet;
    Panel4: TPanel;
    Chbx_ReceiveWebServer: TCheckBox;
    Chbx_SendToWebServer: TCheckBox;
    TabSheet4: TTabSheet;
    Panel6: TPanel;
    Dtp_Data_Inicial: TDateTimePicker;
    Dtp_Data_Final: TDateTimePicker;
    ChBx_Periodo: TCheckBox;
    Label7: TLabel;
    E_Path_url: TEdit;
    Label6: TLabel;
    Label11: TLabel;
    E_Porta: TEdit;
    E_Terminal: TEdit;
    procedure Sb_CloseClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormatScreen;Override;
    procedure Chbx_ReceiveLocalServerClick(Sender: TObject);
    procedure Sb_IntoQuueClick(Sender: TObject);
  private
    { Private declarations }
    function validaConfig:Boolean;
    procedure ExecStartWin;

    procedure SaveConfig;
    procedure ShowConfig;

    //Lista de Tabelas
    procedure preencheListaTabelas(Lista:TCheckListBox);
    procedure ShowExcecoes;
    procedure SalvaExcecoes;
    //First Charge
    procedure Fc_Colaborador;
    procedure Fc_FormaPagto;
    procedure Fc_ContaBancaria;
    procedure Fc_HIstoricoBancario;
    procedure Fc_Cashier;
    procedure Fc_GrupoToCategoria;

    procedure Fc_Categoria;
    procedure Fc_ProductImages;
    procedure Fc_Marca;
    procedure Fc_Medida;
    procedure Fc_Embalagem;
    procedure Fc_Produto;
    procedure Fc_Estoques;
    procedure Fc_Estoque;
    procedure Fc_TabelaPreco;
    procedure Fc_Preco;
    procedure Fc_Cliente;
    procedure Fc_fornecedor;

    procedure Fc_Promotion;
    procedure Fc_PlanoContas;
    procedure Fc_PedidoCompra;
    procedure Fc_PedidoVenda;
    procedure Fc_PedidoAjuste;
    procedure Fc_NotasMercadoria;
    procedure Fc_NotasAvulsa;
    procedure FC_MovimentoEstoque;
    procedure Fc_Financeiro;

    procedure FC_MovimentoFinanceiro;
    procedure FC_ControleCaixa;
    procedure FC_RetornoNFe;
    procedure FC_RetornoNFCe;
    //procedure FC_RetornoNFSe;
    procedure FC_CartaCorrecao;
    procedure FC_Arquivos;

    procedure FC_OrderConsignament;
    procedure Fc_RestMenu;
    procedure FC_RestMenuHasIngrediente;
    procedure FC_RestGroup;
    procedure FC_RestSubgroup;
    procedure FC_RestGroupHasMeasure;
    procedure Fc_RestGroupHasOptiona;

  public
    { Public declarations }
  end;

var
  TasConfig: TTasConfig;

implementation

{$R *.dfm}

uses un_dm, uMain, un_sistema, un_funcoes;



procedure TTasConfig.Chbx_ReceiveLocalServerClick(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
  Begin
    Chbx_ReceiveWebServer.Checked := False;
    Chbx_ReceiveWebServer.Enabled := False;
  End
  else
  Begin
    Chbx_ReceiveWebServer.Enabled := True;
  End;
end;

procedure TTasConfig.ExecStartWin;
var
  Reg: TRegistry;
  S: string;
begin
  if ChBx_IniciarWindows.Checked then
  Begin
    Reg := TRegistry.Create;
    S:=ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
    Reg.rootkey:=HKEY_LOCAL_MACHINE;
    Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
    Reg.WriteString('ProgramaInicia',S);
    Reg.closekey;
    Reg.Free;
  End
  else
  Begin
    Reg := TRegistry.Create;
    S:=ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
    Reg.rootkey:=HKEY_LOCAL_MACHINE;
    Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
    Reg.DeleteValue('ProgramaInicia');
    Reg.closekey;
    Reg.Free;
  End;
end;

procedure TTasConfig.FC_Arquivos;
Var
  LcCtrl : TControllerArquivo;
  I : Integer;
begin
  LcCtrl := TControllerArquivo.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Arquivos: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_CartaCorrecao;
Var
  LcCtrl : TcontrollerCartaCorrecao;
  I : Integer;
begin
  LcCtrl := TcontrollerCartaCorrecao.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Cartao Corre��o: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Cashier;
Var
  LcCtrl : TControllerDskCashier;
  I : Integer;
begin
  LcCtrl := TControllerDskCashier.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Marca de Produtos: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.Fc_Categoria;
Var
  LcCtrl : TControllerDskCategory;
  I : Integer;
begin
  LcCtrl := TControllerDskCategory.Create(nil);
  try

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando CAtegoria ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.Fc_Cliente;
Var
  LcCtrl : TControllerCliente;
  I : Integer;
begin
  LcCtrl := TControllerCliente.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Clientes ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;

procedure TTasConfig.Fc_Colaborador;
Var
  LcCtrl : TControllerColaborador;
  I : Integer;
begin
  LcCtrl := TControllerColaborador.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Colaboradores: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;


procedure TTasConfig.Fc_ContaBancaria;
Var
  LcCtrl : TControllerContaBancaria;
  I : Integer;
begin
  LcCtrl := TControllerContaBancaria.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Contas Corrente: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.FC_ControleCaixa;
Var
  LcCtrl : TControllerDskCashier;
  I : Integer;
begin
  LcCtrl := TControllerDskCashier.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Controle Caixa: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Embalagem;
Var
  LcCtrl : TControllerEmbalagem;
  I : Integer;
begin
  LcCtrl := TControllerEmbalagem.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Embalagens ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Estoque;
Var
  LcCtrl : TControllerEstoque;
  I : Integer;
begin
  LcCtrl := TControllerEstoque.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Saldo de Estoque ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Estoques;
Var
  LcCtrl : TControllerEstoques;
  I : Integer;
begin
  LcCtrl := TControllerEstoques.Create(nil);
  try
    LcCtrl.Registro.Estabelecimento := StrToIntDef(E_institution_origem.Text,0);
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Tabela de Estoque ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;

procedure TTasConfig.Fc_Financeiro;
Var
  LcCtrl : TControllerFinanceiro;
  I : Integer;
begin
  LcCtrl := TControllerFinanceiro.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Financeiro: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.Atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.Fc_FormaPagto;
Var
  LcCtrl : TControllerFormaPagamento;
  I : Integer;
begin
  LcCtrl := TControllerFormaPagamento.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Forma de Pagamento: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_fornecedor;
Var
  LcCtrl : TControllerFornecedor;
  I : Integer;
begin
  LcCtrl :=TControllerFornecedor.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Fornecedor ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_GrupoToCategoria;
Var
  Lc_SqlTxt : String;
  LcProduto : TControllerProduto;
  I : Integer;
  LcQry : TIBQuery;
  LcCategory : TControllerDskCategory;
begin
  I := 0;
  LcCategory := TControllerDskCategory.Create(nil);
  LcProduto := TControllerProduto.create(nil);
  LcQry := TIBQuery.create(nil);
  Try
    with LcQry do
    Begin
      Active := False;
      Transaction := DM.IBT_Consulta;
      SQL.Clear;
      Lc_SqlTxt := 'select PRO_CODIGO, GRP_DESCRICAO, SBG_DESCRICAO '+
                   ' FROM tb_produto '+
                   '  INNER JOIN tb_grupos '+
                   '  ON (grp_CODIGO = pro_codGRP) '+
                   '  INNER JOIN tb_subgrupos '+
                   '  ON (sbg_CODIGO = pro_codSBG) '+
                   ' ORDER BY GRP_DESCRICAO, SBG_DESCRICAO ';
      SQL.Add(Lc_SqlTxt);
      Active := True;
      FetchAll;
      GG_Web_Process.Progress := 0;
      GG_Web_Process.MinValue := 0;
      GG_Web_Process.MaxValue := RECORDCOUNT;
      GG_Web_Process.Update;
      First;
      while not Eof do
      Begin
        Lb_Web_Process.Caption := concat('Processando Categorias e Produtos ',IntToStr(I));
        GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
        GG_Web_Process.Update;

        //Verifica se tem a Categoria

        LcCategory.getAutoCreateByGrupo( StrToIntDef( E_institution_origem.Text,1), String(FieldByName('GRP_DESCRICAO').AsAnsiString));
        LcCategory.getAutoCreateBySubGrupo( StrToIntDef( E_institution_origem.Text,1),LcCategory.Registro.NivelPosicao , String(FieldByName('SBG_DESCRICAO').AsAnsiString));

        LcProduto.Registro.Codigo := FieldByName('PRO_CODIGO').AsInteger;
        LcProduto.Registro.Categoria := LcCategory.Registro.Codigo;
        LcProduto.AtualizaCategoria;
        Next;
        GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
        GG_Web_Process.Update;
      end;
    end;
  Finally
    LcQry.close;
    LcQry.DisposeOf;
    LcProduto.DisposeOf;
    LcCategory.DisposeOf;
  End;
end;

procedure TTasConfig.Fc_HIstoricoBancario;
Var
  LcCtrl : TControllerHistoricoBancario;
  I : Integer;
begin
  LcCtrl := TControllerHistoricoBancario.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Marca de Produtos: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;

procedure TTasConfig.Fc_Marca;
Var
  LcCtrl : TControllerMarcaProduto;
  I : Integer;
begin
  LcCtrl := TControllerMarcaProduto.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Marca de Produtos: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Medida;
Var
  LcCtrl : TControllerMedida;
  I : Integer;
begin
  LcCtrl := TControllerMedida.Create(nil);
  try
    LcCtrl.Registro.MedidaCardapio := '';  //
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Medidas/Unidades: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_MovimentoEstoque;
begin

end;

procedure TTasConfig.FC_MovimentoFinanceiro;
Var
  LcCtrl : TControllerMovimentoFinanceiro;
  I : Integer;
begin
  LcCtrl := TControllerMovimentoFinanceiro.Create(nil);
  try
    LcCtrl.Estabel    := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Movimento Financeiro: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;


procedure TTasConfig.Fc_NotasAvulsa;
Var
  LcCtrl : TControllerNotaFiscal;
  I : Integer;
begin
  LcCtrl := TControllerNotaFiscal.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.TipoNota         := 'EM';
    LcCtrl.TipoPedido       := 0;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;


    LcCtrl.TipoPedido := 0;
    LcCtrl.Registro.Tipo := 'EM';
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Movimento Financeiro: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_NotasMercadoria;
Var
  LcCtrl : TControllerNotaFiscal;
  I : Integer;
begin
  LcCtrl := TControllerNotaFiscal.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.TipoNota         := '';
    LcCtrl.TipoPedido       := 0;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;


    LcCtrl.TipoPedido := 0;
    LcCtrl.Registro.Tipo := '';
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Movimento Financeiro: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_OrderConsignament;
begin

end;

procedure TTasConfig.Fc_PedidoAjuste;
Var
  LcCtrl : TControllerPedido;
  I : Integer;
begin
  LcCtrl := TControllerPedido.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.Registro.Tipo    := 3;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Pedido de Ajuste ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.salva;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;

procedure TTasConfig.Fc_PedidoCompra;
Var
  LcCtrl : TControllerPedido;
  I : Integer;
begin
  LcCtrl := TControllerPedido.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.Registro.Tipo    := 2;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;
    LcCtrl.getListSincronia;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Pedido de Compra ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.salva;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_PedidoVenda;
Var
  LcCtrl : TControllerPedido;
  I : Integer;
begin
  LcCtrl := TControllerPedido.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.Registro.Tipo    := 1;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getListSincronia;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Pedido de VEnda ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.salva;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.Fc_PlanoContas;
begin

end;

procedure TTasConfig.Fc_Preco;
Var
  LcCtrl : TControllerPreco;
  I : Integer;
begin
  LcCtrl := TControllerPreco.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Pre�os ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;


end;

procedure TTasConfig.Fc_ProductImages;
begin

end;

procedure TTasConfig.Fc_Produto;
Var
  LcCtrl : TControllerProduto;
  I : Integer;
begin
  LcCtrl := TControllerProduto.Create(nil);
  try
    LcCtrl.Registro.Tipo := 'P';
    LcCtrl.getList('0');
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Produtos ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_Promotion;
Var
  LcCtrl : TControllerDskPromotion;
  I : Integer;
begin
  LcCtrl := TControllerDskPromotion.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Promotion ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_RestGroup;
Var
  LcCtrl : TControllerGrupos;
  I : Integer;
begin
  LcCtrl := TControllerGrupos.Create(nil);
  try
    LcCtrl.Registro.Composicao := 'S';//s apenas para o preenchimento
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Grupos do restaurante ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.FC_RestGroupHasMeasure;
Var
  LcCtrl : TControllerMedida;
  I : Integer;
begin
  LcCtrl := TControllerMedida.Create(nil);
  try
    LcCtrl.Registro.MedidaCardapio := 'S';  //S apenas para o preenchimento
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Medidas do Grupo ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_RestGroupHasOptiona;
Var
  LcCtrl : TControllerCrpItens;
  I : Integer;
begin
  LcCtrl := TControllerCrpItens.Create(nil);
  try
    LcCtrl.Registro.Tipo := 'O';
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Opcionais do Grupo: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.Fc_RestMenu;
Var
  LcCtrl : TControllerProduto;
  I : Integer;
begin
  LcCtrl := TControllerProduto.Create(nil);
  try
    LcCtrl.Registro.Tipo := 'A';
    LcCtrl.getList('0');
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Menu do Card�pio: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_RestMenuHasIngrediente;
Var
  LcCtrl : TControllerCrpItens;
  I : Integer;
begin
  LcCtrl := TControllerCrpItens.Create(nil);
  try
    LcCtrl.Registro.Tipo := 'P';
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Ingredientes do Menu do Card�pio: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_RestSubgroup;
Var
  LcCtrl : TControllerSubGrupos;
  I : Integer;
begin
  LcCtrl := TControllerSubGrupos.Create(nil);
  try
    LcCtrl.Registro.Abas := 'S';//s apenas para o preenchimento
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Subgrupos do restaurante ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;

procedure TTasConfig.FC_RetornoNFCe;
Var
  LcCtrl : TControllerREtornoNFCe;
  I : Integer;
begin
  LcCtrl := TControllerREtornoNFCe.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Retorno NFC-e: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FC_RetornoNfe;
Var
  LcCtrl : TControllerREtornoNfe;
  I : Integer;
begin
  LcCtrl := TControllerREtornoNfe.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Retorno Nf-e: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

{procedure TTasConfig.FC_RetornoNFSe;
Var
  LcCtrl : TControllerREtornoNFS;
  I : Integer;
begin
  LcCtrl := TControllerRetornoNFS.Create(nil);
  try
    LcCtrl.Estabel          := StrToIntDef(E_institution_origem.Text,1);
    LcCtrl.Periodo          := ChBx_Periodo.Checked;
    LcCtrl.DataInicial      := Dtp_Data_Inicial.DateTime;
    LcCtrl.DataFinal        := Dtp_Data_Final.DateTime;

    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Retorno NFS-e: ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.atualiza;
    End;
  finally
    LcCtrl.DisposeOf;
  end;

end;
      }
procedure TTasConfig.Fc_TabelaPreco;
Var
  LcCtrl : TControllerTabelaPreco;
  I : Integer;
begin
  LcCtrl := TControllerTabelaPreco.Create(nil);
  try
    LcCtrl.getList;
    GG_Web_Process.MinValue := 0;
    GG_Web_Process.Progress := 0;
    GG_Web_Process.MaxValue := LcCtrl.Lista.Count;
    GG_Web_Process.Update;
    for I := 0 to LcCtrl.Lista.Count -1 do
    Begin
      Lb_Web_Process.Caption := concat('Processando Tabela de Pre�os ',IntToStr(I));
      GG_Web_Process.Progress := GG_Web_Process.Progress + 1;
      GG_Web_Process.Update;
      LcCtrl.ClonarObj(LcCtrl.Lista[I],LcCtrl.Registro);
      LcCtrl.update;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTasConfig.FormatScreen;
begin
  pg_Principal.ActivePage := tbs_conexao;
end;

procedure TTasConfig.FormShow(Sender: TObject);
begin
  pg_Principal.ActivePage := tbs_conexao;
  preencheListaTabelas(ChLBx_First_Charge);
  preencheListaTabelas(ChLBx_Excecoes_Envio);
  preencheListaTabelas(ChLBx_Excecoes_Recebo);
  ShowConfig;
end;


procedure TTasConfig.preencheListaTabelas(Lista: TCheckListBox);
begin
  lista.Clear;
  lista.Items.Add('USUARIO');
  lista.Items.Add('CARGO');
  lista.Items.Add('COLABORADOR/VENDEDOR');
  lista.Items.Add('FORMAPAGTO');
  lista.Items.Add('GRUPOS');
  lista.Items.Add('SUBGRUPOS');
  lista.Items.Add('MARCA_PRODUTO');
  lista.Items.Add('MEDIDA');
  lista.Items.Add('EMBALAGEM');
  lista.Items.Add('PRODUTO');
  lista.Items.Add('ESTOQUES');
  lista.Items.Add('ESTOQUE');
  lista.Items.Add('TABELA_PRECO');
  lista.Items.Add('PRECO');
  lista.Items.Add('CLIENTE');
  lista.Items.Add('CONTABANCARIA');
  lista.Items.Add('FORNECEDOR');
  lista.Items.Add('CATEGORIAS');
  lista.Items.Add('IMAGEM DE PRODUTOS');
  lista.Items.Add('PROMO��O');
  lista.Items.Add('PLANOCONTAS');
  lista.Items.Add('PEDIDO COMPRA');
  lista.Items.Add('PEDIDO VENDA');
  lista.Items.Add('PEDIDO AJUSTE');
  lista.Items.Add('NOTA FISCAL MERCADORIA');
  lista.Items.Add('NOTA FISCAL AVULSA');
  lista.Items.Add('MOVIMENTO ESTOQUE');
  lista.Items.Add('FINANCEIRO');
  lista.Items.Add('MOVIMENTO FINANCEIRO');
  lista.Items.Add('CONTROLE DE CAIXA');
  lista.Items.Add('RETORNO NF-E');
  lista.Items.Add('RETORNO NFC-E');
  lista.Items.Add('RETORNO NFS-E');
  lista.Items.Add('CARTA DE CORRE��O');
  lista.Items.Add('ARQUIVOS');
  lista.Items.Add('CONSIGNA��O');
  lista.Items.Add('MENU CARDAPIO');
  lista.Items.Add('INGREDIENTES MENU');
  lista.Items.Add('GRUPO RESTAURANTE');
  lista.Items.Add('SUBGRUPO RESTAURANTE');
  lista.Items.Add('MEDIDAS GRUPO RESTAURANTE');
  lista.Items.Add('OPCIONAIS GRUPO RESTAURANTE');
  lista.Items.Add('OPCIONAIS BORDA - TESTE');
  lista.Items.Add('HISTBANCARIO');
  lista.Items.Add('CASHIER');
end;


procedure TTasConfig.ShowConfig;
begin
  E_Path_BD_Local.Text            := Fc_Aq_Geral('L','SISWEB', 'BDPathBDLocal','');

  E_Intervalo.Text                := Fc_Aq_Geral('L','SISWEB', 'intervalo','0') ;

  E_NoMinuto.Text                 := Fc_Aq_Geral('L','SISWEB', 'nominuto','5');

  E_institution_origem.Text       := Fc_Aq_Geral('L','SISWEB', 'institution_origem','1');

  Chbx_AutoMinimize.Checked       := (Fc_Aq_Geral('L','SISWEB', 'AutoMinimize','S') = 'S');

  ChBx_IniciarWindows.Checked     := (Fc_Aq_Geral('L','SISWEB', 'startWind','S') = 'S' );

  E_CNPJ.Text                     := Fc_Aq_Geral('L','SISWEB', 'CNPJ','');

  E_Path_url.Text                 := Fc_Aq_Geral('L', 'SISWEB', 'FPathURL','0');

  E_PORTA.Text                    := Fc_Aq_Geral('L', 'SISWEB', 'PORTA','223');

  E_Terminal.Text                 := Fc_Aq_Geral('L', 'SISWEB', 'TERMINAL','0');

  Chbx_ReceiveWebServer.Checked   := ( Fc_Aq_Geral('L','SISWEB', 'ReceiveWebServer','S') = 'S');

  Chbx_SendToWebServer.Checked    := ( Fc_Aq_Geral('L','SISWEB', 'SendToWebServer','S') = 'S');

  ShowExcecoes;
end;





procedure TTasConfig.ShowExcecoes;
Var
  I:Integer;
begin
  //Envio
  for I := 0 to ChLBx_Excecoes_Envio.Count -1 do
  Begin
    ChLBx_Excecoes_Envio.Checked[I] := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', ChLBx_Excecoes_Envio.Items[I],'N') = 'S' );
  End;
  //Recebimento
  for I := 0 to ChLBx_Excecoes_Recebo.Count -1 do
  Begin
    ChLBx_Excecoes_Recebo.Checked[I] := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', ChLBx_Excecoes_Recebo.Items[I],'N') = 'S' );
  End;

end;

procedure TTasConfig.SalvaExcecoes;
Var
  I:Integer;
begin
  //Envio
  for I := 0 to ChLBx_Excecoes_Envio.Count -1 do
  Begin
    if ChLBx_Excecoes_Envio.Checked[I] then
      Fc_Aq_Geral('G','SISWEB_EXC_ENVI', ChLBx_Excecoes_Envio.Items[I],'S')
    else
      Fc_Aq_Geral('G','SISWEB_EXC_ENVI', ChLBx_Excecoes_Envio.Items[I],'N');
  End;
  //Recebimento
  for I := 0 to ChLBx_Excecoes_Recebo.Count -1 do
  Begin
    if ChLBx_Excecoes_Recebo.Checked[I] then
      Fc_Aq_Geral('G','SISWEB_EXC_RECE', ChLBx_Excecoes_Recebo.Items[I],'S')
    else
      Fc_Aq_Geral('G','SISWEB_EXC_RECE', ChLBx_Excecoes_Recebo.Items[I],'N');
  End;


end;

procedure TTasConfig.SaveConfig;
begin
  Fc_Aq_Geral('G','SISWEB', 'BDPathBDLocal',E_Path_BD_Local.Text);

  Fc_Aq_Geral('G', 'SISWEB', 'intervalo',E_Intervalo.Text);

  Fc_Aq_Geral('G', 'SISWEB', 'nominuto',E_NoMinuto.Text);

  if Chbx_AutoMinimize.Checked then
    Fc_Aq_Geral('G', 'SISWEB', 'AutoMinimize','S')
  else
    Fc_Aq_Geral('G', 'SISWEB', 'AutoMinimize','N');


  if ChBx_IniciarWindows.Checked then
    Fc_Aq_Geral('G', 'SISWEB', 'startWind','S')
  else
    Fc_Aq_Geral('G', 'SISWEB', 'startWind','N');

  Fc_Aq_Geral('G','SISWEB', 'institution_origem',E_institution_origem.Text);

  Fc_Aq_Geral('G', 'SISWEB', 'CNPJ',E_CNPJ.Text);

  if Chbx_ReceiveWebServer.Checked then
    Fc_Aq_Geral('G', 'SISWEB', 'ReceiveWebServer','S')
  else
    Fc_Aq_Geral('G', 'SISWEB', 'ReceiveWebServer','N');

  if Chbx_SendToWebServer.Checked then
    Fc_Aq_Geral('G', 'SISWEB', 'SendToWebServer','S')
  else
    Fc_Aq_Geral('G', 'SISWEB', 'SendToWebServer','N');

  Fc_Aq_Geral('G', 'SISWEB', 'FPathURL',E_Path_url.Text);

  Fc_Aq_Geral('G', 'SISWEB', 'PORTA',E_PORTA.Text);

  Fc_Aq_Geral('G', 'SISWEB', 'TERMINAL',E_Terminal.Text);

  SalvaExcecoes;

end;



procedure TTasConfig.Sb_CloseClick(Sender: TObject);
begin
  Close;
end;

procedure TTasConfig.SpeedButton1Click(Sender: TObject);
begin
  if validaConfig then
  Begin
    ExecStartWin;
    SaveConfig;
    Close;
  End;
end;

procedure TTasConfig.Sb_IntoQuueClick(Sender: TObject);
begin
  Try
    self.Enabled := false;
     inherited;
    //USUARIO
    //CARGO
    if ChLBx_First_Charge.Checked[2]  then Fc_Colaborador;
    if ChLBx_First_Charge.Checked[3]  then Fc_FormaPagto;
    if (ChLBx_First_Charge.Checked[4]) or (ChLBx_First_Charge.Checked[5]) then
    Begin
      Fc_GrupoToCategoria;
    End;
    if ChLBx_First_Charge.Checked[6]  then Fc_Marca;
    if ChLBx_First_Charge.Checked[7]  then Fc_Medida;
    if ChLBx_First_Charge.Checked[8]  then Fc_Embalagem;
    if ChLBx_First_Charge.Checked[9]  then Fc_Produto;
    if ChLBx_First_Charge.Checked[10] then Fc_Estoques;
    if ChLBx_First_Charge.Checked[11] then Fc_Estoque;
    if ChLBx_First_Charge.Checked[12] then Fc_TabelaPreco;
    if ChLBx_First_Charge.Checked[13] then Fc_Preco;
    if ChLBx_First_Charge.Checked[14] then Fc_Cliente;
    if ChLBx_First_Charge.Checked[15] then Fc_ContaBancaria;
    if ChLBx_First_Charge.Checked[16] then Fc_fornecedor;
    if ChLBx_First_Charge.Checked[17] then Fc_categoria;
    if ChLBx_First_Charge.Checked[18] then Fc_ProductImages;
    if ChLBx_First_Charge.Checked[19] then Fc_Promotion;
    if ChLBx_First_Charge.Checked[20] then Fc_PlanoContas;
    if ChLBx_First_Charge.Checked[21] then Fc_PedidoCompra;
    if ChLBx_First_Charge.Checked[22] then Fc_PedidoVenda;
    if ChLBx_First_Charge.Checked[23] then Fc_PedidoAjuste;
    if ChLBx_First_Charge.Checked[24] then Fc_NotasMercadoria;
    if ChLBx_First_Charge.Checked[25] then Fc_NotasAvulsa;
    if ChLBx_First_Charge.Checked[26] then FC_MovimentoEstoque;
    if ChLBx_First_Charge.Checked[27] then Fc_Financeiro;
    if ChLBx_First_Charge.Checked[28] then FC_MovimentoFinanceiro;
    if ChLBx_First_Charge.Checked[29] then FC_ControleCaixa;
    if ChLBx_First_Charge.Checked[30] then FC_RetornoNFe;
    if ChLBx_First_Charge.Checked[31] then FC_RetornoNFCe;
   // if ChLBx_First_Charge.Checked[32] then FC_RetornoNFSe;
    if ChLBx_First_Charge.Checked[33] then FC_CartaCorrecao;
    if ChLBx_First_Charge.Checked[34] then FC_Arquivos;
    if ChLBx_First_Charge.Checked[35] then FC_OrderConsignament;
    if ChLBx_First_Charge.Checked[36] then Fc_RestMenu;
    if ChLBx_First_Charge.Checked[37] then FC_RestMenuHasIngrediente;
    if ChLBx_First_Charge.Checked[38] then FC_RestGroup;
    if ChLBx_First_Charge.Checked[39] then FC_RestSubgroup;
    if ChLBx_First_Charge.Checked[40] then FC_RestGroupHasMeasure;
    if ChLBx_First_Charge.Checked[41] then Fc_RestGroupHasOptiona;
    if ChLBx_First_Charge.Checked[42] then Fc_HIstoricoBancario;
    if ChLBx_First_Charge.Checked[43] then Fc_HIstoricoBancario;
    if ChLBx_First_Charge.Checked[44] then Fc_Cashier;
  Finally
    Self.Enabled := true;
  End;
end;

function TTasConfig.validaConfig: Boolean;
begin
  Result := True;
  if (StrToIntDef(E_Intervalo.Text,0) < 1 ) and (StrToIntDef(E_Intervalo.Text,0) >0 ) then
  BEgin
    ShowMessage(concat(
                  'O Intervalo deve ser maior do que 1 minuto.',#13,
                  'Caso n�o deseje usar o temporizador preencha com 0(zero)',#13,
                  'Imposs�vel continuar. '
                  ));
    Result := FAlse;
    exit;
  End;
  if not VerificaConectaBanco(True,E_Path_BD_Local.Text) then
  Begin
    ShowMessage(concat(
                  'O Banco de dados local n�o est� disponivel.',#13,
                  'Verifique antes de continuar. '
                  ));
    Result := False;
    exit;
  End;

end;



end.
