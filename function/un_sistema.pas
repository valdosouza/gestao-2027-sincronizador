unit un_sistema;

interface

uses
  ibx.IBQuery, ControllerGeral, System.SysUtils, un_funcoes, System.IniFiles,
  Vcl.Forms, IdRawBase, IdRawClient, IdIcmpClient;

  function Fc_Tb_Geral(Fc_Tipo: char; Fc_CAmpo: string; Fc_Conteudo: string): string;
  function Fc_Aq_Geral(Fc_TipoOper: string; Fc_Secao: string; Fc_CHave: string; Fc_Valor: string): string;

  function VerificaConectaBanco(Conncec:Boolean;PathBD:String):Boolean;
  function ConectaBancoServidor(Conncec:Boolean):Boolean;

  Function Fc_PingConectadoSetes():Boolean;

//   function Fc_Generator(pc_Gen: string;pc_NomeTabela:String;Pc_campo : String): Integer;
var
  GbStartWin : Boolean;
  Gb_Terminal : Integer;
implementation

uses un_dm;


function Fc_Tb_Geral(Fc_Tipo: char; Fc_CAmpo: string; Fc_Conteudo: string): string;
Var
  Lc_Geral : TControllerGeral;
begin
  Try
    Lc_Geral := TControllerGeral.Create(nil);
    with Lc_Geral do
    Begin
      Registro.Campo := Fc_CAmpo;
      Registro.Conteudo := Fc_Conteudo;
      Registro.CodigoEstabelecimento := StrToIntDef(Fc_Aq_Geral('L','SINCRONIA', 'estabelecimento','30'),30);
      if Fc_Tipo = 'G' then
      Begin
        salva;
      End
      else
      Begin
        getById;
        if not exist then salva;
      End;
      Result := Registro.Conteudo;
    End;
  Finally
    FreeAndNil(Lc_Geral);
  End;
end;

function Fc_Aq_Geral(Fc_TipoOper: string; Fc_Secao: string; Fc_CHave: string; fc_Valor: string): string;
var
   ArquivoIni: TIniFile;
   Lc_NameArq: string;

   Lc_Resultado: string;
begin
   Lc_NameArq := getPathExe + 'CONFIG.INI';
   ArquivoIni := TIniFile.Create(Lc_NameArq);
   if Fc_TipoOper = 'L' then
   begin
      if ArquivoIni.SectionExists(Fc_Secao) then
      begin
         Lc_Resultado := ArquivoIni.ReadString(Fc_Secao, Fc_CHave, Lc_Resultado);
         Result := Lc_Resultado;
         ArquivoIni.DisposeOf;
         exit;
      end
      else
      begin
      ArquivoIni.WriteString(Fc_Secao, Fc_CHave, Fc_Valor);
      Result := Lc_Resultado;
      ArquivoIni.DisposeOf;
      end;
   end
   else
   begin
      ArquivoIni.WriteString(Fc_Secao, Fc_CHave, Fc_Valor);
      Result := Lc_Resultado;
      ArquivoIni.DisposeOf;
   end;
end;


function VerificaConectaBanco(Conncec:Boolean;PathBD:String):Boolean;
Var
  lcDM : TDM;
Begin
  Result := True;
  if Conncec then
  Begin
    if ( Trim( PathBD )<> '' ) then
    Begin
      lcDM := TDM.Create(Application);
      try
        Try
          lcDM.IBD_Gestao.Close;
          lcDM.IBD_Gestao.DatabaseName := PathBD;
          lcDM.IBD_Gestao.Connected := True;
        Except
          lcDM.IBD_Gestao.Connected := False;
          Result := False;
        End;
      finally
        lcDM.IBD_Gestao.Close;
        lcDM.DisposeOf;
      end;
    End;
  End;
End;

function ConectaBancoServidor(Conncec:Boolean):Boolean;
Begin
  Result := True;
  if Conncec then
  Begin
    if not DM.IBD_Servidor.Connected then
    Begin
      Try
        DM.IBD_Servidor.DatabaseName := Fc_Aq_Geral('L','SINCRONIA', 'BDPathBDLocal','');
        DM.IBD_Servidor.Connected := True;
      Except
        DM.IBD_Servidor.Connected := False;
      End;
    End;
  End
  else
  Begin
    DM.IBD_Servidor.Connected := False;
  End;

End;

Function Fc_PingConectadoSetes():Boolean;
Var
  Lc_ICMP: TIdIcmpClient;
begin
  Lc_ICMP := TIdIcmpClient.Create(nil);
  try
    try
      Lc_ICMP.Host := '200.150.205.102';
      Lc_ICMP.Ping();
      Result := (Lc_ICMP.ReplyStatus.BytesReceived > 0);
    except
      Result := False;
    end;
  finally
    Lc_ICMP.disposeOf;
  end;
end;




end.
