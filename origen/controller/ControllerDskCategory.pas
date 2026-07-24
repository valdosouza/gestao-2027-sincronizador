unit ControllerDskCategory;

interface

uses System.Classes, System.SysUtils,ControllerBase,
      tblDskCategory,IbQuery,  System.Generics.Defaults, System.Generics.Collections, UnFunctions;

Type
  TListDskCategory = TObjectList<TDskCategory>;

  TControllerDskCategory = Class(TControllerBase)

  private
    Procedure DefineNivel;
  public
    Registro : TDskCategory;
    Lista : TListDskCategory;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function insert:boolean;
    function save:boolean;
    function update:boolean;
    function getByKey:Boolean;
    function getList():boolean;
    function getAutoCreateByGrupo(Institute:Integer;Pc_Grupo: String):Boolean;
    function getAutoCreateBySubGrupo(Institute:Integer;NivelPosicao,Pc_Subgrupo: String):Boolean;
    function InsertByGroupSubGroup():Boolean;
  End;

implementation

{ TControllerDskCategory }

uses Un_Funcoes;

procedure TControllerDskCategory.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerDskCategory.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TDskCategory.Create;
  Lista := TListDskCategory.Create;
end;

procedure TControllerDskCategory.DefineNivel;
Var
  Lc_Nivel : String;
Begin
  Lc_Nivel := StrZero( Registro.codigo,3,0);
  if Trim(Registro.NivelPosicao) ='' then
    Registro.NivelPosicao := Lc_Nivel
  else
    Registro.NivelPosicao := concat(Registro.NivelPosicao , '.' , Lc_Nivel);
end;

destructor TControllerDskCategory.Destroy;
begin
  Registro.DisposeOf;
  Lista.DisposeOf;
  inherited;
end;


function TControllerDskCategory.getAutoCreateByGrupo(Institute:Integer;Pc_Grupo: String): Boolean;
var
  Lc_Qry: TIBQuery;
begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      SQL.Clear;
      SQL.add(concat('SELECT * ',
                     'FROM TB_CATEGORY ',
                     'WHERE DESCRIPTION =:DESCRIPTION AND (CHARACTER_LENGTH(POSIT_LEVEL) =3) ',
                     'ORDER BY POSIT_LEVEL'
      ));
      ParamByName('DESCRIPTION').AsAnsiString := AnsiString(Pc_Grupo);
      Active := True;
      FetchAll;
      exist := ( recordCount>0 );
      if exist then
      Begin
        get(Lc_Qry,Registro);
      End
      else
      Begin
        clearObj(Registro);
        Registro.Estabelecimento := Institute;
        Registro.Descricao := Pc_Grupo;
        Registro.Tipo := 'P';
        Registro.Ativo := 'S';
        self.Insert;
      End;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  end;
end;

function TControllerDskCategory.getAutoCreateBySubGrupo(Institute:Integer;NivelPosicao, Pc_Subgrupo: String): Boolean;
var
  Lc_Qry: TIBQuery;
begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      SQL.Clear;
      SQL.add(concat('SELECT * ',
                     'FROM TB_CATEGORY ',
                     'WHERE DESCRIPTION =:DESCRIPTION ',
                     ' AND (POSIT_LEVEL > :POSIT_LEVEL) ',
                     'ORDER BY POSIT_LEVEL'
      ));
      ParamByName('DESCRIPTION').AsAnsiString := AnsiString(Pc_Subgrupo);
      ParamByName('POSIT_LEVEL').AsAnsiString := AnsiString(NivelPosicao);
      Active := True;
      FetchAll;
      exist := ( recordCount>0 );
      if exist then
      Begin
        get(Lc_Qry,Registro);
      End
      else
      Begin
        clearObj(Registro);
        Registro.Estabelecimento := Institute;
        Registro.Descricao := Pc_Subgrupo;
        Registro.NivelPosicao := NivelPosicao;
        Registro.Tipo := 'P';
        Registro.Ativo := 'S';
        self.Insert;
      End;
    end;
  Finally
    FinalizaQuery( Lc_Qry );
  end;

end;

function TControllerDskCategory.getByKey: Boolean;
begin
  Result := True;
  _getByKey(Registro);
end;

function TControllerDskCategory.getList: boolean;
Var
  Lc_Qry : TIBQuery;
  LcCat : TDskCategory;
Begin
  Result := True;
  Lc_Qry := GeraQuery;
  Try
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM tb_category ',
                'order by POSIT_LEVEL '));
      Active := True;
      First;
      while not eof do
      Begin
        LcCat := TDskCategory.Create;
        get(Lc_Qry,LcCat);
        Lista.Add(LcCat);
        Next;
      End;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

function TControllerDskCategory.insert: boolean;
begin
  try
    if registro.Codigo = 0 then
      registro.Codigo := Generator('GN_CATEGORY');
    DefineNivel;
    insertObj(Registro);
    REsult := True;
  Except
    REsult := False;
  end;
end;

function TControllerDskCategory.InsertByGroupSubGroup: Boolean;
begin
  Result := True;
end;

function TControllerDskCategory.save: boolean;
begin
  try
    SaveObj(registro);
    result := True;
  except
    result := False;
  end;
end;

function TControllerDskCategory.update: boolean;
begin
  try
    updateObj(registro);
    result := True;
  except
    result := False;
  end;

end;

end.
