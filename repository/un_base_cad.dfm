object Fr_base_cad: TFr_base_cad
  Left = 240
  Top = 77
  BorderIcons = [biSystemMenu, biMinimize, biHelp]
  BorderStyle = bsSingle
  ClientHeight = 552
  ClientWidth = 862
  Color = clBtnFace
  Constraints.MaxHeight = 780
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Pg_Cadastro: TPageControl
    Left = 0
    Top = 0
    Width = 862
    Height = 552
    ActivePage = tbs_cadastro
    Align = alClient
    Style = tsButtons
    TabOrder = 0
    OnChange = Pg_CadastroChange
    object tbs_cadastro: TTabSheet
      Caption = 'Cadastro'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pnUtil: TPanel
        Left = 0
        Top = 456
        Width = 854
        Height = 65
        Align = alBottom
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          854
          65)
        object SB_Inserir: TSpeedButton
          Left = 135
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Inserir - F2'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_InserirClick
        end
        object SB_Alterar: TSpeedButton
          Left = 237
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Alterar - F3'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_AlterarClick
        end
        object SB_Excluir: TSpeedButton
          Left = 339
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Excluir - F4'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_ExcluirClick
        end
        object SB_Cancelar: TSpeedButton
          Left = 543
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Cancelar - F6'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_CancelarClick
        end
        object SB_Sair_0: TSpeedButton
          Left = 747
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Sair - ESC'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_Sair_0Click
        end
        object Sb_Pesquisar: TSpeedButton
          Left = 645
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Pesquisar - F7'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = Sb_PesquisarClick
        end
        object SB_Gravar: TSpeedButton
          Left = 441
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight]
          Caption = 'Gravar - F5'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_GravarClick
        end
      end
      object gbMain: TGroupBox
        Left = 0
        Top = 0
        Width = 854
        Height = 456
        Align = alClient
        TabOrder = 1
      end
    end
    object tbs_pesquisa: TTabSheet
      Caption = '&Pesquisa'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gbCamposPesquisa: TGroupBox
        Left = 0
        Top = 0
        Width = 854
        Height = 131
        Align = alTop
        Caption = ' Digite sua op'#231#227'o de busca '
        Font.Charset = ANSI_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object Grp_Pesquisa: TGroupBox
        Left = 0
        Top = 131
        Width = 854
        Height = 390
        Align = alClient
        Caption = 'Resultado da pesquisa :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        DesignSize = (
          854
          390)
        object SB_Buscar: TSpeedButton
          Left = 756
          Top = 221
          Width = 92
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Buscar - F7'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_BuscarClick
        end
        object SB_Visualizar: TSpeedButton
          Left = 756
          Top = 275
          Width = 92
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Visualizar - F8'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_VisualizarClick
        end
        object SB_Cadastrar: TSpeedButton
          Left = 756
          Top = 167
          Width = 92
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Cadastrar - F2'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_CadastrarClick
        end
        object Sb_Sair_1: TSpeedButton
          Left = 756
          Top = 329
          Width = 92
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Sair- Esc'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = Sb_Sair_1Click
        end
        object Dbg_Pesquisa: TDBGrid
          Left = 5
          Top = 14
          Width = 743
          Height = 368
          Anchors = [akLeft, akTop, akRight, akBottom]
          Color = clCream
          DataSource = ds_Pesquisa
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Options = [dgTitles, dgIndicator, dgColLines, dgRowSelect, dgAlwaysShowSelection, dgTitleClick]
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clNavy
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
          OnDblClick = Dbg_PesquisaDblClick
        end
      end
    end
  end
  object Qr_Pesquisa: TIBQuery
    Database = DM.IBD_Gestao
    Transaction = DM.IB_Transacao
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      '')
    Left = 564
    Top = 64
  end
  object ds_Pesquisa: TDataSource
    DataSet = Qr_Pesquisa
    Left = 636
    Top = 64
  end
  object Tb_Cadastro: TIBDataSet
    Database = DM.IBD_Gestao
    Transaction = DM.IB_Transacao
    ForcedRefresh = True
    AfterCancel = Tb_CadastroAfterCancel
    AfterDelete = Tb_CadastroAfterDelete
    AfterEdit = Tb_CadastroAfterEdit
    AfterInsert = Tb_CadastroAfterInsert
    AfterPost = Tb_CadastroAfterPost
    BeforeDelete = Tb_CadastroBeforeDelete
    BeforeEdit = Tb_CadastroBeforeEdit
    BeforeInsert = Tb_CadastroBeforeInsert
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from TB_PRODUTO'
      'where'
      '  PRO_CODIGO = :PRO_CODIGO')
    RefreshSQL.Strings = (
      'Select *'
      'from TB_PRODUTO '
      'where'
      '  PRO_CODIGO = :PRO_CODIGO')
    SelectSQL.Strings = (
      'SELECT *'
      'FROM TB_PRODUTO'
      'WHERE PRO_CODIGO =:PRO_CODIGO'
      '')
    ParamCheck = True
    UniDirectional = False
    Left = 720
    Top = 64
  end
  object Ds_Cadastro: TDataSource
    AutoEdit = False
    DataSet = Tb_Cadastro
    Left = 790
    Top = 64
  end
end
