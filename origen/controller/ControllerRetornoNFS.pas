unit ControllerRetornoNFS;

interface
uses Classes, IBX.IBQuery, SysUtils, ControllerBase, tblRetornoNFS;

Type
  // Patch 04 (C3): controller minimo para a sincronia da NFS-e — a
  // TB_RETORNO_NFS e gravada pelo Gestao2016; o Sincronizador so LE
  // (getSincronia) para montar o payload do /invoice-return-service.
  TControllerRetornoNFS = Class(TControllerBase)
  public
    Registro : TRetornoNFS;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure getSincronia;
  End;

implementation

{ TControllerRetornoNFS }

constructor TControllerRetornoNFS.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TRetornoNFS.Create;
end;

destructor TControllerRetornoNFS.Destroy;
begin
  Registro.DisposeOf;
  inherited;
end;

procedure TControllerRetornoNFS.Clear;
begin
  clearObj(Registro);
end;

procedure TControllerRetornoNFS.getSincronia;
var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                     'FROM TB_RETORNO_NFS ',
                     'WHERE NFS_CODNFL=:NFS_CODNFL '
                    ));
      ParamByName('NFS_CODNFL').AsInteger := Registro.CodigoNotaFiscal;
      Active := True;
      FetchAll;
      exist := (RecordCount > 0);
      if exist then get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
