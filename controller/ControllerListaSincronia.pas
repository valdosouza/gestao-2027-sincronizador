unit ControllerListaSincronia;

interface

uses
  System.Classes,Generics.Collections, IBX.IBDatabase,tblTabelaParaSincronizar,
  IBX.IBQuery, ControllerBase, IBX.IBScript;

Type

  TListaListaParaSincronizar = TObjectList<TTabelaParaSincronizar>;

  TControllerListaSincronia = Class(TControllerBase)
  private
    FTempoMinimo: TDateTime;


    procedure _getListaReceber;
    procedure _getListaEnviar;
    procedure setFTempoMinimo(const Value: TDateTime);


  public
    registro : TTabelaParaSincronizar;
    ListaReceber :TListaListaParaSincronizar;
    ListaEnviar :TListaListaParaSincronizar;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure getListaReceber;
    procedure getListaEnviar;


    function SincronizaTabela:Boolean;
    property TempoMinimo : TDateTime read FTempoMinimo write setFTempoMinimo;



  End;

implementation

uses ControllerSincronia;

{ TControllerListaSincronia }

constructor TControllerListaSincronia.Create(AOwner: TComponent);
begin
  inherited;
  registro := TTabelaParaSincronizar.Create;
  ListaReceber := TListaListaParaSincronizar.create;
  ListaEnviar  := TListaListaParaSincronizar.create;
end;

destructor TControllerListaSincronia.Destroy;
begin
  Registro.Disposeof;
  ListaReceber.DisposeOf;
  ListaEnviar.DisposeOf;
  inherited;
end;



procedure TControllerListaSincronia.getListaEnviar;
Begin
  _getListaEnviar;
end;

procedure TControllerListaSincronia.getListaReceber;
Begin
  _getListaReceber;
end;




procedure TControllerListaSincronia.setFTempoMinimo(const Value: TDateTime);
begin
  FTempoMinimo := Value;
end;


function TControllerListaSincronia.SincronizaTabela: Boolean;
var
  Lc_Qry : TIBQuery;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE ( DESC_TABELA =:DESC_TABELA ) ',
                '  and ( WAY = ''E'' ) ',
                '  and ( SET_ON = ''S'') ' //Enviar do PDV para Retaguarda
      ));
      ParamByName('DESC_TABELA').AsString := Registro.Tabela;
      Active := True;
      FetchAll;
      Result := RecordCount > 0;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia._getListaEnviar;
var
  Lc_Qry : TIBQuery;
  LITem : TTabelaParaSincronizar;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE WAY = ''E'' ',
                ' and (SET_ON = ''S'') ',//Enviar do PDV para Retaguarda
                'ORDER BY seq '
      ));
      Active := True;
      FetchAll;
      First;
      ListaEnviar.Clear;
      while not eof do
      Begin
        LITem := TTabelaParaSincronizar.Create;
        get(Lc_Qry,LITem);
        ListaEnviar.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

procedure TControllerListaSincronia._getListaReceber;
var
  Lc_Qry : TIBQuery;
  LITem : TTabelaParaSincronizar;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      sql.add(concat(
                'SELECT * ',
                'FROM TB_LISTA_SINCRONIA ',
                'WHERE WAY = ''R'' ', //Receber da Retaguarda
                ' AND SET_ON = ''S'' ',
                'ORDER BY seq '
      ));
      Active := True;
      FetchAll;
      First;
      ListaReceber.Clear;
      while not eof do
      Begin
        LITem := TTabelaParaSincronizar.Create;
        get(Lc_Qry,LITem);
        ListaReceber.add(LITem);
        next;
      end;
    end;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
