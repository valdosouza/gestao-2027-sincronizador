unit un_send_to_web_server;

interface

uses

  Classes,System.SysUtils,System.StrUtils,Vcl.Forms,Vcl.CheckLst,
  IdHTTP,un_base_setes, general_web;

type
    TSendToWebServer = Class(TBaseSetes)
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

{ TSendToWebServer }

procedure TSendToWebServer.PreparaListBox;
Var
  I: Integer;
Begin
  FlistBox.Items.Clear;
  FListaSincronia.getListaEnviar;
  for I := 0 to FListaSincronia.ListaEnviar.count - 1 do
  Begin
    FlistBox.Items.Add(FListaSincronia.ListaEnviar[I].Tabela);
  End;
End;



procedure TSendToWebServer.SyncTable(indice: Integer);
Var
  I: Integer;
  Lc_Increme : Integer;
  LcSendWeb : TGeneralWeb;
begin
  getListSincronia(FListaSincronia.registro.Tabela,FListaSincronia.registro.Tipo, 'E');
  if FSincronia.Lista.count > 0 then
  Begin
    try
      SetProgressBar(FSincronia.Lista.count);
      LcSendWeb := TGeneralSendFactory.Instanciar(FListaSincronia.registro.NomeClasse);
      LcSendWeb.InstitutionDestino := FInstitutionDestino;
      LcSendWeb.URL := FURL;
      LcSendWeb.Metodo := 'Post';
      LcSendWeb.EndPoint := FListaSincronia.registro.endPoint;
      LcSendWeb.Inicializa;
      for I := 0 to FSincronia.Lista.count - 1 do
      Begin
        TRy
          Try
            LcSendWeb.Codigo := FSincronia.Lista[I].Registro;
            LcSendWeb.send;
          Finally
            FSincronia.Clear;
            FSincronia.Registro.Tabela    := FListaSincronia.Registro.Tabela;
            FSincronia.Registro.Registro  := FSincronia.Lista[I].Registro;
            FSincronia.Registro.LogResult := LcSendWeb.Retorno.Mensagem;
            FSincronia.saveReturn;
            case LcSendWeb.Retorno.ID of
              200:Begin
                    // Se der certo a proxima sincronia ser� a partir desta data e hora + 01 segundo
                    SetLastUpdate(FListaSincronia.registro.Tabela, FListaSincronia.registro.Tipo, 'E', FSincronia.Lista[I].Tempo + StrToTime('00:00:01'));
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
      LcSendWeb.Destroy;
    end;
  end;

end;

procedure TSendToWebServer.send;
Var
  I: Integer;
begin
  for I := 0 to FListaSincronia.ListaEnviar.count - 1 do
  Begin
    FListaSincronia.ClonarObj(FListaSincronia.ListaEnviar[I],FListaSincronia.registro);
    if FListaSincronia.registro.ativo = 'S' then
    Begin
      SyncTable(I)
    End;
  End;
end;

constructor TSendToWebServer.Create(AOwner: TComponent);
begin
  inherited;
end;

destructor TSendToWebServer.Destroy;
begin
  inherited;
end;


procedure TSendToWebServer.inicializa;
begin
  inherited;
end;

procedure TSendToWebServer.Execute;
begin
  if ValidaConexao then
  Begin
    PreparaListBox;
    send;
  End;
end;
end.
