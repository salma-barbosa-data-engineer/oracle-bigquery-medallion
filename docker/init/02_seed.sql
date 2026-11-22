-- Dados de exemplo para a primeira carga
ALTER SESSION SET CONTAINER = FREEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = APP;

INSERT INTO clientes (id, nome, email, cidade, uf) VALUES (1, 'Ana Souza',     'ana@email.com',     'São Paulo',      'SP');
INSERT INTO clientes (id, nome, email, cidade, uf) VALUES (2, 'Bruno Lima',    'bruno@email.com',   'Campinas',       'SP');
INSERT INTO clientes (id, nome, email, cidade, uf) VALUES (3, 'Carla Mendes',  'carla@email.com',   'Belo Horizonte', 'MG');
INSERT INTO clientes (id, nome, email, cidade, uf) VALUES (4, 'Diego Rocha',   'diego@email.com',   'Curitiba',       'PR');
INSERT INTO clientes (id, nome, email, cidade, uf) VALUES (5, 'Elisa Martins', 'elisa@email.com',   'Rio de Janeiro', 'RJ');

INSERT INTO produtos (id, nome, categoria, preco) VALUES (1, 'Notebook',       'Informática', 4500.00);
INSERT INTO produtos (id, nome, categoria, preco) VALUES (2, 'Mouse sem fio',  'Informática',  120.00);
INSERT INTO produtos (id, nome, categoria, preco) VALUES (3, 'Cadeira gamer',  'Móveis',      1350.00);
INSERT INTO produtos (id, nome, categoria, preco) VALUES (4, 'Monitor 27"',    'Informática', 1899.90);
INSERT INTO produtos (id, nome, categoria, preco) VALUES (5, 'Mesa de escritório', 'Móveis',   980.00);

INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (1, 1, TIMESTAMP '2026-11-01 10:15:00', 'ENTREGUE');
INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (2, 2, TIMESTAMP '2026-11-01 14:30:00', 'ENTREGUE');
INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (3, 3, TIMESTAMP '2026-11-02 09:00:00', 'CANCELADO');
INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (4, 1, TIMESTAMP '2026-11-03 18:45:00', 'ENVIADO');
INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (5, 4, TIMESTAMP '2026-11-03 20:10:00', 'ENTREGUE');
INSERT INTO pedidos (id, cliente_id, data_pedido, status) VALUES (6, 5, TIMESTAMP '2026-11-04 11:20:00', 'PAGO');

INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (1,  1, 1, 1, 4500.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (2,  1, 2, 2,  120.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (3,  2, 4, 1, 1899.90);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (4,  3, 3, 1, 1350.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (5,  4, 5, 1,  980.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (6,  4, 3, 1, 1350.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (7,  5, 2, 3,  120.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (8,  6, 1, 1, 4500.00);
INSERT INTO itens_pedido (id, pedido_id, produto_id, quantidade, preco_unitario) VALUES (9,  6, 4, 2, 1899.90);

COMMIT;
