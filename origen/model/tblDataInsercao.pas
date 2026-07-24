unit tblDataInsercao;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_DATAINSERCAO')]
  TDataInsercao = Class(TGenericEntity)
  private
    FDIN_SEMANA: String;
    FDIN_CODIGO: Integer;
    FDIN_INSERCAO: Integer;
    FDIN_CODPCA: Integer;
    FDIN_DATA: TDate;
    procedure setFDIN_CODIGO(const Value: Integer);
    procedure setFDIN_CODPCA(const Value: Integer);
    procedure setFDIN_DATA(const Value: TDate);
    procedure setFDIN_INSERCAO(const Value: Integer);
    procedure setFDIN_SEMANA(const Value: String);


  public
    [KeyField('DIN_CODIGO')]
    [FieldName('DIN_CODIGO')]
    property Codigo: Integer read FDIN_CODIGO write setFDIN_CODIGO;

    [FieldName('DIN_CODPCA')]
    property Peca: Integer read FDIN_CODPCA write setFDIN_CODPCA;

    [FieldName('DIN_DATA')]
    property Data: TDate read FDIN_DATA write setFDIN_DATA;

    [FieldName('DIN_SEMANA')]
    property Semana: String read FDIN_SEMANA write setFDIN_SEMANA;

    [FieldName('DIN_INSERCAO')]
    property Insercao: Integer read FDIN_INSERCAO write setFDIN_INSERCAO;

  End;

implementation

{ TDataInsercao }

procedure TDataInsercao.setFDIN_CODIGO(const Value: Integer);
begin
  FDIN_CODIGO := Value;
end;

procedure TDataInsercao.setFDIN_CODPCA(const Value: Integer);
begin
  FDIN_CODPCA := Value;
end;

procedure TDataInsercao.setFDIN_DATA(const Value: TDate);
begin
  FDIN_DATA := Value;
end;

procedure TDataInsercao.setFDIN_INSERCAO(const Value: Integer);
begin
  FDIN_INSERCAO := Value;
end;

procedure TDataInsercao.setFDIN_SEMANA(const Value: String);
begin
  FDIN_SEMANA := Value;
end;

end.
