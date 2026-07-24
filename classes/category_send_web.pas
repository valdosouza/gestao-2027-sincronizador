unit category_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerDskCategory, System.JSON;

Type
  TCategorySendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskCategory;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TCategorySendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskCategory.Create(nil);
end;

destructor TCategorySendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TCategorySendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getByKey;
  if FCtrl.exist then
  Begin
    // Contrato /category/sincronize: id = CAT_CODIGO local ✅; tb_institution_id
    // NÃO viaja (D12); posit_level NUNCA viaja — o servidor recalcula a árvore.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('kind', FCtrl.Registro.Tipo);
      // TODO: Firebird (TDskCategory/TB_CATEGORY) não tem campo de pai explícito
      // (só posit_level, string tipo "001.002") — usando raiz até haver FK própria.
      LcJson.AddPair('parentId', TJSONNumber.Create(0));
      LcJson.AddPair('active', FCtrl.Registro.Ativo);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_CATEGORY', 'ID', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

