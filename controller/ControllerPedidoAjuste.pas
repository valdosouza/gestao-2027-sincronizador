unit ControllerPedidoAjuste;

interface

uses ControllerPedido,tblOrder,tblOrderStockAdjust,tblOrderItem,objORderStockAdjust,
  System.SysUtils,ObjCustomer,tblPedido, System.Classes, Controllercolaborador;

type
  TControllerPedidoAjuste = class(TControllerPedido)
  private

  protected


  public
    Obj : TObjOrderStockAdjust;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearDataObjecto;
    procedure FillDataObjeto(PcReg: TPedido);
    function ValidasaveObjWeb(pOrder: TObjOrderStockAdjust): Boolean;

  end;
implementation

{ TControllerPedidoAjuste }

procedure TControllerPedidoAjuste.ClearDataObjecto;
begin
  ClearObj(Obj);
end;

constructor TControllerPedidoAjuste.Create(AOwner: TComponent);
begin
  inherited;
  Obj := TObjOrderStockAdjust.Create;
end;

destructor TControllerPedidoAjuste.Destroy;
begin
  Obj.Destroy;
  inherited;
end;

procedure TControllerPedidoAjuste.FillDataObjeto(PcReg: TPedido);
Var
  I : Integer;
  lcitems : TOrderItem;
  Lc_Colab : TControllercolaborador;
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
  Obj.Order.UserExternalCode :=  PcReg.Usuario;
  Obj.Order.RegistroCriado  := PcReg.DataAlteracao;
  Obj.Order.RegistroCriado  := PcReg.DataAlteracao;

  //OrderStockAdjust
  Obj.OrderStockAdjust.Codigo          := Obj.Order.Codigo;
  Obj.OrderStockAdjust.Estabelecimento := Obj.Estabelecimento;
  Obj.OrderStockAdjust.Terminal        := Obj.Terminal;
  Obj.OrderStockAdjust.Numero          := PcReg.Numero;
  Obj.OrderStockAdjust.Destinatario    := 0;
  Obj.OrderStockAdjust.EntityExternalCode := PcReg.Empresa;

  //Items Lembrando que o NFL_Codigo será o tb_order_id
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
      lcitems.kind              := 'StockAdjust';
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
  Obj.Totalizer.AlíquotaDesconto  := PcReg.AliqDesconto;
  Obj.Totalizer.ValorDesconto     := PcReg.ValorDesconto;
  Obj.Totalizer.ValorDespesas     := PcReg.ValorOutrasDEspesas;
  Obj.Totalizer.ValorTotal        := PcReg.ValorPedido;

end;


function TControllerPedidoAjuste.ValidasaveObjWeb( pOrder: TObjOrderStockAdjust): Boolean;
begin
  Result := True;
  {
  if (pOrder.Cliente.Fiscal.Fisica.CPF = '') and (pOrder.Cliente.Fiscal.Juridica.CNPJ = '') then
  Begin
    geralog('TControllerPedido.ValidasaveObjWeb',
            concat(
              'Mensagem: Sem CPF/CNJ :   ',
              ' | Terminal: ', IntToStr(pOrder.OrderStockAdjust.Terminal),
              ' | Numero: ', IntToStr(pOrder.OrderStockAdjust.Numero),
              ' | Estabelecimento: ', IntToStr(pOrder.Estabelecimento)
            ));
  End;
  }

end;

end.

