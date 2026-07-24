unit objEntityFiscal;

interface

uses tblPerson, tblCompany,tblEntityExternalCode,objEntity;

Type

  TObjEntityFiscal = Class
  private
    FobjEntity: TObjEntity;
    Fcompany: TCompany;
    Fperson: TPerson;
    Fentity_external_code: TEntityExternalCode;
    procedure setFperson(const Value: TPerson);
    procedure setFcompany(const Value: TCompany);

    procedure setFobjEntity(const Value: TObjEntity);
    procedure setFentity_external_code(const Value: TEntityExternalCode);

  public
    constructor Create;
    destructor Destroy;
    procedure clear;
    property Entidade : TObjEntity read FobjEntity write setFobjEntity;
    property Fisica : TPerson read Fperson write setFperson;
    property Juridica : TCompany read Fcompany write setFcompany;
    property EntityExternalCode : TEntityExternalCode read Fentity_external_code write setFentity_external_code;
  End;

implementation

{ TObjEntityFiscal }

uses GenericDao;


procedure TObjEntityFiscal.clear;
begin
  TGenericDAO._Clear(Fcompany);
  TGenericDAO._Clear(Fperson);
  Entidade.clear;
end;

constructor TObjEntityFiscal.Create;
begin
  FobjEntity := TObjEntity.Create;
  Fcompany := TCompany.Create;
  Fperson   := TPerson.Create;
  Fentity_external_code := TEntityExternalCode.Create;
end;

destructor TObjEntityFiscal.Destroy;
begin
  clear;
  FobjEntity.Destroy;
  Fcompany.DisposeOf;
  Fperson.DisposeOf;
  Fentity_external_code.DisposeOf;
end;


procedure TObjEntityFiscal.setFperson(const Value: TPerson);
begin
  Fperson := Value;
end;

procedure TObjEntityFiscal.setFcompany(const Value: TCompany);
begin
  Fcompany := Value;
end;


procedure TObjEntityFiscal.setFentity_external_code(
  const Value: TEntityExternalCode);
begin
  Fentity_external_code := Value;
end;


procedure TObjEntityFiscal.setFobjEntity(const Value: TObjEntity);
begin
  FobjEntity := Value;
end;

end.
