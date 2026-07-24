unit merchandise_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerProduto,ObjMerchandise,
     System.JSON, ControllerMarcaProduto, ControllerEmbalagem, ControllerMedida;

Type
  TMerchandiseSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerProduto;
      // Nomes por descrição (D5 do guia de revisão): TMerchandise/TStock
      // (destiny/model) não têm mais name_brand/name_package/name_measure
      // (não são colunas reais) — a resolução mora aqui, não no controller.
      function GetBrandName(pCodigo: Integer): String;
      function GetPackageName(pCodigo: Integer): String;
      function GetMeasureName(pCodigo: Integer): String;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

function TMerchandiseSendWeb.GetBrandName(pCodigo: Integer): String;
Var
  LcCtrl: TControllerMarcaProduto;
begin
  Result := 'N�O INFORMADA';
  LcCtrl := TControllerMarcaProduto.Create(nil);
  Try
    LcCtrl.Registro.Codigo := pCodigo;
    LcCtrl.getbyId;
    if LcCtrl.exist then
      Result := LcCtrl.Registro.Descricao;
  Finally
    LcCtrl.DisposeOf;
  End;
end;

function TMerchandiseSendWeb.GetPackageName(pCodigo: Integer): String;
Var
  LcCtrl: TControllerEmbalagem;
begin
  Result := 'UND';
  LcCtrl := TControllerEmbalagem.Create(nil);
  Try
    LcCtrl.Registro.Codigo := pCodigo;
    LcCtrl.getbyId;
    if LcCtrl.exist then
      Result := LcCtrl.Registro.Descricao;
  Finally
    LcCtrl.DisposeOf;
  End;
end;

function TMerchandiseSendWeb.GetMeasureName(pCodigo: Integer): String;
Var
  LcCtrl: TControllerMedida;
begin
  Result := 'UND';
  LcCtrl := TControllerMedida.Create(nil);
  Try
    LcCtrl.Registro.Codigo := pCodigo;
    LcCtrl.getbyId;
    if LcCtrl.exist then
      Result := LcCtrl.Registro.Descricao;
  Finally
    LcCtrl.DisposeOf;
  End;
end;

constructor TMerchandiseSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerProduto.Create(nil);
end;

destructor TMerchandiseSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TMerchandiseSendWeb.GenerateJson;
Var
  LcJson,
  LcProduct,
  LcMerchandise,
  LcStock: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
    // FillDataObjects preenche product/merchandise/stock (campos reais das
    // tabelas); marca/embalagem/medida são resolvidas por descrição AQUI
    // (GetBrandName/GetPackageName/GetMeasureName), pois TMerchandise/TStock
    // não têm mais name_brand/name_package/name_measure. LcObj morto
    // (criado e nunca usado) foi REMOVIDO.
    FCtrl.FillDataObjects(FCtrl.Registro, FCtrl.Obj, FInstitutionDestino);

    LcJson := TJSONObject.Create;
    try
      // Contrato /merchandise/sincronize: id = PRO_CODIGO ✅; tb_institution_id
      // NÃO viaja (D12) — resolvido pela API key no servidor.
      LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_PRODUTO', 'PRO_CODIGO', FCodigo));

      LcProduct := TJSONObject.Create;
      LcProduct.AddPair('description', FCtrl.Obj.Produto.Descricao);
      LcProduct.AddPair('categoryId', TJSONNumber.Create(FCtrl.Obj.Produto.Categoria));
      LcProduct.AddPair('identifier', FCtrl.Obj.Produto.Identificador);
      // TODO: Firebird (TProduto) não grava centro de custo/plano financeiro
      // no produto ainda — financialPlansId fica NULL.
      LcProduct.AddPair('financialPlansId', TJSONNull.Create);
      LcProduct.AddPair('promotion', FCtrl.Obj.Produto.Promocao);
      LcProduct.AddPair('highlights', FCtrl.Obj.Produto.Destaque);
      LcProduct.AddPair('active', FCtrl.Obj.Produto.Ativo);
      LcProduct.AddPair('published', FCtrl.Obj.Produto.Publicado);
      LcProduct.AddPair('note', FCtrl.Obj.Produto.Observacao);
      LcJson.AddPair('product', LcProduct);

      LcMerchandise := TJSONObject.Create;
      LcMerchandise.AddPair('nameBrand', GetBrandName(FCtrl.Registro.CodigoMarca));
      LcMerchandise.AddPair('internalId', FCtrl.Obj.Mercadoria.CodigoInterno);
      LcMerchandise.AddPair('ncm', FCtrl.Obj.Mercadoria.NCM);
      LcMerchandise.AddPair('cest', FCtrl.Obj.Mercadoria.CEST);
      LcMerchandise.AddPair('kindTributary', FCtrl.Obj.Mercadoria.TipoTributacao);
      LcMerchandise.AddPair('source', FCtrl.Obj.Mercadoria.Origem);
      LcMerchandise.AddPair('kind', FCtrl.Obj.Mercadoria.Tipo);
      LcMerchandise.AddPair('print', FCtrl.Obj.Mercadoria.Imprime);
      LcMerchandise.AddPair('controlSeries', FCtrl.Obj.Mercadoria.ControlarSerie);
      LcMerchandise.AddPair('exclusiveDealer', FCtrl.Obj.Mercadoria.ExclusivoRevenda);
      LcMerchandise.AddPair('application', FCtrl.Obj.Mercadoria.Aplicacao);
      LcMerchandise.AddPair('composition', FCtrl.Obj.Mercadoria.TipoComposicao);
      // TODO: Firebird não tem campo equivalente a manufSignIndScale — 'N' fixo.
      LcMerchandise.AddPair('manufSignIndScale', 'N');
      // Fornecedor/id_provider REMOVIDO do payload — contrato mantém NULL até a
      // Onda 4 do servidor (tb_merchandise.id_provider).
      LcJson.AddPair('merchandise', LcMerchandise);

      LcStock := TJSONObject.Create;
      LcStock.AddPair('namePackage', GetPackageName(FCtrl.Registro.CodigoEmbalagem));
      LcStock.AddPair('nameMeasure', GetMeasureName(FCtrl.Registro.MedidaComercial));
      LcStock.AddPair('codebar', FCtrl.Obj.Estoque.CodigoBarra);
      LcStock.AddPair('st', FCtrl.Obj.Estoque.TemST);
      LcStock.AddPair('divisor', TJSONNumber.Create(FCtrl.Obj.Estoque.Divisor));
      LcStock.AddPair('location', FCtrl.Obj.Estoque.Localizacao);
      LcStock.AddPair('weight', TJSONNumber.Create(FCtrl.Obj.Estoque.Peso));
      LcStock.AddPair('width', TJSONNumber.Create(FCtrl.Obj.Estoque.Largura));
      LcStock.AddPair('length', TJSONNumber.Create(FCtrl.Obj.Estoque.Comprimento));
      LcStock.AddPair('height', TJSONNumber.Create(FCtrl.Obj.Estoque.Altura));
      LcStock.AddPair('costManufactures', TJSONNumber.Create(FCtrl.Obj.Estoque.CustoFabrica));
      LcStock.AddPair('actualCost', TJSONNumber.Create(FCtrl.Obj.Estoque.CustoReal));
      LcStock.AddPair('costPrice', TJSONNumber.Create(FCtrl.Obj.Estoque.PrecoCusto));
      LcStock.AddPair('negative', FCtrl.Obj.Estoque.EstoqueNegativa);
      LcStock.AddPair('outline', FCtrl.Obj.Estoque.ForaDeLinha);
      // quantity/minimum NÃO viajam aqui — domínio do /stock-balance.
      LcJson.AddPair('stock', LcStock);

      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.


