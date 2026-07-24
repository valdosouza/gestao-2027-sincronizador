unit tblPI;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_PI')]
  TPI = Class(TGenericEntity)
  private
    FPDI_OBS_EXTRA: String;
    FPDI_VL_BRUTO: Real;
    FPDI_TP_CALC: Integer;
    FPDI_OBS: String;
    FPDI_COMEMP: REal;
    FPDI_PI_INT: Integer;
    FCODIGO: Integer;
    FPDI_COMVEIC: REal;
    FPDI_DATA_VENC: TDate;
    FPDI_COMAGEN: Real;
    FPDI_CODANUNC: Integer;
    FPDI_APLICACAO: String;
    FPDI_DATA_INT: TDate;
    FPDI_TIPOVEIC: String;
    FPDI_VL_LIQUIDO: Real;
    FPDI_VL_COMISSAO: real;
    FPDI_PI_ORIG: String;
    FPDI_VL_EMPRESA: Real;
    FPDI_CODVEIC: Integer;
    FPDI_CODUSU: Integer;
    FPDI_CODAGEN: Integer;
    FPDI_DATA_ORIG: TDate;
    procedure setFCODIGO(const Value: Integer);
    procedure setFPDI_APLICACAO(const Value: String);
    procedure setFPDI_CODAGEN(const Value: Integer);
    procedure setFPDI_CODANUNC(const Value: Integer);
    procedure setFPDI_CODUSU(const Value: Integer);
    procedure setFPDI_CODVEIC(const Value: Integer);
    procedure setFPDI_COMAGEN(const Value: Real);
    procedure setFPDI_COMEMP(const Value: REal);
    procedure setFPDI_COMVEIC(const Value: REal);
    procedure setFPDI_DATA_INT(const Value: TDate);
    procedure setFPDI_DATA_ORIG(const Value: TDate);
    procedure setFPDI_DATA_VENC(const Value: TDate);
    procedure setFPDI_OBS(const Value: String);
    procedure setFPDI_OBS_EXTRA(const Value: String);
    procedure setFPDI_PI_INT(const Value: Integer);
    procedure setFPDI_PI_ORIG(const Value: String);
    procedure setFPDI_TIPOVEIC(const Value: String);
    procedure setFPDI_TP_CALC(const Value: Integer);
    procedure setFPDI_VL_BRUTO(const Value: Real);
    procedure setFPDI_VL_COMISSAO(const Value: real);
    procedure setFPDI_VL_EMPRESA(const Value: Real);
    procedure setFPDI_VL_LIQUIDO(const Value: Real);

  public
    [KeyField('PDI_CODIGO')]
    [FieldName('PDI_CODIGO')]
    property Codigo: Integer read FCODIGO write setFCODIGO;

    [FieldName('PDI_PI_ORIG')]
    property  PiOriginal:String  read FPDI_PI_ORIG write setFPDI_PI_ORIG;

    [FieldName('PDI_DATA_ORIG')]
    property  DataOriginal: TDate  read FPDI_DATA_ORIG write setFPDI_DATA_ORIG;

    [FieldName('PDI_DATA_VENC')]
    property  DataVencimento: TDate  read FPDI_DATA_VENC write setFPDI_DATA_VENC;

    [FieldName('PDI_PI_INT')]
    property  PiInterno: Integer  read FPDI_PI_INT write setFPDI_PI_INT;

    [FieldName('PDI_DATA_INT')]
    property  DataInterna:TDate  read FPDI_DATA_INT write setFPDI_DATA_INT;

    [FieldName('PDI_CODAGEN')]
    property  Agencia: Integer  read FPDI_CODAGEN write setFPDI_CODAGEN;

    [FieldName('PDI_CODANUNC')]
    property  Anunciante: Integer  read FPDI_CODANUNC write setFPDI_CODANUNC;

    [FieldName('PDI_CODVEIC')]
    property Veiculo : Integer read FPDI_CODVEIC write setFPDI_CODVEIC;

    [FieldName('PDI_COMAGEN')]
    property ComissaoAgencia : Real read FPDI_COMAGEN write setFPDI_COMAGEN;

    [FieldName('PDI_COMVEIC')]
    property ComissaoVeiculo : REal read FPDI_COMVEIC write setFPDI_COMVEIC;

    [FieldName('PDI_COMEMP')]
    property  ComissaoEmpresa: REal read FPDI_COMEMP write setFPDI_COMEMP;

    [FieldName('PDI_TP_CALC')]
    property  TipoCalculo:Integer  read FPDI_TP_CALC write setFPDI_TP_CALC;

    [FieldName('PDI_VL_BRUTO')]
    property  ValorBruto:Real  read FPDI_VL_BRUTO write setFPDI_VL_BRUTO;

    [FieldName('PDI_VL_COMISSAO')]
    property  ValorComissao: real  read FPDI_VL_COMISSAO write setFPDI_VL_COMISSAO;

    [FieldName('PDI_VL_LIQUIDO')]
    property  ValorLiquido: Real  read FPDI_VL_LIQUIDO write setFPDI_VL_LIQUIDO;

    [FieldName('PDI_VL_EMPRESA')]
    property  ValorEmpresa:Real  read FPDI_VL_EMPRESA write setFPDI_VL_EMPRESA;

    [FieldName('PDI_OBS')]
    property Obs :String  read FPDI_OBS write setFPDI_OBS;

    [FieldName('PDI_APLICACAO')]
    property Aplicacao : String  read FPDI_APLICACAO write setFPDI_APLICACAO;

    [FieldName('PDI_CODUSU')]
    property Usuario : Integer read FPDI_CODUSU write setFPDI_CODUSU;

    [FieldName('PDI_TIPOVEIC')]
    property TipoVeiculo : String read FPDI_TIPOVEIC write setFPDI_TIPOVEIC;

    [FieldName('PDI_OBS_EXTRA')]
    property  ObsExtra: String  read FPDI_OBS_EXTRA write setFPDI_OBS_EXTRA;

  End;

implementation

{ TPI }

procedure TPI.setFCODIGO(const Value: Integer);
begin
  FCODIGO := Value;
end;

procedure TPI.setFPDI_APLICACAO(const Value: String);
begin
  FPDI_APLICACAO := Value;
end;

procedure TPI.setFPDI_CODAGEN(const Value: Integer);
begin
  FPDI_CODAGEN := Value;
end;

procedure TPI.setFPDI_CODANUNC(const Value: Integer);
begin
  FPDI_CODANUNC := Value;
end;

procedure TPI.setFPDI_CODUSU(const Value: Integer);
begin
  FPDI_CODUSU := Value;
end;

procedure TPI.setFPDI_CODVEIC(const Value: Integer);
begin
  FPDI_CODVEIC := Value;
end;

procedure TPI.setFPDI_COMAGEN(const Value: Real);
begin
  FPDI_COMAGEN := Value;
end;

procedure TPI.setFPDI_COMEMP(const Value: REal);
begin
  FPDI_COMEMP := Value;
end;

procedure TPI.setFPDI_COMVEIC(const Value: REal);
begin
  FPDI_COMVEIC := Value;
end;

procedure TPI.setFPDI_DATA_INT(const Value: TDate);
begin
  FPDI_DATA_INT := Value;
end;

procedure TPI.setFPDI_DATA_ORIG(const Value: TDate);
begin
  FPDI_DATA_ORIG := Value;
end;

procedure TPI.setFPDI_DATA_VENC(const Value: TDate);
begin
  FPDI_DATA_VENC := Value;
end;

procedure TPI.setFPDI_OBS(const Value: String);
begin
  FPDI_OBS := Value;
end;

procedure TPI.setFPDI_OBS_EXTRA(const Value: String);
begin
  FPDI_OBS_EXTRA := Value;
end;

procedure TPI.setFPDI_PI_INT(const Value: Integer);
begin
  FPDI_PI_INT := Value;
end;

procedure TPI.setFPDI_PI_ORIG(const Value: String);
begin
  FPDI_PI_ORIG := Value;
end;

procedure TPI.setFPDI_TIPOVEIC(const Value: String);
begin
  FPDI_TIPOVEIC := Value;
end;

procedure TPI.setFPDI_TP_CALC(const Value: Integer);
begin
  FPDI_TP_CALC := Value;
end;

procedure TPI.setFPDI_VL_BRUTO(const Value: Real);
begin
  FPDI_VL_BRUTO := Value;
end;

procedure TPI.setFPDI_VL_COMISSAO(const Value: real);
begin
  FPDI_VL_COMISSAO := Value;
end;

procedure TPI.setFPDI_VL_EMPRESA(const Value: Real);
begin
  FPDI_VL_EMPRESA := Value;
end;

procedure TPI.setFPDI_VL_LIQUIDO(const Value: Real);
begin
  FPDI_VL_LIQUIDO := Value;
end;

end.
