unit objFinancial;

interface

uses System.SysUtils, ObjBase,  tblFinancial,
  tblFinancialPayment;

Type

  TObjFinancial = Class(TObjBase)
  private
    Fdesc_payment_type: String;
    Ffinancial_payment: TFinancialPayment;
    Ffinancial: TFinancial;
    procedure setFdesc_payment_type(const Value: String);
    procedure setFfinancial(const Value: TFinancial);
    procedure setFfinancial_payment(const Value: TFinancialPayment);

  public
      constructor Create; override;
      destructor Destroy; override;
      property Financeiro : TFinancial read Ffinancial write setFfinancial;
      property Pagamentos : TFinancialPayment read Ffinancial_payment write setFfinancial_payment;
      property DescFormaPagamento: String read Fdesc_payment_type write setFdesc_payment_type;
  End;

implementation

{ TObjFinancial }

constructor TObjFinancial.Create;
begin
  inherited;
  Inherited;
  Ffinancial := TFinancial.Create;
  Ffinancial_payment := TFinancialPayment.Create;
end;

destructor TObjFinancial.Destroy;
begin
  Ffinancial.DisposeOf;
  Ffinancial_payment.DisposeOf;
  inherited;
end;

procedure TObjFinancial.setFdesc_payment_type(const Value: String);
begin
  Fdesc_payment_type := Value;
end;

procedure TObjFinancial.setFfinancial(const Value: TFinancial);
begin
  Ffinancial := Value;
end;

procedure TObjFinancial.setFfinancial_payment(const Value: TFinancialPayment);
begin
  Ffinancial_payment := Value;
end;

end.
