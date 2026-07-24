unit un_receive_from_web_server;

interface

uses
  Classes,System.SysUtils,System.StrUtils,Vcl.Forms,Vcl.CheckLst,
  IdHTTP,un_base_setes, general_web;

type
    TreceiveFromWebServer = Class(TBaseSetes)
  private
    procedure PreparaListBox;

    procedure SyncTable(indice: Integer);
    procedure send;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure   inicializa; Override;
    procedure   Execute;
  End;

implementation

{ TreceiveFromWebServer }

procedure TreceiveFromWebServer.PreparaListBox;
Var
  I: Integer;
Begin
  FlistBox.Items.Clear;
  FListaSincronia.getListaReceber;
  for I := 0 to FListaSincronia.ListaReceber.count - 1 do
  Begin
    FlistBox.Items.Add(FListaSincronia.ListaReceber[I].Tabela);
  End;
End;



procedure TreceiveFromWebServer.SyncTable(indice: Integer);
Var
  I: Integer;
  LcReceiveWeb : TGeneralWeb;
begin
  LcReceiveWeb := TGeneralSendFactory.Instanciar(FListaSincronia.registro.NomeClasse);
  try
    SetProgressBar(FSincronia.Lista.count);
    LcReceiveWeb.InstitutionDestino := FInstitutionDestino;
    LcReceiveWeb.URL := FURL;
    LcReceiveWeb.Metodo := 'Get';
    LcReceiveWeb.EndPoint := FListaSincronia.registro.endPoint;
    LcReceiveWeb.Inicializa;
    for I := 0 to FSincronia.Lista.count - 1 do
    Begin
      // Parada graciosa: usuario pediu para fechar - para ANTES do
      // proximo registro (o atual ja gravou checkpoint/SRC_LOG).
      if PararSolicitado then Break;
      TRy
        Try
          LcReceiveWeb.Codigo := FSincronia.Lista[I].Registro;
          LcReceiveWeb.receive;
        Finally
          FSincronia.Clear;
          FSincronia.Registro.Tabela    := FListaSincronia.Registro.Tabela;
          FSincronia.Registro.Registro  := FSincronia.Lista[I].Registro;
          FSincronia.Registro.LogResult := LcReceiveWeb.Retorno.Mensagem;
          FSincronia.saveReturn;
          case LcReceiveWeb.Retorno.ID of
            200:Begin
                  SetLastUpdate(FListaSincronia.registro.Tabela, FListaSincronia.registro.Tipo, 'R', FSincronia.Lista[I].Tempo);
                end;
          end;
          updateMsgProcess(concat(FListaSincronia.registro.DescricaoProcesso, ' - ',
          intToStr(progresso.MaxValue), ' / ',
          intToStr(progresso.Progress + 1)), indice);
        End;
      Except
        on e: Exception do
        BEgin
          // Se der Errado a proxima sincronia ser� a partir desta data e hora - 10 segundo
          FSincronia.registro.LogResult := e.Message;
          FSincronia.saveReturn;
          // Se der certo a proxima sincronia ser� a partir desta data e hora + 01 segundo
          SetLastUpdate(FListaSincronia.registro.Tabela, FListaSincronia.registro.Tipo, 'E', FSincronia.Lista[I].Tempo - StrToTime('00:01:00'));
        End;
      end;
    End;
  finally
    LcReceiveWeb.Destroy;
  end;
end;

// Nota: o corpo estava nomeado "Receive" sem declaracao correspondente na
// classe (que declara "send") - corrigido para compilar.
procedure TreceiveFromWebServer.send;
Var
  I: Integer;
begin
  for I := 0 to FListaSincronia.ListaReceber.count - 1 do
  Begin
    if PararSolicitado then Break; // parada graciosa entre tabelas
    FListaSincronia.ClonarObj(FListaSincronia.ListaReceber[I],FListaSincronia.registro);
    if FListaSincronia.registro.ativo = 'S' then
    Begin
      SyncTable(I)
    End;
  End;
end;

constructor TreceiveFromWebServer.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TreceiveFromWebServer.Destroy;
begin
  inherited;
end;


procedure TreceiveFromWebServer.inicializa;
begin
  inherited;
end;

procedure TreceiveFromWebServer.Execute;
begin
  if ValidaConexao then
  Begin
    PreparaListBox;
    send;
  End;
end;

end.
