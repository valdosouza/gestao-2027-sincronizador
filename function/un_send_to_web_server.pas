unit un_send_to_web_server;

interface

uses

  Classes,System.SysUtils,System.StrUtils,Vcl.Forms,Vcl.CheckLst,
  IdHTTP,un_base_setes, general_web, un_dm;

type
    TSendToWebServer = Class(TBaseSetes)
  private
    procedure PreparaListBox;
    procedure SyncTable(indice: Integer);
    procedure send;
    // D4/D14: registro sem CPF/CNPJ (personType 'N') — a setes-sync devolve
    // o UUID gerado na 1ª sincronização; gravamos em TB_EMPRESA.EXTERNALCODE
    // (patch 01_firebird_ddl.sql) para os próximos ciclos reindexarem por
    // UUID em vez de correr o risco de duplicar o cliente/fornecedor/vendedor.
    procedure SaveExternalCode(pCodigoEmpresa: Integer; pExternalCode: String);
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
  LcSendWeb : TGeneralWeb;
begin
  getListSincronia(FListaSincronia.registro.Tabela,FListaSincronia.registro.Tipo, 'E');
  if FSincronia.Lista.count > 0 then
  Begin
    LcSendWeb := TGeneralSendFactory.Instanciar(FListaSincronia.registro.NomeClasse);
    try
      SetProgressBar(FSincronia.Lista.count);
      LcSendWeb.InstitutionDestino := FInstitutionDestino;
      LcSendWeb.URL := FURL;
      LcSendWeb.ApiKey := FApiKey;
      LcSendWeb.Metodo := 'Post';
      LcSendWeb.EndPoint := FListaSincronia.registro.endPoint;
      LcSendWeb.Inicializa;
      for I := 0 to FSincronia.Lista.count - 1 do
      Begin
        // Parada graciosa: usuario pediu para fechar - para ANTES do
        // proximo registro (o atual ja gravou checkpoint/SRC_LOG).
        if PararSolicitado then Break;
        TRy
          Try
            LcSendWeb.Codigo := FSincronia.Lista[I].Registro;
            LcSendWeb.send;
            if LcSendWeb.ExternalCode <> '' then
              SaveExternalCode(LcSendWeb.Codigo, LcSendWeb.ExternalCode);
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

procedure TSendToWebServer.SaveExternalCode(pCodigoEmpresa: Integer; pExternalCode: String);
begin
  DM.ExecComando(
    'UPDATE TB_EMPRESA SET EXTERNALCODE = ''' + pExternalCode + ''' ' +
    'WHERE EMP_CODIGO = ' + IntToStr(pCodigoEmpresa)
  );
end;

procedure TSendToWebServer.send;
Var
  I: Integer;
begin
  for I := 0 to FListaSincronia.ListaEnviar.count - 1 do
  Begin
    if PararSolicitado then Break; // parada graciosa entre tabelas
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
