unit un_sincroniza;

interface

uses
   SysUtils, Classes, DB, IBCustomDataSet, IBTable, IBDatabase, IBQuery,
   IBUpdateSQL, IBSQL,forms,dialogs, windows,Graphics,ExtCtrls,Gauges,
   jpeg, pngimage, ControllerPedido, un_sistema, un_receive_from_web_server,
  un_dm,  un_send_to_web_server, un_base_setes,
   Vcl.StdCtrls,  UnFunctions;


type
  TSincroniza = class(TComponent)

  private
    { Private declarations }
    FListBoxSend: TlistBox;
    FListBoxReceive: TlistBox;
    FProgresso: TGauge;

    FReceiveFromWEb : Boolean;
    ReceiveFromWeb  : TReceiveFromWebServer;

    FSendToWEb : Boolean;
    SendToWeb   : TSendToWebServer;

    procedure setFListBoxSend(const Value: TlistBox);
    procedure setFListBoxReceive(const Value: TlistBox);
    procedure setFProgresso(const Value: TGauge);
  protected

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure execute;
    property Progresso : TGauge read FProgresso write setFProgresso;
    property ListBoxSend :TlistBox read FListBoxSend write setFListBoxSend ;
    property ListBoxReceive :TlistBox read FListBoxReceive write setFListBoxReceive ;
  end;

implementation

{ TSincroniza }

constructor TSincroniza.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TSincroniza.Destroy;
begin
  if FReceiveFromWEb then ReceiveFromWeb.DisposeOf;
  if FSendToWEb then SendToWeb.DisposeOf;
  inherited;
end;

procedure TSincroniza.execute;
Var
  LcUrl : String;
  LcApiKey : String;
begin
  // D12: institution/CNPJ nao sao mais configurados no cliente - o servidor
  // resolve institution/schema pela X-Api-Key.
  FReceiveFromWEb     := ( Fc_Aq_Geral('L','SISWEB', 'ReceiveWebServer','S') = 'S');
  FSendToWEb          := ( Fc_Aq_Geral('L','SISWEB', 'SendToWebServer','S') = 'S');
  LcUrl               := Fc_Aq_Geral('L', 'SISWEB', 'FPathURL','0');
  // D12 (revisão do sincronizador): chave de instalação — cadastrada em
  // setes_central.tb_sync_api_key, configurada aqui junto com a URL.
  LcApiKey            := Fc_Aq_Geral('L','SISWEB', 'FApiKey','');


  //Recebe dados do Servidor  - Pedidos para Terminal 1 / Mercadoria para outros terminais
  if FReceiveFromWEb then
  Begin
    ReceiveFromWeb := TReceiveFromWebServer.Create(self);
    ReceiveFromWeb.ListBox := FListBoxReceive;
    ReceiveFromWeb.progresso := FProgresso;
    ReceiveFromWeb.URL := LcUrl;
    ReceiveFromWeb.ApiKey := LcApiKey;
    ReceiveFromWeb.Database := DM.IBD_Gestao;

    ReceiveFromWeb.Execute;
  End;

  // Parada graciosa pedida durante o recebimento: nao inicia o envio
  if TBaseSetes.PararSolicitado then
  Begin
    FSendToWEb := False;
    Exit;
  End;

  if FSendToWEb then
  Begin
    SendToWeb := TSendToWebServer.Create(self);
    SendToWeb.ListBox := FListBoxSend;
    SendToWeb.progresso := FProgresso;
    SendToWeb.URL := LcUrl;
    SendToWeb.ApiKey := LcApiKey;
    SendToWeb.Database := DM.IBD_Gestao;

    SendToWeb.Execute;
  End;
end;


procedure TSincroniza.setFListBoxReceive(const Value: TlistBox);
begin
  FListBoxReceive := Value;
end;

procedure TSincroniza.setFListBoxSend(const Value: TlistBox);
begin
  FListBoxSend := Value;
end;

procedure TSincroniza.setFProgresso(const Value: TGauge);
begin
  FProgresso := Value;
end;

end.
