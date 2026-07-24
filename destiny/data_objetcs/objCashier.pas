unit objCashier;

interface

  {
  "dt_record": "string",
  "tb_institution_id": 0,
  "tb_user_id": 0,
  "items": [

      "description": "string",
      "tag_value": 0,
      "kind": "string"
  ]
  }

uses tblCashier, tblCashierItems,System.Generics.Collections,
  ObjBase;

Type
  TObjCashier = Class(TObjBase)
  private
    type
      TItemsArray = array of TCashierItems;
  private
    Fhr_end: TDAteTime;
    Fid: Integer;
    Fitems: TItemsArray;
    Fhr_begin: TDAteTime;
    Fdt_record: TDateTime;
    Ftb_user_id: Integer;
    procedure setFdt_record(const Value: TDateTime);
    procedure setFhr_begin(const Value: TDAteTime);
    procedure setFhr_end(const Value: TDAteTime);
    procedure setFid(const Value: Integer);
    procedure setFitems(const Value: TItemsArray);
    procedure setFtb_user_id(const Value: Integer);
  public
      constructor Create;
      destructor Destroy;
      procedure setArrayItems(i:Integer);
      property Codigo : Integer  read Fid write setFid;
      property Data : TDateTime  read Fdt_record write setFdt_record;
      property Usuario : Integer  read Ftb_user_id write setFtb_user_id;
      property Fechamento: TDAteTime read Fhr_end write setFhr_end;
      property Abertura: TDAteTime read Fhr_begin write setFhr_begin;
      property ListaItems :TItemsArray read Fitems write setFitems;


  End;
implementation

{ TObjCashier }

constructor TObjCashier.Create;
begin
  inherited;
  Fitems := TItemsArray.create();
end;

destructor TObjCashier.Destroy;
begin

  inherited;
end;

procedure TObjCashier.setArrayItems(i: Integer);
begin
  SetLength(Fitems,I);
end;

procedure TObjCashier.setFdt_record(const Value: TDateTime);
begin
  Fdt_record := Value;
end;

procedure TObjCashier.setFhr_begin(const Value: TDAteTime);
begin
  Fhr_begin := Value;
end;

procedure TObjCashier.setFhr_end(const Value: TDAteTime);
begin
  Fhr_end := Value;
end;

procedure TObjCashier.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TObjCashier.setFitems(const Value: TItemsArray);
begin
  Fitems := Value;
end;

procedure TObjCashier.setFtb_user_id(const Value: Integer);
begin
  Ftb_user_id := Value;
end;

end.
