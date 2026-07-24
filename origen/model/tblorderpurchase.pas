unit tblOrderPurchase;

interface

Uses GenericEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_order_purchase')]
  TOrderPurchase = Class(TGenericEntity)
  private
    Fid: Integer;
    Fupdated_at: TDAteTime;
    Fnumber: Integer;
    Fapproved: String;
    Ftb_provider_id: Integer;
    Ftb_institution_id: Integer;
    Fdoc_provider: String;
    Fterminal: Integer;
    Fcreated_at: TDAteTime;
    Fuser_external_code: Integer;
    Fprovider_external_code: Integer;

    procedure setFapproved(const Value: String);
    procedure setFcreated_at(const Value: TDAteTime);
    procedure setFdoc_provider(const Value: String);
    procedure setFid(const Value: Integer);
    procedure setFnumber(const Value: Integer);
    procedure setFtb_institution_id(const Value: Integer);
    procedure setFtb_provider_id(const Value: Integer);
    procedure setFterminal(const Value: Integer);
    procedure setFupdated_at(const Value: TDAteTime);
    procedure setFprovider_external_code(const Value: Integer);
    procedure setFuser_external_code(const Value: Integer);

  public
    [KeyField('id')]
    [FieldName('id')]
    property Codigo: Integer read Fid write setFid;

    [KeyField('tb_institution_id')]
    [FieldName('tb_institution_id')]
    property Estabelecimento: Integer read Ftb_institution_id write setFtb_institution_id;

    [FieldName('terminal')]
    [KeyField('terminal')]
    property Terminal: Integer read Fterminal write setFterminal;

    [FieldName('approved ')]
    property Aprovado: String read Fapproved write setFapproved;

    [FieldName('number')]
    property Numero: Integer read Fnumber write setFnumber;

    [FieldName('tb_provider_id')]
    property Fornecedor: Integer read Ftb_provider_id write setFtb_provider_id;



    property ProviderExternalCode: Integer read Fprovider_external_code write setFprovider_external_code;

    [FieldName('created_at')]
    property RegistroCriado: TDAteTime read Fcreated_at write setFcreated_at;

    [FieldName('updated_at')]
    property RegistroAlterado: TDAteTime read Fupdated_at write setFupdated_at;

	End;

implementation


{ TOrderPurchase }

procedure TOrderPurchase.setFapproved(const Value: String);
begin
  Fapproved := Value;
end;

procedure TOrderPurchase.setFcreated_at(const Value: TDAteTime);
begin
  Fcreated_at := Value;
end;

procedure TOrderPurchase.setFdoc_provider(const Value: String);
begin
  Fdoc_provider := Value;
end;



procedure TOrderPurchase.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TOrderPurchase.setFnumber(const Value: Integer);
begin
  Fnumber := Value;
end;

procedure TOrderPurchase.setFprovider_external_code(const Value: Integer);
begin
  Fprovider_external_code := Value;
end;

procedure TOrderPurchase.setFtb_institution_id(const Value: Integer);
begin
  Ftb_institution_id := Value;
end;

procedure TOrderPurchase.setFtb_provider_id(const Value: Integer);
begin
  Ftb_provider_id := Value;
end;

procedure TOrderPurchase.setFterminal(const Value: Integer);
begin
  Fterminal := Value;
end;

procedure TOrderPurchase.setFupdated_at(const Value: TDAteTime);
begin
  Fupdated_at := Value;
end;

procedure TOrderPurchase.setFuser_external_code(const Value: Integer);
begin
  Fuser_external_code := Value;
end;

end.

