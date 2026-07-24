unit objSalesMan;

interface

uses
  System.SysUtils, tblSalesMan, objCollaborator  ;

Type
  TObjSalesMan = Class
  private
    FSalesman: TSalesMan;
    FobjCollaborator: TobjCollaborator;
    procedure setFobjCollaborator(const Value: TobjCollaborator);
    procedure setFSalesman(const Value: TSalesMan);

  public
    constructor Create;
    destructor Destroy;reintroduce;
    procedure clear;
    property Vendedor : TSalesMan read FSalesman write setFSalesman;
    property objColaborador : TobjCollaborator read FobjCollaborator write setFobjCollaborator;
  End;

implementation

uses GenericDao;

{ TObjSalesMan }

procedure TObjSalesMan.clear;
begin
  TGenericDAO._Clear(FSalesman);
  FobjCollaborator.clear
end;

constructor TObjSalesMan.Create;
begin
  inherited;
  FSalesman := tSalesMan.create;
  FobjCollaborator := TobjCollaborator.create;
end;


destructor TObjSalesMan.Destroy;
begin
  FSalesman.DisposeOf;
  FobjCollaborator.Destroy;

end;
procedure TObjSalesMan.setFobjCollaborator(const Value: TobjCollaborator);
begin
  FobjCollaborator := Value;
end;

procedure TObjSalesMan.setFSalesman(const Value: TSalesMan);
begin
  FSalesman := Value;
end;

end.
