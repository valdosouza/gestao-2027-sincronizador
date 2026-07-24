unit objOrderSale;

interface

uses System.SysUtils, objEntityFiscal, tblCustomer,  ObjSalesMan, tblOrder,
  tblOrderPi, tblMedParts, tblMedPartsJr, tblMedPartsRt, tblMedInsertDate,
  System.Generics.Collections, tblOrderItem, tblOrderSale,tblOrderTotalizer,
  tblOrderBilling, objBase;

Type
  TListItems = TObjectList<TOrderItem>;

  TObjOrderSale = Class(TObjBase)
    type
      TitemsArray = array of TOrderItem;
  private
    Fsale: TOrderSale;
    Ftotalizer: TOrderTotalizer;
    Fbilling: TOrderBilling;
    Fitems: TitemsArray;
    Forder: TOrder;
    procedure setFbilling(const Value: TOrderBilling);
    procedure setFitems(const Value: TitemsArray);
    procedure setForder(const Value: TOrder);
    procedure setFsale(const Value: TOrderSale);
    procedure setFtotalizer(const Value: TOrderTotalizer);
  public
    constructor Create;override;
    destructor Destroy;override;
    procedure clear;
    procedure setArrayItems(i:Integer);

    property Order        : TOrder read Forder write setForder;
    property OrderSale    : TOrderSale read Fsale write setFsale;
    property Items        : TitemsArray  read Fitems write setFitems;
    property Totalizer    : TOrderTotalizer read Ftotalizer write setFtotalizer;
    property Billing      : TOrderBilling read Fbilling write setFbilling;
  End;

implementation

uses GenericDao;
{ TObjOrderSale }

procedure TObjOrderSale.clear;
begin
  TGenericDAO._Clear(Ftotalizer);
  TGenericDAO._Clear(Fbilling);
  TGenericDAO._Clear(Fsale);
  TGenericDAO._Clear(Forder);
end;

constructor TObjOrderSale.Create;
begin
  inherited;
  Ftotalizer  := TOrderTotalizer.Create;
  Fbilling    := TOrderBilling.Create;
  Fsale  := TOrderSale.Create;
  Forder      := TOrder.Create;;
end;

destructor TObjOrderSale.Destroy;
begin
  Ftotalizer.DisposeOf;
  Fbilling.DisposeOf;
  Fsale.DisposeOf;
  Forder.DisposeOf;
end;


procedure TObjOrderSale.setArrayItems(i: Integer);
begin
  SetLength(Fitems,I);
end;


procedure TObjOrderSale.setFbilling(const Value: TOrderBilling);
begin
  Fbilling := Value;
end;

procedure TObjOrderSale.setFitems(const Value: TitemsArray);
begin
  Fitems := Value;
end;

procedure TObjOrderSale.setForder(const Value: TOrder);
begin
  Forder := Value;
end;

procedure TObjOrderSale.setFsale(const Value: TOrderSale);
begin
  Fsale := Value;
end;

procedure TObjOrderSale.setFtotalizer(const Value: TOrderTotalizer);
begin
  Ftotalizer := Value;
end;

end.


