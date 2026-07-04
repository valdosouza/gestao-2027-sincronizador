unit price_list_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerTabelaPreco,json_price_list;

Type
  TPriceListSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerTabelaPreco;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TPriceListSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerTabelaPreco.Create(nil);
end;

destructor TPriceListSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPriceListSendWeb.GenerateJson;
Var
  LcObj: TJsonPriceList;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    LcObj := TJsonPriceList.Create;
    LcObj.Codigo          := FCtrl.Registro.Codigo;
    LcObj.Estabelecimento := FInstitutionDestino;
    LcObj.Descricao       := FCtrl.Registro.Descricao;
    LcObj.Validade        := FCtrl.Registro.Validade;
    LcObj.Modalidade      := FCtrl.Registro.Modalidade;
    LcObj.MargemLucro     := FCtrl.Registro.MargemLucro;
    LcObj.Ativo           := FCtrl.Registro.Ativa;
    FStrJson := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

