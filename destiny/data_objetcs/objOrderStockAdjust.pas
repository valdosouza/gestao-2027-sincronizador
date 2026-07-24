unit objOrderStockAdjust;

interface

uses System.SysUtils, objEntityFiscal, tblprovider, ObjProvider, ObjSalesMan, tblOrder,
  tblOrderPi, tblMedParts, tblMedPartsJr, tblMedPartsRt, tblMedInsertDate,
  System.Generics.Collections, tblOrderItem, tblOrderStockAdjust,tblOrderTotalizer,
  tblOrderBilling,objBase;

Type
   TListItems = TObjectList<Torderitem>;
  TObjOrderStockAdjust = Class(TObjBase)
    type
      TitemsArray = array of TOrderItem;
  private
    Ftotalizer: TOrderTotalizer;
    Fitems: TitemsArray;
    Forder: TOrder;
    Forder_stock_adjust: TOrderStockAdjust;

    procedure setFitems(const Value: TitemsArray);
    procedure setForder(const Value: TOrder);
    procedure setFtotalizer(const Value: TOrderTotalizer);
    procedure setForder_stock_adjust(const Value: TOrderStockAdjust);


  public
    constructor Create;override;
    destructor Destroy;override;
    procedure clear;
    procedure setArrayItems(i:Integer);

    property Order            : TOrder read Forder write setForder;
    property OrderStockAdjust : TOrderStockAdjust read Forder_stock_adjust write setForder_stock_adjust;
    property Items            : TitemsArray  read Fitems write setFitems;
    property Totalizer        : TOrderTotalizer read Ftotalizer write setFtotalizer;
  End;

implementation

uses GenericDao;

{ TObjOrderStockAdjust }

procedure TObjOrderStockAdjust.clear;
begin
  TGenericDAO._Clear(FTotalizer);
  TGenericDAO._Clear(FOrder_stock_Adjust);
  TGenericDAO._Clear(FOrder);
end;

constructor TObjOrderStockAdjust.Create;
begin
  inherited;
  Ftotalizer        := TOrderTotalizer.Create;
  FOrder_stock_Adjust := TOrderStockAdjust.Create;
  Forder            := TOrder.Create;;
end;

destructor TObjOrderStockAdjust.Destroy;
begin
  Ftotalizer.DisposeOf;
  FOrder_stock_Adjust.DisposeOf;
  Forder.DisposeOf;
  inherited;
end;


procedure TObjOrderStockAdjust.setArrayItems(i: Integer);
begin
  SetLength(Fitems,I);
end;

procedure TObjOrderStockAdjust.setFitems(const Value: TitemsArray);
begin
  Fitems := Value;
end;

procedure TObjOrderStockAdjust.setForder(const Value: TOrder);
begin
  Forder := Value;
end;


procedure TObjOrderStockAdjust.setForder_stock_adjust(
  const Value: TOrderStockAdjust);
begin
  Forder_stock_adjust := Value;
end;

procedure TObjOrderStockAdjust.setFtotalizer(const Value: TOrderTotalizer);
begin
  Ftotalizer := Value;
end;

end.
