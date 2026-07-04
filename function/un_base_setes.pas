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
      procedure setFFInstiturionDestino    (const Value: Integer);
      procedure setFDevice                 (const Value: Integer);
      procedure setFCNPJ                   (const Value: String);
      procedure setFURL                    (const Value: String);
      procedure setFInstiturionOrigem      (const Value: Integer);

    protected
      FCNPJ: String;
      FURL: String;
      FInstitutionDestino: Integer;
      FInstiturionOrigem: Integer;
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
      progresso: TGauge;
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
      procedure inicializa; Virtual;

      property Database : TIBDatabase read FDatabase write setFDatabase;

      property InstiturionOrigem : Integer read FInstiturionOrigem write setFInstiturionOrigem;
      property ListBox           : TListBox read FlistBox write setFListbox;
      property Device            : Integer read FDevice write setFDevice;
      property CNPJ              : String read FCNPJ write setFCNPJ;
      property URL               : String read FURL write setFURL;
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
Var
  LcTime : TDatetime;
  I:Integer;
  LcSincronia : TSincronia;
begin
  FSincronia.Tipo := pTipo;
  FSincronia.Registro.Tabela := pTabela;
  FSincronia.getList;
end;

procedure TBaseSetes.inicializa;
begin
  inherited;
end;

procedure TBaseSetes.setFCNPJ(const Value: String);
begin
  FCNPJ := Value;
end;


procedure TBaseSetes.setFDatabase(const Value: TIBDatabase);
begin
  FDatabase := Value;
end;

procedure TBaseSetes.setFDevice(const Value: Integer);
begin
  FDevice := Value;
end;


procedure TBaseSetes.setFFInstiturionDestino(const Value: Integer);
begin
  FInstitutionDestino := Value;
end;


procedure TBaseSetes.setFInstiturionOrigem(const Value: Integer);
begin
  FInstiturionOrigem := Value;
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
Var
  LcStrDataTime : String;
begin
  with FSincronia.SyncClient.Registro do
  Begin
    Codigo := pTabela;
    Tipo := pTipo;
    Sentido := pSentido;
    LcStrDataTime := DateTimeToStr(Tempo);
    //13/12/2017 01:37:38
    Data := StrToDate(Copy(LcStrDataTime,1,10));
    Hora := StrToTimeDef(Copy(LcStrDataTime,12,8 ),StrToTime('00:00:00'));
  End;
  FSincronia.SyncClient.Estabel := FInstiturionOrigem;
  FSincronia.SyncClient.save;
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
  FInstiturionOrigem := 1;
  FInstitutionDestino := 7756;
end;

end.
