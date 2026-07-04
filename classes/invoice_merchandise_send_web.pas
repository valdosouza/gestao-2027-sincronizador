unit invoice_merchandise_send_web;


interface

uses System.SysUtils,general_web,REST.Json,ControllerNotaFiscal,
     ObjInvoiceMerchandise;

Type
  TInvoiceMerchandiseSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerNotaFiscal;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TInvoiceMerchandiseSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerNotaFiscal.Create(nil);
end;

destructor TInvoiceMerchandiseSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceMerchandiseSendWeb.GenerateJson;

begin
  inherited;
    FCtrl.NotaAvulsa := False;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.ClearDataObjecto;
      FCtrl.ObjMerchandise.Estabelecimento:= FInstitutionDestino;
//     FCtrl.Obj.EstabelecimentoCNPJ  := FEstabelecimentoCNPJ;
      FCtrl.ObjMerchandise.Terminal := FTerminal;
//      FCtrl.Obj.Descricao := FDescricao;
      FCtrl.FillDataObjetoMerchandise(FCtrl.Registro);
      FStrJson := TJson.ObjectToJsonString(FCtrl.ObjMerchandise);
  End;
end;


end.

