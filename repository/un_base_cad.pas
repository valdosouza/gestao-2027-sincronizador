unit un_base_cad;

interface

uses
  Windows, Messages, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, IBQuery, DB, IBCustomDataSet, OleCtrls, SHDocVw, TypInfo,
  ComCtrls, ExtCtrls, DBCtrls, Grids, DBGrids, Mask, QEdit_Setes,
  Buttons, StdCtrls, UN_Uteis,SysUtils;

type

    TDataSetStates = set of TDataSetState;

    tSetGetTextObject = class
    private
          fSet: tstringlist;
          fGet: tstringlist;
    public
          property SetText: tstringlist read fset write fset;
          property GetText: tstringlist read fget write fget;
          Constructor Create ( GetText,SetText:string );
          Destructor Destroy;
    end;

    tObjectList = class( tStringList )
    public
          Function add( nme:string; obj:tObject ):integer;
    end;


  TFr_base_cad = class(TForm)
    Pg_Cadastro: TPageControl;
    tbs_cadastro: TTabSheet;
    pnUtil: TPanel;
    SB_Inserir: TSpeedButton;
    SB_Alterar: TSpeedButton;
    SB_Excluir: TSpeedButton;
    SB_Cancelar: TSpeedButton;
    SB_Sair_0: TSpeedButton;
    Sb_Pesquisar: TSpeedButton;
    SB_Gravar: TSpeedButton;
    tbs_pesquisa: TTabSheet;
    gbCamposPesquisa: TGroupBox;
    Grp_Pesquisa: TGroupBox;
    SB_Buscar: TSpeedButton;
    SB_Visualizar: TSpeedButton;
    SB_Cadastrar: TSpeedButton;
    Sb_Sair_1: TSpeedButton;
    Dbg_Pesquisa: TDBGrid;
    Qr_Pesquisa: TIBQuery;
    ds_Pesquisa: TDataSource;
    Tb_Cadastro: TIBDataSet;
    Ds_Cadastro: TDataSource;
    gbMain: TGroupBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SB_CadastrarClick(Sender: TObject);
    procedure SB_BuscarClick(Sender: TObject);
    procedure SB_VisualizarClick(Sender: TObject);
    procedure Sb_Sair_1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Pg_CadastroChange(Sender: TObject);
    procedure Sb_PesquisarClick(Sender: TObject);
    procedure SB_Sair_0Click(Sender: TObject);
    procedure SB_InserirClick(Sender: TObject);
    procedure SB_AlterarClick(Sender: TObject);
    procedure SB_ExcluirClick(Sender: TObject);
    procedure SB_GravarClick(Sender: TObject);
    procedure SB_CancelarClick(Sender: TObject);
    procedure Tb_CadastroBeforeEdit(DataSet: TDataSet);
    procedure Tb_CadastroBeforeInsert(DataSet: TDataSet);
    procedure Tb_CadastroAfterPost(DataSet: TDataSet);
    procedure Tb_CadastroBeforeDelete(DataSet: TDataSet);
    procedure Tb_CadastroAfterDelete(DataSet: TDataSet);
    procedure Tb_CadastroAfterCancel(DataSet: TDataSet);
    procedure Tb_CadastroAfterInsert(DataSet: TDataSet);
    procedure Tb_CadastroAfterEdit(DataSet: TDataSet);
    procedure Dbg_PesquisaDblClick(Sender: TObject);

  private
         fUtl : tQueryUtil;
         fNomeTabela: String;
         fNomeCampoPK: String;
         fNomeGenerator: String;
         fIt_Inserir: Boolean;
         fIt_Alterar: Boolean;
         fIt_Excluir: Boolean;
         fIt_Visualizar: Boolean;
         fSetGetTextList: tObjectList;
         function CadState ( stt: TDataSetStates; TrueOnlyIfExistRecords: Boolean  ): boolean;
         procedure SetStatusBotoes;
         procedure SetStatusCadastro;
         procedure LerImagemBotoes;
         procedure BeginTransaction;
         procedure CommitTransaction;
         procedure RollBackTransaction;
         procedure OpenTbCadastro(isInsert: boolean);

         procedure DefSetText(Sender: TField; const Text: String);
         procedure DefGetText(Sender: TField; var Text: String; DisplayText: Boolean);
         procedure SetPropertyGrids;

  public
        procedure SetGetText(ffield: tField; textget, textset: string;fComboBox: tDBComboBox);
        procedure Pc_PermissaoBotao(Pc_Menu: string);
        Procedure PC_Buscar; virtual ;
        Property It_Inserir: Boolean read fIt_Inserir write fIt_Inserir;
        Property It_Alterar: Boolean read fIt_Alterar write fIt_Alterar;
        Property It_Excluir: Boolean read fIt_Excluir write fIt_Excluir;
        Property It_Visualizar: Boolean read FIt_Visualizar write FIt_Visualizar ;
        procedure OpenPesquisa;
        Property NomeTabela:string read fNomeTabela Write fNomeTabela;
        Property NomeCampoPK:string read fNomeCampoPK Write fNomeCampoPK;
        Property NomeGenerator: String read fNomeGenerator write fNomeGenerator;
        Property Utl: tQueryUtil read fUtl Write fUtl;
  end;

var
  Fr_base_cad: TFr_base_cad;

implementation

uses un_DM, UN_MSG, un_funcoes, un_sistema, UN_Principal;

{$R *.dfm}


procedure TFr_base_cad.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if DM.IB_Transacao.InTransaction then DM.IB_Transacao.CommitRetaining;
  fsetgettextlist.Clear;
end;

procedure TFr_base_cad.FormCloseQuery(Sender: TObject;  var CanClose: Boolean);
var x,y: integer ;
begin
     y := self.ControlCount-1;
     for x := 0 to y do
     begin
          if self.Controls[x].InheritsFrom(TDataSource) then
          begin
               if (TDataSource(self.Controls[x]).State in [dsinsert,dsedit]) then
               Begin
                    canClose := False;
                    MensagemPadrao( 'Mensagem','A T E N Ç Ã O!.'+EOLN+EOLN+
                                    'O registro está sendo editado.'+EOLN+
                                    'Grave ou cancele a edição antes de sair da tela.'+EOLN,
                                    ['OK'],[bEscape],mpAlerta);
                    abort;
               end;
          end;
    end;
end;

procedure TFr_base_cad.FormCreate(Sender: TObject);
var Lc_X: Integer;
Begin
     fUtl := tQueryUtil.create('');
     fUtl.dbConn:=DM.IBD_Gestao;
     for Lc_X := 1 to Pg_Cadastro.PageCount do
         Pg_Cadastro.Pages[Lc_X - 1].TabVisible := False;
     Pg_Cadastro.ActivePage := tbs_pesquisa;
     self.Height := 580;
     It_Inserir:= True;
     It_Alterar:=True;
     It_Excluir:=True;
     It_Visualizar:=True;
     fNomeTabela:='';
     fNomeCampoPK:='';
     fNomeGenerator:='';
     fsetgettextlist:=tObjectList.Create;
     SetPropertyGrids;
end;

procedure TFr_base_cad.SetPropertyGrids;
var n,x: integer;
begin
     n := self.ComponentCount-1;
     for x := 0 to n do
     begin
          if self.Components[x].ClassType=tDBGrid then
          with tDbGrid(self.Components[x]) do
          begin
               Color := clMoneyGreen;
               Font.Charset := ANSI_CHARSET;
               Font.Color := clBlack;
               Font.Height := -11 ;
               Font.Name := 'Lucida Console';
               Font.Style := [];
               Options := [dgTitles, dgColLines, dgRowSelect];
               ParentFont := False;
               TitleFont.Charset := ANSI_CHARSET;
               TitleFont.Color := clNavy;
               TitleFont.Height := -11;
               TitleFont.Name := 'Arial';
               TitleFont.Style := [];
          end;
     end;
end;

procedure TFr_base_cad.Pc_PermissaoBotao(Pc_Menu: string);
begin
     if Gb_Nivel = 1 then
     begin
          It_Inserir:= True;
          It_Alterar:=True;
          It_Excluir:=True;
          It_Visualizar:=True;
     end
     else
     begin
          It_Inserir    := Fc_HabilitaPermissao(Pc_Menu,'INSERIR','S');
          It_Alterar    := Fc_HabilitaPermissao(Pc_Menu,'ALTERAR','S');
          It_Excluir    := Fc_HabilitaPermissao(Pc_Menu,'EXCLUIR','S');
          It_Visualizar := Fc_HabilitaPermissao(Pc_Menu,'VISUALIZAR','S');
     end;
     SB_Cadastrar.Enabled := It_Inserir;
end;

Function TFr_base_cad.CadState ( stt: TDataSetStates; TrueOnlyIfExistRecords: Boolean  ): boolean;
begin
     result := Tb_cadastro.active;
     if result then
     begin
          result := (tb_Cadastro.State in stt) ;
          if Result and TrueOnlyIfExistRecords then
             result := Tb_cadastro.RecordCount > 0;
     end;
end;

Procedure TFr_base_cad.SetStatusBotoes;
begin
  SB_Inserir.Enabled := CadState( [dsBrowse], false ) and It_Inserir ;
  SB_Excluir.Enabled := CadState( [dsBrowse], false ) and It_Excluir ;
  SB_Alterar.Enabled := CadState( [dsBrowse], true ) and It_Alterar ;
  SB_Gravar.Enabled := CadState( [dsInsert, dsEdit], False );
  SB_Cancelar.Enabled := CadState( [dsInsert, dsEdit], false );
  Sb_Pesquisar.Enabled := CadState( [dsBrowse], False ) or ( not Tb_cadastro.active ); // retorno a aba pesquisa
  SB_Sair_0.Enabled := CadState( [dsBrowse] , false ) or ( not Tb_cadastro.active ); // retorno a aba pesquisa
end;

procedure TFr_base_cad.FormShow(Sender: TObject);
begin
     Pc_PermissaoBotao(self.caption);
     SetStatusBotoes; // set enable true/false para os botões do formulário
     SetStatusCadastro; // set enable true/fale para controles de edição de registro
     LerImagemBotoes;
     gbCamposPesquisa.SetFocus;
end;

Procedure TFr_base_cad.LerImagemBotoes;
begin
     with fr_principal do
     Begin
          //Geral;
          SB_Inserir.Glyph := (Fc_CarregaImagemBotao('INSERIR'));
          SB_Alterar.Glyph := (Fc_CarregaImagemBotao('ALTERAR'));
          SB_Excluir.Glyph := (Fc_CarregaImagemBotao('EXCLUIR'));
          SB_Gravar.Glyph := (Fc_CarregaImagemBotao('GRAVAR'));
          SB_Cancelar.Glyph := (Fc_CarregaImagemBotao('CANCELAR'));
          SB_Pesquisar.Glyph := (Fc_CarregaImagemBotao('PESQUISAR'));
          Sb_Sair_0.Glyph := (Fc_CarregaImagemBotao('SAIR'));
          SB_Cadastrar.Glyph := (Fc_CarregaImagemBotao('CADASTRAR'));
          SB_Buscar.Glyph := (Fc_CarregaImagemBotao('BUSCAR'));
          SB_Visualizar.Glyph := (Fc_CarregaImagemBotao('VISUALIZAR'));
          Sb_Sair_1.Glyph := (Fc_CarregaImagemBotao('SAIR'));
     End;
end;

Procedure TFr_base_cad.SetStatusCadastro;
var x,y : integer ;
    ro: boolean ;
    PropInfo: PPropInfo;
begin
    with gbMain do
    begin
      ro := CadState( [ dsInsert, dsEdit ],false );
      y := controlcount - 1 ;
      for x := 0 to y do
      begin
        if not controls[x].InheritsFrom(tPageControl) then
        begin
          PropInfo := GetPropInfo(controls[x].ClassInfo, 'enabled');
          if Assigned(PropInfo) then
          begin
            SetPropValue(controls[x],'enabled', ro );
          end;
        end;
      end;
    end;
end;

procedure TFr_base_cad.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     if (shift = []) and (Pg_Cadastro.ActivePage =tbs_cadastro) then
     begin
          case Key of
          VK_F2: if SB_Inserir.enabled then SB_Inserir.Click ;
          VK_F3: if SB_Alterar.Enabled then SB_Alterar.Click ;
          VK_F4: if SB_Excluir.Enabled then SB_Excluir.Click ;
          VK_F5: if SB_Gravar.Enabled then SB_Gravar.Click;
          VK_F6: if SB_Cancelar.Enabled then SB_Cancelar.Click;
          VK_F7: if SB_Pesquisar.Enabled then SB_Pesquisar.Click;
          VK_Escape: if Sb_Sair_0.Enabled then  Sb_Sair_0.Click;
          end;
     end
     else
     begin
          if shift = [] then
          begin
               case Key of
               VK_F2: if SB_Cadastrar.Enabled then SB_Cadastrar.Click;
               VK_F7: if SB_Buscar.Enabled then SB_Buscar.Click;
               VK_F8: if SB_Visualizar.Enabled then  SB_Visualizar.Click;
               VK_Escape: if Sb_Sair_1.Enabled then Sb_Sair_1.Click;
               end;
          end;
     end;
end;

procedure TFr_base_cad.SB_CadastrarClick(Sender: TObject);
begin
  Pg_cadastro.ActivePage := tbs_cadastro;
   OpenTbcadastro( true ); // true => insert;
end;

procedure TFr_base_cad.SB_BuscarClick(Sender: TObject);
begin
     Pg_cadastro.ActivePage := tbs_pesquisa;
     //tmPsq.enabled:=false;
     PC_Buscar;
end;

procedure TFr_base_cad.SB_VisualizarClick(Sender: TObject);
begin
     if not qr_pesquisa.Active then
        abort;
     if qr_pesquisa.FieldByName(fNomeCampoPk).IsNull then
        abort;
     Pg_cadastro.ActivePage := tbs_cadastro;
     OpenTbCadastro( False );
end;

Procedure TFr_base_cad.OpenTbCadastro( isInsert:boolean );
Var ValueKey,lst1,lst2,lst3: string;
    qry: tIbQuery;
begin
     if fNomeTabela='' then
        Raise Exception.create('Faltando: Propriedade NomeTabela = [tb_cadastro]');
     if fNomeCampoPK='' then
        Raise Exception.create('Faltando: Propriedade NomeCampoPK = [campo]');
     if Tb_Cadastro.Active then
        tb_cadastro.Close;
     tb_Cadastro.SelectSQL.Clear;
     tb_Cadastro.SelectSQL.add('Select * From '+fNomeTabela+' where '+fNomeCampoPK+'=:'+fNomeCampoPK);
     tb_Cadastro.RefreshSQL.Text:=tb_Cadastro.SelectSQL.text;
     tb_Cadastro.DeleteSQL.Clear;
     tb_Cadastro.DeleteSQL.add('Delete From '+fNomeTabela+' where '+fNomeCampoPK+'=:'+fNomeCampoPK);
     tb_Cadastro.ModifySql.Clear;
     tb_Cadastro.InsertSQL.Clear;
     lst1:='';
     lst2:='';
     lst3:='';
     qry := utl.Listacampos(fNomeTabela);
     try
        while not qry.Eof do
        begin
             lst1 := AddCommaText( lst1, ',' , qry.Fields[0].AsAnsiString);
             lst2 := AddCommaText( lst2, ',' , ':'+qry.Fields[0].AsAnsiString);
             lst3 := AddCommaText( lst3, ',' , qry.Fields[0].AsAnsiString+'=:'+qry.Fields[0].AsAnsiString);
             qry.Next;
        end;
     Finally
            qry.Close;
            FreeAndNil(qry);
     end;
     tb_Cadastro.InsertSQL.add('Insert into '+fNomeTabela);
     tb_Cadastro.InsertSQL.add('('+lst1+')');
     tb_Cadastro.InsertSQL.add('Values ('+lst2+')');
     tb_Cadastro.ModifySql.add('Update '+fNomeTabela);
     tb_Cadastro.ModifySql.add('Set '+lst3);
     tb_Cadastro.ModifySql.add('where '+fNomeCampoPK+'=:'+fNomeCampoPK);
     if not isInsert then
        tb_Cadastro.ParamByName(fNomeCampoPK).AsInteger:=Qr_Pesquisa.FieldByName(fNomeCampoPK).asInteger
     Else
        tb_Cadastro.ParamByName(fNomeCampoPK).Clear;
     tb_Cadastro.Open;
     if isInsert then
        tb_Cadastro.insert;
     SetStatusCadastro;
     SetStatusBotoes;
end;

procedure TFr_base_cad.Sb_Sair_1Click(Sender: TObject);
begin
     self.Close;
end;

procedure TFr_base_cad.FormKeyPress(Sender: TObject; var Key: Char);
begin
     if (Key = #13) and (not (ActiveControl is TMemo)) AND (not (ActiveControl is TDBMemo)) then
     begin
          Key := #0;
          Perform(WM_NEXTDLGCTL, 0, 0);
     end;
end;

procedure TFr_base_cad.PC_Buscar;
begin
     if Qr_Pesquisa.active then
        Qr_Pesquisa.close;
     Qr_Pesquisa.sql.clear;
end;

procedure TFr_base_cad.Pg_CadastroChange(Sender: TObject);
begin
  SetStatusBotoes;
  SetStatusCadastro;
end;

procedure TFr_base_cad.Sb_PesquisarClick(Sender: TObject);
begin
     tb_cadastro.Active := False;
     SB_Buscar.Click;     
end;

procedure TFr_base_cad.SB_Sair_0Click(Sender: TObject);
begin
     Self.Close;
end;

procedure TFr_base_cad.SB_InserirClick(Sender: TObject);
begin
     tb_cadastro.insert;
     SetStatusCadastro;
     SetStatusBotoes;
end;

procedure TFr_base_cad.SB_AlterarClick(Sender: TObject);
begin
     tb_cadastro.edit;
     SetStatusCadastro;
     SetStatusBotoes;
end;

procedure TFr_base_cad.SB_ExcluirClick(Sender: TObject);
begin
     if (MensagemPadrao('Mensagem de Confirmação', 'Excluir este registro de seus arquivos.' + EOLN + EOLN +
                                                   'Confirmar a exclusão ?',
                                                   ['Sim', 'Não'], [bNormal,bEscape], mpConfirmacao, clRed) = mrBotao1) then
        tb_cadastro.Delete;
     SetStatusBotoes;
end;

procedure TFr_base_cad.SB_GravarClick(Sender: TObject);
begin
     if tb_cadastro.State in [ dsInsert, dsEdit ] then
        tb_cadastro.post;
     SetStatusCadastro;
end;

procedure TFr_base_cad.SB_CancelarClick(Sender: TObject);
begin
     if tb_cadastro.State in [ dsInsert, dsEdit ] then
        tb_cadastro.Cancel;
     Pg_cadastro.ActivePage := tbs_pesquisa;
     SetStatusCadastro;
end;

procedure TFr_base_cad.Tb_CadastroBeforeEdit(DataSet: TDataSet);
begin
     BeginTransaction;
end;

procedure TFr_base_cad.BeginTransaction;
begin
     if not DM.IB_Transacao.InTransaction then
        DM.IB_Transacao.StartTransaction;
end;

procedure TFr_base_cad.Tb_CadastroBeforeInsert(DataSet: TDataSet);
begin
     BeginTransaction;
end;

procedure TFr_base_cad.Tb_CadastroAfterPost(DataSet: TDataSet);
begin
     CommitTransaction;
     SetStatusBotoes;            
end;

procedure TFr_base_cad.CommitTransaction;
begin
     if not DM.IB_Transacao.InTransaction then
        DM.IB_Transacao.Commit;
end;

procedure TFr_base_cad.Tb_CadastroBeforeDelete(DataSet: TDataSet);
begin
     BeginTransaction;
end;

procedure TFr_base_cad.Tb_CadastroAfterDelete(DataSet: TDataSet);
begin
     CommitTransaction;
     SetStatusBotoes;
end;

procedure TFr_base_cad.Tb_CadastroAfterCancel(DataSet: TDataSet);
begin
     RollBackTransaction;
     
end;

procedure TFr_base_cad.RollBackTransaction;
begin
     if not DM.IB_Transacao.InTransaction then
        DM.IB_Transacao.Rollback;
end;

procedure TFr_base_cad.Tb_CadastroAfterInsert(DataSet: TDataSet);
begin
     SetStatusBotoes;
     if fNomeGenerator<>'' THEN
        tb_cadastro.FieldByName(fNomecampoPK).AsInteger:=utl.GetNextSequence(fNomeGenerator);
end;

procedure TFr_base_cad.Tb_CadastroAfterEdit(DataSet: TDataSet);
begin
     SetStatusBotoes;
end;

procedure TFr_base_cad.OpenPesquisa;
begin
     if delphiaberto then // dep sql
        QR_Pesquisa.Sql.savetofile( GbPathExe+'Pesq_'+self.Name+'.sql' );
     QR_Pesquisa.open;
end;

procedure TFr_base_cad.SetGetText( ffield:tField;textget,textset:string;fComboBox:tDBComboBox );
var nm : string ;
    lst1: tStringList;
begin
     nm := ffield.FieldName;
     ffield.OnGetText := defgettext;
     ffield.OnSetText := defsettext;
     fsetgettextlist.add ( nm , tObject ( tSetGetTextObject.create( textget, textset ) ) );
     if fComboBox<>Nil then
     begin
          fComboBox.Items.clear;
          fComboBox.Items.delimitedtext := textget;
          fComboBox.DataField:=nm;
     end;
end;

procedure TFr_base_cad.DefGetText(Sender: TField; var Text: String; DisplayText: Boolean);
var idx : integer;
begin
     idx := fSetGetTextList.IndexOf(sender.FieldName);
     if idx>-1 then
     begin
          with tSetGetTextObject(fSetGetTextList.Objects[idx]) do
          begin
               idx := SetText.indexof(sender.AsAnsiString);
               if idx>-1 then
                  Text := GetText[idx];
          end;
     end;
end;

procedure TFr_base_cad.DefSetText(Sender: TField;  const Text: String);
var idx : integer;
begin
     idx := fSetGetTextList.IndexOf(sender.FieldName);
     if idx>-1 then
     begin
          with tSetGetTextObject(fSetGetTextList.Objects[idx]) do
          begin
               idx := GetText.indexof(text);
               if idx>-1 then
                  Sender.AsAnsiString := SetText[idx];
          end;
     end;
end;

constructor tSetGetTextObject.Create(GetText, SetText: string);
begin
    fGet := tStringList.Create;
    fGet.CommaText := GetText;
    fset := tStringList.Create;
    fSet.CommaText := SetText;
end;

function tObjectlist.add(nme: string; obj: tObject): integer;
begin
     result := IndexOf(nme);
     if result=-1 then
        Result := inherited AddObject( nme,obj );
end;

destructor tSetGetTextObject.Destroy;
begin
     fGet.Clear;
     fSet.Clear;
end;

procedure TFr_base_cad.Dbg_PesquisaDblClick(Sender: TObject);
begin
    SB_Visualizar.Click;
end;

end.
