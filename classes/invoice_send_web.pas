unit invoice_send_web;


interface

uses System.SysUtils,general_web,REST.Json,
     ControllerNotaFiscal,ObjInvoiceMerchandise;

Type
  TInvoiceSendWeb = class(TGeneralWeb)
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

constructor TInvoiceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerNotaFiscal.Create(nil);
end;

destructor TInvoiceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceSendWeb.GenerateJson;
begin
  inherited;
  FCtrl.NotaAvulsa := True;
  FCtrl.Registro.Tipo := 'EM';
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getSincronia;
  if FCtrl.exist then
  Begin
    FCtrl.ClearDataObjecto;
    FCtrl.ObjInvoice.Estabelecimento := FInstitutionDestino;
    FCtrl.ObjInvoice.Terminal := FTerminal;
    FCtrl.FillDataObjetoDetached(FCtrl.Registro);
    FStrJson := TJson.ObjectToJsonString(FCtrl.ObjInvoice);
  End;
end;


end.

