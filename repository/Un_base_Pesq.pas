unit Un_base_Pesq;

interface

uses
  Winapi.Windows, Winapi.Messages, SysUtils, Variants, Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Un_Base, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.Buttons, Vcl.StdCtrls, Vcl.ExtCtrls, Datasnap.DBClient,  Datasnap.Provider,
  IBX.IBCustomDataSet, IBX.IBQuery, Vcl.Menus, Un_Msg;

type

  TMoveSG = class(TCustomGrid); // reveals protected MoveRow procedure

  TFr_Base_Pesq = class(TFr_Base)
    GrB_Parametros: TGroupBox;
    Pnl_Resultado: TPanel;
    Lb_ResultadoPesquisa: TLabel;
    SB_Cadastrar: TSpeedButton;
    SB_Buscar: TSpeedButton;
    SB_Visualizar: TSpeedButton;
    Sb_Sair: TSpeedButton;
    Qr_Pesquisa: TIBQuery;
    Grd_Pesquisa: TStringGrid;
    pnl_botao: TPanel;
    procedure SB_BuscarClick(Sender: TObject);
    procedure Grd_PesquisaClick(Sender: TObject);
    procedure Grd_PesquisaDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Sb_SairClick(Sender: TObject);
    procedure SB_CadastrarClick(Sender: TObject);
    procedure SB_VisualizarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    { Private declarations }

    function Fc_VerificaMarcado(Fc_grid:TStringGrid):Boolean;
    procedure setPerfil;Override;
    procedure ImagemBotao;Override;
    procedure IniciaVariaveis;Override;
    procedure FormataTela;Override;
    procedure Buscar;Virtual;
    procedure SelectSql;Virtual;
    procedure InnerJoinSql;Virtual;
    procedure WhereSql;Virtual;
    procedure OrderBy;Virtual;
    procedure PassagemParametros;Virtual;
    procedure PreencherGrade;Virtual;
    procedure Insere;Virtual;
    function ValidaVisualiza:Boolean;Virtual;
    procedure Visualiza;Virtual;
  public
    { Public declarations }
    SqlTxt : String;
    MultiSelect : Boolean;
    Visualizar : Boolean;
    procedure MarcarTudo;
    procedure DesmarcaTudo;
  end;

var
  Fr_Base_Pesq: TFr_Base_Pesq;

implementation

{$R *.dfm}

uses UN_Principal, RN_Permissao, Un_DM, Un_Regra_Negocio, Un_Sistema;


{ TFr_Base_Pesq }

procedure SortGridByCols(Grid: TStringGrid; ColOrder: array of Integer);
var
  i, j: Integer;
  Sorted: Boolean;
  function Sort(Row1, Row2: Integer): Integer;
    var
    C: Integer;
  begin
    C := 0;
    Result := AnsiCompareStr(Grid.Cols[ColOrder[C]][Row1], Grid.Cols[ColOrder[C]][Row2]);
    if Result = 0 then
    begin
      Inc(C);
      while (C <= High(ColOrder)) and (Result = 0) do
      begin
        Result := AnsiCompareStr(Grid.Cols[ColOrder[C]][Row1],
        Grid.Cols[ColOrder[C]][Row2]);
        Inc(C);
      end;
    end;
  end;
begin
  if SizeOf(ColOrder) div SizeOf(i) <> Grid.ColCount then
    Exit;
  for i := 0 to High(ColOrder) do
    if (ColOrder[i] < 0) or (ColOrder[i] >= Grid.ColCount) then
      Exit;
  j := 0;
  Sorted := False;
  repeat
    Inc(j);
    with Grid do
      for i := 0 to RowCount - 2 do
        if Sort(i, i + 1) > 0 then
        begin
          TMoveSG(Grid).MoveRow(i + 1, i);
          Sorted := False;
        end;
  until Sorted or (j = 1000);
  Grid.Repaint;
end;

procedure TFr_Base_Pesq.Sb_SairClick(Sender: TObject);
begin
  Close;
end;

procedure TFr_Base_Pesq.SB_VisualizarClick(Sender: TObject);
begin
  if ValidaVisualiza then
  Begin
    Visualiza;
  End;
end;

procedure TFr_Base_Pesq.DesmarcaTudo;
Var
  Lc_I : Integer;
begin
  with Grd_Pesquisa do
  Begin
    For LC_I := 1 to RowCount -1 do
    Begin
      Cells[2,Lc_I] := '';
    end;
    Repaint;
  end;
end;

function TFr_Base_Pesq.Fc_VerificaMarcado(Fc_grid: TStringGrid): Boolean;
Var
  Lc_I : Integer;
Begin
  with Fc_grid do
  Begin
    Result := False;
    For Lc_I := 1 to RowCount - 1 do
    Begin
      if Cells[2,Lc_I] = 'X' then
      Begin
        Result := true;
        break;
      end;
    end;
  end;
  if not Result then
  Begin
    MensagemPadrao('Mensagem ','A T E N Ç Ã O!.'+EOLN+EOLN+
                   'Nenhum registro foi selecionado.'+EOLN+
                   'Verifique e tente novamente.'+EOLN,
                  ['OK'],[bEscape],mpAlerta);
  end;
end;

procedure TFr_Base_Pesq.FormataTela;
Var
  I: Integer;
begin
  inherited;
 with Grd_Pesquisa,Qr_Pesquisa do
  Begin
    ColCount := FieldCount + 3;
    ColWidths[0]:=17;
    if MultiSelect then
      ColWidths[1]:=54
    else
      ColWidths[1]:= - 1;
    ColWidths[2]:=-1;
    Cols[1].Add('Selecionar');
    For I := 0 to FieldCount -1 do
    Begin
      ColWidths[I + 3]:= Fields[I].Tag;
      Cols[I + 3].Add(Fields[I].DisplayLabel);
    end;
  end;
end;

procedure TFr_Base_Pesq.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (shift = []) then
  begin
    case Key of
      VK_F2  : SB_CadastrarClick(Sender);
      VK_F7  : SB_BuscarClick(Sender);
      VK_F8  : SB_VisualizarClick(Sender);
      VK_Escape : Sb_SairClick(Sender);
    end;
  end;
end;

procedure TFr_Base_Pesq.Grd_PesquisaClick(Sender: TObject);
begin
  if not MultiSelect then DesmarcaTudo;

  with Grd_Pesquisa do
  Begin
    IF Cells[2,Row]= 'X' then
      Cells[2,Row] := ''
    else
      Cells[2,Row] := 'X';
    Repaint;
  end;
end;

procedure TFr_Base_Pesq.Grd_PesquisaDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
Var
  LarguraTexto, AlturaTexto, X, Y: integer;
  Texto: string;
begin
  with Qr_Pesquisa, Grd_Pesquisa do
  Begin
    if (ACol = 1)and(ARow>0) Then
    begin
      if (Cells[3,ARow] <> '') then
      Begin
        if (Cells[2,ARow] = 'X') then
          DrawFrameControl(Canvas.Handle, Rect,DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED) // Desenha o CheckBox desmarcado
        else
          DrawFrameControl(Canvas.Handle, Rect,   DFC_BUTTON, DFCS_BUTTONCHECK); // Desenha o CheckBox marcado
      end;
    end
    else
    Begin
      If (arow > 0) and (acol >0) then // testa se não é a primeira linha (fixa)
      Begin
        if (Cells[2,ARow] = '') then
        Begin
          Canvas.Font.Color:= clBlack;
          Canvas.Brush.Color:= clCream;
        end
        else
        Begin
          Canvas.Font.Color:= clBlack;
          Canvas.Brush.Color:= clMoneyGreen;
        end;
        Canvas.FillRect(Rect); // redesenha a celula
        Canvas.TextOut(Rect.Left+2,Rect.Top,Cells[acol,arow]); // reimprime o texto.
        // Pega o texto da célula
        Texto := Cells[acol, ARow];
        //{ Calcura largura e altura (em pontos) do texto
        LarguraTexto := Canvas.TextWidth(Texto);
        AlturaTexto := Canvas.TextHeight(Texto);
        // Calcula a posição horizontal do início do texto
        if (Acol > 2) then
        Begin
          if (Fields[ACol-3].Alignment = taLeftJustify) then   // esquerda
            X := Rect.Left + 2
          else
          if (Fields[ACol-3].Alignment = taCenter) then // Centro
            X := Rect.Left + (Rect.Right - Rect.Left) div 2 - LarguraTexto div 2
          else // Direita
            X := Rect.Right - LarguraTexto - 2;
        end;
        // Calcula a posição vertical do início do texto para que seja impresso no centro (verticalmente) da célula
        Y := Rect.Top + (Rect.Bottom - Rect.Top) div 2 - AlturaTexto div 2;
        Canvas.TextRect(Rect, X, Y, Texto);
      end;
    end;
  end;

end;

procedure TFr_Base_Pesq.ImagemBotao;
begin
  CarregaImagemBotao(SB_Cadastrar,'CADASTRAR');
  CarregaImagemBotao(SB_Buscar,'BUSCAR');
  CarregaImagemBotao(SB_Visualizar,'VISUALIZAR');
  CarregaImagemBotao(Sb_Sair,'SAIR');
end;

procedure TFr_Base_Pesq.IniciaVariaveis;
begin
  inherited;
  MultiSelect := True;
end;

procedure TFr_Base_Pesq.MarcarTudo;
Var
  Lc_I : Integer;
begin
  with Grd_Pesquisa do
  Begin
    For LC_I := 1 to RowCount -1 do
    Begin
      Cells[2,Lc_I] := 'X';
    end;
    Repaint;
  end;
end;

procedure TFr_Base_Pesq.OrderBy;
begin
  //
end;

procedure TFr_Base_Pesq.Buscar;
begin
  with Qr_Pesquisa do
  Begin
    Active := False;
    sql.Clear;
    SqlTxt := '';
    SelectSql;
    InnerJoinSql;
    WhereSql;
    OrderBy;
    sql.Add(SqlTxt);
    PassagemParametros;
    Active := True;
    FetchAll;
  End;
end;

procedure TFr_Base_Pesq.SelectSql;
Begin
  //Sera implementado na Classes filhas

End;

procedure TFr_Base_Pesq.setPerfil;
begin
  inherited;
  if Gb_Nivel = 1 then
  begin
    SB_Cadastrar.Enabled   := True;
  end
  else
  begin
    SB_Cadastrar.Enabled   := Fc_HabilitaPermissao(pfMenu,'INSERIR','S');
  end;
end;

function TFr_Base_Pesq.ValidaVisualiza: Boolean;
begin
  Result := True;
  if Qr_Pesquisa.RecordCount = 0 then
  Begin
    MensagemPadrao(' Mensagem', 'A T E N Ç Ã O!.' + EOLN + EOLN +
                  ' Não há registros para visualizar.' + EOLN +
                  ' Favor verifique e tente novamente.' + EOLN,
                   ['OK'], [bEscape], mpAlerta);
    Result := False;
    exit;
  End;
end;

procedure TFr_Base_Pesq.Visualiza;
begin
  //
end;

procedure TFr_Base_Pesq.InnerJoinSql;
Begin
  //Sera implementado na Classes filhas

End;

procedure TFr_Base_Pesq.Insere;
begin
  //
end;

procedure TFr_Base_Pesq.WhereSql;
BEgin
  //Sera implementado na Classes filhas

End;

procedure TFr_Base_Pesq.PassagemParametros;
begin
  //
end;

procedure TFr_Base_Pesq.PreencherGrade;
Var
  Lc_registro, I : Integer;
begin
  Grd_Pesquisa.Visible := False;
  Pc_LimpaStringGrid(Grd_Pesquisa);
  with Qr_Pesquisa, Grd_Pesquisa  do
  Begin
    First;
    Lc_registro := 0;
    while not Eof do
    Begin
      Lc_registro := Lc_registro + 1;
      RowCount := Lc_registro + 1;
      For I:= 0 to FieldCount -1 do
        if (Fields.Fields[I].DataType = ftFloat) OR (Fields.Fields[I].DataType = ftBCD) or
        (Fields.Fields[I].DataType = ftFMTBcd) then
          Cells[I + 3,Lc_registro] := FloatToStrF(Fields[I].AsFloat,ffFixed,10,2)
        else
          Cells[I + 3,Lc_registro] := Fields[I].AsString;
      Next;
    end;
    Lb_ResultadoPesquisa.Caption := 'Resultado da pesquisa : ' + IntTostr(recordCount) + ' registro(s)';
    Repaint;
  End;
  Grd_Pesquisa.Visible := True;
end;

procedure TFr_Base_Pesq.SB_BuscarClick(Sender: TObject);
begin
  inherited;
  Buscar;
  PreencherGrade;
end;

procedure TFr_Base_Pesq.SB_CadastrarClick(Sender: TObject);
begin
  Insere;
end;

end.
