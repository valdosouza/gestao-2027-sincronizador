unit listaTables;

interface

uses System.Classes,System.SysUtils,System.Generics.Collections,IniFiles,
  un_funcoes, un_sistema ;

Type
  TTables = class(TObject)
  private
    FName: String;
    FSincroniza: Boolean;
    FWebId: Boolean;
    FProcMessage: String;
    procedure setName(const Value: String);
    procedure setSincroniza(const Value: Boolean);
    procedure setWebId(const Value: Boolean);
    procedure setFProcMessage(const Value: String);
  public
    constructor Create;
    destructor Destroy;
    property Name: String read FName write setName;
    property Sincroniza: Boolean read FSincroniza write setSincroniza;
    property WebId: Boolean read FWebId write setWebId;
    property ProcMessage : String read FProcMessage write setFProcMessage;
  End;

  TListaTables = TObjectList<TTables>;

  TControllerTable = Class(TComponent)
    Lista : TListaTables;
  private

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure getlistEnvio;
    procedure getlistRecebimento;
    Function getIndex(ptab:STring):Integer;
  End;

implementation




{ TControllerTable }

constructor TControllerTable.Create(AOwner: TComponent);
begin
  inherited;
  Lista := TListaTables.create;
end;

destructor TControllerTable.Destroy;
begin
  Lista.DisposeOf;
  inherited;
end;

function TControllerTable.getIndex(ptab: STring): Integer;
Var
  I : Integer;
  LcFind : Boolean;
begin
  LcFind := False;
  for I := 0 to Lista.Count -1 do
  Begin
    if ( Lista[I].Name = ptab ) then
    Begin
      Result := I;
      LcFind := True;
      Break;
    End;
  End;
  if not LcFind then Result := -1;  
end;

procedure TControllerTable.getlistEnvio;
Var
  LcReg : TTables;
  Lc_Arq_Ini  : TIniFile;
begin
  Try
    Lista.Clear;
    Lc_Arq_Ini := TIniFile.Create(getPathExe + 'config.ini');
    //Lista Tabelas e Campos
    // - 0
    LcReg := TTables.create;
    LcReg.Name := 'TB_USUARIO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'USUARIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Usuário em desenvolvimento';
    Lista.Add(LcReg);
    // - 1
    LcReg := TTables.create;
    LcReg.Name := 'TB_CARGO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CARGO','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Cargo em desenvolvimento';
    Lista.Add(LcReg);
    // - 2
    LcReg := TTables.create;
    LcReg.Name := 'TB_COLABORADOR';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'COLABORADOR/VENDEDOR','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Colaborador em processamento';
    Lista.Add(LcReg);
    // - 3
    LcReg := TTables.create;
    LcReg.Name := 'TB_FORMAPAGTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'FORMAPAGTO','N') = 'N' );
    LcReg.WebId := true;
    LcReg.ProcMessage := 'Tabela Forma de Pagamento em processamento';
    Lista.Add(LcReg);
    // - 4
    LcReg := TTables.create;
    LcReg.Name := 'TB_GRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'GRUPOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Grupo em desenvolvimento';
    Lista.Add(LcReg);
    // - 5
    LcReg := TTables.create;
    LcReg.Name := 'TB_SUBGRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'SUBGRUPOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela SubGrupo em desenvolvimento';
    Lista.Add(LcReg);
    // - 6
    LcReg := TTables.create;
    LcReg.Name := 'TB_MARCA_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MARCA_PRODUTO','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Marca em processamento';
    Lista.Add(LcReg);
    // - 7
    LcReg := TTables.create;
    LcReg.Name := 'TB_MEDIDA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MEDIDA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Medida em processamento';
    Lista.Add(LcReg);
    // - 8
    LcReg := TTables.create;
    LcReg.Name := 'TB_EMBALAGEM';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'EMBALAGEM','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Embalagem em processamento';
    Lista.Add(LcReg);
    // - 9
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PRODUTO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Produto em processamento';
    Lista.Add(LcReg);
    // - 10
    LcReg := TTables.create;
    LcReg.Name := 'TB_ESTOQUES';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'ESTOQUES','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Lista de Estoque em processamento';
    Lista.Add(LcReg);
    // - 11
    LcReg := TTables.create;
    LcReg.Name := 'TB_ESTOQUE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'ESTOQUE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Saldo de Estoque em processamento';
    Lista.Add(LcReg);
    // - 12
    LcReg := TTables.create;
    LcReg.Name := 'TB_TABELA_PRECO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'TABELA_PRECO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Lista de Preço em processamento';
    Lista.Add(LcReg);
    // - 13
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRECO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PRECO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Preço em processamento';
    Lista.Add(LcReg);
    // - 14
    LcReg := TTables.create;
    LcReg.Name := 'TB_CLIENTE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CLIENTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Clientes em processamento';
    Lista.Add(LcReg);
    // - 15
    LcReg := TTables.create;
    LcReg.Name := 'TB_CONTABANCARIA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CONTABANCARIA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Conta Bancária em processamento';
    Lista.Add(LcReg);
    // - 16
    LcReg := TTables.create;
    LcReg.Name := 'TB_FORNECEDOR';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'FORNECEDOR','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Fornecedores em desenvolvimento';
    Lista.Add(LcReg);
    // - 17
    LcReg := TTables.create;
    LcReg.Name := 'TB_CATEGORY';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CATEGORIAS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Categorias em processamento';
    Lista.Add(LcReg);
    // - 18
    LcReg := TTables.create;
    LcReg.Name := 'TB_IMAGES';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'IMAGEM DE PRODUTOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Imagens em desenvolvimento';
    Lista.Add(LcReg);
    // - 19
    LcReg := TTables.create;
    LcReg.Name := 'TB_PROMOTION';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PROMOÇÃO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Promoções em processamento';
    Lista.Add(LcReg);
    // - 20
    LcReg := TTables.create;
    LcReg.Name := 'TB_PLANOCONTAS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PLANOCONTAS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Plano de Contas';
    Lista.Add(LcReg);
    // - 21
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PEDIDO VENDA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Vendas';
    Lista.Add(LcReg);
    // - 22
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PEDIDO COMPRA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Compra';
    Lista.Add(LcReg);
    // - 23
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'PEDIDO AJUSTE','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Ajuste de Estoque';
    Lista.Add(LcReg);

    // - 24
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';
    LcReg.Sincroniza :=( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'NOTA FISCAL','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Notas Fiscais Avulsas';
    Lista.Add(LcReg);

    // - 25
    LcReg := TTables.create;
    LcReg.Name := 'TB_CTRL_ESTOQUEL';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MOVIMENTO ESTOQUE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Controle de Estoque';
    Lista.Add(LcReg);

    // - 26
    LcReg := TTables.create;
    LcReg.Name := 'TB_FINANCEIRO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'FINANCEIRO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela do Financeiro';
    Lista.Add(LcReg);

    // - 27
    LcReg := TTables.create;
    LcReg.Name := 'TB_MOVIM_FINANCEIRO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MOVIMENTO FINANCEIRO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Movimento Financeiro';
    Lista.Add(LcReg);

    // - 28
    LcReg := TTables.create;
    LcReg.Name := 'TB_CASHIER';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CONTROLE DE CAIXA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Conttrole de Caixa';
    Lista.Add(LcReg);

    // - 29
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'RETORNO NF-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NF-e 55';
    Lista.Add(LcReg);

    // - 30
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFC';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'RETORNO NFC-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NF-e 65';
    Lista.Add(LcReg);

    // - 31
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'RETORNO NFS-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NFS-e ';
    Lista.Add(LcReg);

    // - 32
    LcReg := TTables.create;
    LcReg.Name := 'TB_CARTA_CORRECAO';
    LcReg.Sincroniza :=( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'CARTA DE CORREÇÃO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Cartas de Correção ';
    Lista.Add(LcReg);

    // - 33
    LcReg := TTables.create;
    LcReg.Name := 'TB_ARQUIVOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'ARQUIVOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Arquivos ';
    Lista.Add(LcReg);

    // - 34
    LcReg := TTables.create;
    LcReg.Name := 'TB_ORDER_CONSIGNMENT';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'OCONSIGNA플O=','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Consignação ';
    Lista.Add(LcReg);

    // - 35 - TB_PRODUTO tb_rest_menu E tb_rest_menu_has produto
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MENU CARDAPIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Menu do Restaurante ';
    Lista.Add(LcReg);

  	// 36 - TB_CRP_ITENS tb_rest_menu_has_ingredient - CPI_TIPO = P
    LcReg := TTables.create;
    LcReg.Name := 'TB_CRP_ITENS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'INGREDIENTES MENU','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Ingredientes do Menu ';
    Lista.Add(LcReg);

  	// 37 - TB_GRUPO tb_rest_group
    LcReg := TTables.create;
    LcReg.Name := 'TB_GRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Grupos do Menu ';
    Lista.Add(LcReg);

  	// 38 - TB_SUBGRUPO tb_rest_group
    LcReg := TTables.create;
    LcReg.Name := 'TB_SUBGRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'SUBGRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Subgrupos do Menu ';
    Lista.Add(LcReg);

  	// 39 - TB_MEDIDA tb_rest_group_has_measure
    LcReg := TTables.create;
    LcReg.Name := 'TB_MEDIDA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MEDIDAS GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Medidas do Grupo ';
    Lista.Add(LcReg);

  	// 40 - TB_CRP_ITENS tb_rest_group_has_optional - COM CPI_TIPO = O
    LcReg := TTables.create;
    LcReg.Name := 'TB_CRP_ITENS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'OPCIONAIS GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Opcionais do Grupo ';
    Lista.Add(LcReg);

    // - 41 - TB_PRODUTO : tb_rest_group_has_attribute - Bordas
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'REST_ATRIB_BORDA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Atributos Borda ';
    Lista.Add(LcReg);
    // - 42
    LcReg := TTables.create;
    LcReg.Name := 'TB_HISTBANCARIO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'HISTBANCARIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Histórico Bancário em desenvolvimento';
    Lista.Add(LcReg);


  Finally
    Lc_Arq_Ini.DisposeOf;
  End;

end;

procedure TControllerTable.getlistRecebimento;
Var
  LcReg : TTables;
  Lc_Arq_Ini  : TIniFile;
begin
  Try
    Lista.Clear;
    Lc_Arq_Ini := TIniFile.Create(getPathExe + 'config.ini');
    //Lista Tabelas e Campos
    // - 0
    LcReg := TTables.create;
    LcReg.Name := 'TB_USUARIO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'USUARIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Usuário em desenvolvimento';
    Lista.Add(LcReg);
    // - 1
    LcReg := TTables.create;
    LcReg.Name := 'TB_CARGO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CARGO','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Cargo em desenvolvimento';
    Lista.Add(LcReg);
    // - 2
    LcReg := TTables.create;
    LcReg.Name := 'TB_COLABORADOR';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'COLABORADOR/VENDEDOR','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Colaborador em processamento';
    Lista.Add(LcReg);
    // - 3
    LcReg := TTables.create;
    LcReg.Name := 'TB_FORMAPAGTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'FORMAPAGTO','N') = 'N' );
    LcReg.WebId := true;
    LcReg.ProcMessage := 'Tabela Forma de Pagamento em processamento';
    Lista.Add(LcReg);
    // - 4
    LcReg := TTables.create;
    LcReg.Name := 'TB_GRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'GRUPO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Grupo em desenvolvimento';
    Lista.Add(LcReg);
    // - 5
    LcReg := TTables.create;
    LcReg.Name := 'TB_SUBGRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'SUBGRUPO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela SubGrupo em desenvolvimento';
    Lista.Add(LcReg);
    // - 6
    LcReg := TTables.create;
    LcReg.Name := 'TB_MARCA_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'MARCA_PRODUTO','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Marca em processamento';
    Lista.Add(LcReg);
    // - 7
    LcReg := TTables.create;
    LcReg.Name := 'TB_MEDIDA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'MEDIDA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Medida em processamento';
    Lista.Add(LcReg);
    // - 8
    LcReg := TTables.create;
    LcReg.Name := 'TB_EMBALAGEM';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'EMBALAGEM','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela Embalagem em processamento';
    Lista.Add(LcReg);
    // - 9
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PRODUTO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Produto em processamento';
    Lista.Add(LcReg);
    // - 10
    LcReg := TTables.create;
    LcReg.Name := 'TB_ESTOQUES';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'ESTOQUES','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Lista de Estoque em processamento';
    Lista.Add(LcReg);
    // - 11
    LcReg := TTables.create;
    LcReg.Name := 'TB_ESTOQUE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'ESTOQUE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Saldo de Estoque em processamento';
    Lista.Add(LcReg);
    // - 12
    LcReg := TTables.create;
    LcReg.Name := 'TB_TABELA_PRECO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'TABELA_PRECO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Lista de Preço em processamento';
    Lista.Add(LcReg);
    // - 13
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRECO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PRECO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Preço em processamento';
    Lista.Add(LcReg);
    // - 14
    LcReg := TTables.create;
    LcReg.Name := 'TB_CLIENTE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CLIENTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Clientes em processamento';
    Lista.Add(LcReg);
    // - 15
    LcReg := TTables.create;
    LcReg.Name := 'TB_CONTABANCARIA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CONTABANCARIA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Conta Bancária em processamento';
    Lista.Add(LcReg);
    // - 16
    LcReg := TTables.create;
    LcReg.Name := 'TB_FORNECEDOR';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'FORNECEDOR','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Fornecedores em desenvolvimento';
    Lista.Add(LcReg);
    // - 17
    LcReg := TTables.create;
    LcReg.Name := 'TB_CATEGORY';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CATEGORIAS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Categorias em processamento';
    Lista.Add(LcReg);
    // - 18
    LcReg := TTables.create;
    LcReg.Name := 'TB_IMAGES';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'IMAGEM DE PRODUTOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Imagens em desenvolvimento';
    Lista.Add(LcReg);
    // - 19
    LcReg := TTables.create;
    LcReg.Name := 'TB_PROMOTION';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PROMOÇÃO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Promoções em processamento';
    Lista.Add(LcReg);
    // - 20
    LcReg := TTables.create;
    LcReg.Name := 'TB_PLANOCONTAS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PLANOCONTAS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Plano de Contas';
    Lista.Add(LcReg);
    // - 21
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';//'TB_NF_VENDA'; //Apelido para TB_NOTA_FISCAL
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PEDIDO VENDA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Vendas';
    Lista.Add(LcReg);
    // - 22
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';//'TB_NF_COMPRA'; //Apelido para TB_NOTA_FISCAL
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PEDIDO COMPRA','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Compra';
    Lista.Add(LcReg);
    // - 23
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';// 'TB_NF_AJUSTE';  //Apelido para TB_NOTA_FISCAL
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'PEDIDO AJUSTE','N') = 'N' );
    LcReg.WebId := True;
    LcReg.ProcMessage := 'Tabela de Pedidos de Ajuste de Estoque';
    Lista.Add(LcReg);

    // - 24
    LcReg := TTables.create;
    LcReg.Name := 'TB_NOTA_FISCAL';//'TB_NF_AVULSA';  //Apelido para TB_NOTA_FISCAL
    LcReg.Sincroniza :=( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'NOTA FISCAL','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Notas Fiscais Avulsas';
    Lista.Add(LcReg);

    // - 25
    LcReg := TTables.create;
    LcReg.Name := 'TB_CTRL_ESTOQUEL';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'MOVIMENTO ESTOQUE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Controle de Estoque';
    Lista.Add(LcReg);

    // - 26
    LcReg := TTables.create;
    LcReg.Name := 'TB_FINANCEIRO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'FINANCEIRO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela do Financeiro';
    Lista.Add(LcReg);

    // - 27
    LcReg := TTables.create;
    LcReg.Name := 'TB_MOVIM_FINANCEIRO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'MOVIMENTO FINANCEIRO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Movimento Financeiro';
    Lista.Add(LcReg);

    // - 28
    LcReg := TTables.create;
    LcReg.Name := 'TB_CASHIER';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CONTROLE DE CAIXA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Conttrole de Caixa';
    Lista.Add(LcReg);

    // - 29
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFE';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'RETORNO NF-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NF-e 55';
    Lista.Add(LcReg);

    // - 30
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFC';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'RETORNO NFC-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NF-e 65';
    Lista.Add(LcReg);

    // - 31
    LcReg := TTables.create;
    LcReg.Name := 'TB_RETORNO_NFS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'RETORNO NFS-E','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Retorno de NFS-e ';
    Lista.Add(LcReg);

    // - 32
    LcReg := TTables.create;
    LcReg.Name := 'TB_CARTA_CORRECAO';
    LcReg.Sincroniza :=( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'CARTA DE CORREÇÃO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Cartas de Correção ';
    Lista.Add(LcReg);

    // - 33
    LcReg := TTables.create;
    LcReg.Name := 'TB_ARQUIVOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'ARQUIVOS','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Arquivos ';
    Lista.Add(LcReg);

    // - 34
    LcReg := TTables.create;
    LcReg.Name := 'TB_ORDER_CONSIGNMENT';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_RECE', 'ORDER_CONSIGNMENT','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Consignação ';
    Lista.Add(LcReg);

    // - 35 - TB_PRODUTO tb_rest_menu E tb_rest_menu_has produto
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MENU CARDAPIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Menu do Restaurante ';
    Lista.Add(LcReg);

  	// 36 - TB_CRP_ITENS tb_rest_menu_has_ingredient - CPI_TIPO = P
    LcReg := TTables.create;
    LcReg.Name := 'TB_CRP_ITENS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'INGREDIENTES MENU','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Ingredientes do Menu ';
    Lista.Add(LcReg);

  	// 37 - TB_GRUPO tb_rest_group
    LcReg := TTables.create;
    LcReg.Name := 'TB_GRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Grupos do Menu ';
    Lista.Add(LcReg);

  	// 38 - TB_SUBGRUPO tb_rest_group
    LcReg := TTables.create;
    LcReg.Name := 'TB_SUBGRUPOS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'SUBGRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Subgrupos do Menu ';
    Lista.Add(LcReg);

  	// 39 - TB_MEDIDA tb_rest_group_has_measure
    LcReg := TTables.create;
    LcReg.Name := 'TB_MEDIDA';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'MEDIDAS GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Medidas do Grupo ';
    Lista.Add(LcReg);

  	// 40 - TB_CRP_ITENS tb_rest_group_has_optional - COM CPI_TIPO = O
    LcReg := TTables.create;
    LcReg.Name := 'TB_CRP_ITENS';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'OPCIONAIS GRUPO RESTAURANTE','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Opcionais do Grupo ';
    Lista.Add(LcReg);

    // - 41 - TB_PRODUTO : tb_rest_group_has_attribute - Bordas
    LcReg := TTables.create;
    LcReg.Name := 'TB_PRODUTO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'REST_ATRIB_BORDA','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela de Atributos Borda ';
    Lista.Add(LcReg);
    // - 42 - TB_HISTBANCARIO - Historico Bancario
    LcReg := TTables.create;
    LcReg.Name := 'TB_HISTBANCARIO';
    LcReg.Sincroniza := ( Fc_Aq_Geral('L','SISWEB_EXC_ENVI', 'HISTBANCARIO','N') = 'N' );
    LcReg.WebId := False;
    LcReg.ProcMessage := 'Tabela Histórico Bancário em desenvolvimento';
    Lista.Add(LcReg);

  Finally
    Lc_Arq_Ini.DisposeOf;
  End;

end;

{ TTables }

constructor TTables.Create;
begin
  inherited;

end;

destructor TTables.Destroy;
begin

  inherited;
end;

procedure TTables.setFProcMessage(const Value: String);
begin
  FProcMessage := Value;
end;

procedure TTables.setName(const Value: String);
begin
  FName := Value;
end;

procedure TTables.setSincroniza(const Value: Boolean);
begin
  FSincroniza := Value;
end;

procedure TTables.setWebId(const Value: Boolean);
begin
  FWebId := Value;
end;

end.



