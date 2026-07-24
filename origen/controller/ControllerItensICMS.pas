unit ControllerItensICMS;

interface

uses IBX.IBDatabase,Classes, Vcl.Grids,IBX.IBQuery, SysUtils,ControllerBase,
       tblItensicms ,  Generics.Collections,controllerProduto;


Type
  TListaItemICMS = TObjectList<TItensIcms>;

  TControllerItensICMS = Class(TControllerBase)
    Lista: TListaItemICMS;
  private

  public
    Registro : TItensIcms;
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

function TControllerItensICMS.atualiza: boolean;
begin
  Result := True;
  UpdateObj(Registro);
end;

constructor TControllerItensICMS.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TItensICMS.Create;
  Lista := TListaItemICMS.Create;
end;

destructor TControllerItensICMS.Destroy;
begin
  Registro.DisposeOf;
  FreeAndNil(Lista);
  inherited;
end;

procedure TControllerItensICMS.getByItemNota;
Var
  Lc_Qry : TIBQuery;
Begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_icms ',
                      'WHERE ICM_CODITF=:ITF_CODIGO '));
      ParamByName('ITF_CODIGO').AsInteger := Registro.ItemNota;
      Active := True;
      FetchAll;
      exist := RecordCount > 0;
      if exist then get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry)
  End;
end;

procedure TControllerItensICMS.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TItensICMS;
begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_icms ',
                      'WHERE ICM_CODIGO > 0 '
            ));
      if Registro.Nota > 0 then
        sql.add(' AND ICM_CODNFL=:NFL_CODIGO ');

      sql.add(' ORDER BY ICM_CODIGO ');

      if Registro.Nota > 0 then
        ParamByName('NFL_CODIGO').AsInteger := Registro.Nota;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TItensICMS.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;
      Close;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


function TControllerItensICMS.insere: boolean;
begin
  Result := True;
  Registro.Codigo := Generator('GN_ITENS_ICMS');
  InsertObj(Registro);
end;

function TControllerItensICMS.migra: Boolean;
begin
  Result := True;
  InsertObj(Registro);
end;

function TControllerItensICMS.salva: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

end.
