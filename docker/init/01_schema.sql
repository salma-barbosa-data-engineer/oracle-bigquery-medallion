-- Esquema de origem: um pequeno sistema de vendas (OLTP)
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = APP;

CREATE TABLE clientes (
  id          NUMBER(10)    PRIMARY KEY,
  nome        VARCHAR2(100) NOT NULL,
  email       VARCHAR2(120),
  cidade      VARCHAR2(80),
  uf          CHAR(2),
  created_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
  updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE produtos (
  id          NUMBER(10)    PRIMARY KEY,
  nome        VARCHAR2(100) NOT NULL,
  categoria   VARCHAR2(50),
  preco       NUMBER(10,2)  NOT NULL,
  updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE pedidos (
  id          NUMBER(10)    PRIMARY KEY,
  cliente_id  NUMBER(10)    NOT NULL REFERENCES clientes(id),
  data_pedido TIMESTAMP     NOT NULL,
  status      VARCHAR2(20)  NOT NULL,
  updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

CREATE TABLE itens_pedido (
  id             NUMBER(10)   PRIMARY KEY,
  pedido_id      NUMBER(10)   NOT NULL REFERENCES pedidos(id),
  produto_id     NUMBER(10)   NOT NULL REFERENCES produtos(id),
  quantidade     NUMBER(5)    NOT NULL,
  preco_unitario NUMBER(10,2) NOT NULL,
  updated_at     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL
);

-- Índices para a carga incremental (filtro por updated_at)
CREATE INDEX ix_clientes_upd     ON clientes(updated_at);
CREATE INDEX ix_produtos_upd     ON produtos(updated_at);
CREATE INDEX ix_pedidos_upd      ON pedidos(updated_at);
CREATE INDEX ix_itens_pedido_upd ON itens_pedido(updated_at);
