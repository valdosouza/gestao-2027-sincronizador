unit stock_list_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerEstoques,tblStockList,
     System.JSON;

Type
  TStockListSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerEstoques;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TStockListSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerEstoques.Create(nil);
end;

destructor TStockListSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TStockListSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // Contrato /stock-list/sincronize: id = ETS_CODIGO local ✅; Estabelecimento
    // NÃO viaja (D12). TEstoques/tb_estoques só tem Codigo/Descricao/Principal —
    // active/kind/terminal recebem defaults razoáveis (TODO abaixo).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('main', FCtrl.Registro.Principal);
      // TODO: Firebird (tb_estoques) não tem coluna de ativo — 'S' fixo.
      LcJson.AddPair('active', 'S');
      // TODO: Firebird não tem coluna de "kind" para estoque — null.
      LcJson.AddPair('kind', TJSONNull.Create);
      // TODO: Firebird não tem coluna de terminal para estoque — 0 fixo.
      LcJson.AddPair('terminal', TJSONNumber.Create(0));
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_ESTOQUES', 'ETS_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

