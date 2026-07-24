unit tblDskMailing;

interface

Uses TEntity,CAtribEntity;

implementation

Type
  //nome da classe de entidade
  [TableName('tb_mailing')]
  TDskMailing = Class(TGenericEntity)
  private
    FID: AnsiString;
    FEMAIL: AnsiString;
    FKIND: AnsiString;
    FNEWS: AnsiString;

    procedure setFID(value: AnsiString);
    procedure setFEMAIL(value: AnsiString);
    procedure setFKIND(value: AnsiString);
    procedure setFNEWS(value: AnsiString);

  public
    [KeyField('id')]
    [FieldName('id')]
    property id: AnsiString read FID write setFID;
    [FieldName('email')]
    property email: AnsiString read FEMAIL write setFEMAIL;
    [FieldName('kind')]
    property kind: AnsiString read FKIND write setFKIND;
    [FieldName('news')]
    property news: AnsiString read FNEWS write setFNEWS;

  End;
  { TDskMailing }

procedure TDskMailing.setFEMAIL(value: AnsiString);
begin
  FEMAIL := value;

end;

procedure TDskMailing.setFID(value: AnsiString);
begin
  FID := value;
end;

procedure TDskMailing.setFKIND(value: AnsiString);
begin
  FKIND := value;
end;

procedure TDskMailing.setFNEWS(value: AnsiString);
begin
  FNEWS := value;
end;

end.
