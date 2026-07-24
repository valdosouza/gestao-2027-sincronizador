unit objProvider;

interface

uses System.SysUtils, objEntityFiscal, tblProvider, ObjSalesMan,
  System.Classes,objBase;

Type

  TObjProvider = Class
  private
    Fprovider: TProvider;
    Ffiscal: TObjEntityFiscal;
    procedure setFfiscal(const Value: TObjEntityFiscal);
    procedure setFprovider(const Value: TProvider);

  public
      constructor Create;
      destructor Destroy;
      procedure clear;
      property Fornecedor : TProvider read Fprovider write setFprovider;
      property Fiscal : TObjEntityFiscal read Ffiscal write setFfiscal;
  End;

implementation


{ TObjProvider }

uses GenericDao;

procedure TObjProvider.clear;
begin
  TGenericDAO._Clear(Fprovider);
  fiscal.clear;
end;

constructor TObjProvider.Create;
begin
  inherited;
  Fprovider := TProvider.Create;
  Ffiscal     := TObjEntityFiscal.Create;
end;

destructor TObjProvider.Destroy;
begin
  Fprovider.DisposeOf;
  FFiscal.Destroy;
end;



procedure TObjProvider.setFfiscal(const Value: TObjEntityFiscal);
begin
  Ffiscal := Value;
end;

procedure TObjProvider.setFprovider(const Value: TProvider);
begin
  Fprovider := Value;
end;

end.
