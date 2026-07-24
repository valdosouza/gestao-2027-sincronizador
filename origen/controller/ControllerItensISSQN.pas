unit ControllerItensISSQN;

interface

uses IBX.IBDatabase,System.Classes, Vcl.Grids,IBX.IBQuery, System.SysUtils,ControllerBase,
      tblItensissqn,
      System.Generics.Collections,controllerProduto;


Type
  TListaItemISSQN = TObjectList<TItensISSQN>;

  TControllerItensISSQN = Class(TControllerBase)

  private
  public
    Registro : TItensISSQN;
    Lista: TListaItemISSQN;
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

function TControllerItensISSQN.atualiza: boolean;
begin
  Result := True;
  UpdateObj(Registro);
end;

constructor TControllerItensISSQN.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TItensISSQN.Create;
  Lista := TListaItemISSQN.Create;
end;

destructor TControllerItensISSQN.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;


procedure TControllerItensISSQN.getByItemNota;
Var
  Lc_Qry : TIBQuery;
Begin
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_issqn ',
                      'WHERE ISS_CODITF=:ISS_CODIGO '));
      ParamByName('ISS_CODIGO').AsInteger := Registro.ItemNota;
      Active := True;
      FetchAll;
      exist := RecordCount > 0;
      if exist then get(Lc_Qry,Registro);
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerItensISSQN.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TItensISSQN;
begin
  Lc_Qry := GeraQuery;
  try
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM tb_itens_ISSQN ',
                      'WHERE ISSS_CODNFL=:NFL_CODIGO ',
                      ' ORDER BY ISS_CODIGO '));

      ParamByName('NFL_CODIGO').AsInteger := Registro.Nota;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TItensISSQN.Create;
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

function TControllerItensISSQN.insere: boolean;
begin
  try
    Result := TRue;
    Registro.Codigo := Generator('GN_ITENS_ISSQN');
    InsertObj(Registro);
  Except
    Result := FAlse;
  end;
end;

function TControllerItensISSQN.salva: boolean;
begin
  Result := True;
  SaveObj(Registro);
end;

end.
