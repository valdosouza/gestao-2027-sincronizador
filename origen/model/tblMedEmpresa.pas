unit tblMedEmpresa;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('tb_empresa')]
  TMedEmpresa = Class(TGenericEntity)
  private
    FEMP_BANCO: String;
    FEMP_FONE: String;
    FEMP_MSN: String;
    FEMP_TIPOPESSOA: Integer;
    FEMP_CNPJ: String;
    FEMP_OBSERV: String;
    FEMP_FANTASIA: String;
    FEMP_NUMINSC: String;
    FEMP_SITE: String;
    FEMP_EMAIL: String;
    FEMP_BAIRRO: String;
    FEMP_CODAGENC: Integer;
    FEMP_FAX: String;
    FEMP_VAL_TAB: TDate;
    FCODIGO: Integer;
    FEMP_TIPOVEIC: String;
    FEMP_PERIODICIDADE: String;
    FEMP_CEP: String;
    FEMP_COMISSAO: REal;
    FEMP_EMAIL_PI: String;
    FEMP_CONTA: String;
    FEMP_TIPOVEICULO: String;
    FEMP_COMPLEM: String;
    FEMP_CADASTRO: TDate;
    FEMP_AGENCIA: String;
    FEMP_NOME: String;
    FEMP_CIDADE: String;
    FEMP_TIPO: String;
    FEMP_TAM_PAGE: REal;
    FEMP_PAIS: String;
    FEMP_ESTADO: String;
    FEMP_ENDER: String;
    procedure setFCODIGO(const Value: Integer);
    procedure setFEMP_AGENCIA(const Value: String);
    procedure setFEMP_BAIRRO(const Value: String);
    procedure setFEMP_BANCO(const Value: String);
    procedure setFEMP_CADASTRO(const Value: TDate);
    procedure setFEMP_CEP(const Value: String);
    procedure setFEMP_CIDADE(const Value: String);
    procedure setFEMP_CNPJ(const Value: String);
    procedure setFEMP_CODAGENC(const Value: Integer);
    procedure setFEMP_COMISSAO(const Value: REal);
    procedure setFEMP_COMPLEM(const Value: String);
    procedure setFEMP_CONTA(const Value: String);
    procedure setFEMP_EMAIL(const Value: String);
    procedure setFEMP_EMAIL_PI(const Value: String);
    procedure setFEMP_ENDER(const Value: String);
    procedure setFEMP_ESTADO(const Value: String);
    procedure setFEMP_FANTASIA(const Value: String);
    procedure setFEMP_FAX(const Value: String);
    procedure setFEMP_FONE(const Value: String);
    procedure setFEMP_MSN(const Value: String);
    procedure setFEMP_NOME(const Value: String);
    procedure setFEMP_NUMINSC(const Value: String);
    procedure setFEMP_OBSERV(const Value: String);
    procedure setFEMP_PAIS(const Value: String);
    procedure setFEMP_PERIODICIDADE(const Value: String);
    procedure setFEMP_SITE(const Value: String);
    procedure setFEMP_TAM_PAGE(const Value: REal);
    procedure setFEMP_TIPO(const Value: String);
    procedure setFEMP_TIPOPESSOA(const Value: Integer);
    procedure setFEMP_TIPOVEIC(const Value: String);
    procedure setFEMP_TIPOVEICULO(const Value: String);
    procedure setFEMP_VAL_TAB(const Value: TDate);


  public

    [KeyField('EMP_CODIGO')]
    [FieldName('EMP_CODIGO')]
    property Codigo: Integer read FCODIGO write setFCODIGO;

    [FieldName('EMP_TIPO')]
    property Tipo:String  read FEMP_TIPO write setFEMP_TIPO;

    [FieldName('EMP_CADASTRO')]
    property DataCadastro:TDate  read FEMP_CADASTRO write setFEMP_CADASTRO;

    [FieldName('EMP_NOME')]
    property Nome:String  read FEMP_NOME write setFEMP_NOME;

    [FieldName('EMP_FANTASIA')]
    property Fantasia:String  read FEMP_FANTASIA write setFEMP_FANTASIA;

    [FieldName('EMP_NUMINSC')]
    property NumeroInscricao: String read FEMP_NUMINSC write setFEMP_NUMINSC;

    [FieldName('EMP_ENDER')]
    property Endereco: String  read FEMP_ENDER write setFEMP_ENDER;

    [FieldName('EMP_COMPLEM')]
    property Complemento: String read FEMP_COMPLEM write setFEMP_COMPLEM;


    [FieldName('EMP_BAIRRO')]
    property Bairro:String  read FEMP_BAIRRO write setFEMP_BAIRRO;

    [FieldName('EMP_CEP')]
    property CEP:String  read FEMP_CEP write setFEMP_CEP;

    [FieldName('EMP_CIDADE')]
    property Cidade: String read FEMP_CIDADE write setFEMP_CIDADE;

    [FieldName('EMP_ESTADO')]
    property Estado:String  read FEMP_ESTADO write setFEMP_ESTADO;

    [FieldName('EMP_PAIS')]
    property Pais:String  read FEMP_PAIS write setFEMP_PAIS;

    [FieldName('EMP_FONE')]
    property Fone:String  read FEMP_FONE write setFEMP_FONE;

    [FieldName('EMP_FAX')]
    property FAx:String  read FEMP_FAX write setFEMP_FAX;

    [FieldName('EMP_EMAIL')]
    property email:String  read FEMP_EMAIL write setFEMP_EMAIL;

    [FieldName('EMP_SITE')]
    property Site:String  read FEMP_SITE write setFEMP_SITE;

    [FieldName('EMP_COMISSAO')]
    property Comissao: REal  read FEMP_COMISSAO write setFEMP_COMISSAO;

    [FieldName('EMP_TIPOVEICULO')]
    property TipoVeiculo: String read FEMP_TIPOVEICULO write setFEMP_TIPOVEICULO;

    [FieldName('EMP_PERIODICIDADE')]
    property Periodicidade: String  read FEMP_PERIODICIDADE write setFEMP_PERIODICIDADE;

    [FieldName('EMP_AGENCIA')]
    property Agencia:String  read FEMP_AGENCIA write setFEMP_AGENCIA;

    [FieldName('EMP_CONTA')]
    property Conta:String  read FEMP_CONTA write setFEMP_CONTA;

    [FieldName('EMP_TIPOPESSOA')]
    property TipoPessoa: Integer read FEMP_TIPOPESSOA write setFEMP_TIPOPESSOA;

    [FieldName('EMP_MSN')]
    property MSN:String  read FEMP_MSN write setFEMP_MSN;

    [FieldName('EMP_OBSERV')]
    property Observacao:String  read FEMP_OBSERV write setFEMP_OBSERV;

    [FieldName('EMP_BANCO')]
    property BAnco: String read FEMP_BANCO write setFEMP_BANCO;

    [FieldName('EMP_CODAGENC')]
    property CodigoAgencia: Integer  read FEMP_CODAGENC write setFEMP_CODAGENC;

    [FieldName('EMP_VAL_TAB')]
    property ValidadeTabela:TDate  read FEMP_VAL_TAB write setFEMP_VAL_TAB;

    [FieldName('EMP_CNPJ')]
    property CNPJ: String  read FEMP_CNPJ write setFEMP_CNPJ;

    [FieldName('EMP_EMAIL_PI')]
    property email_pi:String  read FEMP_EMAIL_PI write setFEMP_EMAIL_PI;

    [FieldName('EMP_TIPOVEIC')]
    property TipoVeic:String  read FEMP_TIPOVEIC write setFEMP_TIPOVEIC;

    [FieldName('EMP_TAM_PAGE')]
    property TamanhoPagina: REal  read FEMP_TAM_PAGE write setFEMP_TAM_PAGE;


  End;

implementation

{ TMedEmpresa }

procedure TMedEmpresa.setFCODIGO(const Value: Integer);
begin
  FCODIGO := Value;
end;

procedure TMedEmpresa.setFEMP_AGENCIA(const Value: String);
begin
  FEMP_AGENCIA := Value;
end;

procedure TMedEmpresa.setFEMP_BAIRRO(const Value: String);
begin
  FEMP_BAIRRO := Value;
end;

procedure TMedEmpresa.setFEMP_BANCO(const Value: String);
begin
  FEMP_BANCO := Value;
end;

procedure TMedEmpresa.setFEMP_CADASTRO(const Value: TDate);
begin
  FEMP_CADASTRO := Value;
end;

procedure TMedEmpresa.setFEMP_CEP(const Value: String);
begin
  FEMP_CEP := Value;
end;

procedure TMedEmpresa.setFEMP_CIDADE(const Value: String);
begin
  FEMP_CIDADE := Value;
end;

procedure TMedEmpresa.setFEMP_CNPJ(const Value: String);
begin
  FEMP_CNPJ := Value;
end;

procedure TMedEmpresa.setFEMP_CODAGENC(const Value: Integer);
begin
  FEMP_CODAGENC := Value;
end;

procedure TMedEmpresa.setFEMP_COMISSAO(const Value: REal);
begin
  FEMP_COMISSAO := Value;
end;

procedure TMedEmpresa.setFEMP_COMPLEM(const Value: String);
begin
  FEMP_COMPLEM := Value;
end;

procedure TMedEmpresa.setFEMP_CONTA(const Value: String);
begin
  FEMP_CONTA := Value;
end;

procedure TMedEmpresa.setFEMP_EMAIL(const Value: String);
begin
  FEMP_EMAIL := Value;
end;

procedure TMedEmpresa.setFEMP_EMAIL_PI(const Value: String);
begin
  FEMP_EMAIL_PI := Value;
end;

procedure TMedEmpresa.setFEMP_ENDER(const Value: String);
begin
  FEMP_ENDER := Value;
end;

procedure TMedEmpresa.setFEMP_ESTADO(const Value: String);
begin
  FEMP_ESTADO := Value;
end;

procedure TMedEmpresa.setFEMP_FANTASIA(const Value: String);
begin
  FEMP_FANTASIA := Value;
end;

procedure TMedEmpresa.setFEMP_FAX(const Value: String);
begin
  FEMP_FAX := Value;
end;

procedure TMedEmpresa.setFEMP_FONE(const Value: String);
begin
  FEMP_FONE := Value;
end;

procedure TMedEmpresa.setFEMP_MSN(const Value: String);
begin
  FEMP_MSN := Value;
end;

procedure TMedEmpresa.setFEMP_NOME(const Value: String);
begin
  FEMP_NOME := Value;
end;

procedure TMedEmpresa.setFEMP_NUMINSC(const Value: String);
begin
  FEMP_NUMINSC := Value;
end;

procedure TMedEmpresa.setFEMP_OBSERV(const Value: String);
begin
  FEMP_OBSERV := Value;
end;

procedure TMedEmpresa.setFEMP_PAIS(const Value: String);
begin
  FEMP_PAIS := Value;
end;

procedure TMedEmpresa.setFEMP_PERIODICIDADE(const Value: String);
begin
  FEMP_PERIODICIDADE := Value;
end;

procedure TMedEmpresa.setFEMP_SITE(const Value: String);
begin
  FEMP_SITE := Value;
end;

procedure TMedEmpresa.setFEMP_TAM_PAGE(const Value: REal);
begin
  FEMP_TAM_PAGE := Value;
end;

procedure TMedEmpresa.setFEMP_TIPO(const Value: String);
begin
  FEMP_TIPO := Value;
end;

procedure TMedEmpresa.setFEMP_TIPOPESSOA(const Value: Integer);
begin
  FEMP_TIPOPESSOA := Value;
end;

procedure TMedEmpresa.setFEMP_TIPOVEIC(const Value: String);
begin
  FEMP_TIPOVEIC := Value;
end;

procedure TMedEmpresa.setFEMP_TIPOVEICULO(const Value: String);
begin
  FEMP_TIPOVEICULO := Value;
end;

procedure TMedEmpresa.setFEMP_VAL_TAB(const Value: TDate);
begin
  FEMP_VAL_TAB := Value;
end;

end.
