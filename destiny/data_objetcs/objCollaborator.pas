unit objCollaborator;

interface

uses System.SysUtils, objEntityFiscal, tblCollaborator,ObjBase;

Type
  TobjCollaborator = Class
  private
    FCollaborator: TCollaborator;
    Ffiscal: TObjEntityFiscal;
    procedure setFCollaborator(const Value: TCollaborator);
    procedure setFfiscal(const Value: TObjEntityFiscal);
  public
    constructor Create;
    destructor Destroy;
    procedure clear;
    property Colaborador : TCollaborator read Fcollaborator write setFcollaborator;
    property Fiscal : TObjEntityFiscal read Ffiscal write setFfiscal;

  End;

implementation

uses GenericDao;
{ TobjCollaborator }

procedure TobjCollaborator.clear;
begin
  TGenericDAO._Clear(FCollaborator);
  FFiscal.clear
end;

constructor TobjCollaborator.Create;
begin
  inherited;
  FCollaborator := TCollaborator.create;
  FFiscal := TObjEntityFiscal.create;
end;

destructor TobjCollaborator.Destroy;
begin
  FCollaborator.DisposeOf;
  FFiscal.Destroy;
  inherited;
end;


procedure TobjCollaborator.setFCollaborator(const Value: TCollaborator);
begin
  FCollaborator := Value;
end;

procedure TobjCollaborator.setFfiscal(const Value: TObjEntityFiscal);
begin
  Ffiscal := Value;
end;

end.
