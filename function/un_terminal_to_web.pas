unit un_terminal_to_web;

interface

uses
   Classes,System.SysUtils,System.StrUtils, Gauges, Vcl.Forms,REST.Json,System.Json,
   controllerSyncTable,ControllerMigraPEdido, tblItensnfl, Vcl.Dialogs,uDataCM,
  REST.Response.Adapter, REST.Client,REST.Types,  Data.Bind.Components, Data.Bind.ObjectScope,
  IBX.IBQuery, Data.DB, ControllerGeral,ControllerEmpresa, ControllerEndereco,
  un_dm, un_sistema, tblPedido, tblProduto,un_funcoes, ControllerProduto,
  tblFormaPagamento, ControllerFormaPagamento, IniFiles,tblStockBalance,
  tblPaymentTypes, ObjMerchandise, ObjStockList, ObjPriceList, ControllerGrupos,
  objSalesMan, tblcolaborador, tblPhone, tblAddress, tblCliente, objCustomer,
  ControllerContaBancaria, TblContaBancaria, objBankAccount,ControllerPedido,
  ControllerPlanoContas, TblPLanoContas, objFinancialPlans,
  ControllerMovimentoFinanceiro, tblMovimentoFinanceiro, objFinancialStatement,
  ControllerSincronia, tblSincronia, objStockStatement,ControllerCtrlEstoque,
  tblCtrlEstoque, ControllerGestaoWeb, ControllerCategory, tblCategory, tblBrand,
  tblPackage, tblMeasure, tblStockStatement, uDataStockStatementCC,
  tblmarcaproduto, tblEmbalagem, tblMedida, tblEstoque,System.Generics.Collections,
  objOrderSale,ControllerUsuario, listaTables;

  type
  TObjListOrderSale = TObjectList<TObjOrderSale>;

  TTerminalToWeb = class(TBaseAPI)
    private

      //=======Envia as Ifnormações=====================
      Function SendFalta(IdDsk:Integer):TResult;
      //Sincroniza  Forma de Pagamento
      Function SendPaymentTypes(IdDsk:Integer):TResult;
      //Sincroniza Category
      Function SendCategory(IdDsk:Integer):TResult;
      //Sincroniza Marca
      Function SendBrand(IdDsk:Integer):TResult;
      //Sincroniza Embalagem
      Function SendPackage(IdDsk:Integer):TResult;
      //Sincroniza Medida
      Function SendMeasure(IdDsk:Integer):TResult;
      //Sincroniza Cor
      Function SendColor(IdDsk:Integer):TResult;
      //Sincroniza Tabela de Preco
      Function SendPriceList(IdDsk:Integer):TResult;
      //Sincroniza Tabela de Estoques
      Function SendStockList(IdDsk:Integer):TResult;
      //Sincroniza Mercadoria
      Function SendMerchandise(IdDsk:Integer):TResult;
      //Sincroniza Precos
      Function SendPrice(IdDsk:Integer):TResult;
      //Sincroniza Vendedor
      Function SendSalesMan(IdDsk:Integer):TResult;
      //Sincroniza  cliente
      Function SendCustomer(IdDsk:Integer):TResult;
      //Sincroniza Envia Conta Bancaria
      Function SendBankAccount(IdDsk:Integer):TResult;
      //Sincroniza  Plano de Contas
      Function SendFinancialPlans(IdDsk:Integer):TResult;
      //Sincroniza  Movimento Financeiro
      Function SendFinancialStatement(IdDsk:Integer):TResult;
      //Sincroniza  Movimento Estoque
      Function SendStockStatement(IdDsk:Integer):TResult;
      //Sincroniza o Stock Balance
      Function SendStockBalance(IdDsk:Integer):TResult;


      //=======Sincorniza as tabelas=====================
      procedure SyncListTable;
      function executeSend(pTab: String;pReg:Integer):TREsult;
      procedure SyncTable(pTab:String;pWEbId:Boolean);

      procedure ReceiveOrders;

      //Primeira CArga
      procedure FirstChargePaymentTypes;
      procedure FirstChargeSalesMan;
      procedure FirstChargeBrand;
      procedure FirstChargePackage;
      procedure FirstChargeMeasure;
      procedure FirstChargePriceList;
      procedure FirstChargeStockList;
      procedure FirstChargeMerchandise;
      procedure FirstChargePrice;
      procedure FirstChargeBankAccount;
      procedure FirstChargeCustomer;
      procedure FirstChargeFinancialPlans;
      procedure FirstChargeFinancialStatement;
      procedure FirstChargeStockStatement;
      procedure FirstChargeStockBalance;
    procedure setFDataCM(const Value: TDataCM);



    protected

      procedure GetIdInstitutionWeb;
      procedure FillSalesManObjects(Colab: TColaborador;ObjSalesMan:TObjSalesMan);
      procedure FillMerchandiseObjects(prod: TProduto;ObjMer:TObjMerchandise);
      procedure FillCustomerObjects(PcCliente: TCliente;ObjCustomer:TObjCustomer);
      procedure FillBankAccountObjects(PcCC: TContaBancaria;ObjCC:TObjBankAccount);
      procedure FillFinancialPlansObjects(PcPL: TPLanoContas;ObjPL:TObjFinancialPlans);
      procedure FillFinancialStatementObjects(PcMV: TMovimentoFinanceiro;ObjMV:TObjFinancialStatement);
      procedure FillStockStatementObjects(PcSS: TItensNFL;ObjSS:TObjStockStatement);
    public
      progresso : TGauge;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure Execute;
      procedure FirstCharge;

  End;
implementation

{ TTerminalToWeb }

uses ControllerMarcaProduto, ControllerMedida, ControllerEmbalagem,
  ControllerEstoque,  ControllerPreco, tblPrice,
  ControllerTabelaPreco, tblPreco, tblTabelaPreco, tblPriceList,
  tblEstoques, ControllerEstoques, tblStockList,
  ControllerCliente, ControllerColaborador;


constructor TTerminalToWeb.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TTerminalToWeb.Destroy;
begin
  inherited;
end;

procedure TTerminalToWeb.Execute;
begin
  GetIdInstitutionWeb;
  if ( FInstiturionWeb > 0 ) then
  Begin
    SyncListTable;
  End;
end;


function TTerminalToWeb.executeSend(pTab: String;pReg:Integer): TREsult;
begin
  Result.Create;
  case FListaTables.getIndex(pTab) of
    0:Result := SendFalta(pReg);                //USUARIO';
    1:Result := SendFalta(pReg);                //CARGO';
    2:Result := SendFalta(pReg);                //COLABORADOR';
    3:Result := SendFalta(pReg);                //EMPRESA';
    4:Result := SendFalta(pReg);                //ENDERECO';
    5:Result := SendFalta(pReg);                //FORMAPAGTO';
    6:Result := SendFalta(pReg);                //GRUPOS';
    7:Result := SendFalta(pReg);                //SUBGRUPOS';
    8:Result := SendBrand(pReg);                //MARCA_PRODUTO';
    9:Result := SendMeasure(pReg);              //MEDIDA';
    10:Result := SendPackage(pReg);             //EMBALAGEM';
    11:Result := SendMerchandise(pReg);         //PRODUTO';
    12:Result := SendStockList(pReg);           //ESTOQUES';
    13:Result := SendStockBalance(pReg);        //ESTOQUE';
    14:Result := SendStockList(pReg);           //TABELA_PRECO';
    15:Result := SendPrice(pReg);               //PRECO';
    16:Result := SendCustomer(pReg);            //CLIENTE';
    17:Result := SendBankAccount(pReg);         //CONTABANCARIA';
    18:Result := SendFalta(pReg);               //NOTA_FISCAL';
    19:Result := SendFalta(pReg);               //FINANCEIRO';
    20:Result := SendFinancialPlans(pReg);      //PLANOCONTAS';
    21:Result := SendFalta(pReg);               //HISTBANCARIO';
    22:Result := SendFinancialStatement(pReg);  //MOVIM_FINANCEIRO';
    23:Result := SendFalta(pReg);               //ITENS_NFL';
    24:Result := SendCategory(pReg);            //CATEGORY';
    25:Result := SendFalta(pReg);               //IMAGES';
    else
      Pc_LogTarefasDelphi(concat('executeSend - ',ptab,' : Não encontrada'));
  end;
end;

procedure TTerminalToWeb.FillBankAccountObjects(PcCC: TContaBancaria;
  ObjCC: TObjBankAccount);
Var
  LcCtrl : TControllerContaBancaria;
begin
  Try
    LcCtrl := TControllerContaBancaria.Create(Self);
    LcCtrl.Registro.CodigoBanco := PcCC.CodigoBanco;
    with ObjCC do
    Begin
      NumeroBanco := LcCtrl.getNumeroBanco;
      ContaCorrente.Codigo          :=  PcCC.Codigo;
      ContaCorrente.Estabelecimento :=  FInstiturionWeb;
      ContaCorrente.Banco           :=  PcCC.CodigoBanco;
      ContaCorrente.DataAbertura    :=  PcCC.DataAbertura;
      ContaCorrente.Agencia         :=  PcCC.Agencia;
      ContaCorrente.AgenciaDv       :=  PcCC.DigitoAgencia;
      ContaCorrente.Numero          :=  PcCC.Conta;
      ContaCorrente.NumeroDv        :=  PcCC.DigitoContaCorrente;
      ContaCorrente.Fone            :=  PcCC.Fone;
      ContaCorrente.Gerente         :=  PcCC.Gerente;
      ContaCorrente.ValorLimite     :=  PcCC.ValorLimite;
      ContaCorrente.DataContrato    :=  PcCC.DataVencto;
    End;
  Finally
    LcCtrl.DisposeOf;;
  End;
end;

procedure TTerminalToWeb.FillFinancialPlansObjects(PcPL: TPLanoContas;
  ObjPL: TObjFinancialPlans);
begin
  with ObjPL do
  Begin
    PlanoContas.Codigo          := PcPL.Codigo;
    PlanoContas.Estabelecimento := FInstiturionWeb;
    PlanoContas.NivelPosicao    := PcPL.PlanoContas;
    PlanoContas.Descricao       := PcPL.Descricao;
    PlanoContas.Fonte           := PcPL.Origem;
    PlanoContas.Tipo            := PcPL.Tipo;
    PlanoContas.Agrupador       := PcPL.Nivel;
    PlanoContas.Ativo           := 'S';
  End;
end;

procedure TTerminalToWeb.FillFinancialStatementObjects(PcMV: TMovimentoFinanceiro;
  ObjMV: TObjFinancialStatement);
begin
  with ObjMV do
  Begin
    MovimFinanceiro.Codigo            :=  PcMV.Codigo;
    MovimFinanceiro.Estabelecimento   :=  FInstiturionWeb;
    MovimFinanceiro.Terminal          :=  FTerminal;
    MovimFinanceiro.ContaCorrente     :=  PcMV.ContaCorrente;
    MovimFinanceiro.Data              :=  PcMV.Data;
    MovimFinanceiro.HistoricoBancario :=  PcMV.HistoricoBancario;
    MovimFinanceiro.ValorCredito      :=  PcMV.ValorCredito;
    MovimFinanceiro.ValorDebito       :=  PcMV.ValorDebito;
    MovimFinanceiro.HistoricoManual   :=  PcMV.Historico;
    MovimFinanceiro.TipoMovimento     :=  PcMV.Tipo;
    MovimFinanceiro.CodigoQuitacao    :=  PcMV.Quitacao;
    MovimFinanceiro.Usuario           :=  PcMV.Usuario;
    if PcMV.ValorFuturo > 0 then
      MovimFinanceiro.ValorFuturo     :=  'S'
    else
      MovimFinanceiro.ValorFuturo     :=  'N';
    MovimFinanceiro.DataOriginal      :=  PcMV.DataOriginal;
    MovimFinanceiro.DocReferencia     :=  PcMV.NrDocumento;
    MovimFinanceiro.Conferido         :=  PcMV.Conferido;
    MovimFinanceiro.FormaPagamento    :=  PcMV.FormaPagto;
    MovimFinanceiro.ContaCredito      :=  PcMV.PL_Credito;
    MovimFinanceiro.ContaDebito       :=  PcMV.PL_Debito;
  End;
end;

procedure TTerminalToWeb.FillCustomerObjects(PcCliente: TCliente;
  ObjCustomer: TObjCustomer);
Var
  LcPhone : TPhone;
  LcAddress : TAddress;
  LcCtrlEmpresa :TControllerEmpresa;
begin
  with ObjCustomer do
  BEgin
    Estabelecimento := FInstiturionWeb;
    LcCtrlEmpresa := TControllerEmpresa.Create(self);
    LcCtrlEmpresa.Registro.Codigo := pcCliente.Codigo;
    LcCtrlEmpresa.getById;

    Fiscal.Estabelecimento := FInstiturionWeb;
    Fiscal.Entidade.Codigo := 0;
    Fiscal.Entidade.NomeRazao           := LcCtrlEmpresa.Registro.NomeRazaoSocial;
    Fiscal.Entidade.ApelidoFantasia     := LcCtrlEmpresa.Registro.ApelidoFantasia;
    Fiscal.Entidade.AniversarioFundacao := LcCtrlEmpresa.Registro.DataFundacao;
    Fiscal.Entidade.RamoAtividade       := 0;
    Fiscal.Entidade.Observacao          := LcCtrlEmpresa.Registro.Observacao;

    if True then

    if ( Length( Trim(LcCtrlEmpresa.Registro.CpfCNPJ)) = 11 ) then
    Begin
      Fiscal.Fisica.CPF := LcCtrlEmpresa.Registro.CpfCNPJ;
      Fiscal.Fisica.RG := LcCtrlEmpresa.Registro.InscricaoEstadual;
      Fiscal.Fisica.Aniversario := LcCtrlEmpresa.Registro.DataFundacao;
    End
    else
    Begin
      Fiscal.Juridica.CNPJ := LcCtrlEmpresa.Registro.CpfCNPJ;
      Fiscal.Juridica.InscricaoEstadual := LcCtrlEmpresa.Registro.InscricaoEstadual;
      Fiscal.Juridica.CRT := LcCtrlEmpresa.Registro.CodigoRegimeTributario.ToString;
      Fiscal.Juridica.DataFundacao := LcCtrlEmpresa.Registro.DataFundacao;
      Fiscal.Juridica.IndicacaoIEDestinatario := LcCtrlEmpresa.Registro.IndicadorInscricaoEstadual;
      Fiscal.Juridica.EnviarSomenteXMLNFe := 'N';
    End;


    Fiscal.Email.Email := LcCtrlEmpresa.Registro.email;

    LcCtrlEmpresa.Endereco.Registro.CodigoEmpresa := PcCliente.Codigo;
    LcCtrlEmpresa.Endereco.getByEmpresa;
    if LcCtrlEmpresa.Endereco.exist then
    Begin
      LcAddress := TAddress.Create;
      LcAddress.Logradouro := LcCtrlEmpresa.Endereco.Registro.Logradouro;
      LcAddress.NumeroPredial := LcCtrlEmpresa.Endereco.Registro.NumeroPredial;
      LcAddress.Complemento := LcCtrlEmpresa.Endereco.Registro.Complemento;
      LcAddress.Bairro := LcCtrlEmpresa.Endereco.Registro.Bairro;
      LcAddress.Regiao := LcCtrlEmpresa.Endereco.Registro.Regiao;
      LcAddress.Tipo := 'COMERCIAL';
      LcAddress.Cep := LcCtrlEmpresa.Endereco.Registro.Cep;
      LcAddress.CodigoPais := LcCtrlEmpresa.Endereco.Registro.CodigoPais;
      LcAddress.CodigoEstado := LcCtrlEmpresa.Endereco.Registro.CodigoEstado;
      LcAddress.CodigoCidade := LcCtrlEmpresa.Endereco.Registro.CodigoCidade;
      LcAddress.Principal := LcCtrlEmpresa.Endereco.Registro.EnderecoPrincipal;
      Fiscal.ListaEndereco.Add(LcAddress);


      if LcCtrlEmpresa.Endereco.Registro.Fone <> '' then
      Begin
        LcPhone := TPhone.Create;
        LcPhone.Codigo := 0;
        LcPhone.Tipo := 'Fone';
        LcPhone.Numero := LcCtrlEmpresa.Endereco.Registro.Fone;
        LcPhone.TipoEndereco := 'Fone';
        Fiscal.ListaFones.Add(LcPhone);
      End;

      if LcCtrlEmpresa.Endereco.Registro.Fax <> '' then
      Begin
        LcPhone := TPhone.Create;
        LcPhone.Codigo := 0;
        LcPhone.Tipo := 'Celular';
        LcPhone.Numero := LcCtrlEmpresa.Endereco.Registro.Fax;
        LcPhone.TipoEndereco := 'Fax';
        Fiscal.ListaFones.Add(LcPhone);
      End;

      if LcCtrlEmpresa.Endereco.Registro.Celular <> '' then
      Begin
        LcPhone := TPhone.Create;
        LcPhone.Codigo := 0;
        LcPhone.Tipo := 'Celular';
        LcPhone.Numero := LcCtrlEmpresa.Endereco.Registro.Celular;
        LcPhone.TipoEndereco := 'Celular';
        Fiscal.ListaFones.Add(LcPhone);
      End;
    End;

    Cliente.Codigo          := 0;
    Cliente.Estabelecimento := FInstiturionWeb;
    Cliente.Vendedor        := 0;
    Cliente.Transportador   := 0;
    Cliente.SituacaoCredito := LcCtrlEmpresa.Registro.SituacaoCredito;
    Cliente.ValorCredito    := LcCtrlEmpresa.Registro.ValorCredito;
    if LcCtrlEmpresa.Registro.VendaEmCarteira > 0 then
      Cliente.VendeEmCarteira := 'S'
    else
      Cliente.VendeEmCarteira := 'N';
    Cliente.ConsumidorFinal := LcCtrlEmpresa.Registro.ConsumidorFinal;
    Cliente.Ativo           := PcCliente.Ativo;
    Cliente.Multiplicador   := LcCtrlEmpresa.Registro.Multiplicador;
    Cliente.IgnoraST        := LcCtrlEmpresa.Registro.IgnorarCalculoST;
  End;
end;

procedure TTerminalToWeb.FillMerchandiseObjects(prod: TProduto;ObjMer:TObjMerchandise);
var
  I,J : Integer;
  LcOriMarca : TControllerMarcaProduto;
  LcOriMedida : TControllerMedida;
  LcOriEmbalagem : TControllerEmbalagem;
  LcOriListaEstoque : TControllerEstoques;
  LcDestStock : TStockBalance;
  LcOriListaPreco : TControllerTabelaPreco;
  LcDestPrice : TPrice;
  LcObjEstoque : TObjStockList;
  LcObjPreco : TObjPriceList;
  LcCtrlGrupo : TControllerGrupos;
  LcGesWeb:TControllerGestaoWeb;
  LcIdCategory : Integer;
  LcIdBrand : Integer;
  LcIdMeasure : Integer;
  LcIdPackage : Integer;
begin
  Try
    LcGesWeb := TControllerGestaoWeb.Create(Self);
    with ObjMer do
    BEgin
      //Objeto produto
      with Produto do
      BEgin
        Codigo            := Prod.Codigo;
        Identificador     := Prod.CodigoFabrica;
        Estabelecimento   := FInstiturionWeb;
        Descricao         := Prod.Descricao;
        Categoria         := Prod.Categoria;
        Promocao          := Prod.Campanha;
        Destaque          := Prod.Destaque;
        Ativo             := Prod.Ativo;
        Publicado         := Prod.Internet;
        Observaocao       := Prod.Detalhes;
      End;

      //Verifica se a Marca foi enviada para o sistema Web
      LcGesWeb.Registro.Tabela := 'TB_MARCA_PRODUTO';
      LcGesWeb.Registro.Codigo := prod.CodigoMarca;
      LcGesWeb.getByKey;
      if LcGesWeb.exist then
      Begin
        LcIdBrand := LcGesWeb.Registro.WebID;
      end
      else
      Begin
//        LcIdBrand := SendBrand(prod.CodigoMarca);
        LcGesWeb.Registro.Tabela := 'TB_MARCA_PRODUTO';
        LcGesWeb.Registro.Codigo := prod.CodigoMarca;
        LcGesWeb.Registro.WebID   := LcIdBrand;
        LcGesWeb.insert;
      End;

      //Objeto Mercadoria
      with Mercadoria do
      BEgin
        Codigo            := Prod.Codigo;
        Estabelecimento   := FInstiturionWeb;
        CodigoInterno     := Prod.CodigoFabrica;
        Fornecedor        := StrToIntDEf(Prod.CodigoFornecedor,0);
        NCM               := Prod.CodigoNCM;
        CEST              := Prod.CEST;
        TipoTributacao    := Prod.FinalidadeTributacao;
        Origem            := Prod.Origem;
        Tipo              := Prod.Tipo;
        Marca             := LcIdBrand;
        Imprime           := Prod.Imprime;
        ControlarSerie    := Prod.UtilizaSerie;
        ExclusivoRevenda  := Prod.Exclusivo;
        Aplicacao         := Prod.Aplicacao;
        TipoComposicao    := Prod.Composicao;
      End;

      //Verifica se a Medida foi enviada para o sistema Web
      LcGesWeb.Registro.Tabela := 'TB_MEDIDA';
      LcGesWeb.Registro.Codigo := prod.CodigoMedida;
      LcGesWeb.getByKey;
      if LcGesWeb.exist then
      Begin
        LcIdMeasure := LcGesWeb.Registro.WebID;
      end
      else
      Begin
//        LcIdMeasure := SendMeasure(prod.CodigoMedida);
        LcGesWeb.Registro.Tabela  := 'TB_MEDIDA';
        LcGesWeb.Registro.Codigo  := prod.CodigoMarca;
        LcGesWeb.Registro.WebID   := LcIdMeasure;
        LcGesWeb.insert;
      End;

      //Verifica se a Embalagem foi enviada para o sistema Web
      LcGesWeb.Registro.Tabela := 'TB_EMBALAGEM ';
      LcGesWeb.Registro.Codigo := prod.CodigoEmbalagem;
      LcGesWeb.getByKey;
      if LcGesWeb.exist then
      Begin
        LcIdPackage := LcGesWeb.Registro.WebID;
      end
      else
      Begin
//        LcIdPackage := SendPackage(prod.CodigoMedida);
        LcGesWeb.Registro.Tabela  := 'TB_EMBALAGEM';
        LcGesWeb.Registro.Codigo  := prod.CodigoEmbalagem;
        LcGesWeb.Registro.WebID   := LcIdPackage;
        LcGesWeb.insert;
      End;

      with Estoque do
      BEgin
        Mercadoria        := prod.Codigo;
        Estabelecimento   := FInstiturionWeb;
        Embalagem         := LcIdPackage;
        Medida            := LcIdMeasure;
        Cor               := 0;
        //CodigoBarra     := prod.CodigoBarras;
        TemST             := prod.SubsTrib;
        Qtde              := 0;
        QtdeMinima        := prod.QtdeMinima;
        Divisor           := prod.Divisor;
        Localizacao       := prod.Localizacao;
        Peso              := prod.Peso;
        Largura           := prod.Largura;
        Comprimento       := prod.Comprimento;
        Altura            := prod.Altura;
        CustoFabrica      := prod.ValorFabrica;
        CustoReal         := prod.ValorCustoMedio;
        PrecoCusto        := prod.ValorCusto;
        EstoqueNegativa   := prod.EstoqueNegativo;
        ForaDeLinha       := prod.ForaLinha;
      End;
    End;
  Finally
    LcGesWeb.DisposeOf;;
  End;
end;

procedure TTerminalToWeb.FillSalesManObjects(Colab: TColaborador;
  ObjSalesMan: TObjSalesMan);
Var
  LcPhone : TPhone;
  LcAddress : TAddress;
begin
  with ObjSalesMan do
  BEgin
    ObjSalesMan.Colaborador.Fiscal.Estabelecimento := FInstiturionWeb;
    ObjSalesMan.Colaborador.Fiscal.Entidade.Codigo := 0;
    ObjSalesMan.Colaborador.Fiscal.Entidade.NomeRazao           := Colab.Nome;
    ObjSalesMan.Colaborador.Fiscal.Entidade.ApelidoFantasia     := Colab.Nome;
    ObjSalesMan.Colaborador.Fiscal.Entidade.AniversarioFundacao := Colab.NAscimento;
    ObjSalesMan.Colaborador.Fiscal.Entidade.RamoAtividade       := 0;
    ObjSalesMan.Colaborador.Fiscal.Entidade.Observacao          := Colab.Observacao;

    if ( Length( Trim(Colab.CPFCNPJ)) = 11 ) then
    Begin
      ObjSalesMan.Colaborador.Fiscal.Fisica.CPF := Colab.CPFCNPJ;
      ObjSalesMan.Colaborador.Fiscal.Fisica.RG := Colab.Identidade;
      ObjSalesMan.Colaborador.Fiscal.Fisica.Aniversario := Colab.NAscimento;
    End
    else
    Begin
      ObjSalesMan.Colaborador.Fiscal.Juridica.CNPJ := Colab.CPFCNPJ;
      ObjSalesMan.Colaborador.Fiscal.Juridica.InscricaoEstadual := Colab.Identidade;
      ObjSalesMan.Colaborador.Fiscal.Juridica.CRT := '1';
      ObjSalesMan.Colaborador.Fiscal.Juridica.DataFundacao := Colab.NAscimento;
      ObjSalesMan.Colaborador.Fiscal.Juridica.IndicacaoIEDestinatario := '1';
      ObjSalesMan.Colaborador.Fiscal.Juridica.EnviarSomenteXMLNFe := 'N';
    End;

    LcAddress := TAddress.Create;
    LcAddress.Logradouro := Colab.Endereco;
    LcAddress.NumeroPredial := '';
    LcAddress.Complemento := '';
    LcAddress.Bairro := Colab.Bairro;
    LcAddress.Regiao := '';
    LcAddress.Tipo := 'RESIDENCIAL';
    LcAddress.Cep := Colab.Cep;
    LcAddress.CodigoPais := 1058;
//    LcAddress.CodigoEstado := Fc_BuscaCodigoEstado(Colab.Estado);
//    LcAddress.CodigoCidade := Fc_BuscaCodigoCidade(0,Colab.Cidade,Colab.Estado);
    LcAddress.Principal := 'S';
    ObjSalesMan.Colaborador.Fiscal.ListaEndereco.Add(LcAddress);

    ObjSalesMan.Colaborador.Fiscal.Email.Email := Colab.email;

    if Colab.Fone <> '' then
    Begin
      LcPhone := TPhone.Create;
      LcPhone.Codigo := 0;
      LcPhone.Tipo := 'Fone';
      LcPhone.Numero := Colab.Fone;
      LcPhone.TipoEndereco := 'Fone';
      ObjSalesMan.Colaborador.Fiscal.ListaFones.Add(LcPhone);
    End;

    if Colab.Celular <> '' then
    Begin
      LcPhone := TPhone.Create;
      LcPhone.Codigo := 0;
      LcPhone.Tipo := 'Celular';
      LcPhone.Numero := Colab.Fone;
      LcPhone.TipoEndereco := 'Celular';
      ObjSalesMan.Colaborador.Fiscal.ListaFones.Add(LcPhone);
    End;

    ObjSalesMan.Colaborador.Colaborador.Codigo := 0;
    ObjSalesMan.Colaborador.Colaborador.Estabelecimento := FInstiturionWeb;
    ObjSalesMan.Colaborador.Colaborador.DataAdmissao := Colab.Admissao;
    ObjSalesMan.Colaborador.Colaborador.DataDemissao := Colab.Demissao;
    ObjSalesMan.Colaborador.Colaborador.Salario := Colab.Salario;
    ObjSalesMan.Colaborador.Colaborador.Pai := Colab.NomePai;
    ObjSalesMan.Colaborador.Colaborador.Mamae := Colab.NomeMae;
    ObjSalesMan.Colaborador.Colaborador.Titulo := Colab.TituloEleitor;
    ObjSalesMan.Colaborador.Colaborador.Zona  := Colab.TituloZona;
    ObjSalesMan.Colaborador.Colaborador.Sessão := Colab.SecaoZona;
    ObjSalesMan.Colaborador.Colaborador.Certificado := Colab.CertificadoMilitar;
    ObjSalesMan.Colaborador.Colaborador.Ativo := 'S';
    ObjSalesMan.Colaborador.Colaborador.Pis := Colab.PIS;


    ObjSalesMan.Vendedor.Codigo           := 0;
    ObjSalesMan.Vendedor.Estabelecimento  := FInstiturionWeb;
    ObjSalesMan.Vendedor.Ativo            := 'S';
    ObjSalesMan.Vendedor.AliquotaComissao := Colab.ComissaoAliqVenda;
    ObjSalesMan.Vendedor.ComissaoProduto  := Colab.ComissaoPorProduto;
  End;
end;

procedure TTerminalToWeb.FillStockStatementObjects(PcSS: TItensNFL;
  ObjSS: TObjStockStatement);
begin
  with ObjSS do
  Begin
    {
    Movimento.Estabelecimento := FInstiturionWeb;
    Movimento.Terminal        := StrToIntDef(GbTerminal,1);
    Movimento.Ordem           := PcSS.CodigoPedido;
    Movimento.OrdemItem       := PcSS.Codigo;
    Movimento.Estoque         := PcSS.CodigoEstoque;
    Movimento.Local           := 'Matriz';
    Movimento.Tipo            := '';
    Movimento.DataRegistro    :=
    Movimento.Mercadoria      := PcSS.CodigoProduto;
    Movimento.Quantidade      := PcSS.Quantidade;
    }
  End;
end;

procedure TTerminalToWeb.FirstChargeBankAccount;
Var
  LcCtrl : TControllerContaBancaria;
  LcReg : TContaBancaria;
  I : Integer;
  LcObj : TObjBankAccount;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerContaBancaria.Create(Self);

    LcTab := 'TB_CONTABANCARIA';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TContaBancaria.Create;
      LcReg := LcCtrl.Lista[I];

      //Objeto Novo
      LcObj := TObjBankAccount.Create;
      //Popular
      FillBankAccountObjects(LcCtrl.Registro,LcObj);
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMBankAccountClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;


end;

procedure TTerminalToWeb.FirstChargeBrand;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerMarcaProduto;
  LcGesWeb : TControllerGestaoWeb;
  LcIdBrand : Integer;
begin
  try
    LcGesWeb  := TControllerGestaoWeb.Create(Self);
    LcCtrl    := TControllerMarcaProduto.Create(Self);
    LcTab := 'TB_MARCA_PRODUTO';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;

    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      //LcIdBrand := SendBrand(LcReg.Codigo);
      //VErifica o Codigo na Tabela de Controle DE=>PARA
      LcGesWeb.Registro.Tabela := LcTab;
      LcGesWeb.Registro.Codigo := LcCtrl.Lista[I].Codigo;
      LcGesWeb.getByKey;
      if (not LcGesWeb.exist) and (LcIdBrand > 0 ) then
      Begin
        LcGesWeb.Registro.Tabela := LcTab;
        LcGesWeb.Registro.Codigo := LcCtrl.Lista[I].Codigo;
        LcGesWeb.Registro.WebID :=  LcIdBrand;
        LcGesWeb.insert;
      End;
      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcGesWeb.DisposeOf;;
    LcCtrl.DisposeOf;
  end;
end;

procedure TTerminalToWeb.FirstChargeCustomer;
Var
  LcCtrl : TControllerCliente;
  LcReg : TCliente;
  I : Integer;
  LcObj : TObjCustomer;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerCliente.Create(Self);
    LcTab := 'TB_CLIENTE';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;

    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TCliente.Create;
      LcReg := LcCtrl.Lista[I];

      //Objeto Novo
      FillCustomerObjects(LcReg,LcObj);
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMCustomerClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;

end;

procedure TTerminalToWeb.FirstChargeFinancialPlans;
Var
  LcCtrl : TControllerPlanoContas;
  LcReg : TPLanoContas;
  I : Integer;
  LcObj : TObjFinancialPlans;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerPlanoContas.Create(Self);

    LcTab := 'TB_PLANOCONTAS';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TPLanoContas.Create;
      LcReg := LcCtrl.Lista[I];

      //Objeto Novo
      LcObj := TObjFinancialPlans.Create;
      //Popular
      FillFinancialPlansObjects(LcReg,LcObj);
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMFinancialPLansClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;

end;

procedure TTerminalToWeb.FirstChargeFinancialStatement;
Var
  LcCtrl : TControllerMovimentoFinanceiro;
  LcReg : TMovimentoFinanceiro;
  I : Integer;
  LcObj : TObjFinancialStatement;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerMovimentoFinanceiro.Create(Self);

    LcTab:= 'TB_MOVIM_FINANCEIRO';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TMovimentoFinanceiro.Create;
      LcReg := LcCtrl.Lista[I];

      //Objeto Novo
      LcObj := TObjFinancialStatement.Create;
      //Popular
      FillFinancialStatementObjects(LcReg,LcObj);
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMFinancialStatementClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.FirstChargeMeasure;
Var
  I : Integer;
  LcTab : String;
  LcGesWeb : TControllerGestaoWeb;
  LcCtrl : TControllerMedida;
  LcReg : TMedida;
  LcIdMeasure : Integer;
begin
  try
    LcGesWeb  := TControllerGestaoWeb.Create(Self);
    LcCtrl    := TControllerMedida.Create(Self);
    LcTab := 'TB_MEDIDA';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    begin
      LcReg := TMedida.Create;
      LcReg := LcCtrl.Lista[I];

//      LcIdMeasure := SendMeasure(LcReg.Codigo);
      //VErifica o Codigo na Tabela de Controle DE=>PARA
      LcGesWeb.Registro.Tabela := LcTab;
      LcGesWeb.Registro.Codigo := LcReg.Codigo;
      LcGesWeb.getByKey;
      if (not LcGesWeb.exist) and (LcIdMeasure > 0 ) then
      Begin
        LcGesWeb.Registro.Tabela := LcTab;
        LcGesWeb.Registro.Codigo := LcReg.Codigo;
        LcGesWeb.Registro.WebID :=  LcIdMeasure;
        LcGesWeb.insert;
      End;

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcGesWeb.DisposeOf;;
    LcCtrl.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.FirstChargeMerchandise;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerProduto;
  LcReg : TProduto;
  LcObj: TObjMerchandise;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcResult : TResult;
begin
  try
    LcCtrl := TControllerProduto.Create(Self);

    LcTab := 'TB_PRODUTO';
    LcCtrl.getList('');
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TProduto.Create;
      LcReg := LcCtrl.Lista[I];

      //Preenche o Objeto para enviar para o servidor
      LcObj := TObjMerchandise.Create;

      FillMerchandiseObjects(LcReg,LcObj);

      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMMerchandiseClient.save(LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcCtrl.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.FirstChargePackage;
Var
  I : Integer;
  LcTab : String;
  LcGesWeb : TControllerGestaoWeb;
  LcCtrl : TControllerEmbalagem;
  LcIdPackage : Integer;
begin
  try
    LcGesWeb  := TControllerGestaoWeb.Create(Self);
    LcCtrl    := TControllerEmbalagem.Create(Self);
    LcTab := 'TB_EMBALAGEM';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
//      LcIdPackage := SendPackage(LcReg.Codigo);
      //VErifica o Codigo na Tabela de Controle DE=>PARA
      LcGesWeb.Registro.Tabela := LcTab;
      LcGesWeb.Registro.Codigo := LcCtrl.Lista[I].Codigo;
      LcGesWeb.getByKey;
      if (not LcGesWeb.exist) and (LcIdPackage > 0 ) then
      Begin
        LcGesWeb.Registro.Tabela := LcTab;
        LcGesWeb.Registro.Codigo := LcCtrl.Lista[I].Codigo;
        LcGesWeb.Registro.WebID :=  LcIdPackage;
        LcGesWeb.insert;
      End;

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcGesWeb.DisposeOf;;
    LcCtrl.DisposeOf;;
  end;


end;

procedure TTerminalToWeb.FirstChargePaymentTypes;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerFormaPagamento;
  LcReg : TFormaPagamento;
  LcPayTypes : TPaymentTypes;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcGesWeb : TControllerGestaoWeb;
  LcResult : TResult;
begin
  try
    LcCtrl := TControllerFormaPagamento.Create(Self);
    LcGesWeb := TControllerGestaoWeb.Create(Self);

    LcTab := 'TB_FORMAPAGTO';
    LcCtrl.getlist;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TFormaPagamento.Create;
      LcReg := LcCtrl.Lista[I];

      //VErifica o Codigo na Tabela de Controle DE=>PARA
      LcGesWeb.Registro.Tabela := LcTab;
      LcGesWeb.Registro.Codigo := LcReg.Codigo;
      LcGesWeb.getByKey;
      //Preenche o Objeto para enviar para o servidor
      LcPayTypes := TPaymentTypes.Create;
      if LcGesWeb.exist then
        LcPayTypes.Codigo := LcGesWeb.Registro.WebID
      else
        LcPayTypes.Codigo := 0;
      LcPayTypes.Descricao := LcReg.Descricao;
      LcStrJSon := TJson.ObjectToJsonString(LcPayTypes);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMPaymentTypesClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
      //Regsitra na Tabela de Controle DE=>PARA
      if (not LcGesWeb.exist) and (LcREsult.ID > 0 ) then
      Begin
        LcGesWeb.Registro.Tabela := LcTab;
        LcGesWeb.Registro.Codigo := LcReg.Codigo;
        LcGesWeb.Registro.WebID :=  LcREsult.ID;
        LcGesWeb.insert;
      End;

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcCtrl.DisposeOf;;
    LcGesWeb.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.FirstChargePrice;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerPreco;
  LcReg : TPreco;
  LcPrice : TPrice;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;

begin
  try
    LcCtrl := TControllerPreco.Create(Self);

    LcTab := 'TB_PRECO';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TPreco.Create;
      LcReg := LcCtrl.Lista[I];

      //Preenche o Objeto para enviar para o servidor
      LcPrice := TPrice.Create;
      LcPrice.Estabelecimento := FInstiturionWeb;
      LcPrice.Tabela          := LcReg.CodigoTabela;
      LcPrice.Produto         := LcReg.CodigoProduto;
      LcPrice.Preco           := LcReg.Valor;
      LcPrice.Comissao        := LcReg.AliComissao;
      LcPrice.Quantidade      := LcReg.QtdeMinima;
      LcPrice.MargemLucro     := LcReg.MargemLucro;

      LcStrJSon := TJson.ObjectToJsonString(LcPrice);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMPriceClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTerminalToWeb.FirstChargePriceList;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerTabelaPreco;
  LcReg : TTabelapreco;
  LcPriceList : TPriceList;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
begin
  try
    LcCtrl := TControllerTabelaPreco.Create(Self);

    LcTab := 'TB_TABELA_PRECO';
    LcCtrl.Registro.Estabelecimento := FEstabelecimento;
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TTabelapreco.Create;
      LcReg := LcCtrl.Lista[I];

      //Preenche o Objeto para enviar para o servidor
      LcPriceList := TPriceList.Create;
      LcPriceList.Codigo          := LcReg.Codigo;
      LcPriceList.Estabelecimento := FInstiturionWeb;
      LcPriceList.Descricao       := LcReg.Descricao;
      LcPriceList.Validade        := LcReg.Validade;
      LcPriceList.Modalidade      := LcReg.Modalidade;
      LcPriceList.MargemLucro     := LcReg.MargemLucro;

      LcStrJSon := TJson.ObjectToJsonString(LcPriceList);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMPriceListClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcCtrl.DisposeOf;
  end;
end;

procedure TTerminalToWeb.FirstChargeSalesMan;
Var
  LcCtrl : TControllerColaborador;
  LcReg : TColaborador;
  I : Integer;
  LcObjSalesMan : TObjSalesMan;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerColaborador.Create(Self);

    LcTab := 'TB_COLABORADOR';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TColaborador.Create;
      LcReg := LcCtrl.Lista[I];
      //Popular
      if ValidaCPF_CPJ(LcReg.CPFCNPJ) then
      Begin
        //objeto da nova Estrutura na Web
        LcObjSalesMan := TObjSalesMan.Create;

        FillSalesManObjects(LcReg,LcObjSalesMan);
        LcStrJSon := TJson.ObjectToJsonString(LcObjSalesMan);
        LcValorJSon := FDataCM.SMSalesManClient.save(LcStrJSon);
      End;
      SetLastUpdate(LcTab,'W',NOW);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;

end;

procedure TTerminalToWeb.FirstChargeStockBalance;
Var
  LcCtrl : TControllerEstoque;
  LcReg : TEstoque;
  LcRegWeb : TStockBalance;

  I : Integer;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
begin
  try
    LcCtrl := TControllerEstoque.Create(Self);

    LcTab := 'TB_ESTOQUE';
    LcCtrl.getList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;
    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      LcReg := TEstoque.Create;
      LcReg := LcCtrl.Lista[I];

      //Objeto Novo
      LcRegWeb := TStockBalance.Create;
      LcRegWeb.Estabelecimento  := FInstiturionWeb;
      LcRegWeb.Tabela           := LcReg.CodigoEstoque;
      LcRegWeb.Mercadoria       := LcReg.CodigoProduto;
      LcRegWeb.Quantidade       := LcReg.QtdeDisp;
      LcRegWeb.Minimo           := LcReg.QtdeMinima;

      LcStrJSon := TJson.ObjectToJsonString(LcRegWeb);
      LcValorJSon := FDataCM.SMStockBalanceClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End
  finally
    LcCtrl.DisposeOf;;
  end;

end;

procedure TTerminalToWeb.FirstChargeStockList;
Var
  I : Integer;
  LcTab : String;
  LcCtrl : TControllerEstoques;
  LcStockList : TStockList;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
begin
  try
    LcCtrl := TControllerEstoques.Create(Self);

    LcTab := 'TB_ESTOQUES';
    LcCtrl.Registro.Estabelecimento := FEstabelecimento;
    LcCtrl.GetList;
    progresso.MinValue := 0;
    progresso.MaxValue := LcCtrl.Lista.Count;
    progresso.Progress := 0;

    for I := 0 to LcCtrl.Lista.Count - 1 do
    Begin
      //Preenche o Objeto para enviar para o servidor
      LcStockList := TStockList.Create;
      LcStockList.Codigo          := LcCtrl.Lista[I].Codigo;
      LcStockList.Estabelecimento := FInstiturionWeb;
      LcStockList.Descricao       := LcCtrl.Lista[I].Descricao;
      LcStockList.Tipo            := LcCtrl.Lista[I].Principal;

      LcStrJSon := TJson.ObjectToJsonString(LcStockList);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMStockListClient.save(LcStrJSon);

      SetLastUpdate(LcTab,'W',Now);
      progresso.Progress := I + 1;
    End;
  finally
    LcCtrl.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.FirstChargeStockStatement;
Var
  I : Integer;
  LcTab : String;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcResult : TResult;
  LcQry : TIBQuery;
  LcStkStt : TStockStatement;
begin
  try
    LcTab := 'TB_CTRL_ESTOQUE';
    //Pega a lista de Alterações
    LcQry := TIBQuery.Create(Self);
    LcQry.Database := DM.IBD_Gestao;
    LcQry.Transaction := DM.IBT_Consulta;
    LcQry.SQL.Clear;
    LcQry.SQL.Add(concat(
                  'SELECT * ' ,
                  'FROM TB_CTRL_ESTOQUE_LOG ',
                  'WHERE (CET_LOG_TIME >=:CET_LOG_TIME) ',
                  'order by CET_LOG_TIME '
    ));
    LcQry.ParamByName('CET_LOG_TIME').AsDateTime := getLastUpdate(LcTab,'W');
    LcQry.Active := True;
    LcQry.FetchAll;
    LcQry.First;
    progresso.Progress := 0;
    progresso.MinValue := 0;
    progresso.MaxValue := LcQry.RecordCount;

    while not LcQry.Eof do
    Begin
      if LcQry.FieldByName('CET_LOG_OPER').AsString <> 'D' then
      Begin
        //Preenche o Objeto para enviar para o servidor
        LcStkStt := TStockStatement.Create;
        LcStkStt.Estabelecimento := FEstabelecimento;
        LcStkStt.Terminal        := FTerminal;
        LcStkStt.Ordem           := LcQry.FieldByName('CET_CONTROLE').AsInteger;
        LcStkStt.OrdemItem       := LcQry.FieldByName('CET_ITEM_CTRL').AsInteger;
        LcStkStt.Local           := concat('Terminal - ',FTerminal.ToString);
        LcStkStt.Tipo            := 'Pedido';
        LcStkStt.DataRegistro    := LcQry.FieldByName('CET_DATA').AsDateTime;
        LcStkStt.Direcao         := LcQry.FieldByName('CET_OPERACAO').AsString;
        LcStkStt.Mercadoria      := LcQry.FieldByName('CET_CODPRO').AsInteger;
        LcStkStt.Quantidade      := LcQry.FieldByName('CET_QTDE').AsFloat;

        LcStrJSon := TJson.ObjectToJsonString(LcStkStt);
        //Envia para o servidor e pega o retorno
        LcValorJSon := FDataCM.SMStockStatementClient.save(LcStrJSon);
        LcResult := TResult.Create;
        LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

        SetLastUpdate(LcTab,'W',LcQry.FieldByName('CET_LOG_TIME').AsDateTime);
      End;
      LcQry.Next;
      progresso.Progress := I + 1;
    End;
    LcQry.Close;
  finally
    LcQry.DisposeOf;;
  end;
end;


procedure TTerminalToWeb.GetIdInstitutionWeb;
Var
  LcValorJSon : TJSONValue;
begin
  //Desabilita o Botão
  LcvalorJSon := FDataCM.SMInstitutionClient.getCodigo(FCNPJ);
  FInstiturionWeb := StrToIntDef( LcvalorJSon.Value,0 );
end;


procedure TTerminalToWeb.ReceiveOrders;
Var
  LcCtrl : TControllerPedido;
  LcRegWeb : TObjOrderSale;
  Lista : TObjListOrderSale;
  I : Integer;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcTab : String;
  LcDateTime : TDAteTime;
  LcDateTimeStr : String;
  LcUsuario : TControllerUsuario;
begin
  Try
    LcCtrl  := TControllerPedido.create(Self);
    LcUsuario := TControllerUsuario.Create(Self);
    LcUsuario.getList;
    LcCtrl.UsuarioIntegracao := LcUsuario.Lista[0].Codigo;
    LcTab := 'TB_PEDIDO';
    LcDateTimeStr := DateTimeToSTr(getLastUpdate(LcTab,'D'));
    LcJSon := FDataCM.SMOrderSaleClient.getSyncronize(FInstiturionWeb,LcDateTimeStr);
    Lista := TJson.JsonToObject<TObjListOrderSale>(LcJson);
    I := 0;
    progresso.Progress := 0;
    progresso.MinValue := 0;
    progresso.MaxValue := Lista.Count;
    ;
    for I := 0 to ( Lista.Count - 1) do
    Begin
      LcRegWeb := TObjOrderSale.Create;
      LcRegWeb := Lista[I];
      LcRegWeb.Estabelecimento := FEstabelecimento;
      Try
        Try
          //LcCtrl.saveObjWeb(LcRegWeb);
        Except
           Pc_LogTarefasDelphi(concat(
                                'ReceiveOrders - ',
                                'Terminal: ', intToStr(LcRegWeb.OrdemSale.Terminal),' - ',
                                'Numero  : ', IntToStr(LcRegWeb.OrdemSale.Numero),' - ',
                                'Data    : ', DateToStr(LcRegWeb.Ordem.Data)
           ));
        End;
      Finally
        LcDateTime := LcRegWeb.Ordem.RegistroAlterado;
        SetLastUpdate(LcTab,'D',LcDateTime);
      End;
      progresso.Progress := I + 1;
      ;
      if LcRegWeb <> nil then
        LcRegWeb.DisposeOf;
    End;
  Finally
    LcCtrl.DisposeOf;
    LcUsuario.DisposeOf;
  End;
end;

procedure TTerminalToWeb.FirstCharge;
var
   Lc_Arq_Ini: TIniFile;
begin
  GetIdInstitutionWeb;
  if ( FInstiturionWeb > 0 ) then
  Begin
//    FirstChargePaymentTypes;
//    FirstChargeSalesMan;
    FirstChargeBrand;
    FirstChargePackage;
    FirstChargeMeasure;
    FirstChargePriceList;
    FirstChargeStockList;
    FirstChargeMerchandise;
      FirstChargePrice;
//    FirstChargeBankAccount;
//    FirstChargeCustomer;
//    FirstChargeFinancialPlans;
//    FirstChargeFinancialStatement;
//    FirstChargeStockStatement;
      FirstChargeStockBalance
  End
  Else
  Begin
    ShowMessage('Estabelecimento não encontrado na Internet');
  End;
end;

function TTerminalToWeb.SendBankAccount(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerContaBancaria;
  LcObj : TObjBankAccount;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerContaBancaria.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcObj := TObjBankAccount.Create;
      //Popular
      FillBankAccountObjects(LcCtrl.Registro,LcObj);

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMBankAccountClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendBankAccount - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;

end;

function TTerminalToWeb.SendBrand(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerMarcaProduto;
  LcTbl  : TBrand;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerMarcaProduto.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TBrand.Create;
      LcTbl.Codigo           := 0;
      LcTbl.Descricao        := LcCtrl.Registro.Descricao;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMBrandClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendBrand - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;


function TTerminalToWeb.SendCategory(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerCategory;
  LcTbl  : TCategory;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
begin
  Try
    Try
      LcCtrl := TControllerCategory.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getByKey;

      LcTbl := TCategory.Create;
      LcTbl.Codigo           := LcCtrl.Registro.Codigo;
      LcTbl.Estabelecimento  := FInstiturionWeb;
      LcTbl.Descricao        := LcCtrl.Registro.Descricao;
      LcTbl.NivelPosicao     := LcCtrl.Registro.NivelPosicao;
      LcTbl.Tipo             := LcCtrl.Registro.Tipo;
      LcTbl.Ativo            := LcCtrl.Registro.Ativo;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMCAtegoryClient.save(FInstiturionWeb.ToString,LcStrJSon);
      Result := TResult.Create;
      REsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendCategory - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;

function TTerminalToWeb.SendColor(IdDsk: Integer): TResult;
begin

end;

function TTerminalToWeb.SendCustomer(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerCliente;
  LcObj  : TObjCustomer;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerCliente.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      //Objeto Novo
      FillCustomerObjects(LcCtrl.Registro,LcObj);
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMCustomerClient.save(LcStrJSon);

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMCustomerClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendCustomer - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;

      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;


end;

function TTerminalToWeb.SendFalta(IdDsk: Integer): TResult;
begin
  Result.Create;
  Result.ID := 0;
  Result.Code := 0;
  Result.Mensagem := 'Não implementado';
end;

function TTerminalToWeb.SendFinancialPlans(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerPlanoContas;
  LcObj : TObjFinancialPlans;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerPlanoContas.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      //Objeto Novo
      LcObj := TObjFinancialPlans.Create;
      //Popular
      FillFinancialPlansObjects(LcCtrl.Registro,LcObj);

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMBankAccountClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendFinancialPlans - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;

      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;

end;

function TTerminalToWeb.SendFinancialStatement(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerMovimentoFinanceiro;
  LcObj  : TObjFinancialStatement;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerMovimentoFinanceiro.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      //Objeto Novo
      LcObj := TObjFinancialStatement.Create;
      //Popular
      FillFinancialStatementObjects(LcCtrl.Registro,LcObj);

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMFinancialStatementClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendFinancialSatement - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;

end;

function TTerminalToWeb.SendPackage(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerEmbalagem;
  LcTbl  : TPackage;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerEmbalagem.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TPackage.Create;
      LcTbl.Codigo           := 0;
      LcTbl.Descricao        := LcCtrl.Registro.Descricao;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMPackageClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendPackage - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;

function TTerminalToWeb.SendPaymentTypes(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerFormaPagamento;
  LcTbl  : TPaymentTypes;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerFormaPagamento.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TPaymentTypes.Create;
      LcTbl.Codigo           := 0;
      LcTbl.Descricao        := LcCtrl.Registro.Descricao;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMPaymentTypesClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendPaymentType - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;

function TTerminalToWeb.SendPrice(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerPreco;
  LcTbl  : TPrice;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerPreco.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TPrice.Create;
      LcTbl.Estabelecimento := FInstiturionWeb;
      LcTbl.Tabela          := LcCtrl.Registro.CodigoTabela;
      LcTbl.Produto         := LcCtrl.Registro.CodigoProduto;
      LcTbl.Preco           := LcCtrl.Registro.Valor;
      LcTbl.Comissao        := LcCtrl.Registro.AliComissao;
      LcTbl.Quantidade      := LcCtrl.Registro.QtdeMinima;
      LcTbl.MargemLucro     := LcCtrl.Registro.MargemLucro;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMPriceClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendPrice - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;


end;

function TTerminalToWeb.SendPriceList(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerTabelaPreco;
  LcTbl  : TPriceList;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerTabelaPreco.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TPriceList.Create;
      LcTbl.Codigo          := LcCtrl.Registro.Codigo;
      LcTbl.Estabelecimento := FInstiturionWeb;
      LcTbl.Descricao       := LcCtrl.Registro.Descricao;
      LcTbl.Validade        := LcCtrl.Registro.Validade;
      LcTbl.Modalidade      := LcCtrl.Registro.Modalidade;
      LcTbl.MargemLucro     := LcCtrl.Registro.MargemLucro;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMPriceClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendPriceList - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;

function TTerminalToWeb.SendSalesMan(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerColaborador;
  LcObj  : TObjSalesMan;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerColaborador.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      if ValidaCPF_CPJ(LcCtrl.Registro.CPFCNPJ) then
      Begin
        //objeto da nova Estrutura na Web
        LcObj := TObjSalesMan.Create;

        FillSalesManObjects(LcCtrl.Registro,LcObj);
        LcStrJSon := TJson.ObjectToJsonString(LcObj);
        LcValorJSon := FDataCM.SMSalesManClient.save(LcStrJSon);

        //Envia para o servidor e pega o retorno
        LcStrJSon := TJson.ObjectToJsonString(LcObj);
        LcValorJSon := FDataCM.SMSalesManClient.save(FInstiturionWeb.ToString,LcStrJSon);
        LcResult := TResult.Create;
        LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
      End;
    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendSalesMan - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;


end;

function TTerminalToWeb.SendStockBalance(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerEstoque;
  LcTbl  : TStockBalance;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerEstoque.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl  := TStockBalance.Create;
      LcTbl.Estabelecimento := FInstiturionWeb;
      LcTbl.Tabela          := LcCtrl.Registro.CodigoEstoque;
      LcTbl.Mercadoria      := LcCtrl.Registro.CodigoProduto;
      LcTbl.Quantidade      := LcCtrl.Registro.QtdeDisp;
      LcTbl.Minimo          := LcCtrl.Registro.QtdeMinima;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMStockBalanceClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendStockBalance - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;


end;

function TTerminalToWeb.SendStockList(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerEstoques;
  LcTbl  : TStockList;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerEstoques.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      //Preenche o Objeto para enviar para o servidor
      LcTbl := TStockList.Create;
      LcTbl.Codigo          := LcCtrl.Registro.Codigo;
      LcTbl.Estabelecimento := FInstiturionWeb;
      LcTbl.Descricao       := LcCtrl.Registro.Descricao;
      LcTbl.Tipo            := LcCtrl.Registro.Principal;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMStockListClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendStockList - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;

function TTerminalToWeb.SendStockStatement(IdDsk: Integer): TResult;
Var
  I : Integer;
  LcTab : String;
  LcStrJSon : String;
  LcJSon : TJsonObject;
  LcValorJSon : TJSONValue;
  LcResult : TResult;
  LcQry : TIBQuery;
  LcStkStt : TStockStatement;
  Lista :TListaSincronia;
begin
  try
    Result.Create;
    Result.ID := 0;
    Result.Code := 0;
    Result.Mensagem := 'TB_CTRL_ESTOQUE - Enviado todos juntos';

    LcTab := 'TB_CTRL_ESTOQUE';
    //Pega a lista de Alterações
    LcQry := TIBQuery.Create(Self);
    LcQry.Database := DM.IBD_Gestao;
    LcQry.Transaction := DM.IBT_Consulta;
    LcQry.SQL.Clear;
    LcQry.SQL.Add(concat(
                  'SELECT * ' ,
                  'FROM TB_CTRL_ESTOQUE_LOG ',
                  'WHERE (CET_LOG_TIME >=:CET_LOG_TIME) ',
                  'order by CET_LOG_TIME '
    ));
    LcQry.ParamByName('CET_LOG_TIME').AsDateTime := getLastUpdate(LcTab,'W');
    LcQry.Active := True;
    LcQry.FetchAll;
    LcQry.First;
    progresso.Progress := 0;
    progresso.MinValue := 0;
    progresso.MaxValue := LcQry.RecordCount;

    while not LcQry.Eof do
    Begin
      //VErifica o Codigo na Tabela de Controle DE=>PARA
      //Preenche o Objeto para enviar para o servidor
      LcStkStt := TStockStatement.Create;
      LcStkStt.Estabelecimento := FInstiturionWeb;
      LcStkStt.Terminal        := FTerminal;
      LcStkStt.Ordem           := LcQry.FieldByName('CET_CONTROLE').AsInteger;
      LcStkStt.OrdemItem       := LcQry.FieldByName('CET_ITEM_CTRL').AsInteger;
      LcStkStt.Local           := concat('Terminal - ',FTerminal.ToString);
      LcStkStt.Tipo            := 'Pedido';
      LcStkStt.DataRegistro    := LcQry.FieldByName('CET_DATA').AsDateTime;
      LcStkStt.Direcao         := LcQry.FieldByName('CET_OPERACAO').AsString;
      LcStkStt.Mercadoria      := LcQry.FieldByName('CET_CODPRO').AsInteger;
      LcStkStt.Quantidade      := LcQry.FieldByName('CET_QTDE').AsFloat;

      LcStrJSon := TJson.ObjectToJsonString(LcStkStt);
      //Envia para o servidor e pega o retorno
      LcValorJSon := FDataCM.SMStockStatementClient.save(LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);
      SetLastUpdate(LcTab,'W',LcQry.FieldByName('CET_LOG_TIME').AsDateTime);
      LcQry.Next;
      progresso.Progress := I + 1;
    End;
    LcQry.Close;
  finally
    LcQry.DisposeOf;;
  end;
end;

procedure TTerminalToWeb.setFDataCM(const Value: TDataCM);
begin
  FDataCM := Value;
end;

function TTerminalToWeb.SendMeasure(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerMedida;
  LcTbl  : TMeasure;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerMedida.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcTbl := TMeasure.Create;
      LcTbl.Codigo           := 0;
      LcTbl.Descricao        := LcCtrl.Registro.Descricao;

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcTbl);
      LcValorJSon := FDataCM.SMMeasureClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendMeasure - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcTbl.DisposeOf;;
  End;
end;


function TTerminalToWeb.SendMerchandise(IdDsk: Integer): TResult;
Var
  LcCtrl : TControllerProduto;
  LcObj  : TObjMerchandise;
  LcValorJSon : TJSONValue;
  LcStrJSon : String;
  LcResult : TResult;
begin
  Try
    Try
      LcCtrl := TControllerProduto.Create(Self);
      LcCtrl.Registro.Codigo := IdDsk;
      LcCtrl.getbyId;

      LcObj := TObjMerchandise.create;
      FillMerchandiseObjects(LcCtrl.Registro,LcObj);

      //Envia para o servidor e pega o retorno
      LcStrJSon := TJson.ObjectToJsonString(LcObj);
      LcValorJSon := FDataCM.SMProductClient.save(FInstiturionWeb.ToString,LcStrJSon);
      LcResult := TResult.Create;
      LcREsult := TJson.JsonToObject<TResult>(LcValorJSon.ToJSON);

    Except
      on e: Exception do
      BEgin
        Pc_LogTarefasDelphi(concat('sendMerchandise - ',
                                    e.Message
            ));
        REsult.ID := 0;
        REsult.Code := 0;
        REsult.Mensagem := e.Message;
      End;
    end;
  Finally
    LcCtrl.DisposeOf;;
    LcObj.DisposeOf;;
  End;
end;


procedure TTerminalToWeb.SyncListTable;
Var
  I : Integer;
begin
  FListaTables.getlist;
  for I := 0 to FListaTables.Lista.count -1 do
  Begin
    if FListaTables.Lista[I].Sincroniza then
      SyncTable(FListaTables.Lista[I].Name,FListaTables.Lista[I].WebId);
  End;
end;

procedure TTerminalToWeb.SyncTable(pTab: String;pWEbId:Boolean);
Var
  I : Integer;
  Registro : TSincronia;
  LcResult : TResult;
  LcLista :TListaSincronia;
  LcRegId : Integer;
begin
  try
    LcLista := TListaSincronia.Create;
    LcLista :=  getListSincronia(pTab,'W');
    progresso.Progress := 0;
    progresso.MinValue := 0;
    progresso.MaxValue := LcLista.Count;

    for I := 0 to LcLista.Count - 1 do
    Begin
      TRy
        Try
          Registro := LcLista[I];
           if Registro.Operacao <> 'D' then
          Begin
            LcRegId := Registro.Registro;
            //VErifica o Codigo na Tabela de Controle DE=>PARA
            if pWEbId then
            Begin
              FGesWeb.Registro.Tabela := pTab;
              FGesWeb.Registro.Codigo := Registro.Registro;
              FGesWeb.Registro.Tabela := pTab;
              FGesWeb.getByKey;
              if FGesWeb.exist then
                LcRegId := FGesWeb.Registro.WebID
              else
                LcRegId := 0;
            End;
            //Preenche o Objeto para enviar para o servidor
            LcResult := executeSend(pTab,LcRegId);
            //Regsitra na Tabela de Controle DE=>PARA
            if pWEbId then
            Begin
              if (not FGesWeb.exist) and (LcREsult.ID > 0 ) then
              Begin
                FGesWeb.Registro.Tabela := pTab;
                FGesWeb.Registro.Codigo := Registro.Registro;
                FGesWeb.Registro.WebID :=  LcREsult.ID;
                FGesWeb.insert;
              End;
            End;
          End;
          TThread.Synchronize(nil,
            procedure
            Begin
              progresso.Progress := progresso.Progress + 1;
            end
          );
        Except
          on e: Exception do
          BEgin
            Pc_LogTarefasDelphi(concat('sync - ',pTab,
                                        e.Message
                ));
          End;
        end;
      Finally
        SetLastUpdate(pTab,'W',Registro.Tempo);
         progresso.Progress := I + 1;
      End;
    End;
  finally
    LcLista.DisposeOf;
  end;
end;

end.
