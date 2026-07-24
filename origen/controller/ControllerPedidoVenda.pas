unit ControllerPedidoVenda;

interface

uses ControllerPedido,tblOrder,tblOrderSale,tblOrderItem,objORderSale,
  System.SysUtils,ObjCustomer,tblPedido, System.Classes,ControllerCliente;

type
  TControllerPedidoVenda = class(TControllerPedido)

  private

  protected

  public
    Obj:TObjOrderSale;
    Cliente : TControllerCliente;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearDataObjecto;
    procedure saveObjWeb(pOrder:TObjOrderSale);
    procedure FillDataObjeto(PcReg: TPedido);
    function ValidasaveObjWeb(pOrder: TObjOrderSale): Boolean;
  end;
implementation

{ TControllerPedidoVenda }

procedure TControllerPedidoVenda.ClearDataObjecto;
begin
  Obj.clear;
end;

constructor TControllerPedidoVenda.Create(AOwner: TComponent);
begin
  inherited;
  Cliente   := TControllerCliente.create(Self);
  Obj := TObjOrderSale.Create;
end;

destructor TControllerPedidoVenda.Destroy;
begin
  Cliente.DisposeOf;
  Obj.Destroy;
  inherited;
end;

procedure TControllerPedidoVenda.FillDataObjeto(PcReg: TPedido);
Var
  I : Integer;
  lcitems : TOrderItem;
begin
  //Order
  Obj.Order.Codigo          := PcReg.Codigo;
  Obj.Order.Estabelecimento := Obj.Estabelecimento;
  Obj.Order.Terminal        := Obj.Terminal;
  Obj.Order.Data            := PcReg.Data;
  Obj.Order.Observacao      := PcReg.Observacao;
  Obj.Order.Origem          := 'D';
  Obj.Order.Status          := PcReg.Faturado;
  Obj.Order.SendoUsado      := '';
  Obj.Order.RegistroCriado  := PcReg.DataAlteracao;

  //OrderSale
  Obj.OrderSale.Codigo          := Obj.Order.Codigo;
  Obj.OrderSale.Estabelecimento := Obj.Estabelecimento;
  Obj.OrderSale.Terminal        := Obj.Terminal;
  Obj.OrderSale.Vendedor        := 0;
  Obj.OrderSale.Numero          := PcReg.Numero;
  Obj.OrderSale.Cliente         := 0;

  //Items Lembrando que o NFL_Codigo ser� o tb_order_id
  Itens.Registro.CodigoNota := PcReg.Codigo;
  Itens.getListByNF;
  if Itens.Lista.Count > 0 then
  Begin
    Obj.setArrayItems( Itens.Lista.Count);
    for I := 0 to Itens.Lista.Count -1 do
    Begin
      lcitems     := TOrderItem.Create;
      lcitems.Codigo            := Itens.Lista[I].Codigo;
      lcitems.Estabelecimento   := Obj.Estabelecimento;
      lcitems.Ordem             := Obj.Order.Codigo;
      lcitems.Terminal          := Obj.Terminal;
      lcitems.Produto           := Itens.Lista[I].CodigoProduto;
      lcitems.Estoque           := Itens.Lista[I].CodigoEstoque;
      lcitems.TabelaPreco       := Itens.Lista[I].CodigoTabela;
      lcitems.Quantidade        := Itens.Lista[I].Quantidade;
      lcitems.ValorUnitario     := Itens.Lista[I].ValorUnitario;
      lcitems.AliquotaDesconto  := Itens.Lista[I].AliqDesconto;
      lcitems.ValorDesconto     := Itens.Lista[I].ValorDesconto;
      lcitems.kind              := 'Sale';
      Obj.Items[I] := lcitems;
    end;
  End;

  //Totlalizer
  Obj.Totalizer.Codigo            := Obj.Order.Codigo;
  Obj.Totalizer.Estabelecimento   := Obj.Estabelecimento;
  Obj.Totalizer.Terminal          := Obj.Terminal;
  Obj.Totalizer.ItemsQuantidade   := Itens.Lista.Count;
  Obj.Totalizer.ProdutoQuantidade := PcReg.QtdeProdutos;
  Obj.Totalizer.ValorProduto      := PcReg.ValorProdutos;
  Obj.Totalizer.IPIValor          := PcReg.ValorIPI;
  Obj.Totalizer.AliquotaDesconto  := PcReg.AliqDesconto;
  Obj.Totalizer.ValorDesconto     := PcReg.ValorDesconto;
  Obj.Totalizer.ValorDespesas     := PcReg.ValorOutrasDEspesas;
  Obj.Totalizer.ValorTotal        := PcReg.ValorPedido;

  //Billing
  FormaPagto.Registro.Codigo :=  PcReg.FormaPagto;
  FormaPagto.getById;
  Obj.Billing.Codigo          := Obj.Order.Codigo;
  Obj.Billing.Estabelecimento := Obj.Estabelecimento;
  Obj.Billing.Terminal        := Obj.Terminal;
  Obj.Billing.FormaPagamento  := PcReg.FormaPagto;
  // name_payment removido: TOrderBilling (destiny/model) não tem essa
  // propriedade (descrição de exibição, não coluna real) — order_sale_send_web
  // já resolve paymentTypeDescription pelo próprio lookup (FCtrl.FormaPagto).
  Obj.Billing.Parcelas        := Copy(PcReg.Prazo,1,3);
  Obj.Billing.Prazo           := Copy(PcReg.Prazo,7,Length(PcReg.Prazo )- 6);
  Obj.Billing.Responsavel     := 0;
end;

procedure TControllerPedidoVenda.saveObjWeb(pOrder: TObjOrderSale);
Var
  I : Integer;
begin
  //Informar Codigo WEb e Vendedor
  Registro.CodigoWeb              := pOrder.Order.Codigo;
  Registro.Vendedor               := 0;
  pOrder.OrderSale.Vendedor       := Registro.Vendedor;

  if not WebFaturado then
  Begin
    //Verifica se esta faturado e n�o atualiza
    Registro.Codigo                := 0;
    Registro.Numero                := 0;
    Registro.Terminal              := pOrder.Order.Terminal;
    Registro.NumeroWeb             := pOrder.OrderSale.Numero;
    Registro.Tipo                  := 1;
    if pOrder.Order.Data >0  then
      Registro.Data              := pOrder.Order.Data
    else
      Registro.Data              := Date;

    Self.Cliente.Empresa.Clear;
    Self.Cliente.Empresa.exist := False;
    //Agora com o registro do external code vamos tratar de outra forma - 02/11/2023
    {
    if (Trim(pOrder.OrderSale.DocCustomer) = '') then
    Begin
      Self.Cliente.criarClienteSemCPFCNPJ;
    End
    else
    Begin
      //Busca Por CPF
      if Length( Trim(pOrder.OrderSale.DocCustomer) ) = 11 then
      Begin
        Self.Cliente.Empresa.Registro.CpfCNPJ := pOrder.OrderSale.DocCustomer;
        Self.Cliente.Empresa.getByDocumento;
      End;
      //Se n�o encontrou buscar por CNPJ
      if not Self.Cliente.Empresa.exist then
      Begin
        Self.Cliente.Empresa.Registro.CpfCNPJ := pOrder.OrderSale.DocCustomer;
        Self.Cliente.Empresa.getByDocumento;
      End;
      //Caso n�o encontre precisa salvar o cliente
      if not Self.Cliente.Empresa.exist then
      Begin
        //Self.Cliente.Empresa.saveObjWeb(pOrder.Fiscal);
        //Self.Cliente.saveCustomer(pOrder.Cliente);
      End;
    End;
    }
    //Registra o codigo da Empresa no pedido
    Registro.Empresa                      := Self.Cliente.Empresa.Registro.Codigo;
    Self.Endereco.Registro.CodigoEmpresa  := Self.Cliente.Empresa.Registro.Codigo;
    Self.Endereco.getByEmpresa;
    if not Self.Endereco.exist then
    BEgin
      Self.Endereco.Registro.CodigoEmpresa := Self.Cliente.Empresa.Registro.Codigo;
      Self.Endereco.AutoEndereco;
    End;
    if Self.Endereco.Registro.Codigo >0 then
      Registro.Endereco              := Self.Endereco.Registro.Codigo
    else
      Registro.Endereco              := 1;
    Registro.Usuario               := UsuarioIntegracao;

    // name_payment removido: TObjOrderBilling (destiny/data_objetcs) não tem
    // essa propriedade — sem a descrição, cai no fallback autocreate
    // ('CARTEIRA') já existente abaixo. TODO (D16, fase de recebimento):
    // redesenhar como o payload de entrada vai identificar a forma de
    // pagamento quando essa fase for planejada.
    FormaPagto.Registro.Descricao := '';
    FormaPagto.getByDescricao;
    if FormaPagto.exist then
      Registro.FormaPagto            := FormaPagto.Registro.Codigo
    else
    Begin
      FormaPagto.autocreate('CARTEIRA');
      Registro.FormaPagto            := FormaPagto.Registro.Codigo
    End;

    if trim(pOrder.Billing.Prazo) <> '' then
      Registro.Prazo                 := pOrder.Billing.Prazo
    else
      Registro.Prazo                 := '000 - � VISTA';

    Registro.QtdeProdutos := 0;

    for I := 0 to Length(pOrder.Items)-1 do
    Begin
      Registro.QtdeProdutos := Registro.QtdeProdutos + pOrder.Items[I].Quantidade;
    End;


    Registro.ValorProdutos         := porder.Totalizer.ValorProduto;
    Registro.ValorIPI              := porder.Totalizer.IPIValor;
    Registro.ValorFrete            := 0;
    Registro.AliqDesconto          := porder.Totalizer.AliquotaDesconto;
    Registro.ValorDesconto         := porder.Totalizer.ValorDesconto;
    Registro.ValorPedido           := porder.Totalizer.ValorTotal;
    Registro.Faturado              := porder.Order.Status;
    Registro.TipoContato           := '1';
    //DataEntrega           :=
    Registro.ValorServico          := 0;
    Registro.Transportadora        := 0;
    Registro.FretePorConta         := 0;
    Registro.EmUso                 := '';
    Registro.DataAlteracao         := Now;
    Registro.CodigoNatureza        := 0;
    Registro.EnderecoEntrega       := 0;
    Registro.EnderecoFaturamento   := 0;
    Registro.EnderecoCobranca      := 0;
    Registro.CodigoEstabelecimento := porder.Estabelecimento;
    Registro.Aprovado              := 'N';
    Registro.ValorSubstTributaria  := 0;
    Registro.ValorOutrasDEspesas   := porder.Totalizer.ValorDespesas;
    Registro.Observacao            := porder.Order.Observacao;
    Registro.NumeroOrcamento       := 0;
    Registro.Validade              := Date;
    Registro.ValorCredito          := 0;
    Registro.CodigoNegocio         := 0;
    Registro.Entrega               := '';
    Registro.Garantia              := '';
    Registro.OrigemCliente         := '';
    Registro.IndicaPresenca        := 1;
    salvaPedidoInternet;
    //Desregitrar o Estoque
    CtrlEstoque.Desregistra('P',
                            Registro.Codigo,
                            0);

    //Salvar os itens
    Self.Itens.Registro.CodigoPedido := Self.Registro.Codigo;
    Self.Itens.deleteByPedido;
    for I := 0 to Length(pOrder.Items) -1 do
    Begin
      with Self.Itens.Registro do
      BEgin
        Codigo            := 0;
        Sequencia         := I+1;
        CodigoPedido      := Self.Registro.Codigo;
        CodigoNota        := 0;
        CodigoProduto     := pOrder.Items[I].Produto;
        Quantidade        := pOrder.Items[I].Quantidade;
        ValorCusto        := 0;
        ValorUnitario     := pOrder.Items[I].ValorUnitario;
        Despachar         := 'S';
        Estoque           := 'S';
        AliqComissao      := 0;
        ValorDesconto     := pOrder.Items[I].ValorDesconto;
        AliqDesconto      := pOrder.Items[I].AliquotaDesconto;
        AliqIPI           := 0;
        Operacao          := 'V';
        AliqICMS          := 0;
        if pOrder.Items[I].Estoque > 0 then
          CodigoEstoque     := pOrder.Items[I].Estoque
        else
          CodigoEstoque     := 1;
        if pOrder.Items[I].TabelaPreco > 0 then
          CodigoTabela      := pOrder.Items[I].TabelaPreco
        else
          CodigoTabela      := 1;
        Altura            := 0;
        Largura           := 0;
        Sentido           := 'S';
        PedidoCompra      := '0';
        ItemCompra        := '0';
        ImpostoAproximado := 0;
        NumeroPecas       := 0;
      End;
      Self.Itens.insere;
      //Controle de Estoque - Insere
      with CtrlEstoque.Registro do
      Begin
        Codigo      := 0;
        Vinculo     := 'P';
        Terminal    := pOrder.Order.Terminal;
        Ordem       := Self.Itens.Registro.CodigoPedido;
        Item        := Self.Itens.Registro.Codigo;
        Estoque     := Self.Itens.Registro.CodigoEstoque;
        Operacao    := 'S';
        Produto     := Self.Itens.Registro.CodigoProduto;
        Quantidade  := Self.Itens.Registro.Quantidade;
        case Self.Registro.Tipo of
          1:Tipo := 'Venda';
          2:Tipo := 'Compra';
          3:Tipo := 'Ajuste';
          4:Tipo := 'Venda';
          5:Tipo := 'Consigna��o';
        end;
        Data        := Date;
      End;
      CtrlEstoque.Registra;
    End;
  End;
end;


function TControllerPedidoVenda.ValidasaveObjWeb( pOrder: TObjOrderSale): Boolean;
begin
  Result := True;
  {
  if (pOrder.Cliente.Fiscal.Fisica.CPF = '') and (pOrder.Cliente.Fiscal.Juridica.CNPJ = '') then
  Begin
    geralog('TControllerPedido.ValidasaveObjWeb',
            concat(
              'Mensagem: Sem CPF/CNJ :   ',
              ' | Terminal: ', IntToStr(pOrder.OrderSale.Terminal),
              ' | Numero: ', IntToStr(pOrder.OrderSale.Numero),
              ' | Estabelecimento: ', IntToStr(pOrder.Estabelecimento)
            ));
  End;
  }

end;

end.
