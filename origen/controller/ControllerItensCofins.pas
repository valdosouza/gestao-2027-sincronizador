unit ControllerItensCofins;

interface

uses IBX.IBDatabase,System.Classes, Vcl.Grids,IBX.IBQuery, System.SysUtils,ControllerBase,
      tblItensCofins,   System.Generics.Collections,controllerProduto;


Type
  TListaItemCFS = TObjectList<TItensCofins>;

  TControllerItensCofins = Class(TControllerBase)

  private
  public
    Registro : TItensCofins;
    Lista: TListaItemCFS;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function salva:boolean;
    function insere:boolean;
    function atualiza:boolean;
    procedure getList;
    procedure getByItemNota;

  End;

implementation

uses Un_Regra_Negocio;

function TControllerItensCofins.atualiza: boolean;
begin
  Result := True;
  UpdateObj(Registro);
end;

constructor TControllerItensCofins.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TItensCofins.Create;
  Lista := TListaItemCFS.Create;
end;

destructor TControllerItensCofins.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;


procedure TControllerItensCofins.getByItemNota;
Var
  Lc_Qry : TIBQuery;
Begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_ITENS_CFS ',
                      'WHERE CSF_CODITF=:ITF_CODIGO '));
      ParamByName('ITF_CODIGO').AsInteger := Registro.ItemNota;
      Active := True;
      FetchAll;
      exist := RecordCount > 0;
      if exist then get( Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerItensCofins.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TItensCofins;
begin
  Lc_Qry := GeraQuery;
  try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_ITENS_CFS ',
                      'WHERE CFS_CODNFL=:NFL_CODIGO ',
                      ' ORDER BY CFS_CODIGO '));

      ParamByName('NFL_CODIGO').AsInteger := Registro.Nota;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TItensCofins.Create;
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

function TControllerItensCofins.insere: boolean;
begin
  try
    Result := TRue;
    Registro.Codigo :=  Generator('GN_ITENS_CFS');
    InsertObj(Registro);
  Except
    Result := FAlse;
  end;
end;

function TControllerItensCofins.salva: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

end.
