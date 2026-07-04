unit tblDuplicata;

interface

Uses GenericEntity,CAtribEntity, System.Classes, System.SysUtils;

Type
  //nome da classe de entidade
  [TableName('TB_DUPLICATA')]
  TDuplicata = Class(TGenericEntity)

  private
    FDUP_TIPOVALOR: String;
    FDUP_VALOR: Real;
    FDUP_CODIGO: Integer;
    FDUP_DATAPAGTO: TDate;
    FDUP_CODPDI: Integer;
    FDUP_NR_NOTA: String;
    FDUP_BAIXA: String;
    procedure setFDUP_BAIXA(const Value: String);
    procedure setFDUP_CODIGO(const Value: Integer);
    procedure setFDUP_CODPDI(const Value: Integer);
    procedure setFDUP_DATAPAGTO(const Value: TDate);
    procedure setFDUP_NR_NOTA(const Value: String);
    procedure setFDUP_TIPOVALOR(const Value: String);
    procedure setFDUP_VALOR(const Value: Real);

  public
    [FieldName('DUP_CODIGO')]
    [KeyField('DUP_CODIGO')]
    property Codigo:Integer  read FDUP_CODIGO write setFDUP_CODIGO;

    [FieldName('DUP_CODPDI')]
    property Ordem: Integer read FDUP_CODPDI write setFDUP_CODPDI;

    [FieldName('DUP_VALOR')]
    property Valor: Real  read FDUP_VALOR write setFDUP_VALOR;

    [FieldName('DUP_TIPOVALOR')]
    property TipoValor:String  read FDUP_TIPOVALOR write setFDUP_TIPOVALOR;

    [FieldName('DUP_DATAPAGTO')]
    property DataPagamento: TDate  read FDUP_DATAPAGTO write setFDUP_DATAPAGTO;

    [FieldName('DUP_BAIXA')]
    property Baixado: String  read FDUP_BAIXA write setFDUP_BAIXA;

    [FieldName('DUP_NR_NOTA')]
    property NumeroNota: String read FDUP_NR_NOTA write setFDUP_NR_NOTA;

  End;

implementation


{ TDuplicata }

procedure TDuplicata.setFDUP_BAIXA(const Value: String);
begin
  FDUP_BAIXA := Value;
end;

procedure TDuplicata.setFDUP_CODIGO(const Value: Integer);
begin
  FDUP_CODIGO := Value;
end;

procedure TDuplicata.setFDUP_CODPDI(const Value: Integer);
begin
  FDUP_CODPDI := Value;
end;

procedure TDuplicata.setFDUP_DATAPAGTO(const Value: TDate);
begin
  FDUP_DATAPAGTO := Value;
end;

procedure TDuplicata.setFDUP_NR_NOTA(const Value: String);
begin
  FDUP_NR_NOTA := Value;
end;

procedure TDuplicata.setFDUP_TIPOVALOR(const Value: String);
begin
  FDUP_TIPOVALOR := Value;
end;

procedure TDuplicata.setFDUP_VALOR(const Value: Real);
begin
  FDUP_VALOR := Value;
end;

end.
