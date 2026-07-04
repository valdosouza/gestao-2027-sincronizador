unit invoice_detached_send_web;


interface

uses System.SysUtils,general_send_web,REST.Json,
     ControllerNotaFiscal,ObjInvoiceMerchandise;

Type
  TInvoiceDetachedSendWeb = class(TGeneralSendWeb)
    private
      FCtrl: TControllerNotaFiscal;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralSendWeb }

constructor TInvoiceDetachedSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerNotaFiscal.Create(nil);
end;

destructor TInvoiceDetachedSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TInvoiceDetachedSendWeb.GenerateJson;
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
//    FCtrl.Obj.EstabelecimentoCNPJ := FCNPJ;
      FCtrl.ObjInvoice.Terminal := FTerminal;
//    FCtrl.Obj.Descricao := FDESCRICAO;
      FCtrl.FillDataObjetoDetached(FCtrl.Registro);
      FStrJson := TJson.ObjectToJsonString(FCtrl.ObjInvoice);
//    Envia para o servidor e pega o retorno
//    FStrJSon := EncodeBase64(TJson.ObjectToJsonString(FCtrl.Obj.Nota) );
//    LcStrJSon := FDataCM.SMInvoiceClient.save(LcStrJSon);
//    Result := TJson.JsonToObject<TResult>(LcStrJSon);
  End;
end;


end.

