unit un_funcoes;

interface

USES System.SysUtils,IniFiles, System.Classes,REST.Json,System.Json,
  Data.DB, IBX.IBCustomDataSet,IBX.IBQuery,Tlhelp32,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, Vcl.Forms,
  Winapi.Windows;


  function Fc_Generator(pc_Gen: string;pc_NomeTabela:String;Pc_campo : String): Integer;
  function Fc_NomeComputador: string;

  function Fc_BuscaCodigoCidade(fc_IBGE:Integer; Fc_Descricao,Fc_UF:String): Integer;
  function getCamposJsonString(json,value:String): String;
  function Verifica_Rede(porta:Word;ip:String): boolean;
  Function VirgPorPonto(d:Double):String;
  function RemoveAcento(const pText: string): string;
  function getPathExe:String;
  function PadR(AValue: String; const ALength: Integer): String;
  function Pad(AValue: String; const ALength: Integer; const ASide: TAlignment): String;
  function PadL(AValue: String; const ALength: Integer): String;


implementation


uses un_sistema, Un_Msg, un_dm;



function Fc_Generator(pc_Gen: string;pc_NomeTabela:String;Pc_campo : String): Integer;
begin
  REsult := 0;
end;

function Fc_NomeComputador: string;
var
  lpBuffer : PChar;
  nSize : DWord;
const Buff_Size = MAX_COMPUTERNAME_LENGTH + 1;
begin
  nSize := Buff_Size;
  lpBuffer := StrAlloc(Buff_Size);
  GetComputerName(lpBuffer,nSize);
  Result := String(lpBuffer);
  StrDispose(lpBuffer);

end;


function Fc_BuscaCodigoCidade(fc_IBGE:Integer; Fc_Descricao,Fc_UF:String): Integer;
Var
  Lc_Qry : TIBQuery;
begin
  Lc_Qry := TIBQuery.Create(nil);
  with Lc_Qry do
    Begin
    Database := DM.IBD_Gestao;
    Transaction := DM.IBT_Consulta;
    ForcedRefresh := True;
    CachedUpdates := True;
    SQL.Clear;
    if (fc_IBGE > 0) then
      Begin
      SQL.Add('select CDD_CODIGO FROM TB_CIDADE WHERE CDD_IBGE=:CDD_IBGE');
      ParamByName('CDD_IBGE').AsInteger := fc_IBGE;
      end
    else
      Begin
      SQL.Add('select CDD_CODIGO '+
              'FROM TB_CIDADE '+
              'WHERE CDD_DESCRICAO=:CDD_DESCRICAO AND CDD_UF =:CDD_UF');
      ParamByName('CDD_DESCRICAO').AsAnsiString := AnsiString(Fc_Descricao);
      ParamByName('CDD_UF').AsAnsiString := AnsiString(Fc_UF);
      end;
    Active := True;
    FetchAll;
    IF (Recordcount > 0) then
      Result := FieldByName('CDD_CODIGO').AsInteger
    else
      Result := 4004;
    end;
  Lc_Qry.Close;
  FreeAndNil(Lc_Qry);
end;


function getCamposJsonString(json,value:String): String;
var
   LJSONObject: TJSONObject;
   function TrataObjeto(jObj:TJSONObject):string;
   var i:integer;
       jPar: TJSONPair;
   begin
        result := '';
        for i := 0 to jObj.Count - 1 do
        begin
             jPar := jObj.Pairs[i];
             if jPar.JsonValue Is TJSONObject then
                result := TrataObjeto((jPar.JsonValue As TJSONObject)) else
             if sametext(trim(jPar.JsonString.Value),value) then
             begin
                  Result := jPar.JsonValue.Value;
                  break;
             end;
             if result <> '' then
                break;
        end;
   end;
begin
   LJSONObject := nil;
   try
      LJSONObject := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;
      result := TrataObjeto(LJSONObject);
   finally
      LJSONObject.Free;
   end;
end;

function Verifica_Rede(porta:Word;ip:String): boolean;
Var
  LcIdTCPClient : TIdTCPClient;
begin
  try
    LcIdTCPClient := TIdTCPClient.Create(nil);
    LcIdTCPClient.ReadTimeout:=2000;
    LcIdTCPClient.ConnectTimeout:=2000;
    LcIdTCPClient.Port:=porta;
    LcIdTCPClient.Host := ip; // '177.70.22.118'; // ip é um campo que o usuario sete qual o ip da maquina servidora
    try
      LcIdTCPClient.Connect;
      LcIdTCPClient.Disconnect;
      result:=true;
    except
      LcIdTCPClient.Disconnect;
      result:=false;
    end;
  finally
    LcIdTCPClient.Disconnect;
    FreeAndNil(LcIdTCPClient);
  end;
end;

Function VirgPorPonto(d:Double):String;
var
  x:integer;
  s:String;
  Aux:String;
begin
  aux := '';
  s := FloatToStrf(d,ffFixed,10,2);
  For x := 1 To Length(s) do
  if s[x] = ',' then
  Aux := Aux + '.'
  else
  Aux := Aux + s[x];
  Result := Aux;
end;

function RemoveAcento(const pText: string): string;
type
  USAscii20127 = type AnsiString(20127);
begin
  Result := string(USAscii20127(pText));
end;

function getPathExe:String;
Begin
  Result := ExtractFilePath(Application.ExeName) ;
End;

function PadR(AValue: String; const ALength: Integer): String;

begin
  Result := Pad(AValue, ALength, taRightJustify);
end;

function Pad(AValue: String; const ALength: Integer; const ASide: TAlignment): String;
begin
  AValue := Trim(AValue);
  if Length(AValue) > ALength then AValue := Copy(AValue,1,ALength);
  case ASide of
    taLeftJustify:
      while Length(AValue) < ALength do AValue := AValue + ' ';
    taRightJustify:
      while Length(AValue) < ALength do AValue := ' ' + AValue;
    taCenter:
      while Length(AValue) < ALength do
        if (Length(AValue) mod 2)=0 then
          AValue := AValue + ' '
        else
          AValue := ' ' + AValue;
  end;
  Result := AValue;
end;

function PadL(AValue: String; const ALength: Integer): String;
begin
  Result := Pad(AValue, ALength, taLeftJustify);
end;


end.
