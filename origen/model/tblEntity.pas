unit tblEntity;

interface

Uses GenericEntity,CAtribEntity, System.SysUtils;

Type
  //nome da classe de entidade
  [TableName('tb_entity')]
  TEntity = Class(TGenericEntity)
  private
    Fnote: String;
    Ftb_line_business_id: Integer;
    Faniversary: TDateTime;
    Fid: Integer;
    Fnick_trade: String;
    Fupdated_at: TDAteTime;
    Fname_company: String;
    Fcreated_at: TDAteTime;
    procedure setFaniversary(const Value: TDateTime);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFid(const Value: Integer);
    procedure setFname_company(const Value: String);
    procedure setFnick_trade(const Value: String);
    procedure setFnote(const Value: String);
    procedure setFtb_line_business_id(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);

  public
    [KeyField('id')]
    [FieldName('id')]
    property Codigo: Integer read Fid write setFid;

    [FieldName('name_company')]
    property NomeRazao: String read Fname_company write setFname_company;

    [FieldName('nick_trade')]
    property ApelidoFantasia: String read Fnick_trade write setFnick_trade;

    [FieldName('aniversary')]
    property AniversarioFundacao: TDateTime read Faniversary write setFaniversary;

    [FieldName('tb_line_business_id')]
    property RamoAtividade: Integer read Ftb_line_business_id write setFtb_line_business_id;

    [FieldName('note')]
    property Observacao: String read Fnote write setFnote;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;

implementation


{ TEntity }

procedure TEntity.setFaniversary(const Value: TDateTime);
begin
  Faniversary := Value;
end;

procedure TEntity.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TEntity.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TEntity.setFname_company(const Value: String);
begin
  Fname_company := Value;
end;

procedure TEntity.setFnick_trade(const Value: String);
begin
  Fnick_trade := Value;
end;

procedure TEntity.setFnote(const Value: String);
begin
  Fnote := Value;
end;

procedure TEntity.setFtb_line_business_id(const Value: Integer);
begin
  Ftb_line_business_id := Value;
end;

procedure TEntity.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
