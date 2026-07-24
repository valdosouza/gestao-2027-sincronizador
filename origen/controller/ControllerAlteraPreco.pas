unit ControllerAlteraPreco;

interface

uses IBX.IBDatabase,System.Classes, System.SysUtils,ControllerBase,
      tblAlteraPreco, Md5,  IBX.IBQuery;

 Type
  TControllerAlteraPreco = Class(TControllerBase)
  private

  public
    Registro : TAlteraPreco;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function insert:boolean;
    Function delete:boolean;
    function getByKey:Boolean;
    function getAllByKey:boolean;
    procedure clear;
  End;

  implementation
{ ControllerAlteraPreco }

procedure TControllerAlteraPreco.clear;
begin
ClearObj(Registro);
end;

constructor TControllerAlteraPreco.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TAlteraPreco.Create;
end;

function TControllerAlteraPreco.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerAlteraPreco.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

function TControllerAlteraPreco.insert: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerAlteraPreco.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

procedure TControllerAlteraPreco.get(Qry:TIBQuery;Obj:TAlteraPreco);

function TControllerAlteraPreco.getAllByKey: boolean;
begin
  getByKey;
end;

function TControllerAlteraPreco.getByKey: Boolean;
begin
  Result := True;
  Self._getByKey(Registro);
end;
end.

