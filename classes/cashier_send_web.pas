unit cashier_send_web;

interface

uses System.SysUtils, System.JSON, general_web,
     ControllerDskCashier, ObjCashier, un_dm;

Type
  TCashierSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerDskCashier;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

{ TGeneralWeb }

constructor TCashierSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerDskCashier.Create(nil);
end;

destructor TCashierSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TCashierSendWeb.GenerateJson;
Var
  LcJson    : TJSONObject;
  LcUser    : TJSONObject;
  LcUserDoc : String;
  LcUserExt : String;
begin
  inherited;
    FCtrl.Registro.Codigo := FCodigo;
    FCtrl.getSincronia;
    if FCtrl.exist then
    Begin
      // Contrato novo REMOVEU o bloco "items" (fechamento por forma de
      // pagamento passou a ter endpoint próprio na onda de movimento
      // financeiro). AUTOR (prompt_indexacao_usuario_firebird.md, decisao
      // 6): o usuario do caixa viaja no bloco `user` (cascata via
      // DM.GetUserSyncRef); sem referencia o bloco nao viaja (tb_userid
      // fica NULL na web).
      LcJson := TJSONObject.Create;
      Try
        LcJson.AddPair('id', TJSONNumber.Create(FCtrl.Registro.Codigo));
        LcJson.AddPair('terminal', TJSONNumber.Create(FTerminal));
        LcJson.AddPair('dtRecord', FormatDateTime('yyyy-mm-dd', FCtrl.Registro.Data));
        if FCtrl.Registro.Abertura = 0 then
          LcJson.AddPair('hrBegin', TJSONNull.Create)
        else
          LcJson.AddPair('hrBegin', FormatDateTime('yyyy-mm-dd hh:nn:ss', FCtrl.Registro.Abertura));
        if FCtrl.Registro.Fechamento = 0 then
          LcJson.AddPair('hrEnd', TJSONNull.Create)
        else
          LcJson.AddPair('hrEnd', FormatDateTime('yyyy-mm-dd hh:nn:ss', FCtrl.Registro.Fechamento));
        LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_CASHIER', 'ID', FCodigo)); // decisao 8: le o DELETED real da tabela

        if DM.GetUserSyncRef(FCtrl.Registro.Usuario, LcUserDoc, LcUserExt) then
        Begin
          LcUser := TJSONObject.Create;
          if LcUserDoc <> '' then
            LcUser.AddPair('userDocument', LcUserDoc)
          else
            LcUser.AddPair('userExternalCode', LcUserExt);
          LcJson.AddPair('user', LcUser);
        End;

        FStrJSon := LcJson.ToJSON;
      Finally
        LcJson.Free;
      End;
  End;
end;


end.
