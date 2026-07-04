unit stock_list_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerEstoques,tblStockList;

Type
  TStockListSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerEstoques;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TStockListSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerEstoques.Create(nil);
end;

destructor TStockListSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TStockListSendWeb.GenerateJson;
Var
  LcObj: TStockList;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyId;
  if FCtrl.exist then
  Begin
 // Preenche o Objeto para enviar para o servidor
    LcObj                 := TStockList.Create;
    LcObj.Codigo          := FCtrl.Registro.Codigo;
    LcObj.Estabelecimento := FInstitutionDestino;
    LcObj.Descricao       := FCtrl.Registro.Descricao;
    LcObj.Tipo            := FCtrl.Registro.Principal;
    FStrJson              := TJson.ObjectToJsonString(LcObj);
  End;
end;


end.

