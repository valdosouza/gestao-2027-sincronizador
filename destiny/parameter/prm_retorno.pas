unit prm_retorno;

interface

uses
  System.SysUtils, System.Classes;

type
  TPrmRetorno = class(TPersistent)
    private
    Fcode: Integer;
    Fid: Integer;
    Fmessage: String;
    procedure setFcode(const Value: Integer);
    procedure setFid(const Value: Integer);
    procedure setFmessage(const Value: String);

    public
      constructor Create;Virtual;
      destructor Destroy;override;
      procedure Clear;
      property Mensagem: String read Fmessage write setFmessage;
      property ID: Integer read Fid write setFid;
      property Code: Integer read Fcode write setFcode;
  end;

implementation

{ TPrmRetorno }

procedure TPrmRetorno.Clear;
begin
  Fcode := 0;
  Fid := 0;
  Fmessage := '';
end;

constructor TPrmRetorno.Create;
begin
  inherited
end;

destructor TPrmRetorno.Destroy;
begin
  inherited;
end;

procedure TPrmRetorno.setFcode(const Value: Integer);
begin
  Fcode := Value;
end;

procedure TPrmRetorno.setFid(const Value: Integer);
begin
  Fid := Value;
end;

procedure TPrmRetorno.setFmessage(const Value: String);
begin
  Fmessage := Value;
end;

end.
