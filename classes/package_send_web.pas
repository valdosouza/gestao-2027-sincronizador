unit package_send_web;

interface

uses System.SysUtils,general_web,REST.Json, ControllerEmbalagem,  System.JSON;

Type
  TPackageSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerEmbalagem;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TPackageSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerEmbalagem.Create(nil);
end;

destructor TPackageSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TPackageSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    // Contrato /package/sincronize: SEM id, SEM institution, SEM active
    // fantasma (TEmbalagem/tb_embalagem não tem coluna de ativo) — só
    // description/abbreviation/deleted, mesmo padrão do brand.
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('abbreviation', FCtrl.Registro.Abreviatura);
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_EMBALAGEM', 'EMB_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

