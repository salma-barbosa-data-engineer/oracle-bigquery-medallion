// Tabelas da camada bronze, carregadas pelo script ingestion/extract_load.py.
// Declará-las permite usar ref("bronze", "<tabela>") e ver a linhagem no Dataform.
["clientes", "produtos", "pedidos", "itens_pedido"].forEach((tabela) =>
  declare({
    schema: "bronze",
    name: tabela,
    description: `Cópia append-only da tabela ${tabela.toUpperCase()} do Oracle, com metadados de ingestão.`,
  })
);
