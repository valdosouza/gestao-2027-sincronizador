inherited Fr_Base_Config: TFr_Base_Config
  BorderStyle = bsDialog
  Caption = 'Base Configura'#231#245'es'
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel [0]
    Left = 0
    Top = 0
    Width = 636
    Height = 361
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    ExplicitTop = -1
    ExplicitWidth = 482
    ExplicitHeight = 309
  end
  object Panel2: TPanel [1]
    Left = 0
    Top = 361
    Width = 636
    Height = 38
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    ExplicitTop = 309
    ExplicitWidth = 482
    object Btn_Ok_12: TButton
      AlignWithMargins = True
      Left = 177
      Top = 5
      Width = 100
      Height = 28
      Margins.Left = 0
      Margins.Right = 0
      Align = alRight
      Caption = 'OK'
      TabOrder = 0
      OnClick = Btn_Ok_12Click
    end
    object Btn_Cn_12: TButton
      AlignWithMargins = True
      Left = 277
      Top = 5
      Width = 100
      Height = 28
      Margins.Left = 0
      Margins.Right = 0
      Align = alRight
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = Btn_Cn_12Click
    end
    object Btn_AP_12: TButton
      AlignWithMargins = True
      Left = 377
      Top = 5
      Width = 100
      Height = 28
      Margins.Left = 0
      Align = alRight
      Caption = 'Aplicar'
      TabOrder = 2
      OnClick = Btn_AP_12Click
      ExplicitTop = 6
    end
  end
end
