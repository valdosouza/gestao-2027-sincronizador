unit un_base_cad.par;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, IBQuery, DB, IBCustomDataSet, OleCtrls, SHDocVw,
  ComCtrls, StdCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, Mask, QEdit_Setes,
  Buttons;

type
  TFr_base_cad = class(TForm)
    Pg_Cadastro: TPageControl;
    tbs_cadastro: TTabSheet;
    Panel24: TPanel;
    SB_Inserir: TSpeedButton;
    SB_Alterar: TSpeedButton;
    SB_Excluir: TSpeedButton;
    SB_Cancelar: TSpeedButton;
    SB_Sair_0: TSpeedButton;
    Sb_Pesquisar: TSpeedButton;
    SB_Gravar: TSpeedButton;
    tbs_pesquisa: TTabSheet;
    GroupBox1: TGroupBox;
    Grp_Pesquisa: TGroupBox;
    SB_Buscar: TSpeedButton;
    SB_Visualizar: TSpeedButton;
    SB_Cadastrar: TSpeedButton;
    Sb_Sair_1: TSpeedButton;
    Dbg_Pesquisa: TDBGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Fr_base_cad: TFr_base_cad;

implementation

{$R *.dfm}

end.
