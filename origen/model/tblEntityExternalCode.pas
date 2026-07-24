unit tblEntityExternalCode;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_no_doc_number')]
  TEntityExternalCode = Class(TGenericEntity)
  private
    Ftb_entity_id: Integer;
    Fupdated_at: TDatetime;
    Ftb_institution_id: Integer;
    Freference: Integer;
    Fcreated_at: TDatetime;
    Fkind: String;
    procedure setFcreated_at(const Value: TDatetime);
    procedure setFtb_entity_id(const Value: Integer);
    procedure setFreference(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFupdated_at(const Value: TDatetime);
    procedure setFkind(const Value: String);


  public

    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [KeyField('reference')]
    [FieldName('reference')]
    property Referencia: Integer read Freference write setFreference;

    [KeyField('kind')]
    [FieldName('kindt')]
    property Tipo: String read Fkind write setFkind;

    [FieldName('tb_entity_id')]
    property Codigo: Integer read Ftb_entity_id write setFtb_entity_id;

    [FieldName('created_at')]
    property RegistroCriado: TDatetime read Fcreated_at write setFcreated_at;

	  [FieldName('updated_at')]
    property RegistroAlterado: TDatetime read Fupdated_at write setFupdated_at;

	End;

implementation

{ TEntityExternalCode }

procedure TEntityExternalCode.setFcreated_at(const Value: TDatetime);
begin
  Fcreated_at := Value;
end;

procedure TEntityExternalCode.setFtb_entity_id(const Value: Integer);
begin
  Ftb_entity_id := Value;
end;

procedure TEntityExternalCode.setFkind(const Value: String);
begin
  Fkind := Value;
end;

procedure TEntityExternalCode.setFreference(const Value: Integer);
begin
  Freference := Value;
end;

procedure TEntityExternalCode.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TEntityExternalCode.setFupdated_at(const Value: TDatetime);
begin
  Fupdated_at := Value;
end;

end.
