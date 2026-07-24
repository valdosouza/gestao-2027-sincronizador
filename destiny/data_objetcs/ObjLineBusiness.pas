unit ObjLineBusiness;


interface

uses System.SysUtils, tblLinebusiness, ObjBase;

Type


  TObjLineBusiness = Class(TObjBase)
  private
    FRamoAtividade: TLineBusiness;
    procedure setFRamoAtividade(const Value: TLineBusiness);

  public
      constructor Create;override;
      destructor Destroy;override;
    property RamoAtividade : TLineBusiness read FRamoAtividade write setFRamoAtividade;

  End;

implementation


{ TObjLineBusiness }

constructor TObjLineBusiness.Create;
begin
  FRamoAtividade := TLineBusiness.Create;
  inherited;
end;

destructor TObjLineBusiness.Destroy;
begin
  FRamoAtividade.DisposeOf;
  inherited
end;

procedure TObjLineBusiness.setFRamoAtividade(const Value: TLineBusiness);
begin
  FRamoAtividade := Value;
end;

end.
