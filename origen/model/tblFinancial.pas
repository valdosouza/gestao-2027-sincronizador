unit tblFinancial;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_financial')]
  Tfinancial = Class(TGenericEntity)
  private
    Foperation: String;
    Ftag_value: Real;
    Ftb_order_id: Integer;
    Ftb_payment_types_id: Integer;
    Fupdated_at: TDAteTime;
    Fdt_expiration: TDateTime;
    Fnumber: String;
    Fsituation: String;
    Ftb_institution_id: Integer;
    Fstage: String;
    Fkind: String;
    FTerminal: Integer;
    Ftb_financial_plans_id: Integer;
    Fcreated_at: TDAteTime;
    Fparcel: Integer;
    Fid: Integer;
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFdt_expiration(const Value: TDateTime);
    procedure setFkind(const Value: String);
    procedure setFnumber(const Value: String);
    procedure setFoperation(const Value: String);
    procedure setFparcel(const Value: Integer);
    procedure setFsituation(const Value: String);
    procedure setFstage(const Value: String);
    procedure setFtag_value(const Value: Real);
    procedure setFtb_financial_plans_id(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFtb_order_id(const Value: Integer);
    procedure setFtb_payment_types_id(const Value: Integer);
    procedure setFTerminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);
    procedure setFid(const Value: Integer);

  public

    [KeyField('id')]
    [FieldName('id')]
    property Codigo: Integer read Fid write setFid;

    [KeyField('tb_order_id')]
    [FieldName('tb_order_id')]
    property Ordem: Integer read Ftb_order_id write setFtb_order_id;

    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [KeyField('terminal')]
    [FieldName('terminal')]
    property Terminal: Integer read FTerminal write setFTerminal;

    [FieldName('parcel')]
    property Parcela: Integer read Fparcel write setFparcel;

    [FieldName('tag_value')]
    property Valor: Real read Ftag_value write setFtag_value;

    [FieldName('dt_expiration')]
    property DataExpiracao: TDateTime read Fdt_expiration write setFdt_expiration;

    [FieldName('tb_payment_types_id')]
    property TipoPagamento: Integer read Ftb_payment_types_id write setFtb_payment_types_id;


    [FieldName('number')]
    property Numero: String read Fnumber write setFnumber;

    [FieldName('kind')]
    property Tipo: String read Fkind write setFkind;

    [FieldName('situation')]
    property Situacao: String read Fsituation write setFsituation;

    [FieldName('operation')]
    property Operacao: String read Foperation write setFoperation;

    [FieldName('stage')]
    property Fase: String read Fstage write setFstage;

    [FieldName('tb_financial_plans_id')]
    property PlanoContas: Integer read Ftb_financial_plans_id write setFtb_financial_plans_id;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

	End;

implementation


{ Tfinancial }

procedure Tfinancial.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure Tfinancial.setFdt_expiration(const Value: TDateTime);
begin
  Fdt_expiration := Value;
end;

procedure Tfinancial.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure Tfinancial.setFkind(const Value: String);
begin
  Fkind := Value;
end;

procedure Tfinancial.setFnumber(const Value: String);
begin
  Fnumber := Value;
end;

procedure Tfinancial.setFoperation(const Value: String);
begin
  Foperation := Value;
end;

procedure Tfinancial.setFparcel(const Value: Integer);
begin
  Fparcel := Value;
end;

procedure Tfinancial.setFsituation(const Value: String);
begin
  Fsituation := Value;
end;

procedure Tfinancial.setFstage(const Value: String);
begin
  Fstage := Value;
end;

procedure Tfinancial.setFtag_value(const Value: Real);
begin
  Ftag_value := Value;
end;

procedure Tfinancial.setFtb_financial_plans_id(const Value: Integer);
begin
  Ftb_financial_plans_id := Value;
end;

procedure Tfinancial.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure Tfinancial.setFtb_order_id(const Value: Integer);
begin
  Ftb_order_id := Value;
end;

procedure Tfinancial.setFtb_payment_types_id(const Value: Integer);
begin
  Ftb_payment_types_id := Value;
end;

procedure Tfinancial.setFTerminal(const Value: Integer);
begin
  FTerminal := Value;
end;

procedure Tfinancial.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

end.
