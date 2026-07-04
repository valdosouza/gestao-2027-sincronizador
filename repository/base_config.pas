unit base_config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Un_Base, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TFr_Base_Config = class(TFr_Base)
    Panel1: TPanel;
    Panel2: TPanel;
    Btn_Ok_12: TButton;
    Btn_Cn_12: TButton;
    Btn_AP_12: TButton;
    procedure Btn_Ok_12Click(Sender: TObject);
    procedure Btn_Cn_12Click(Sender: TObject);
    procedure Btn_AP_12Click(Sender: TObject);
  private
    { Private declarations }


  protected
    procedure CriarVariaveis;Override;
    procedure IniciaVariaveis;Override;

    //Mostrar
    procedure ShowData;Virtual;
    //Salvar
    function ValidateSave():boolean;Virtual;
    procedure Save;Virtual;

  public
    { Public declarations }

  end;

var
  Fr_Base_Config: TFr_Base_Config;

implementation

{$R *.dfm}



procedure TFr_Base_Config.Btn_AP_12Click(Sender: TObject);
begin
  if ValidateSave then
  Begin
    Save;
  End;
end;

procedure TFr_Base_Config.Btn_Cn_12Click(Sender: TObject);
begin
  Close;
end;

procedure TFr_Base_Config.Btn_Ok_12Click(Sender: TObject);
begin
  if ValidateSave then
  Begin
    Save;
    Close;
  End;
end;

procedure TFr_Base_Config.CriarVariaveis;
begin
  inherited;

end;

procedure TFr_Base_Config.IniciaVariaveis;
begin
  inherited;
  ShowData;
end;

procedure TFr_Base_Config.Save;
begin

end;

procedure TFr_Base_Config.ShowData;
begin

end;

function TFr_Base_Config.ValidateSave: boolean;
begin
  REsult := True;
end;

end.
