unit brand_send_web;

interface

uses System.SysUtils,general_web,REST.Json,ControllerMarcaProduto, System.JSON;

Type
  TBrandSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMarcaProduto;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TBrandSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMarcaProduto.Create(nil);
end;

destructor TBrandSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TBrandSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // Contrato /brand/sincronize: SEM id, SEM institution (catálogo central,
    // dedupe por descrição — MRC_CODIGO local é descartado, D17/D12).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_MARCA_PRODUTO', 'MRC_CODIGO', FCodigo));
      FStrJSon := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

