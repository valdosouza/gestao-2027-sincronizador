unit ObjMerchandise;

interface

uses System.SysUtils, System.Generics.Collections,
     tblMerchandise,tblProduct, tblStock,objbase;

Type
  TObjMerchandise = Class(TObjBase)
  private
    FProduct: TProduct;
    FStock: TStock;
    FMerchandise: TMerchandise;
    procedure setFMerchandise(const Value: TMerchandise);
    procedure setFProduct(const Value: TProduct);
    procedure setFStock(const Value: TStock);

  public
    constructor Create;override;
    destructor Destroy;override;
    Property Produto : TProduct read FProduct write setFProduct;
    property Mercadoria : TMerchandise read FMerchandise write setFMerchandise;
    property Estoque : TStock read FStock write setFStock;

  End;

implementation
{ TObjMerchandise }

constructor TObjMerchandise.Create;
begin
  inherited;
  FProduct := TProduct.Create;
  FMerchandise := TMerchandise.Create;
  FStock := TStock.Create;
end;

destructor TObjMerchandise.Destroy;
begin
  FProduct.DisposeOf;
  FMerchandise.DisposeOf;
  FStock.DisposeOf;
end;



procedure TObjMerchandise.setFMerchandise(const Value: TMerchandise);
begin
  FMerchandise := Value;
end;

procedure TObjMerchandise.setFProduct(const Value: TProduct);
begin
  FProduct := Value;
end;

procedure TObjMerchandise.setFStock(const Value: TStock);
begin
  FStock := Value;
end;

end.
