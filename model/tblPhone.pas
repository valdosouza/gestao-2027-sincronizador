unit tblPhone;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_PHONE')]
  TPhone = Class(TGenericEntity)
  private
    Fid: Integer;
    Fnumber: String;
    Fcontact: String;
    Faddress_kind: String;
    Fkind: String;
    procedure setFaddress_kind(const Value: String);
    procedure setFcontact(const Value: String);
    procedure setFid(const Value: Integer);
    procedure setFkind(const Value: String);
    procedure setFnumber(const Value: String);

  public

    [KeyField('ID')]
    [FieldName('ID')]
    property Codigo: Integer read Fid write setFid;

    [KeyField('KIND')]
    [FieldName('KIND')]
    property Tipo: String read Fkind write setFkind;

    [FieldName('CONTACT')]
    property Contato: String read Fcontact write setFcontact;

    [KeyField('NUMBER')]
    [FieldName('NUMBER')]
    property Numero: String read Fnumber write setFnumber;

    [FieldName('ADDRESS_KIND')]
    property TipoEndereco: String read Faddress_kind write setFaddress_kind;

  End;

implementation

{ TPhone }

procedure TPhone.setFaddress_kind(const Value: String);
begin
  Faddress_kind := Value;
end;

procedure TPhone.setFcontact(const Value: String);
begin
  Fcontact := Value;
end;

procedure TPhone.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TPhone.setFkind(const Value: String);
begin
  Fkind := Value;
end;

procedure TPhone.setFnumber(const Value: String);
begin
  Fnumber := Value;
end;

end.
