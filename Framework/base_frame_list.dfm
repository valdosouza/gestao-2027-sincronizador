inherited BaseFrameList: TBaseFrameList
  Width = 460
  Height = 35
  ExplicitWidth = 460
  ExplicitHeight = 35
  DesignSize = (
    460
    35)
  object Label1: TLabel [0]
    Left = 3
    Top = -1
    Width = 97
    Height = 13
    Caption = 'Descri'#231#227'o das Rotas'
  end
  object Sb_Routes: TSpeedButton [1]
    Left = 432
    Top = 12
    Width = 23
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = '...'
  end
  object DBLCB_Lista: TDBLookupComboBox [2]
    Left = 2
    Top = 13
    Width = 430
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    KeyField = 'ID'
    ListField = 'DESCRIPTION'
    ListSource = Ds_Consulta
    TabOrder = 0
    OnKeyDown = DBLCB_ListaKeyDown
  end
  inherited Qr_Consulta: TIBQuery
    SQL.Strings = (
      'Select sr.id, sr.DESCRIPTION'
      'from TB_SALES_ROUTES sr'
      'WHERE tb_institution_id =:tb_institution_id')
    Left = 107
    Top = 18
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'tb_institution_id'
        ParamType = ptUnknown
      end>
  end
  inherited Ds_Consulta: TDataSource
    Left = 159
    Top = 20
  end
end
