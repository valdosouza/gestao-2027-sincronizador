unit ControllerBoletoEletronico;

interface

uses IBX.IBDatabase,System.Classes, System.SysUtils,ControllerBase,
      tblBoletoEletronico, Md5, IBX.IBQuery;

Type
  TControllerBoletoEletronico = Class(TControllerBase)

  private

  public
    Registro : TBoletoEletronico;
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
{ ControllerBoletoEletronico}


procedure TControllerBoletoEletronico.clear;
begin

end;

constructor TControllerBoletoEletronico.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TBoletoEletronico.Create;
end;

function TControllerBoletoEletronico.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerBoletoEletronico.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

function TControllerBoletoEletronico.insert: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerBoletoEletronico.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


function TControllerBoletoEletronico.getAllByKey: boolean;
begin
  getByKey;
end;

function TControllerBoletoEletronico.getByKey: Boolean;
begin
  Result := True;
  Self._getByKey(Registro);
end;
end.
