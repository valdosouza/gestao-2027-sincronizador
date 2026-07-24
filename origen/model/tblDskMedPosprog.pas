unit tblDskMedPosprog;

interface

Uses TEntity,CAtribEntity;

Type
  //nome da classe de entidade
  [TableName('TB_POPROPE')]
  TDskMedPosprog = Class(TGenericEntity)
  private
    FPPP_DESCRICAO: String;
    FCODIGO: Integer;
    procedure setFCODIGO(const Value: Integer);
    procedure setFPPP_DESCRICAO(const Value: String);

  public
    [KeyField('PPP_CODIGO')]
    [FieldName('PPP_CODIGO')]
    property Codigo: Integer read FCODIGO write setFCODIGO;

    [FieldName('PPP_DESCRICAO')]
    property DEscricao :String  read FPPP_DESCRICAO write setFPPP_DESCRICAO;


  End;

implementation

{ TDskMedPosprog }

procedure TDskMedPosprog.setFCODIGO(const Value: Integer);
begin
  FCODIGO := Value;
end;

procedure TDskMedPosprog.setFPPP_DESCRICAO(const Value: String);
begin
  FPPP_DESCRICAO := Value;
end;

end.
