unit ControllerItensPIS;

interface

uses IBX.IBDatabase,System.Classes, Vcl.Grids,IBX.IBQuery, System.SysUtils,ControllerBase,
      tblItenspis,
      System.Generics.Collections,controllerProduto;


Type
  TListaItemPIS = TObjectList<TItensPIS>;

  TControllerItensPIS = Class(TControllerBase)

  private

  public
    Registro : TItensPIS;
    Lista: TListaItemPIS;
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

function TControllerItensPIS.atualiza: boolean;
begin
  Result := True;
  UpdateObj(Registro);
end;

constructor TControllerItensPIS.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TItensPIS.Create;
  Lista := TListaItemPIS.Create;
end;

destructor TControllerItensPIS.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;


procedure TControllerItensPIS.getByItemNota;
Var
  Lc_Qry : TIBQuery;
Begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_pis ',
                      'WHERE PIS_CODITF=:ITF_CODIGO '));
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

procedure TControllerItensPIS.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TItensPIS;
begin
  Lc_Qry := GeraQuery;
  try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_PIS ',
                      'WHERE PIS_CODNFL=:NFL_CODIGO ',
                      ' ORDER BY PIS_CODIGO '));

      ParamByName('NFL_CODIGO').AsInteger := Registro.Nota;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TItensPIS.Create;
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

function TControllerItensPIS.insere: boolean;
begin
  try
    Result := TRue;
    Registro.Codigo := Generator('GN_ITENS_PIS'); //nextCodigo;
    InsertObj(Registro);
  Except
    Result := FAlse;
  end;
end;



function TControllerItensPIS.salva: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

end.
