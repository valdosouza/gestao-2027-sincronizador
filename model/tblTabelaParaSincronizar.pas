unit tblTabelaParaSincronizar;

interface

Uses GenericEntity,CAtribEntity, Classes, SysUtils;

Type
  //nome da classe de entidade
  [TableName('TB_LISTA_SINCRONIA')]
  TTabelaParaSincronizar = Class(TGenericEntity)//esse nome é diferente da tabela porqque há conflito com outro a lista de da tabela sincronia.
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

  End;
implementation


{ TTabelaParaSincronizar }

procedure TTabelaParaSincronizar.setFCLASS_NAME(const Value: String);
begin
  FCLASS_NAME := Value;
end;

procedure TTabelaParaSincronizar.setFDESC_FIELD(const Value: String);
begin
  FDESC_FIELD := Value;
end;

procedure TTabelaParaSincronizar.setFDESC_PROCESS(const Value: String);
begin
  FDESC_PROCESS := Value;
end;

procedure TTabelaParaSincronizar.setFDESC_TABELA(const Value: String);
begin
  FDESC_TABELA := Value;
end;

procedure TTabelaParaSincronizar.setFDESC_TRIGGER(const Value: String);
begin
  FDESC_TRIGGER := Value;
end;

procedure TTabelaParaSincronizar.setFEND_POINT(const Value: String);
begin
  FEND_POINT := Value;
end;

procedure TTabelaParaSincronizar.setFKIND(const Value: String);
begin
  FKIND := Value;
end;

procedure TTabelaParaSincronizar.setFNOTE(const Value: String);
begin
  FNOTE := Value;
end;

procedure TTabelaParaSincronizar.setFSEQ(const Value: Integer);
begin
  FSEQ := Value;
end;

procedure TTabelaParaSincronizar.setFSET_ON(const Value: String);
begin
  FSET_ON := Value;
end;

procedure TTabelaParaSincronizar.setFWAY(const Value: String);
begin
  FWAY := Value;
end;

end.
