-- ============================================================
-- TB_LISTA_SINCRONIA
-- Tabela de configuração do sincronizador
-- WAY: 'E' = Enviar (PDV → Retaguarda) | 'R' = Receber (Retaguarda → PDV)
-- SET_ON: 'S' = ativo | 'N' = inativo
-- KIND: tipo de operação (valor domínio não definido no código)
-- ============================================================

CREATE TABLE TB_LISTA_SINCRONIA (
    WAY          VARCHAR(1)   NOT NULL,
    DESC_TABELA  VARCHAR(60)  NOT NULL,
    KIND         VARCHAR(20)  NOT NULL,
    DESC_PROCESS VARCHAR(100),
    SEQ          INTEGER,
    DESC_FIELD   VARCHAR(60),
    DESC_TRIGGER VARCHAR(60),
    NOTE         VARCHAR(255),
    SET_ON       VARCHAR(1),
    CLASS_NAME   VARCHAR(100),
    END_POINT    VARCHAR(200),
    CONSTRAINT PK_LISTA_SINCRONIA PRIMARY KEY (WAY, DESC_TABELA, KIND)
);

COMMENT ON TABLE  TB_LISTA_SINCRONIA              IS 'Configuração das entidades a sincronizar';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.WAY          IS 'Direção: E=Enviar PDV->Web, R=Receber Web->PDV';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.DESC_TABELA  IS 'Nome da tabela Firebird monitorada';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.KIND         IS 'Tipo/categoria da sincronização';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.DESC_PROCESS IS 'Descrição legível do processo';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.SEQ          IS 'Ordem de execução (ORDER BY SEQ)';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.DESC_FIELD   IS 'Campo chave monitorado na tabela';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.DESC_TRIGGER IS 'Nome da trigger associada';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.NOTE         IS 'Observações';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.SET_ON       IS 'Ativo: S=Sim, N=Não';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.CLASS_NAME   IS 'Nome da classe Delphi instanciada pela factory via RTTI';
COMMENT ON COLUMN TB_LISTA_SINCRONIA.END_POINT    IS 'Rota da API Node.js (ex: /api/customers)';