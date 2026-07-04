unit tblVeiculoCom;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_EMPRESA')]
  TVeiculoCom = Class(TGenericEntity)
  private
    FEMP_ATIVO: String;
    FEMP_CODIGO: Integer;
    FEMP_CADASTRO: Tdate;
    procedure setFEMP_ATIVO(const Value: String);
    procedure setFEMP_CADASTRO(const Value: Tdate);
    procedure setFEMP_CODIGO(const Value: Integer);

  public

    [KeyField('EMP_CODIGO')]
    [FieldName('EMP_CODIGO')]
    property Codigo: Integer read FEMP_CODIGO write setFEMP_CODIGO;

    [FieldName('EMP_ATIVO')]
    property Ativo: String read FEMP_ATIVO write setFEMP_ATIVO;

    [FieldName('EMP_CADASTRO')]
    property DataCadastro: Tdate read FEMP_CADASTRO write setFEMP_CADASTRO;


  End;

implementation

{ TVeiculoCom }

procedure TVeiculoCom.setFEMP_ATIVO(const Value: String);
begin
  FEMP_ATIVO := Value;
end;

procedure TVeiculoCom.setFEMP_CADASTRO(const Value: Tdate);
begin
  FEMP_CADASTRO := Value;
end;

procedure TVeiculoCom.setFEMP_CODIGO(const Value: Integer);
begin
  FEMP_CODIGO := Value;
end;

end.
