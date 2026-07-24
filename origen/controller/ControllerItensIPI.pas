unit ControllerItensIPI;

interface

uses IBX.IBDatabase,Classes, Vcl.Grids,IBX.IBQuery, SysUtils,ControllerBase,
       tblItensipi,    Generics.Collections,controllerProduto;


Type
  TListaItemIPI = TObjectList<TItensIpi>;

  TControllerItensIPI = Class(TControllerBase)
    Lista: TListaItemIPI;
  private
  public
    Registro : TItensIpi;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function salva:boolean;
    function migra:Boolean;
    function insere:boolean;
    function atualiza:boolean;
    procedure getList;
    procedure getByItemNota;

  End;

implementation

uses Un_Regra_Negocio;

function TControllerItensIPI.atualiza: boolean;
begin
  Result := True;
  UpdateObj(Registro);
end;

constructor TControllerItensIPI.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TItensIPI.Create;
  Lista := TListaItemIPI.Create;
end;

destructor TControllerItensIPI.Destroy;
begin
  FreeAndNil(Lista);
  Registro.DisposeOf;
  inherited;
end;


procedure TControllerItensIPI.getByItemNota;
Var
  Lc_Qry : TIBQuery;
Begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_ipi ',
                      'WHERE IPI_CODITF=:IPI_CODIGO '));
      ParamByName('IPI_CODIGO').AsInteger := Registro.ItemNota;
      Active := True;
      FetchAll;
      exist := RecordCount > 0;
      if exist then get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry)
  End;
end;

procedure TControllerItensIPI.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TItensIPI;
begin
  Lc_Qry := GeraQuery;
  try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                     'FROM tb_itens_ipi ',
                     'WHERE IPI_CODIGO > 0 '
          ));
      if Registro.Nota > 0 then
        sql.add(' AND IPI_CODNFL=:NFL_CODIGO ');

      sql.add(' ORDER BY IPI_CODIGO ');

      if Registro.Nota > 0 then
        ParamByName('NFL_CODIGO').AsInteger := Registro.Nota;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TItensIPI.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;
      Close;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;

end;


function TControllerItensIPI.insere: boolean;
begin
  Result := True;
  Registro.Codigo := Generator('GN_ITENS_IPI');
  InsertObj(Registro);
end;

function TControllerItensIPI.migra: Boolean;
begin
  Result := True;
  InsertObj(Registro);
end;

function TControllerItensIPI.salva: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

end.
