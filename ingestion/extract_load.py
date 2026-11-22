"""
Ingestão Oracle -> GCS (raw) -> BigQuery (bronze).

Para cada tabela de origem:
  1. Lê a marca d'água (maior updated_at já carregado) da tabela bronze.
  2. Extrai do Oracle somente as linhas novas ou alteradas (carga incremental).
  3. Grava um arquivo Parquet na camada raw do Cloud Storage, particionado por data.
  4. Carrega esse arquivo na tabela bronze do BigQuery em modo append.

As camadas silver e gold são construídas depois pelo Dataform (pasta dataform/).
"""

import logging
import os
import tempfile
from datetime import datetime, timezone

import oracledb
import pandas as pd
from dotenv import load_dotenv
from google.api_core.exceptions import NotFound
from google.cloud import bigquery, storage

load_dotenv()

logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")
log = logging.getLogger("ingestao")

GCP_PROJECT = os.environ["GCP_PROJECT"]
GCS_BUCKET = os.environ["GCS_BUCKET"]
BQ_BRONZE_DATASET = os.getenv("BQ_BRONZE_DATASET", "bronze")
BQ_LOCATION = os.getenv("BQ_LOCATION", "US")

# Tabela de origem -> coluna usada como marca d'água da carga incremental
TABELAS = {
    "CLIENTES": "UPDATED_AT",
    "PRODUTOS": "UPDATED_AT",
    "PEDIDOS": "UPDATED_AT",
    "ITENS_PEDIDO": "UPDATED_AT",
}


def conectar_oracle() -> oracledb.Connection:
    return oracledb.connect(
        user=os.environ["ORACLE_USER"],
        password=os.environ["ORACLE_PASSWORD"],
        dsn=os.environ["ORACLE_DSN"],  # ex.: localhost:1521/FREEPDB1
    )


def ler_marca_dagua(bq: bigquery.Client, tabela: str):
    """Retorna o maior updated_at já carregado na bronze, ou None na primeira carga."""
    tabela_bq = f"{GCP_PROJECT}.{BQ_BRONZE_DATASET}.{tabela.lower()}"
    try:
        bq.get_table(tabela_bq)
    except NotFound:
        return None
    linha = next(iter(bq.query(f"SELECT MAX(updated_at) AS wm FROM `{tabela_bq}`").result()))
    wm = linha.wm
    # O Oracle recebe o valor sem fuso horário
    return wm.replace(tzinfo=None) if wm is not None else None


def extrair(conn: oracledb.Connection, tabela: str, coluna_wm: str, marca_dagua) -> pd.DataFrame:
    sql = f"SELECT * FROM {tabela}"
    params = {}
    if marca_dagua is not None:
        sql += f" WHERE {coluna_wm} > :wm"
        params["wm"] = marca_dagua
    with conn.cursor() as cur:
        cur.execute(sql, params)
        colunas = [c[0].lower() for c in cur.description]
        return pd.DataFrame(cur.fetchall(), columns=colunas)


def gravar_raw(gcs: storage.Client, df: pd.DataFrame, tabela: str, agora: datetime) -> str:
    """Grava o lote como Parquet em gs://<bucket>/raw/<tabela>/dt=AAAA-MM-DD/ e devolve a URI."""
    caminho = f"raw/{tabela.lower()}/dt={agora:%Y-%m-%d}/{tabela.lower()}_{agora:%Y%m%dT%H%M%S}.parquet"
    with tempfile.TemporaryDirectory() as tmp:
        arquivo_local = os.path.join(tmp, "lote.parquet")
        df.to_parquet(arquivo_local, index=False)
        gcs.bucket(GCS_BUCKET).blob(caminho).upload_from_filename(arquivo_local)
    return f"gs://{GCS_BUCKET}/{caminho}"


def carregar_bronze(bq: bigquery.Client, uri: str, tabela: str) -> None:
    destino = f"{GCP_PROJECT}.{BQ_BRONZE_DATASET}.{tabela.lower()}"
    config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        schema_update_options=[bigquery.SchemaUpdateOption.ALLOW_FIELD_ADDITION],
    )
    bq.load_table_from_uri(uri, destino, job_config=config).result()


def main() -> None:
    bq = bigquery.Client(project=GCP_PROJECT, location=BQ_LOCATION)
    gcs = storage.Client(project=GCP_PROJECT)
    bq.create_dataset(f"{GCP_PROJECT}.{BQ_BRONZE_DATASET}", exists_ok=True)

    agora = datetime.now(timezone.utc)
    with conectar_oracle() as conn:
        for tabela, coluna_wm in TABELAS.items():
            wm = ler_marca_dagua(bq, tabela)
            df = extrair(conn, tabela, coluna_wm, wm)
            if df.empty:
                log.info("%s: nenhuma linha nova desde %s", tabela, wm)
                continue

            # Metadados de linhagem
            df["_ingested_at"] = agora
            df["_source"] = f"oracle.{tabela.lower()}"

            uri = gravar_raw(gcs, df, tabela, agora)
            carregar_bronze(bq, uri, tabela)
            log.info("%s: %d linhas | marca d'água anterior: %s | %s", tabela, len(df), wm, uri)


if __name__ == "__main__":
    main()
