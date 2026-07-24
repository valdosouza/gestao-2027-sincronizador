unit objCustomer;

interface

uses System.SysUtils, objEntityFiscal, tblCustomer,System.Classes;

Type

  TObjCustomer = Class
  private
    Fcustomer: TCustomer;
    Ffiscal: TObjEntityFiscal;
    procedure setFcustomer(const Value: TCustomer);
    procedure setFfiscal(const Value: TObjEntityFiscal);

  public
      constructor Create;
      destructor Destroy;
      procedure clear;
      property Cliente : TCustomer read Fcustomer write setFcustomer;
      property Fiscal : TObjEntityFiscal read Ffiscal write setFfiscal;
  End;

implementation


{ TObjCustomer }

uses GenericDao;

procedure TObjCustomer.clear;
begin
  TGenericDAO._Clear(Fcustomer);
  Ffiscal.clear
end;

constructor TObjCustomer.Create;
begin
  inherited;
  Fcustomer:= TCustomer.Create;
  Ffiscal := TObjEntityFiscal.Create;
end;

destructor TObjCustomer.Destroy;
begin
  Fcustomer.DisposeOf;
  Ffiscal.Destroy;
end;

procedure TObjCustomer.setFcustomer(const Value: TCustomer);
begin
  Fcustomer := Value;
end;

procedure TObjCustomer.setFfiscal(const Value: TObjEntityFiscal);
begin
  Ffiscal := Value;
end;

end.

