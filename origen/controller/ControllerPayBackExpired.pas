unit ControllerPayBackExpired;

interface

uses IBX.IBDatabase,Classes, Vcl.Grids,IBQuery, SysUtils,ControllerBase,
      tblPayBackExpired ,Un_MSg,Generics.Collections,prmbase, prm_pay_back;

Type
  TControllerPayBackExpired = Class(TControllerBase)
  private

  public
    Registro : TPayBackExpired;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function insert:boolean;
    function getLast:TDate;
    procedure Clear;
  End;

implementation

{ TControllerPayBackExpired }

procedure TControllerPayBackExpired.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerPayBackExpired.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TPayBackExpired.Create;
end;

destructor TControllerPayBackExpired.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;


function TControllerPayBackExpired.getLast: TDate;
var
  Lc_Qry : TIBQuery;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
          'Select MAX(DT_RECORD) DATA ',
          'FROM tb_pay_back_expired '
      ));
      Active := True;
      FetchAll;
      if RecordCount > 0 then
        Result := FieldByName('DATA').AsDateTime
      else
        Result := StrToDate('01/01/2000');
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;

end;

function TControllerPayBackExpired.insert: boolean;
begin
  try
    insertObj(Registro);
    Result := True;
  Except
    Result := False;
  end;
end;

end.
