unit tblListaSincronia;

interface

Uses GenericEntity,CAtribEntity, Classes, SysUtils;

Type
  // Catalogo das tabelas sincronizaveis (decisao 4 do prompt de construcao do
  // banco do cliente — antes: tblTabelaParaSincronizar/TTabelaParaSincronizar).
  // LAST_UPDATE (decisao 3) e o checkpoint do ultimo registro processado por
  // linha (WAY+DESC_TABELA+KIND) — substitui a antiga TB_SYNC_TABLE (decisao 1).
  [TableName('TB_LISTA_SINCRONIA')]
  TListaSincronia = Class(TGenericEntity)
  private
    FSEQ: Integer;
    FSET_ON: String;
    FDESC_PROCESS: String;
    FDESC_TABELA: String;
    FNOTE: String;
    FCLASS_NAME: String;
    FDESC_TRIGGER: String;
    FDESC_FIELD: String;
    FWAY: String;
    FKIND: String;
    FEND_POINT: String;
    FLAST_UPDATE: TDateTime;
    procedure setFCLASS_NAME(const Value: String);
    procedure setFDESC_FIELD(const Value: String);
    procedure setFDESC_PROCESS(const Value: String);
    procedure setFDESC_TABELA(const Value: String);
    procedure setFDESC_TRIGGER(const Value: String);
    procedure setFEND_POINT(const Value: String);
    procedure setFKIND(const Value: String);
    procedure setFNOTE(const Value: String);
    procedure setFSEQ(const Value: Integer);
    procedure setFSET_ON(const Value: String);
    procedure setFWAY(const Value: String);
    procedure setFLAST_UPDATE(const Value: TDateTime);
  Public

    [KeyField('WAY')]
    [FieldName('WAY')]
    property Sentido: String read FWAY write setFWAY;

    [KeyField('DESC_TABELA')]
    [FieldName('DESC_TABELA')]
    property Tabela: String read FDESC_TABELA write setFDESC_TABELA;

    [KeyField('KIND')]
    [FieldName('KIND')]
    property Tipo: String read FKIND write setFKIND;

    [FieldName('DESC_PROCESS')]
    property DescricaoProcesso: String read FDESC_PROCESS write setFDESC_PROCESS;

    [FieldName('SEQ')]
    property Sequence: Integer read FSEQ write setFSEQ;

    [FieldName('DESC_FIELD')]
    property Campo: String read FDESC_FIELD write setFDESC_FIELD;

    [FieldName('DESC_TRIGGER')]
    property Trigger: String read FDESC_TRIGGER write setFDESC_TRIGGER;

    [FieldName('NOTE')]
    property Obsevacao: String read FNOTE write setFNOTE;

    [FieldName('SET_ON')]
    property ativo: String read FSET_ON write setFSET_ON;

    [FieldName('CLASS_NAME')]
    property NomeClasse: String read FCLASS_NAME write setFCLASS_NAME;

    [FieldName('END_POINT')]
    property EndPoint: String read FEND_POINT write setFEND_POINT;

    // Checkpoint: data/hora do ultimo registro enviado/recebido com sucesso.
    // NULL no banco = nunca sincronizou (processa tudo desde o inicio).
    [FieldName('LAST_UPDATE')]
    property LastUpdate: TDateTime read FLAST_UPDATE write setFLAST_UPDATE;

  End;
implementation


{ TListaSincronia }

procedure TListaSincronia.setFCLASS_NAME(const Value: String);
begin
  FCLASS_NAME := Value;
end;

procedure TListaSincronia.setFDESC_FIELD(const Value: String);
begin
  FDESC_FIELD := Value;
end;

procedure TListaSincronia.setFDESC_PROCESS(const Value: String);
begin
  FDESC_PROCESS := Value;
end;

procedure TListaSincronia.setFDESC_TABELA(const Value: String);
begin
  FDESC_TABELA := Value;
end;

procedure TListaSincronia.setFDESC_TRIGGER(const Value: String);
begin
  FDESC_TRIGGER := Value;
end;

procedure TListaSincronia.setFEND_POINT(const Value: String);
begin
  FEND_POINT := Value;
end;

procedure TListaSincronia.setFKIND(const Value: String);
begin
  FKIND := Value;
end;

procedure TListaSincronia.setFNOTE(const Value: String);
begin
  FNOTE := Value;
end;

procedure TListaSincronia.setFSEQ(const Value: Integer);
begin
  FSEQ := Value;
end;

procedure TListaSincronia.setFSET_ON(const Value: String);
begin
  FSET_ON := Value;
end;

procedure TListaSincronia.setFWAY(const Value: String);
begin
  FWAY := Value;
end;

procedure TListaSincronia.setFLAST_UPDATE(const Value: TDateTime);
begin
  FLAST_UPDATE := Value;
end;

end.
