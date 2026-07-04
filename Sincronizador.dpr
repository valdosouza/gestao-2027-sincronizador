program Sincronizador;

uses
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF }
  Forms,
  Vcl.Dialogs,
  Winapi.Windows,
  tas_config in 'Task\tas_config.pas' {TasConfig},
  uMain in 'uMain.pas' {Principal},
  un_dm in 'un_dm.pas' {DM: TDataModule},
  un_send_to_web_server in 'function\un_send_to_web_server.pas',
  base_form in 'repository\base_form.pas' {BaseForm},
  json_category in '..\share\json_objects\json_category.pas',
  un_receive_from_web_server in 'function\un_receive_from_web_server.pas',
  order_sale_receive_web in 'classes\receive\order_sale_receive_web.pas';

var
  handle: Thandle;

{$R *.res}
begin
  {$IFDEF DEBUG}
  FullDebugModeScanMemoryPoolBeforeEveryOperation := True;
  ReportMemoryLeaksOnShutdown := True;
  SuppressMessageBoxes := FAlse;
  {$ENDIF}
  handle := FindWindow('TPrincipal',nil);
   if Handle<>0 then
  begin
    if not ISWindowVisible(Handle) then
      showWindow (handle, sw_restore);
    setForegroundWindow(handle);
    application.Terminate;
  end;
  begin
    Application.Initialize;
    Application.CreateForm(TDM, DM);
  Application.Title := 'Integração Gestão Web';
    Application.CreateForm(TPrincipal, Principal);
    Application.Run;
  end;
end.
