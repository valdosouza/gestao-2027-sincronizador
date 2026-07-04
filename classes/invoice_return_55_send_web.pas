unit invoice_return_55_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerRetornoNFe,ObjInvoiceReturn55;

Type
  TInvoiceReturn55SendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerRetornoNFe;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TInvoiceReturn55SendWeb.Create;
begin
  inherited;
  FCtrl := TControllerRetornoNFe.Create(nil);
end;

destructor TInvoiceReturn55SendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceReturn55SendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
//    FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.fillDataObjeto(FCtrl.Registro);
      FStrJSon := TJson.ObjectToJsonString(FCtrl.Obj);
//    
  End;
end;


end.

