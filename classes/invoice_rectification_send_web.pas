unit invoice_rectification_send_web;

interface

uses System.SysUtils,general_web,REST.Json,
     ControllerCartaCorrecao,ObjInvoiceRectification;

Type
  TInvoiceRectificationSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCartaCorrecao;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TInvoiceRectificationSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCartaCorrecao.Create(nil);
end;

destructor TInvoiceRectificationSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceRectificationSendWeb.GenerateJson;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      FCtrl.Obj.Estabelecimento := FInstitutionDestino;
      FCtrl.Obj.Terminal := FTerminal;
//    FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.fillDataObjeto(FCtrl.Registro);
      FStrJson := TJson.ObjectToJsonString(FCtrl.Obj);

  End;
end;


end.

