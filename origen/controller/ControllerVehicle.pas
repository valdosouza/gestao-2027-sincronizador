unit ControllerVehicle;

interface

uses IBX.IBDatabase,Classes, Vcl.Grids,IBQuery, SysUtils,ControllerBase,
      Un_sistema,Un_funcoes,Un_Regra_Negocio, tblVehicle ,Un_MSg,
      Forms, ControllerUf, ControllerPedido,ControllerNotaFiscal;

Type
  TControllerVehicle = Class(TControllerBase)
  private

  public
    Registro : TVehicle;
    Uf : Tcontrolleruf;
    Pedido : TControllerPedido;
    NotaFiscal : TControllerNotaFiscal;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function salva:boolean;

    procedure getbyId;
    Function delete:boolean;
    function getMarcaModelo:String;
    procedure clear;
  End;

implementation

uses RN_Estoque, RN_Produto, Un_VehicleSo;

procedure TControllerVehicle.clear;
begin
  clearObj(Registro);
end;

constructor TControllerVehicle.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TVehicle.Create;
  Uf := Tcontrolleruf.Create(self);
  Pedido := TControllerPedido.Create(self);
  NotaFiscal := TControllerNotaFiscal.Create(self);
end;

function TControllerVehicle.delete: boolean;
begin
  Try
    DeleteObj(Registro);
    Result := True;
  Except
    Result := False;
  End;
end;

destructor TControllerVehicle.Destroy;
begin
  NotaFiscal.DisposeOf;
  Pedido.DisposeOf;
  Registro.DisposeOf;
  Uf.DisposeOf;
  inherited;
end;


function TControllerVehicle.salva: boolean;
begin
  if existObj(Registro) then
  Begin
    UpdateObj(Registro);
  End
  else
  Begin
    Registro.Codigo := Generator('GN_veiculo');
    InsertObj(Registro);
  End;
  SaveObj(Registro);
end;

procedure TControllerVehicle.getById;
begin
  _getByKey(Registro);
end;

function TControllerVehicle.getMarcaModelo: String;
Var
  Lc_Qry: TIBQuery;
Begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    BEgin
      Active := False;
      SQL.Clear;
      sql.Add(concat(
              'select (ma.mrc_descricao || ',''' - ''',' || mo.mod_descricao) marcamodelo ',
              'from tb_veiculo v ',
              '  inner join tb_marca_veiculo ma ',
              '  on (ma.mrc_codigo = v.vei_codmrc) ',
              '  inner join tb_modelo mo ',
              '  on (mo.mod_codigo = v.vei_codmod) ',
               'where v.vei_placa =:vei_placa '
       ));
       ParamByName('vei_placa').AsString := Registro.Placa;
       Active := True;
       Result := FieldByName('marcamodelo').AsString;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;




end.


