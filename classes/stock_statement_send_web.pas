unit stock_statement_send_web;


interface

uses System.SysUtils,general_web,REST.Json,
     ControllerCtrlEstoque, tblStockStatement;

Type
   TStockStatementSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerCtrlEstoque;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TStockStatementSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerCtrlEstoque.Create(nil);
end;

destructor TStockStatementSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TStockStatementSendWeb.GenerateJson;
Var
  LcObj: TStockStatement;
begin
  inherited;
    FCtrl.Clear;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getbyId;
    if FCtrl.exist then
    Begin
      LcObj                 := TStockStatement.Create;
      LcObj.Codigo          := FCtrl.Registro.Codigo;
      LcObj.Estabelecimento := FInstitutionDestino;
      LcObj.Terminal        := FTerminal;
      LcObj.Ordem           := FCtrl.Registro.Ordem;
      LcObj.OrdemItem       := FCtrl.Registro.Item;
      LcObj.Estoque         := FCtrl.Registro.Estoque;
//       if FDESCRICAO = 'SERVER' then
//       LcObj.Local := 'Desktop'
//         else
//       LcObj.Local := concat('Terminal ', intToStr(FDevice));
      LcObj.Tipo          := FCtrl.Registro.Tipo;
      LcObj.DataRegistro  := FCtrl.Registro.Data;
      LcObj.Direcao       := FCtrl.Registro.operacao;
      LcObj.Mercadoria    := FCtrl.Registro.Produto;
      LcObj.Quantidade    := FCtrl.Registro.Quantidade;

      // Envia para o servidor e pega o retorno
       FStrJson := TJson.ObjectToJsonString(LcObj);
//    LcStrJSon := FDataCM.SMStockStatementClient.save(LcStrJSon);
//    Result := TJson.JsonToObject<TResult>(LcStrJSon);
  End;
end;


end.

