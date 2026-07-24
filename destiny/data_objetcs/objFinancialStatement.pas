unit objFinancialStatement;

interface

uses System.SysUtils, ObjBase,  tblFinancialStatement;

Type

  TObjFinancialStatement = Class(TObjBase)
  private
    Fdesc_payment_type: String;
    Ffinancial_statement: TFinancialStatement;
    procedure setFdesc_payment_type(const Value: String);
    procedure setFfinancial_statement(const Value: TFinancialStatement);

  public
    constructor Create; override;
    destructor Destroy; override;
    property Movimento : TFinancialStatement read Ffinancial_statement write setFfinancial_statement;
    property DescFormaPagamento: String read Fdesc_payment_type write setFdesc_payment_type;
  End;

implementation


{ TObjFinancialStatement }

constructor TObjFinancialStatement.Create;
begin
  inherited;
  Ffinancial_statement := TFinancialStatement.Create;
end;

destructor TObjFinancialStatement.Destroy;
begin
  Ffinancial_statement.DisposeOf;
end;


procedure TObjFinancialStatement.setFdesc_payment_type(const Value: String);
begin
  Fdesc_payment_type := Value;
end;

procedure TObjFinancialStatement.setFfinancial_statement(
  const Value: TFinancialStatement);
begin
  Ffinancial_statement := Value;
end;

end.
