object Fr_base_cad: TFr_base_cad
  Left = 261
  Top = 102
  BorderIcons = [biSystemMenu, biMinimize, biHelp]
  BorderStyle = bsSingle
  ClientHeight = 552
  ClientWidth = 841
  Color = clBtnFace
  Constraints.MaxHeight = 780
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Pg_Cadastro: TPageControl
    Left = 0
    Top = 0
    Width = 841
    Height = 552
    ActivePage = tbs_pesquisa
    Align = alClient
    Style = tsButtons
    TabOrder = 0
    object tbs_cadastro: TTabSheet
      Caption = 'Cadastro'
      object Panel24: TPanel
        Left = 0
        Top = 456
        Width = 833
        Height = 65
        Align = alBottom
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        DesignSize = (
          833
          65)
        object SB_Inserir: TSpeedButton
          Left = 44
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Inserir - F2'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object SB_Alterar: TSpeedButton
          Left = 146
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Alterar - F3'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object SB_Excluir: TSpeedButton
          Left = 248
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Excluir - F4'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object SB_Cancelar: TSpeedButton
          Left = 452
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Cancelar - F6'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object SB_Sair_0: TSpeedButton
          Left = 656
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Sair - ESC'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object Sb_Pesquisar: TSpeedButton
          Left = 554
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Pesquisar - F7'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
        object SB_Gravar: TSpeedButton
          Left = 350
          Top = 5
          Width = 102
          Height = 54
          Anchors = [akRight, akBottom]
          Caption = 'Gravar - F5'
          Flat = True
          Font.Charset = ANSI_CHARSET
          Font.Color = clNavy
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
        end
      end
    end
    object tbs_pesquisa: TTabSheet
      Caption = '&Pesquisa'
      ImageIndex = 2
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 833
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
        Width = 833
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
          833
          390)
        object SB_Buscar: TSpeedButton
          Left = 726
          Top = 143
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
        end
        object SB_Visualizar: TSpeedButton
          Left = 726
          Top = 197
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
        end
        object SB_Cadastrar: TSpeedButton
          Left = 726
          Top = 89
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
        end
        object Sb_Sair_1: TSpeedButton
          Left = 726
          Top = 251
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
        end
        object Dbg_Pesquisa: TDBGrid
          Left = 5
          Top = 14
          Width = 709
          Height = 368
          Anchors = [akLeft, akTop, akRight, akBottom]
          Color = clCream
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          Options = [dgTitles, dgIndicator, dgColLines, dgRowSelect, dgAlwaysShowSelection]
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clNavy
          TitleFont.Height = -11
          TitleFont.Name = 'MS Sans Serif'
          TitleFont.Style = []
        end
      end
    end
  end
end
