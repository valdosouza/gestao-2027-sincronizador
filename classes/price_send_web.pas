unit price_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerPreco,tblPrice;

Type
  TPriceSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerPreco;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TPriceSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerPreco.Create(nil);
end;

destructor TPriceSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPriceSendWeb.GenerateJson;
Var
  LcObj: TPrice;
begin
inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getByCodigo;
    if FCtrl.exist then
  Begin
      LcObj                 := TPrice.Create;
      LcObj.Estabelecimento := FInstitutionDestino;
      LcObj.Tabela          := FCtrl.Registro.CodigoTabela;
      LcObj.Produto         := FCtrl.Registro.CodigoProduto;
      LcObj.Preco           := FCtrl.Registro.Valor;
      LcObj.Comissao        := FCtrl.Registro.AliComissao;
      LcObj.Quantidade      := FCtrl.Registro.QtdeMinima;
      LcObj.MargemLucro     := FCtrl.Registro.MargemLucro;
      FStrJson              := TJson.ObjectToJsonString(LcObj);

  End;

end;

end.


