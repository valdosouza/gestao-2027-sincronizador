unit tblCashierItems;

interface
Uses GenericEntity,CAtribEntity, System.Classes, System.SysUtils;
Type
  //nome da classe de entidade
  [TableName('tb_cashier_items')]
  TCashierItems = Class(TGenericEntity)

  private
    Ftag_value: Real;
    Fid: Integer;
    Ftb_payment_types_id: Integer;
    Fupdated_at: TDAteTime;
    Ftb_cashier_id: Integer;
    Ftb_institution_id: integer;
    Fkind: String;
    Fterminal: Integer;
    Fcreated_at: TDAteTime;
    Fname_payment: String;
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFid(const Value: Integer);
    procedure setFkind(const Value: String);
    procedure setFtag_value(const Value: Real);
    procedure setFtb_cashier_id(const Value: Integer);
    procedure setFtb_institution_id(const Value: integer);
    procedure setFtb_payment_types_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);
    procedure setFname_payment(const Value: String);

  public

    [FieldName('id')]
    [KeyField('id')]
    property Codigo: Integer read Fid write setFid;

    [FieldName('tb_institution_id')]
    [KeyField('tb_institution_id')]
    property Estabelecimento: integer read Ftb_institution_id write setFtb_institution_id;

    [FieldName('terminal')]
    [KeyField('terminal')]
    property Terminal: Integer read Fterminal write setFterminal;

    [KeyField('tb_cashier_id')]
    [FieldName('tb_cashier_id')]
    property Caixa: Integer read Ftb_cashier_id write setFtb_cashier_id;

    [KeyField('tb_payment_types_id')]
    [FieldName('tb_payment_types_id')]
    property TipoPagamento: Integer read Ftb_payment_types_id write setFtb_payment_types_id;

    property name_payment: String read Fname_payment write setFname_payment;

    [FieldName('kind')]
    property Tipo: String read Fkind write setFkind;

    [FieldName('tag_value')]
    property Valor: Real read Ftag_value write setFtag_value;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

  End;
implementation

{ TCashierItems }

procedure TCashierItems.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TCashierItems.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TCashierItems.setFkind(const Value: String);
begin
  Fkind := Value;
end;

procedure TCashierItems.setFname_payment(const Value: String);
begin
  Fname_payment := Value;
end;

procedure TCashierItems.setFtag_value(const Value: Real);
begin
  Ftag_value := Value;
end;

procedure TCashierItems.setFtb_cashier_id(const Value: Integer);
begin
  Ftb_cashier_id := Value;
end;

procedure TCashierItems.setFtb_institution_id(const Value: integer);
begin
  Ftb_institution_id := Value;
end;

procedure TCashierItems.setFtb_payment_types_id(const Value: Integer);
begin
  Ftb_payment_types_id := Value;
end;

procedure TCashierItems.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TCashierItems.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
