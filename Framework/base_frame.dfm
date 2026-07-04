object BaseFrame: TBaseFrame
  Left = 0
  Top = 0
  Width = 542
  Height = 131
  TabOrder = 0
  object Qr_Consulta: TIBQuery
    Database = DM.IBD_Gestao
    Transaction = DM.IBT_Consulta
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      
        'Select sr.id, sr.DESCRIPTION, e.EMP_NOME,e.EMP_FANTASIA, en.END_' +
        'BAIRRO, cd.CDD_DESCRICAO   '
      'from TB_SALES_ROUTES sr'
      '  inner join TB_SALES_ROUTES_HAS_CUSTOMER srhc '
      
        '  ON (srhc.TB_SALES_ROUTES_ID = sr.id) and (srhc.TB_INSTITUTION_' +
        'ID = sr.TB_INSTITUTION_ID) '
      '  inner Join tb_cliente c '
      '  ON (c.CLI_CODEMP  = srhc.TB_CUSTOMER_ID)'
      '  inner join tb_empresa e '
      '  on (e.emp_codigo = c.cli_codemp)'
      '  inner join tb_endereco en '
      '  on (en.END_CODEMP = e.EMP_CODIGO) '
      '  INNER JOIN tb_cidade cd '
      '  on (cd.cdd_codigo = en.END_CODCDD)')
    Left = 116
    Top = 61
  end
  object Ds_Consulta: TDataSource
    DataSet = Qr_Consulta
    Left = 120
    Top = 103
  end
end
