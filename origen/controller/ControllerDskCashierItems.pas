unit ControllerDskCashierItems;

interface

uses IBX.IBDatabase,Classes, SysUtils,ControllerBase,
      tblDskCashierItems, Md5, IBX.IBQuery, System.Generics.Collections;
Type
  TListaDskCashierItems = TObjectList<TDskCashierItems>;

  TControllerDskCashierItems = Class(TControllerBase)
  private

  public
    Registro : TDskCashierItems;
    Lista:TListaDskCashierItems;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function insert:boolean;
    Function delete:boolean;
    function getByKey:Boolean;
    function getAllByKey:boolean;
    procedure getList;
    procedure clear;
  End;

  implementation
{ ControllerDskCashierItems}

procedure TControllerDskCashierItems.clear;
begin

end;

constructor TControllerDskCashierItems.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TDskCashierItems.Create;
  Lista := TListaDskCashierItems.Create;
end;

function TControllerDskCashierItems.delete: boolean;
begin
  Try
    deleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerDskCashierItems.Destroy;
begin
  Lista.DisposeOf;
  Registro.DisposeOf;
  inherited;
end;

function TControllerDskCashierItems.insert: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerDskCashierItems.save: boolean;
begin
  try
    SaveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerDskCashierItems.getAllByKey: boolean;
begin
  getByKey;
end;

function TControllerDskCashierItems.getByKey: Boolean;
begin
  Result := True;
  Self._getByKey(Registro);
end;

procedure TControllerDskCashierItems.getList;
var
  Lc_Qry : TIBQuery;
  LITem : TDskCashierItems;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat('SELECT * ',
                      'FROM TB_CASHIER_ITEMS ',
                      'WHERE TB_CASHIER_ID =:TB_CASHIER_ID '
                    ));
      ParamByName('TB_CASHIER_ID').AsInteger := Registro.CodigoCaixa;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TDskCashierItems.Create;
        get(Lc_Qry,LITem);
        Lista.add(LITem);
        next;
      end;

    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;


end;

end.
