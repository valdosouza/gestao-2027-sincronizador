unit tblPecas;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_PECAS')]
  TPecas = Class(TGenericEntity)
  private
    FPCA_REPETICAO: integer;
    FPCA_DURACAO: String;
    FPCA_SEQUENCIA: String;
    FPCA_COR: String;
    FPCA_CODMTR: Integer;
    FPCA_TITULO: String;
    FPCA_ALIQ_DESC: REal;
    FPCA_ALTURA: String;
    FPCA_CODIGO: Integer;
    FPCA_VL_UNIT: REal;
    FPCA_CODPPP: Integer;
    FPCA_VL_TABELA: Real;
    FPCA_VL_TOTAL: Real;
    FPCA_INSERCAO: Integer;
    FPCA_DIA: String;
    FPCA_CODPI: Integer;
    FPCA_COLUNA: String;
    FPCA_DATA: Tdate;
    procedure setFPCA_ALIQ_DESC(const Value: REal);
    procedure setFPCA_ALTURA(const Value: String);
    procedure setFPCA_CODIGO(const Value: Integer);
    procedure setFPCA_CODMTR(const Value: Integer);
    procedure setFPCA_CODPI(const Value: Integer);
    procedure setFPCA_CODPPP(const Value: Integer);
    procedure setFPCA_COLUNA(const Value: String);
    procedure setFPCA_COR(const Value: String);
    procedure setFPCA_DATA(const Value: Tdate);
    procedure setFPCA_DIA(const Value: String);
    procedure setFPCA_DURACAO(const Value: String);
    procedure setFPCA_INSERCAO(const Value: Integer);
    procedure setFPCA_REPETICAO(const Value: integer);
    procedure setFPCA_SEQUENCIA(const Value: String);
    procedure setFPCA_TITULO(const Value: String);
    procedure setFPCA_VL_TABELA(const Value: Real);
    procedure setFPCA_VL_TOTAL(const Value: Real);
    procedure setFPCA_VL_UNIT(const Value: REal);

  public

    [KeyField('PCA_CODIGO')]
    [FieldName('PCA_CODIGO')]
    property Codigo: Integer read FPCA_CODIGO write setFPCA_CODIGO;

    [FieldName('PCA_CODPI')]
    property PI: Integer read FPCA_CODPI write setFPCA_CODPI;

    [FieldName('PCA_TITULO')]
    property Titulo: String  read FPCA_TITULO write setFPCA_TITULO;

    [FieldName('PCA_CODMTR')]
    property Material: Integer  read FPCA_CODMTR write setFPCA_CODMTR;

    [FieldName('PCA_CODPPP')]
    property PosicaoProg: Integer  read FPCA_CODPPP write setFPCA_CODPPP;

    [FieldName('PCA_COLUNA')]
    property Coluna:String  read FPCA_COLUNA write setFPCA_COLUNA;

    [FieldName('PCA_ALTURA')]
    property Altura: String  read FPCA_ALTURA write setFPCA_ALTURA;

    [FieldName('PCA_COR')]
    property Cor:String  read FPCA_COR write setFPCA_COR;

    [FieldName('PCA_DURACAO')]
    property Duracao: String  read FPCA_DURACAO write setFPCA_DURACAO;

    [FieldName('PCA_INSERCAO')]
    property Insercao: Integer read FPCA_INSERCAO write setFPCA_INSERCAO;

    [FieldName('PCA_REPETICAO')]
    property Repeticao:integer  read FPCA_REPETICAO write setFPCA_REPETICAO;

    [FieldName('PCA_DATA')]
    property Data:Tdate  read FPCA_DATA write setFPCA_DATA;

    [FieldName('PCA_VL_UNIT')]
    property ValorUnitario: REal  read FPCA_VL_UNIT write setFPCA_VL_UNIT;

    [FieldName('PCA_VL_TOTAL')]
    property ValorTotal: Real  read FPCA_VL_TOTAL write setFPCA_VL_TOTAL;

    [FieldName('PCA_ALIQ_DESC')]
    property AliqDesc:REal  read FPCA_ALIQ_DESC write setFPCA_ALIQ_DESC;

    [FieldName('PCA_DIA')]
    property Dia:String  read FPCA_DIA write setFPCA_DIA;

    [FieldName('PCA_VL_TABELA')]
    property ValorTabela:Real  read FPCA_VL_TABELA write setFPCA_VL_TABELA;

    [FieldName('PCA_SEQUENCIA')]
    property Sequencia:String  read FPCA_SEQUENCIA write setFPCA_SEQUENCIA;

  End;

implementation

{ TPecas }

procedure TPecas.setFPCA_ALIQ_DESC(const Value: REal);
begin
  FPCA_ALIQ_DESC := Value;
end;

procedure TPecas.setFPCA_ALTURA(const Value: String);
begin
  FPCA_ALTURA := Value;
end;

procedure TPecas.setFPCA_CODIGO(const Value: Integer);
begin
  FPCA_CODIGO := Value;
end;

procedure TPecas.setFPCA_CODMTR(const Value: Integer);
begin
  FPCA_CODMTR := Value;
end;

procedure TPecas.setFPCA_CODPI(const Value: Integer);
begin
  FPCA_CODPI := Value;
end;

procedure TPecas.setFPCA_CODPPP(const Value: Integer);
begin
  FPCA_CODPPP := Value;
end;

procedure TPecas.setFPCA_COLUNA(const Value: String);
begin
  FPCA_COLUNA := Value;
end;

procedure TPecas.setFPCA_COR(const Value: String);
begin
  FPCA_COR := Value;
end;

procedure TPecas.setFPCA_DATA(const Value: Tdate);
begin
  FPCA_DATA := Value;
end;

procedure TPecas.setFPCA_DIA(const Value: String);
begin
  FPCA_DIA := Value;
end;

procedure TPecas.setFPCA_DURACAO(const Value: String);
begin
  FPCA_DURACAO := Value;
end;

procedure TPecas.setFPCA_INSERCAO(const Value: Integer);
begin
  FPCA_INSERCAO := Value;
end;

procedure TPecas.setFPCA_REPETICAO(const Value: integer);
begin
  FPCA_REPETICAO := Value;
end;

procedure TPecas.setFPCA_SEQUENCIA(const Value: String);
begin
  FPCA_SEQUENCIA := Value;
end;

procedure TPecas.setFPCA_TITULO(const Value: String);
begin
  FPCA_TITULO := Value;
end;

procedure TPecas.setFPCA_VL_TABELA(const Value: Real);
begin
  FPCA_VL_TABELA := Value;
end;

procedure TPecas.setFPCA_VL_TOTAL(const Value: Real);
begin
  FPCA_VL_TOTAL := Value;
end;

procedure TPecas.setFPCA_VL_UNIT(const Value: REal);
begin
  FPCA_VL_UNIT := Value;
end;

end.
