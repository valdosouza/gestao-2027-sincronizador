unit base_form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.StdCtrls, Vcl.ComCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids;

type
  TBaseForm = class(TForm)
    procedure InitVariable;Virtual;
    procedure SetVariable;Virtual;
    procedure setImages;Virtual;
    procedure FormatScreen;Virtual;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }

  protected
    procedure ClearFields(T: TComponent);
  public
    { Public declarations }
    //Controlar a ativação da edição da tela
    CodigoRegistro : Integer;

  end;

var
  BaseForm: TBaseForm;

implementation

{$R *.dfm}

{ TBaseForm }

procedure TBaseForm.ClearFields(T: TComponent);
Var
  I,J:Integer;
begin
  with T do
  Begin
    for I := 0 to ((ComponentCount)-1) do
    begin
      if (Components[I].ClassName = 'TEdit') then
        TEdit (Components[I]).Clear;

      if (Components[I].ClassName = 'TMemo') then
        TMemo (Components[I]).Clear;

      if (Components[I].ClassName = 'TCheckBox') then
      Begin
        if ( TCheckBox (Components[I]).name = 'chbx_cad_active' ) then
          TCheckBox (Components[I]).Checked := true
        else
          TCheckBox (Components[I]).Checked := False;
      End;

      if (Components[I].ClassName = 'TComboBox') then
        TComboBox (Components[I]).ItemIndex := 0;

      if (Components[I].ClassName = 'TRadioGroup') then
        TRadioGroup (Components[I]).ItemIndex := 0;

      if (Components[I].ClassName = 'TDateTimePicker') then
        TDateTimePicker (Components[I]).DateTime := Now;

      if (Components[I].ClassName = 'TTreeView') then
        TTreeView (Components[I]).Items.Clear;

      if (Components[I].ClassName = 'TDBGrid') then
        TDBGrid (Components[I]).DataSource.DataSet.Close;
    end;
  End;
end;

procedure TBaseForm.FormatScreen;
begin
//
end;

procedure TBaseForm.FormCreate(Sender: TObject);
begin
  InitVariable;
end;

procedure TBaseForm.FormShow(Sender: TObject);
begin
  SetVariable;
  setImages
end;

procedure TBaseForm.InitVariable;
begin
//
end;

procedure TBaseForm.setImages;
begin
//
end;

procedure TBaseForm.SetVariable;
begin
//
end;

end.
