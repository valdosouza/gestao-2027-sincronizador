unit tblDskMedMaterial;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_MATERIAL')]
  TDskMedMaterial = Class(TGenericEntity)
  private
    FMTR_DESCRICAO: String;
    FCODIGO: Integer;
    FMTR_APLICACAO: Integer;
    procedure setFCODIGO(const Value: Integer);
    procedure setFMTR_APLICACAO(const Value: Integer);
    procedure setFMTR_DESCRICAO(const Value: String);


  public
    [KeyField('MTR_CODIGO')]
    [FieldName('MTR_CODIGO')]
    property Codigo: Integer read FCODIGO write setFCODIGO;

    [FieldName('MTR_DESCRICAO')]
    property DEscricao :String  read FMTR_DESCRICAO write setFMTR_DESCRICAO;

    [FieldName('MTR_APLICACAO')]
    property Aplicacao :Integer  read FMTR_APLICACAO write setFMTR_APLICACAO;

  End;

implementation

{ TDskMedMaterial }

procedure TDskMedMaterial.setFCODIGO(const Value: Integer);
begin
  FCODIGO := Value;
end;

procedure TDskMedMaterial.setFMTR_APLICACAO(const Value: Integer);
begin
  FMTR_APLICACAO := Value;
end;

procedure TDskMedMaterial.setFMTR_DESCRICAO(const Value: String);
begin
  FMTR_DESCRICAO := Value;
end;

end.
