unit ControllerBoletoBancario;

interface

uses IBX.IBDatabase,Classes, IBQuery, SysUtils,ControllerBase,tblCartao,
      Un_sistema,Un_funcoes,Un_Regra_Negocio, tblBoletoBancario ,   Generics.Collections;

Type
  TListaBoletoEletronico = TObjectList<TBoletoBancario>;
  TControllerBoletoBancario = Class(TControllerBase)
    Lista : TListaBoletoEletronico;
  private

  public

    Registro : TBoletoBancario;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure getById;
    function salva:boolean;
    function insere:boolean;
    procedure AlteraVencimentoValor;
    procedure salvaRemessa;
    procedure Clear;
  End;

implementation

{ TControllerBoletoBancario }

procedure TControllerBoletoBancario.Clear;
begin
  clearObj(Registro);
end;

constructor TControllerBoletoBancario.Create(AOwner: TComponent);
begin
  inherited;
  Registro := TBoletoBancario.Create;
  Lista := TListaBoletoEletronico.create;
end;

destructor TControllerBoletoBancario.Destroy;
begin
  FreeAndNil(Lista);
  Registro.DisposeOf;
  inherited;
end;

procedure TControllerBoletoBancario.AlteraVencimentoValor;
Var
  Lc_Qry : TIBQuery;
begin
  Try
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    Begin
      SQL.Add('UPDATE TB_FINANCEIRO SET '+
              'FIN_VL_PARCELA =:FIN_VL_PARCELA,'+
              'FIN_DT_VENCIMENTO=:FIN_DT_VENCIMENTO '+
              'WHERE FIN_CODIGO =:FIN_CODIGO ');
      FieldByName('FIN_VL_PARCELA').AsFloat := Registro.Valor;
      FieldByName('FIN_DT_VENCIMENTO').AsDateTime := Registro.DataVencimento;
      FieldByName('FIN_CODIGO').AsFloat := Registro.Codigo;
      ExecSQL;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;


procedure TControllerBoletoBancario.getById;
begin
  _getByKey(Registro);
end;

function TControllerBoletoBancario.insere: boolean;
begin
  Registro.Codigo := Generator('GN_BOLETO_BANCARIO');
  InsertObj(Registro);
end;

function TControllerBoletoBancario.salva: boolean;
begin
  SaveObj(Registro);
end;

procedure TControllerBoletoBancario.salvaRemessa;
Var
  Lc_Qry : TIBQuery;
  Lc_I : Integer;
  LcReg : TBoletoBancario;
Begin
  TRy
    Lc_Qry := GeraQuery;
    with Lc_Qry do
    BEgin
      Active := False;
      SQL.Clear;
      SQL.Add('UPDATE TB_BOLETO_BANCARIO  SET '+
              'BLT_NR_REMESSA =:BLT_NR_REMESSA, '+
              'BLT_MSG_RETORNO =:BLT_MSG_RETORNO '+
              'WHERE (BLT_CODIGO =:BLT_CODIGO) ');

      For Lc_I := 0 to Lista.Count -1 do
      Begin
        LcReg := TBoletoBancario.Create;
        LcReg := Lista[LC_I];
        Close;
        ParamByName('BLT_NR_REMESSA').AsInteger := LcReg.NumeroRemessa;
        ParamByName('BLT_CODIGO').AsInteger     := LcReg.Codigo;
        ParamByName('BLT_MSG_RETORNO').AsString := LcReg.MensagemRetorno;
        ExecSQL;
      end;
    End;
  Finally
    FinalizaQuery(Lc_Qry);
  End;
end;

end.
