unit measure_send_web;


interface

uses System.SysUtils,general_web,REST.Json, ControllerMedida, System.JSON;

Type
  TMeasureSendWeb = class(TGeneralWeb)
    private
      FCtrl: TControllerMedida;
    protected
      procedure GenerateJson;Override;
    public
    constructor Create;override;
    destructor Destroy;override;
  end;

implementation

uses un_dm;

{ TGeneralWeb }

constructor TMeasureSendWeb.Create;
begin
  inherited;
  FCtrl := TControllerMedida.Create(nil);
end;

destructor TMeasureSendWeb.Destroy;
begin
  FreeAndNil(FCtrl);
  inherited;
end;

procedure TMeasureSendWeb.GenerateJson;
Var
  LcJson: TJSONObject;
begin
  inherited;
  FCtrl.Registro.Codigo := FCodigo;
  FCtrl.getbyid;
  if FCtrl.exist then
  Begin
    // Contrato /measure/sincronize (endpoint NOVO): SEM id, SEM institution —
    // catálogo central, dedupe por descrição (mesmo padrão do brand/package).
    LcJson := TJSONObject.Create;
    try
      LcJson.AddPair('description', FCtrl.Registro.Descricao);
      LcJson.AddPair('abbreviation', FCtrl.Registro.Abreviatura);
      // MED_ESCALA é String no Firebird (ex.: '1') — convertido para número.
      LcJson.AddPair('escale', TJSONNumber.Create(StrToIntDef(FCtrl.Registro.Escala, 1)));
      // decisao 8: le o DELETED real da tabela
      LcJson.AddPair('deleted', DM.GetDeletedFlag('TB_MEDIDA', 'MED_CODIGO', FCodigo));
      FStrJson := LcJson.ToJSON;
    finally
      LcJson.Free;
    end;
  End;
end;


end.

