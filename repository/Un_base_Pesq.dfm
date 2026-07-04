inherited Fr_Base_Pesq: TFr_Base_Pesq
  Caption = 'Pesquisa'
  ClientHeight = 509
  ClientWidth = 815
  ExplicitWidth = 821
  ExplicitHeight = 558
  PixelsPerInch = 96
  TextHeight = 13
  object GrB_Parametros: TGroupBox [0]
    Left = 0
    Top = 0
    Width = 815
    Height = 81
    Align = alTop
    Caption = ' Digite sua op'#231#227'o de busca '
    Font.Charset = ANSI_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object Pnl_Resultado: TPanel [1]
    Left = 0
    Top = 81
    Width = 815
    Height = 428
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Lb_ResultadoPesquisa: TLabel
      Left = 2
      Top = 2
      Width = 811
      Height = 14
      Align = alTop
      Caption = 'Resultado da pesquisa :'
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      ExplicitWidth = 116
    end
    object Grd_Pesquisa: TStringGrid
      Left = 2
      Top = 16
      Width = 710
      Height = 410
      Align = alClient
      Color = clCream
      ColCount = 2
      DefaultColWidth = 40
      DefaultRowHeight = 18
      RowCount = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ParentFont = False
      TabOrder = 0
      OnClick = Grd_PesquisaClick
      OnDrawCell = Grd_PesquisaDrawCell
      ColWidths = (
        40
        40)
      RowHeights = (
        18
        18)
    end
    object pnl_botao: TPanel
      Left = 712
      Top = 16
      Width = 101
      Height = 410
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object Sb_Sair: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 355
        Width = 95
        Height = 54
        Margins.Top = 0
        Margins.Bottom = 1
        Align = alBottom
        Caption = 'Sair- Esc'
        Flat = True
        Font.Charset = ANSI_CHARSET
        Font.Color = clNavy
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        Layout = blGlyphTop
        ParentFont = False
        OnClick = Sb_SairClick
        ExplicitLeft = 521
        ExplicitTop = 369
        ExplicitWidth = 92
      end
      object SB_Visualizar: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 300
        Width = 95
        Height = 54
        Margins.Top = 0
        Margins.Bottom = 1
        Align = alBottom
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
        ExplicitLeft = 521
        ExplicitTop = 317
        ExplicitWidth = 92
      end
      object SB_Buscar: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 245
        Width = 95
        Height = 54
        Margins.Top = 0
        Margins.Bottom = 1
        Align = alBottom
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
        ExplicitLeft = 521
        ExplicitTop = 265
        ExplicitWidth = 92
      end
      object SB_Cadastrar: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 190
        Width = 95
        Height = 54
        Margins.Top = 0
        Margins.Bottom = 1
        Align = alBottom
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
        ExplicitLeft = 521
        ExplicitTop = 213
        ExplicitWidth = 92
      end
    end
  end
  object Qr_Pesquisa: TIBQuery
    Database = DM.IBD_Gestao
    Transaction = DM.IB_Transacao
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      
        'SELECT NFL_CODIGO, PED_NUMERO, NFL_NUMERO, NFL_DT_EMISSAO, EMP_F' +
        'ANTASIA, EMP_NOME,NFL_VL_TL_NOTA,NFL_MODELO, NFL_SERIE'
      'FROM TB_NOTA_FISCAL Tb_nota_fiscal'
      'INNER JOIN TB_EMPRESA tb_empresa'
      'ON (tb_empresa.EMP_CODIGO = tb_nota_fiscal.NFL_CODEMP)'
      'INNER JOIN TB_PEDIDO tb_pedido'
      'ON (tb_pedido.PED_CODIGO = tb_nota_fiscal.NFL_CODPED)'
      'INNER JOIN TB_RETORNO_NFE'
      'ON (NFE_CODNFL = NFL_CODIGO)'
      'AND (NFL_DT_EMISSAO BETWEEN '#39'06/26/2019'#39' AND '#39'06/26/2019'#39')'
      'AND  ( (PED_TIPO = 0 )  OR (PED_TIPO = 1) OR (PED_TIPO = 4 )  )')
    Left = 56
    Top = 136
  end
end
