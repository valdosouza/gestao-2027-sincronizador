object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 256
  Width = 401
  object Qr_Crud: TIBQuery
    Database = IBD_Gestao
    Transaction = IBT_Crud
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      
        'Select e.EMP_CODIGO, e.EMP_NOME,e.EMP_FANTASIA, en.END_BAIRRO, c' +
        'd.CDD_DESCRICAO'
      'from tb_empresa e'
      '  inner Join tb_cliente c'
      '  ON (c.CLI_CODEMP  = e.emp_codigo)'
      '  inner join tb_endereco en'
      '  on (en.END_CODEMP = e.EMP_CODIGO)'
      '  inner JOIN tb_cidade cd'
      '  on (cd.cdd_codigo = en.END_CODCDD)'
      '  LEFT OUTER join TB_SALES_ROUTES_HAS_CUSTOMER srhc'
      '  ON (srhc.tb_sales_routes_id = c.cli_codemp)')
    Left = 332
    Top = 69
  end
  object IBT_Crud: TIBTransaction
    DefaultDatabase = IBD_Gestao
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 332
    Top = 13
  end
  object IBT_Consulta: TIBTransaction
    DefaultDatabase = IBD_Gestao
    Params.Strings = (
      'concurrency'
      'nowait')
    Left = 20
    Top = 117
  end
  object IBD_Gestao: TIBDatabase
    DatabaseName = 'D:\Modelos\Merconeti\Database\IBGCOM.FDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1252')
    LoginPrompt = False
    DefaultTransaction = IBT_Atualiza
    ServerType = 'IBServer'
    AllowStreamedConnected = False
    Left = 36
    Top = 6
  end
  object IBT_Atualiza: TIBTransaction
    DefaultDatabase = IBD_Gestao
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 36
    Top = 57
  end
  object IBD_Servidor: TIBDatabase
    DatabaseName = 'C:\Modelos\Performance\Database\IBGCOM.FDB'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1252')
    LoginPrompt = False
    DefaultTransaction = IBT_Servidor
    ServerType = 'IBServer'
    AllowStreamedConnected = False
    Left = 132
    Top = 6
  end
  object IBT_Servidor: TIBTransaction
    DefaultDatabase = IBD_Servidor
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 132
    Top = 65
  end
  object IBSQL: TIBSQL
    Database = IBD_Servidor
    Transaction = IBT_Servidor
    Left = 232
    Top = 176
  end
  object Qr_Acao: TIBQuery
    Database = IBD_Gestao
    Transaction = IBT_Crud
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      
        'Select e.EMP_CODIGO, e.EMP_NOME,e.EMP_FANTASIA, en.END_BAIRRO, c' +
        'd.CDD_DESCRICAO'
      'from tb_empresa e'
      '  inner Join tb_cliente c'
      '  ON (c.CLI_CODEMP  = e.emp_codigo)'
      '  inner join tb_endereco en'
      '  on (en.END_CODEMP = e.EMP_CODIGO)'
      '  inner JOIN tb_cidade cd'
      '  on (cd.cdd_codigo = en.END_CODCDD)'
      '  LEFT OUTER join TB_SALES_ROUTES_HAS_CUSTOMER srhc'
      '  ON (srhc.tb_sales_routes_id = c.cli_codemp)')
    Left = 332
    Top = 141
  end
  object Qr_Consulta: TIBQuery
    Database = IBD_Gestao
    Transaction = IBT_Consulta
    ForcedRefresh = True
    BufferChunks = 1000
    CachedUpdates = False
    ParamCheck = True
    SQL.Strings = (
      
        'Select e.EMP_CODIGO, e.EMP_NOME,e.EMP_FANTASIA, en.END_BAIRRO, c' +
        'd.CDD_DESCRICAO'
      'from tb_empresa e'
      '  inner Join tb_cliente c'
      '  ON (c.CLI_CODEMP  = e.emp_codigo)'
      '  inner join tb_endereco en'
      '  on (en.END_CODEMP = e.EMP_CODIGO)'
      '  inner JOIN tb_cidade cd'
      '  on (cd.cdd_codigo = en.END_CODCDD)'
      '  LEFT OUTER join TB_SALES_ROUTES_HAS_CUSTOMER srhc'
      '  ON (srhc.tb_sales_routes_id = c.cli_codemp)')
    Left = 332
    Top = 197
  end
  object IB_Transacao: TIBTransaction
    DefaultDatabase = IBD_Gestao
    Params.Strings = (
      'read_committed'
      'rec_version'
      'wait')
    Left = 28
    Top = 177
  end
end
