unit ControllerSincronia;

interface
uses IBX.IBDatabase,Classes, Vcl.Grids,IBQuery, SysUtils,ControllerBase,
      Un_sistema,Un_funcoes,Un_Regra_Negocio, tblSincronia ,ControllerDskRestMenu,
      Generics.Collections, ControllerEstoque;


Type
  // Renomeado de TListaSincronia (decisao 4): o nome agora pertence ao model
  // do catalogo TB_LISTA_SINCRONIA (tblListaSincronia.pas).
  TListaFilaSincronia = TObjectList<TSincronia>;

  TControllerSincronia = Class(TControllerBase)
  private
    FTipo: String;
    function getSqlAtualiza:String;
    function getSqlDeleta:String;

    function SqlPadraoAtualiza:String;
    function SqlPadraoDeleta:String;

    function SqlTBPedidoAtualiza(Tipo:String):String;
    function SqlTBPedidoDeleta(Tipo:String):String;

    function SqlTBNotaFiscalAtualiza(Tipo:String):String;
    function SqlTBNotaFiscalDeleta(Tipo:String):String;

    procedure setFTipo(const Value: String);


  protected

  public
    Registro : TSincronia;
    Lista :TListaFilaSincronia;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function save:boolean;
    function saveReturn:boolean;
    function insert:boolean;
    function update:boolean;
    procedure Clear;
    procedure getById;
    procedure getList;
    procedure getListProduto;
    procedure deleteAfterSyncProdutos;
    procedure deleteBeforeSyncProdutos;
    procedure deleteByTable;
    procedure deleteByTableRegistro;
    procedure getListTrayImage;
    procedure getListForRetaguarda;
    Function delete:boolean;
    function deleteAll:Boolean;
    procedure DeleteAfterRestMenu;
    // Limpeza automatica da fila (decisao 9): remove registros ja processados
    // com sucesso (SRC_LOG = 'ok') ha mais de 48 horas. Disparada 1x por dia
    // pelo loop do Sincronizador (ver uMain).
    procedure DeleteProcessadosAntigos;
    property Tipo : String read FTipo write setFTipo;
  End;

implementation

{ TControllerEmpresa }

procedure TControllerSincronia.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerSincronia.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TSincronia.Create;
  Lista := TListaFilaSincronia.Create;
end;

function TControllerSincronia.delete: boolean;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                    'DELETE ',
                    'FROM tb_sincronia ',
                    'WHERE ( SRC_TABELA   =:SRC_TABELA ) ',
                    ' AND  ( SRC_CHAVE    =:SRC_CHAVE ) ',
                    ' AND  ( SRC_REGISTRO =:SRC_REGISTRO ) '
      ));
      ParamByName('SRC_TABELA').AsString    := Registro.Tabela;
      ParamByName('SRC_CHAVE').AsString     := Registro.Chave;
      ParamByName('SRC_REGISTRO').AsInteger  := Registro.Registro;
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.deleteAfterSyncProdutos;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                'DELETE FROM tb_sincronia ',
                'WHERE SRC_CODIGO IN( ',
                'select src_codigo ',
                'FROM tb_sincronia S ',
                'WHERE S.src_registro =:PRO_CODIGO ',
                'UNION ',
                'select src_codigo ',
                'FROM tb_sincronia S ',
                '   INNER JOIN tb_estoque E ',
                '   ON (E.est_codigo = S.src_registro) ',
                'WHERE e.est_codpro =:PRO_CODIGO ',
                'UNION ',
                'select src_codigo ',
                'FROM tb_sincronia S ',
                '   INNER JOIN tb_preco p ',
                '   ON (p.prc_codigo = S.src_registro) ',
                'WHERE p.prc_codpro =:PRO_CODIGO ',
                ')'
      ));
      ParamByName('PRO_CODIGO').AsInteger:= Registro.Registro;
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

function TControllerSincronia.deleteAll: Boolean;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                    'DELETE ',
                    'FROM tb_sincronia '
      ));
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;

end;

procedure TControllerSincronia.DeleteAfterRestMenu;
var
  I : Integer;
  Lc_RestMenu : TControllerDskRestMenu;
begin
  TRy
    Lc_RestMenu := TControllerDskRestMenu.Create(nil);
    Lc_RestMenu.Registro.Codigo := Self.Registro.Registro;
    Lc_RestMenu.getbyId;
    Lc_RestMenu.getListbyDescription;
    for I := 0 to Lc_RestMenu.Lista.Count -1 do
    Begin
      Self.registro.Tabela:= 'TB_PRODUTO';
      Self.registro.Registro := Lc_RestMenu.Lista[I].Codigo;
      self.deleteByTableRegistro;
    End;
  Finally
    Lc_RestMenu.DisposeOf;
  End;

end;

procedure TControllerSincronia.DeleteProcessadosAntigos;
var
  Lc_Qry : TIBQuery;
begin
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      // DATEADD funciona igual no Firebird 2.5 e 5.0 (decisao 10)
      sql.add( concat(
                  'DELETE FROM tb_sincronia ',
                  'WHERE ( UPPER(SRC_LOG) = ''OK'' ) ',
                  '  and ( SRC_TIME < DATEADD(-48 HOUR TO CURRENT_TIMESTAMP) ) '
      ));
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.deleteBeforeSyncProdutos;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                  'delete from tb_sincronia where src_codigo in ( ',
                  'select s.src_codigo ', //--, S.src_tabela, S.src_registro, s.src_time,LT.id
                  'FROM tb_sincronia s ',
                  '    inner join tb_produto pd ',
                  '    on (pd.pro_codigo = s.src_registro) ',
                  '    left outer join tb_loja_tray lt ',
                  '    on (lt.id = s.src_registro)and (lt.tabela  =''TB_PRODUTO'') ',
                  'WHERE s.src_tabela =''TB_PRODUTO'' ',
                  'and pd.pro_internet = ''N''  ',
                  'and lt.ID is null ',
                  'UNION ',
                  'select s.src_codigo ', //--, S.src_tabela, e.est_codpro src_registro, s.src_time ,LT.id
                  'FROM tb_sincronia s ',
                  '   INNER JOIN tb_estoque e ',
                  '   ON (e.est_codigo = s.src_registro) ',
                  '   inner join tb_produto pd ',
                  '    on (pd.pro_codigo = e.est_codpro) ',
                  '    left outer join tb_loja_tray lt ',
                  '    on (lt.id = s.src_registro) and (lt.tabela  =''TB_ESTOQUE'') ',
                  'WHERE s.src_tabela =''TB_ESTOQUE'' ',
                  'and pd.pro_internet = ''N'' ',
                  'and lt.ID is null ',
                  'UNION ',
                  'select s.src_codigo ', //--, S.src_tabela, pc.prc_codpro src_registro, s.src_time,LT.id
                  'FROM tb_sincronia s ',
                  '   INNER JOIN tb_preco pc ',
                  '   ON (pc.prc_codigo = s.src_registro) ',
                  '   inner join tb_produto pd ',
                  '   on (pd.pro_codigo = pc.prc_codpro) ',
                  '    left outer join tb_loja_tray lt ',
                  '    on (lt.id = s.src_registro) and (lt.tabela  =''TB_PRECO'') ',
                  'WHERE s.src_tabela = ''TB_PRECO'' ',
                  'and pd.pro_internet = ''N'' ',
                  'and lt.ID is null ',
                  ') '
      ));
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.deleteByTable;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                  'delete from tb_sincronia  ',
                  'WHERE (src_tabela = :src_tabela) '
      ));
      ParamByName('src_tabela').AsString := Registro.Tabela;
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.deleteByTableRegistro;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                  'delete from tb_sincronia  ',
                  'WHERE (src_tabela = :src_tabela) ',
                  ' and (SRC_REGISTRO=:SRC_REGISTRO) '
      ));
      ParamByName('src_tabela').AsString := Registro.Tabela;
      ParamByName('src_registro').AsInteger := Registro.Registro;
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;


end;

destructor TControllerSincronia.Destroy;
begin
  Lista.Clear;
  FreeAndNil(Lista);
  FreeAndNil(Registro);
  inherited;
end;



function TControllerSincronia.save: boolean;
begin
  SaveObj(Registro);
end;

function TControllerSincronia.saveReturn: boolean;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin  //Seleciona REgistros do Servidor
      sql.add( concat(
                'UPDATE TB_SINCRONIA s SET ',
                's.src_log =:src_log ',
                'WHERE s.src_registro=:src_registro ',
                'and s.SRC_TABELA =:SRC_TABELA '
          ));
      ParamByName('SRC_TABELA').AsString := Registro.Tabela;
      ParamByName('src_log').AsString := Registro.LogResult;
      ParamByName('src_registro').AsInteger := Registro.Registro;
      ExecSQL;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;

end;


procedure TControllerSincronia.setFTipo(const Value: String);
begin
  FTipo := Value;
end;

function TControllerSincronia.SqlPadraoAtualiza: String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
//              'WHERE ( cast (substring( (cast (SRC_TIME as varchar(25))) from 1 for 19) as timeStamp) >=:SRC_TIME ) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER <> ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = ''''))  ',
              'GROUP BY 1,2,3 ',
              'ORDER BY 4 ASC '
      );
end;

function TControllerSincronia.SqlPadraoDeleta: String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
//              'WHERE ( cast (substring( (cast (SRC_TIME as varchar(25))) from 1 for 19) as timeStamp) >=:SRC_TIME ) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER = ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = ''''))  ',
              'GROUP BY 1,2,3 ',
              'ORDER BY 4 ASC '
           );

end;



function TControllerSincronia.SqlTBNotaFiscalAtualiza(Tipo: String): String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
              '    inner join TB_NOTA_FISCAL N ',
              '    on (N.NFL_codigo = s.src_registro) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER <> ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = '''')) ');
  if ( Tipo = 'AVULSA') then
  Begin
    Result := concat(Result,
                    '  AND (n.nfl_tipo = ''EM'') ');
  End
  else
  Begin
    Result := concat(Result,
                    '  AND (n.nfl_tipo <> ''EM'') ');
  End;
  Result := concat(Result,
                  'GROUP BY 1,2,3 ',
                  'ORDER BY 4 ASC ');

end;

function TControllerSincronia.SqlTBNotaFiscalDeleta(Tipo: String): String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
              '    inner join TB_NOTA_FISCAL N ',
              '    on (N.NFL_codigo = s.src_registro) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER = ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = '''')) ');
  if ( Tipo <> 'EM') then
  Begin
    Result := concat(Result,
                    '  AND (n.nfl_tipo <> ''',tipo,''') ');
  End
  else
  Begin
    Result := concat(Result,
                    '  AND (n.nfl_tipo = ''',tipo,''') ');
  End;
  Result := concat(Result,
                  'GROUP BY 1,2,3 ',
                  'ORDER BY 4 ASC ');

end;

function TControllerSincronia.SqlTBPedidoAtualiza(Tipo:String): String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
              '    inner join tb_pedido p ',
              '    on (p.ped_codigo = s.src_registro) ',
              '    INNER JOIN tb_nota_fiscal N ',
              '    ON (N.nfl_codped = P.ped_codigo) ',

//              'WHERE ( cast (substring( (cast (SRC_TIME as varchar(25))) from 1 for 19) as timeStamp) >=:SRC_TIME ) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER <> ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = '''')) ',
              '  AND (p.ped_tipo = ',tipo,') ',
              'GROUP BY 1,2,3 ',
              'ORDER BY 4 ASC '
  );
end;

function TControllerSincronia.SqlTBPedidoDeleta(Tipo:String): String;
begin
  Result := concat(
              'SELECT ',
              '    SRC_REGISTRO, ',
              '    SRC_TABELA, ',
              '    SRC_CHAVE, ',
              '    MAX(SRC_TIME) SRC_TIME ',
              'FROM tb_sincronia s ',
              '    inner join tb_pedido p ',
              '    on (p.ped_codigo = s.src_registro) ',
              '    INNER JOIN tb_nota_fiscal N ',
              '    ON (N.nfl_codped = P.ped_codigo) ',
              //              'WHERE ( cast (substring( (cast (SRC_TIME as varchar(25))) from 1 for 19) as timeStamp) >=:SRC_TIME ) ',
              '  WHERE ( src_tabela =:SRC_TABELA ) ',
              '  and (SRC_OPER = ''D'' ) ',
              '  and  ((SRC_LOG is null) or (SRC_LOG = '''')) ',
              '  AND (p.ped_tipo = ',tipo,') ',
              'GROUP BY 1,2,3 ',
              'ORDER BY 4 ASC '
  );
end;

function TControllerSincronia.update: boolean;
begin
  UpdateObj(Registro);
end;


procedure TControllerSincronia.getById;
begin
  _getByKey(Registro);
end;

procedure TControllerSincronia.getList;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Pegar os itens Para Deletar
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add(getSqlDeleta);
      //ParamByName('SRC_TIME').AsDateTime := Registro.Tempo;
      ParamByName('SRC_TABELA').AsString := Registro.Tabela;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LcLista := TSincronia.Create;
        LcLista.Codigo   := 0;
        LcLista.Tabela   := FieldByNAme('SRC_TABELA').AsString;
        LcLista.Chave    := FieldByNAme('SRC_CHAVE').AsString;
        LcLista.Operacao := 'D';
        LcLista.Tempo    := FieldByNAme('SRC_TIME').AsDateTime;
        LcLista.Registro := FieldByNAme('SRC_REGISTRO').AsInteger;
        Lista.add(LcLista);
        next;
      end;
      //Pegar os itens Para Atualizar
      Active := False;
      sql.Clear;
      sql.add( getSqlAtualiza);
      //ParamByName('SRC_TIME').AsDateTime := Registro.Tempo;
      ParamByName('SRC_TABELA').AsString := Registro.Tabela;
      Active := True;
      FetchAll;
      First;
      while not eof do
      Begin
        LcLista := TSincronia.Create;
        LcLista.Codigo   := 0;
        LcLista.Tabela   := FieldByNAme('SRC_TABELA').AsString;
        LcLista.Chave    := FieldByNAme('SRC_CHAVE').AsString;
        LcLista.Operacao := 'U';
        LcLista.Tempo    := FieldByNAme('SRC_TIME').AsDateTime;
        LcLista.Registro := FieldByNAme('SRC_REGISTRO').AsInteger;
        Lista.add(LcLista);
        next
      End;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.getListForRetaguarda;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
 //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                    'SELECT ',
                    '    SRC_REGISTRO, ',
                    '    SRC_TABELA, ',
                    '    SRC_CHAVE, ',
                    '    MAX(SRC_TIME) SRC_TIME ',
                    'FROM tb_sincronia s ',
                    'WHERE ( SRC_TIME > :SRC_TIME ) ',
                    '  and ( src_tabela =:SRC_TABELA ) ',
                    '  and ( SRC_OPER <> ''D'' ) ',
                    'GROUP BY 1,2,3 ',
                    'ORDER BY 4 ASC '
      ));

      ParamByName('SRC_TIME').AsDateTime := Registro.Tempo;
      ParamByName('SRC_TABELA').AsString := Registro.Tabela;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LcLista := TSincronia.Create;
        LcLista.Codigo   := 0;
        LcLista.Tabela   := FieldByNAme('SRC_TABELA').AsString;
        LcLista.Chave    := FieldByNAme('SRC_CHAVE').AsString;
        LcLista.Operacao := 'U';
        LcLista.Tempo    := FieldByNAme('SRC_TIME').AsDateTime;
        LcLista.Registro := FieldByNAme('SRC_REGISTRO').AsInteger;
        Lista.add(LcLista);
        next;
      end;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.getListProduto;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  //Seleciona REgistros do Servidor
  try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      active := False;
      sql.Clear;
      sql.add( concat(
                'select src_registro, MAX(SRC_TIME) SRC_TIME ',
                'FROM ( ',
                'select s.src_registro, s.src_time ',
                'FROM tb_sincronia s ',
                'WHERE s.src_tabela =''TB_PRODUTO'' ',
                'UNION ',
                'select e.est_codpro src_registro, s.src_time ',
                'FROM tb_sincronia s ',
                '   INNER JOIN tb_estoque e ',
                '   ON (e.est_codigo = s.src_registro) ',
                'WHERE s.src_tabela =''TB_ESTOQUE'' ',
                'UNION ',
                'select p.prc_codpro src_registro, s.src_time ',
                'FROM tb_sincronia s ',
                '   INNER JOIN tb_preco p ',
                '   ON (p.prc_codigo = s.src_registro) ',
                'WHERE s.src_tabela = ''TB_PRECO'' ',
                ') ',
                'GROUP BY 1 '
      ));
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LcLista := TSincronia.Create;
        LcLista.Codigo   := 0;
        LcLista.Tabela   := 'TB_PRODUTO';
        LcLista.Chave    := 'PRO_CODIGO';
        LcLista.Operacao := 'U';
        LcLista.Tempo    := FieldByNAme('SRC_TIME').AsDateTime;
        LcLista.Registro := FieldByNAme('SRC_REGISTRO').AsInteger;
        Lista.add(LcLista);
        next;
      end;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

procedure TControllerSincronia.getListTrayImage;
var
  Lc_Qry : TIBQuery;
  LcLista : TSincronia;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin  //Seleciona REgistros do Servidor
      sql.add( concat(
                  'SELECT DISTINCT i.table_id, max(s.src_time) src_time ',
                  'FROM tb_images i ',
                  '  inner join tb_sincronia s ',
                  '  on (i.id = s.src_registro) ',
                  'where ( s.src_tabela =:src_tabela) ',
                  ' and ( s.src_time >= :src_time ) ',
                  'group by 1 '
          ));

      ParamByName('SRC_TABELA').AsString := Registro.Tabela;
      ParamByName('src_time').AsDateTime := Registro.Tempo;
      Active := True;
      FetchAll;
      First;
      Lista.Clear;
      while not eof do
      Begin
        LcLista := TSincronia.Create;
        with LcLista do
        Begin
          Codigo := 0;
          Tabela := 'TB_IMAGES';
          Chave := 'PRO_CODIGO';
          Operacao := 'U';
          Tempo := fieldByName('SRC_TIME').asDateTime;
          Registro := fieldByName('table_id').asInteger;
        end;
        Lista.add(LcLista);
        next;
      end;
    end;
  finally
    FinalizaQuery(Lc_Qry);
  end;
end;

function TControllerSincronia.getSqlAtualiza: String;
begin
  if (Registro.Tabela = 'TB_PEDIDO') THEN
  Begin
    Result := SqlTBPedidoAtualiza(FTipo);
  End
  else
  if (Registro.Tabela = 'TB_NOTA_FISCAL') THEN
  Begin
    Result := SqlTBNotaFiscalAtualiza(FTipo);
  End
  else
  Begin
    Result := SqlPadraoAtualiza();
  End;
end;

function TControllerSincronia.getSqlDeleta: String;
begin
  if (Registro.Tabela = 'TB_PEDIDO') THEN
  Begin
    Result := SqlTBPedidoDeleta(FTipo);
  End
  else
  if (Registro.Tabela = 'TB_NOTA_FISCAL') THEN
  Begin
    Result := SqlTBNotaFiscalDeleta(FTipo);
  End
  else
  Begin
    Result := SqlPadraoDeleta();
  End;
end;

function TControllerSincronia.insert: boolean;
begin
  InsertObj(Registro);
end;

end.
