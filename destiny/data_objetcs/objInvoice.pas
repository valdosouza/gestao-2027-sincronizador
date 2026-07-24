unit objInvoice;

interface

uses System.SysUtils,System.Generics.Collections,  ObjBase,tblFinancialPlans,
      tblInvoice,tblInvoiceObs, objEntityFiscal;

Type
  TlistaObs   = TObjectList<TInvoiceObs>;

  TObjInvoice = Class(TObjBase)
     type
      TinvoiceObsArray = array of TInvoiceObs;
  private
    Finvoice: Tinvoice;
    Finvoice_obs: TInvoiceObsArray;
    procedure setFinvoice(const Value: Tinvoice);
    procedure setFinvoiceobs(const Value: TInvoiceObsArray);

  public
    constructor Create;override;
    destructor Destroy;override;
    procedure setArrayInvoiceObs(i:Integer);
    property Nota : Tinvoice read Finvoice write setFinvoice;
    property Observacao     : TInvoiceObsArray    read Finvoice_obs write setFinvoiceobs;
  End;
implementation

{ TObjInvoice }

constructor TObjInvoice.Create;
begin
  inherited;
  Finvoice := Tinvoice.Create;
end;

destructor TObjInvoice.Destroy;
begin
  FInvoice.DisposeOf;
  inherited;
end;

procedure TObjInvoice.setArrayInvoiceObs(i: Integer);
begin
  SetLength(Finvoice_obs,I);
end;

procedure TObjInvoice.setFinvoice(const Value: Tinvoice);
begin
  Finvoice := Value;
end;


procedure TObjInvoice.setFinvoiceobs(const Value: TInvoiceObsArray);
begin
  Finvoice_obs := Value;
end;

end.
