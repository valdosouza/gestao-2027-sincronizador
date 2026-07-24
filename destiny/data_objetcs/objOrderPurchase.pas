unit objOrderPurchase;


interface

uses System.SysUtils, System.Generics.Collections, tblOrderItem, tblOrderSale,
  tblOrder, tblOrderPurchase,tblOrderTotalizer,tblOrderBilling, objBase;

Type
  TListItems = TObjectList<TOrderItem>;
  TObjOrderPurchase = Class(TObjBase)
    type
      TitemsArray = array of TOrderItem;
  private
    Forder_purchase: TOrderPurchase;
    Ftotalizer: TOrderTotalizer;
    Fbilling: TOrderBilling;
    Fitems: TitemsArray;
    Forder: TOrder;
    procedure setFbilling(const Value: TOrderBilling);
    procedure setFitems(const Value: TitemsArray);
    procedure setForder(const Value: TOrder);
    procedure setForder_sale(const Value: TOrderPurchase);
    procedure setFtotalizer(const Value: TOrderTotalizer);


  public
    constructor Create;override;
    destructor Destroy;override;
    procedure clear;
    procedure setArrayItems(i:Integer);

    property Order          : TOrder read Forder write setForder;
    property OrderPurchase  : TOrderPurchase read Forder_purchase write setForder_sale;
    property Items          : TitemsArray  read Fitems write setFitems;
    property Totalizer      : TOrderTotalizer read Ftotalizer write setFtotalizer;
    property Billing        : TOrderBilling read Fbilling write setFbilling;
  End;

implementation

uses GenericDao;
{ TObjOrderPurchase }

procedure TObjOrderPurchase.clear;
begin
  TGenericDAO._Clear(Ftotalizer);
  TGenericDAO._Clear(Fbilling);
  TGenericDAO._Clear(Forder_purchase);
  TGenericDAO._Clear(Forder);
end;

constructor TObjOrderPurchase.Create;
begin
  inherited;
  Ftotalizer  := TOrderTotalizer.Create;
  Fbilling    := TOrderBilling.Create;
  Forder_purchase  := TOrderPurchase.Create;
  Forder      := TOrder.Create;;
end;

destructor TObjOrderPurchase.Destroy;
begin
  Ftotalizer.DisposeOf;
  Fbilling.DisposeOf;
  Forder_purchase.DisposeOf;
  Forder.DisposeOf;
end;


procedure TObjOrderPurchase.setArrayItems(i: Integer);
begin
    SetLength(Fitems,I);
end;

procedure TObjOrderPurchase.setFbilling(const Value: TOrderBilling);
begin
  Fbilling := Value;
end;

procedure TObjOrderPurchase.setFitems(const Value: TitemsArray);
begin
  Fitems := Value;
end;

procedure TObjOrderPurchase.setForder(const Value: TOrder);
begin
  Forder := Value;
end;

procedure TObjOrderPurchase.setForder_sale(const Value: TOrderPurchase);
begin
  Forder_purchase := Value;
end;

procedure TObjOrderPurchase.setFtotalizer(const Value: TOrderTotalizer);
begin
  Ftotalizer := Value;
end;

end.


