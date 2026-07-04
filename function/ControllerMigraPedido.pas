unit ControllerMigraPedido;

interface

uses BaseController, ControllerPedido, System.Classes, ControllerNotaFiscal,
  ControllerFinanceiro, System.SysUtils, ControllerMovimentoFinanceiro,
  ControllerRetornoNFCe, ControllerRetornoNFe, ControllerArquivo;

type
  TControllerMigraPedido = Class(TBaseController)
      Pedido : TControllerPedido;
      NotaFiscal : TControllerNotaFiscal;
      Financeiro : TControllerFinanceiro;
      Movimento : TControllerMovimentoFinanceiro;
      RetornoNFe : TControllerRetornoNfe;
      RetornoNFCe : TControllerRetornoNfCe;
      ArquivoXML : TControllerArquivo;
    private

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  End;
implementation

{ TControllerMigraPedido }

constructor TControllerMigraPedido.Create(AOwner: TComponent);
begin
  inherited;
  Pedido      := TControllerPedido.Create(Self);
  NotaFiscal  := TControllerNotaFiscal.Create(Self);
  Financeiro  := TControllerFinanceiro.Create(Self);
  Movimento  := TControllerMovimentoFinanceiro.Create(Self);
  RetornoNFe  := TControllerRetornoNfe.Create(Self);
  RetornoNFCe := TControllerRetornoNfCe.Create(Self);
  ArquivoXML  := TControllerArquivo.Create(Self);
end;

destructor TControllerMigraPedido.Destroy;
begin
  FreeAndNil( Pedido );
  FreeAndNil( NotaFiscal );
  FreeAndNil( Financeiro );
  FreeAndNil( Movimento );
  FreeAndNil( RetornoNFe );
  FreeAndNil( RetornoNFCe );
  FreeAndNil( ArquivoXML );
  inherited;
end;

end.
