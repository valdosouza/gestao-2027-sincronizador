unit un_sincroniza;

interface

uses
   SysUtils, Classes, DB, IBCustomDataSet, IBTable, IBDatabase, IBQuery,
   IBUpdateSQL, IBSQL,forms,dialogs, windows,Graphics,ExtCtrls,Gauges,
   jpeg, pngimage, ControllerPedido, un_sistema, un_receive_from_web_server,
  un_dm,  un_send_to_web_server,
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
  LcInstitutionOrigem : Integer;
  LcUrl : String;
  LcCnpj : String;
begin
  FReceiveFromWEb     := ( Fc_Aq_Geral('L','SISWEB', 'ReceiveWebServer','S') = 'S');
  FSendToWEb          := ( Fc_Aq_Geral('L','SISWEB', 'SendToWebServer','S') = 'S');
  LcInstitutionOrigem := StrToIntDef(Fc_Aq_Geral('L','SISWEB', 'institution_origem','1'),1);
  LcUrl               := Fc_Aq_Geral('L', 'SISWEB', 'FPathURL','0');
  LcCnpj              := Fc_Aq_Geral('L','SISWEB', 'CNPJ','');


  //Recebe dados do Servidor  - Pedidos para Terminal 1 / Mercadoria para outros terminais
  if FReceiveFromWEb then
  Begin
    ReceiveFromWeb := TReceiveFromWebServer.Create(self);
    ReceiveFromWeb.ListBox := FListBoxReceive;
    ReceiveFromWeb.progresso := FProgresso;
    ReceiveFromWeb.InstiturionOrigem := LcInstitutionOrigem;
    ReceiveFromWeb.CNPJ := LcCnpj;
    ReceiveFromWeb.URL := LcUrl;
    ReceiveFromWeb.Database := DM.IBD_Gestao;

    ReceiveFromWeb.Execute;
  End;

  if FSendToWEb then
  Begin
    SendToWeb := TSendToWebServer.Create(self);
    SendToWeb.ListBox := FListBoxSend;
    SendToWeb.progresso := FProgresso;
    SendToWeb.InstiturionOrigem := LcInstitutionOrigem;
    SendToWeb.CNPJ := LcCnpj;
    SendToWeb.URL := LcUrl;
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
