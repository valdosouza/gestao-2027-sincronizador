unit price_list_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerTabelaPreco,  System.JSON;

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

uses un_dm;

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
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    // Contrato /price-list/sincronize: id = TPR_CODIGO local ✅; Estabelecimento
    // NÃO viaja (D12).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('validity', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.Validade));
      LcJson.AddPair('modality', FCtrl.Registro.Modalidade);
      LcJson.AddPair('aliqProfit', TJSONNumber.Create(FCtrl.Registro.MargemLucro));
      LcJson.AddPair('published', FCtrl.Registro.Ativa);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_TABELA_PRECO', 'TPR_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

