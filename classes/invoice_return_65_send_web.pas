unit invoice_return_65_send_web;


interface

uses System.SysUtils,general_web,REST.Json,
     ControllerRetornoNFCe,ObjInvoiceReturn65;

Type
  TInvoiceReturn65SendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerRetornoNFCe;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TInvoiceReturn65SendWeb.Create;
begin
  inherited;
  FCtrl := TControllerRetornoNFCe.Create(nil);
end;

destructor TInvoiceReturn65SendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceReturn65SendWeb.GenerateJson;
begin
  inherited;
    FCtrl.clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal        := FTerminal;
     // FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.fillDataObjeto(FCtrl.Registro);
//    Envia para o servidor e pega o retorno
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
      end;
end;


end.

