unit un_base_setes;

interface

uses  Classes,SysUtils,StrUtils, Gauges, Vcl.Forms,REST.Json,Json,
       REST.Response.Adapter, REST.Client,REST.Types,
       IniFiles,  IBX.IBDatabase, Data.DB, Vcl.StdCtrls,
       UnFunctions,
       tblSincronia,
       ControllerSincronia, ControllerListaSincronia;
type

  TBaseSetes = Class(TComponent)
    private

      procedure setFDatabase               (const Value: TIBDatabase);
      procedure setFListbox                (const Value: TListBox);
      procedure setFDevice                 (const Value: Integer);
      procedure setFURL                    (const Value: String);
      procedure setFApiKey                 (const Value: String);

    protected
      FURL: String;
      // D12 (revisão do sincronizador): chave de instalação (SISWEB\FApiKey no
      // registro), threaded até TGeneralWeb.ApiKey em cada classe de envio.
      FApiKey: String;
      FInstitutionDestino: Integer;
      FlistBox: TListBox;
      FDevice: Integer;
      FListaSincronia : TControllerListaSincronia;
      FSincronia   : TControllerSincronia;
      FDatabase: TIBDatabase;

      procedure updateMsgProcess          ( pMsg: String; msgIndex: Integer);
      procedure SetProgressBar            ( MaxValue : Integer);
      Procedure geralog                   (acesso : string);
      function ConverteDataHora           (Tempo:String):TDateTime;

      procedure getListSincronia          (pTabela,pTipo:String;pSentido:String);


      procedure SetLastUpdate(pTabela,pTipo,pSentido: String; tempo: TDateTime);


      function ValidaConexao:boolean;
    public
      // Parada graciosa: setado pela UI (FormCloseQuery) quando o usuario
      // pede para fechar durante uma sincronia — os loops de envio/recebi-
      // mento checam entre registros e terminam o registro atual antes de
      // parar (checkpoint e SRC_LOG ficam consistentes).
      class var PararSolicitado: Boolean;
      progresso: TGauge;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure inicializa; Virtual;

      property Database : TIBDatabase read FDatabase write setFDatabase;

      property ListBox           : TListBox read FlistBox write setFListbox;
      property Device            : Integer read FDevice write setFDevice;
      property URL               : String read FURL write setFURL;
      property ApiKey            : String read FApiKey write setFApiKey;
  End;

implementation

{ TBaseSetes }


function TBaseSetes.ConverteDataHora(Tempo: String): TDateTime;
Var
  LcAno:String;
  LcMes:String;
  LcDia:String;
  LcTime:String;
begin
  //2018-09-19 01:12:18'
  LcAno   := Copy(Tempo,1,4);
  LcMes   := Copy(Tempo,6,2);
  LcDia   := Copy(Tempo,9,2);
  LcTime  := Copy(Tempo,12,8);
  Result := StrToDateTimeDef(concat(LcDia,'/',LcMes,'/',LcAno,' ',LcTime),now);
end;

constructor TBaseSetes.Create(AOwner: TComponent);
begin
  inherited;
  FSincronia      := TControllerSincronia.Create(self);
  FListaSincronia := TControllerListaSincronia.Create(self);
end;


destructor TBaseSetes.Destroy;
begin
  FSincronia.DisposeOf;
  FListaSincronia.DisposeOf;
  inherited;
end;

procedure TBaseSetes.geralog(acesso: string);
var
  Arq : TextFile;
  Data : String;
  LcArq : String;
begin
exit;
  Data := DateToStr(Now);
  Data := StringReplace(Data,'/','-',[rfReplaceAll]);
  LcArq := Concat(ExtractFilePath(ParamStr(0)),'log\',Data ,'.log');
  AssignFile(Arq, LcArq );
  if not FileExists( LcArq ) then
    Rewrite(arq, LcArq)
  else
    Append(arq);
  Writeln(Arq, concat(DateTimeToStr(Now),acesso));
  Writeln(Arq, '');
  CloseFile(Arq);

end;

procedure TBaseSetes.getListSincronia(pTabela,pTipo: String;pSentido:String);
begin
  FSincronia.Tipo := pTipo;
  FSincronia.Registro.Tabela := pTabela;
  FSincronia.getList;
end;

procedure TBaseSetes.inicializa;
begin
  inherited;
end;

procedure TBaseSetes.setFApiKey(const Value: String);
begin
  FApiKey := Value;
end;


procedure TBaseSetes.setFDatabase(const Value: TIBDatabase);
begin
  FDatabase := Value;
end;

procedure TBaseSetes.setFDevice(const Value: Integer);
begin
  FDevice := Value;
end;


procedure TBaseSetes.setFListbox(const Value: TListBox);
begin
  FlistBox := Value;
end;

procedure TBaseSetes.setFURL(const Value: String);
begin
  FURL := Value;
end;

procedure TBaseSetes.SetLastUpdate(pTabela,pTipo,pSentido: String; tempo: TDateTime);
begin
  // Checkpoint em TB_LISTA_SINCRONIA.LAST_UPDATE (decisoes 1 e 3) —
  // granularidade = PK do catalogo (WAY + DESC_TABELA + KIND).
  FListaSincronia.SetLastUpdate(pSentido, pTabela, pTipo, tempo);
end;

procedure TBaseSetes.SetProgressBar(MaxValue: Integer);
begin
  TThread.Synchronize(nil,
    procedure
    Begin
      progresso.Progress := 0;
      progresso.MinValue := 0;
      progresso.MaxValue := MaxValue;
      Application.ProcessMessages;
    end
  );

end;

procedure TBaseSetes.updateMsgProcess(pMsg: String; msgIndex: Integer);
begin
  TThread.Synchronize(nil,
    procedure
    Begin
      try
        FlistBox.Items[msgIndex] := pMsg;
        progresso.Progress := progresso.Progress + 1;
        Application.ProcessMessages;
      except
        on E: Exception do
        BEgin
          FlistBox.Items[msgIndex] := concat('Indice: ',msgIndex.ToString,' - ',e.Message);
        End;
      end;
    end
  );

end;


function TBaseSetes.ValidaConexao: boolean;
begin
  REsult := True;
  FInstitutionDestino := 7756;
end;

end.
