unit objInvoiceMerchandise;

interface
  uses System.SysUtils,System.Generics.Collections,objInvoice, tblinvoiceMerchandise,
      tblOrderItemIcms, tblOrderItemIpi, tblOrderItemPis, tblOrderItemCofins,
      tblInvoice,tblOrderItemII,tblOrderItemISSqn, ObjBase, tblInvoiceShipping,
      tblInvoiceObs;

Type

  TObjInvoiceMerchandise = class(TObjInvoice)
    type
      TitemsIcmsArray = array of TOrderItemIcms;
      TitemsIpiArray = array of TOrderItemIpi;
      TitemsPisArray = array of TOrderItemPis;
      TitemsCofinsArray = array of TOrderItemCofins;
      TitemsIIArray = array of TOrderItemII;
      TitemsIssQNArray = array of TOrderItemIssQN;
      TinvoiceObsArray = array of TInvoiceObs;
  private
    Fitems_ipi: TitemsIPIArray;
    Finvoice_shipping: TInvoiceShipping;
    Fitems_ii: TitemsIIArray;
    Fitems_icms: TitemsIcmsArray;
    Fitems_issqn: TitemsIssQNArray;
    Fitems_pis: TitemsPisArray;
    Fitems_cofins: TitemsCofinsArray;
    Finvoice_merchandise: TInvoiceMerchandise;
    procedure setFinvoice_merchandise(const Value: TInvoiceMerchandise);
    procedure setFinvoice_shipping(const Value: TInvoiceShipping);
    procedure setFitem_ii(const Value: TitemsIIArray);
    procedure setFitems_cofins(const Value: TitemsCofinsArray);
    procedure setFitems_icms(const Value: TitemsIcmsArray);
    procedure setFitems_ipi(const Value: TitemsIPIArray);
    procedure setFitems_issqn(const Value: TitemsIssQNArray);
    procedure setFitems_pis(const Value: TitemsPisArray);


  public
    constructor Create;Override;
    destructor Destroy;Override;
    procedure setArrayItemsIcms(i:Integer);
    procedure setArrayItemsIpi(i:Integer);
    procedure setArrayItemsPis(i:Integer);
    procedure setArrayItemsCofins(i:Integer);
    procedure setArrayItemsII(i:Integer);
    procedure setArrayItemsIssqn(i:Integer);


    property NotaMercadoria : TInvoiceMerchandise read Finvoice_merchandise write setFinvoice_merchandise;
    property Entrega        : TInvoiceShipping read Finvoice_shipping write setFinvoice_shipping;
    property ItemsICMS      : TitemsIcmsArray    read Fitems_icms write setFitems_icms;
    property ItemsIPI       : TitemsIPIArray     read Fitems_ipi write setFitems_ipi;
    property ItemsPIS       : TitemsPisArray     read Fitems_pis write setFitems_pis;
    property ItemsCofins    : TitemsCofinsArray  read Fitems_cofins write setFitems_cofins;
    property ItemsII        : TitemsIIArray      read Fitems_ii write setFitem_ii;
    property ItemsIss       : TitemsIssQNArray     read Fitems_issqn write setFitems_issqn;

  End;
implementation

{ TObjInvoiceMerchandise }

constructor TObjInvoiceMerchandise.Create;
begin
  inherited;
  Finvoice_merchandise := TInvoiceMerchandise.Create;
  Finvoice_shipping    := TInvoiceShipping.Create;
end;

destructor TObjInvoiceMerchandise.Destroy;
begin
  Finvoice_merchandise.DisposeOf;
  Finvoice_shipping.DisposeOf;
end;

procedure TObjInvoiceMerchandise.setArrayItemsCofins(i: Integer);
begin
  SetLength(Fitems_cofins,i);
end;

procedure TObjInvoiceMerchandise.setArrayItemsIcms(i: Integer);
begin
  SetLength(Fitems_icms,i);
end;

procedure TObjInvoiceMerchandise.setArrayItemsII(i: Integer);
begin
  SetLength(Fitems_ii,i);
end;

procedure TObjInvoiceMerchandise.setArrayItemsIpi(i: Integer);
begin
  SetLength(Fitems_ipi,i);
end;

procedure TObjInvoiceMerchandise.setArrayItemsIssqn(i: Integer);
begin
  SetLength(Fitems_issqn,i);
end;

procedure TObjInvoiceMerchandise.setArrayItemsPis(i: Integer);
begin
  SetLength(Fitems_pis,i);
end;

procedure TObjInvoiceMerchandise.setFinvoice_merchandise(
  const Value: TInvoiceMerchandise);
begin
  Finvoice_merchandise := Value;
end;

procedure TObjInvoiceMerchandise.setFinvoice_shipping(
  const Value: TInvoiceShipping);
begin
  Finvoice_shipping := Value;
end;

procedure TObjInvoiceMerchandise.setFitems_cofins(
  const Value: TitemsCofinsArray);
begin
  Fitems_cofins := Value;
end;

procedure TObjInvoiceMerchandise.setFitems_icms(const Value: TitemsIcmsArray);
begin
  Fitems_icms := Value;
end;

procedure TObjInvoiceMerchandise.setFitems_ipi(const Value: TitemsIPIArray);
begin
  Fitems_ipi := Value;
end;

procedure TObjInvoiceMerchandise.setFitems_issqn(const Value: TitemsIssQNArray);
begin
  Fitems_issqn := Value;
end;

procedure TObjInvoiceMerchandise.setFitems_pis(const Value: TitemsPisArray);
begin
  Fitems_pis := Value;
end;

procedure TObjInvoiceMerchandise.setFitem_ii(const Value: TitemsIIArray);
begin
  Fitems_ii := Value;
end;

end.
