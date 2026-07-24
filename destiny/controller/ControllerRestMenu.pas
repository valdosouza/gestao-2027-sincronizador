unit ControllerRestMenu;

interface
uses System.Classes, System.SysUtils,BaseController,
      Md5, FireDAC.Stan.Param,tblRestMenu, ControllerProduct,
      ControllerRestMenuHasProduct, FireDAC.Comp.Client,TypesCollection;

Type

  TControllerRestMenu = Class(TBaseController)
    procedure clear;
  private

  public
    Registro : TRestMenu;
    HasProducto : TControllerRestMenuHasProduct;
    Lista : TListRestMenu;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function insert:boolean;
    function update:boolean;
    function delete: boolean;
    function getByKey:Boolean;
    function getByDescription:Boolean;
    function getlist:Boolean;
    procedure UpdateImage;
  End;

implementation

procedure TControllerRestMenu.clear;
begin
  ClearObj(Registro);
end;

constructor TControllerRestMenu.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TRestMenu.Create;
  HasProducto := TControllerRestMenuHasProduct.create(Self);
  Lista := TListRestMenu.Create;
end;

function TControllerRestMenu.delete: boolean;
begin
  deleteObj(Registro);
end;

destructor TControllerRestMenu.Destroy;
begin
  Lista.disposeOf;
  HasProducto.disposeOf;
  Registro.disposeOf;
  inherited;
end;


function TControllerRestMenu.insert: boolean;
begin
  try
    Registro.Codigo := getNextByField(Registro,'id',Registro.Estabelecimento);
    insertObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerRestMenu.save: boolean;
begin
  try
    saveObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;

function TControllerRestMenu.update: boolean;
begin
  try
    UpdateObj(Registro);
    Result := true;
  except
    Result := False;
  end;
end;


procedure TControllerRestMenu.UpdateImage;
Var
  Lc_Qry : TFdQuery;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      SQL.Clear;
      SQL.Add(concat(
                'update tb_rest_menu set ',
                ' link_url =:link_url ',
                'Where ( tb_institution_id =:tb_institution_id ) ',
                ' and  ( id =:id ) '
      ));
      ParamByName('tb_institution_id').AsInteger  := REgistro.Estabelecimento;
      ParamByName('id').AsInteger                 := Registro.Codigo;
      ParamByName('link_url').AsString            := Registro.linkUrl;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;


end;

function TControllerRestMenu.getByDescription: Boolean;
Var
  Lc_Qry : TFDQuery;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      Active := False;
      sql.Clear;
      sql.Add(concat(
              'select * ',
              'from tb_rest_menu r ',
              'where r.description =:description ',
              ' and  r.tb_institution_id=:tb_institution_id ',
              ' and  r.tb_rest_group_id =:tb_rest_group_id '
              ));
      paramByName('tb_institution_id').AsInteger := Registro.Estabelecimento;
      paramByName('description').asString := Registro.Description;
      paramByName('tb_rest_group_id').AsInteger := Registro.Grupo;
      Lc_Qry.Active := True;
      Lc_Qry.FetchAll;
      exist  := ( Lc_Qry.RecordCount > 0 );
      if exist then get(Lc_Qry,Registro) ;
    End;
  Finally
    finalizaQuery(Lc_Qry);
  End;
end;

function TControllerRestMenu.getByKey: Boolean;
begin
  _getByKey(Registro);
end;

function TControllerRestMenu.getlist: Boolean;
var
  Lc_Qry : TFDQuery;
  LITem : TRestMenu;
begin
  Try
    Lc_Qry := createQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                'select rm.* ',
                'from tb_rest_menu rm ',
                '  inner join tb_rest_group rg ',
                '  on (rg.id = rm.tb_rest_group_id) ',
                '    and (rg.tb_institution_id = rm.tb_institution_id) ',
                'where ( rg.tb_institution_id =:tb_institution_id ) '
      ));

      //Incrementa SQL
      if Registro.Grupo > 0 then
        sql.add(' and ( tb_rest_group_id =:tb_rest_group_id ) ');

      //Passagem de parametros
      parambyname('tb_institution_id').AsInteger := Registro.Estabelecimento;

      if Registro.Grupo > 0 then
        parambyname('tb_rest_group_id').AsInteger := Registro.Grupo;

      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LITem := TRestMenu.Create;
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
