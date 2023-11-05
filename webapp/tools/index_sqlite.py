import os
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def tenant_db_path(id: int) -> str:
    """テナントDBのパスを返す"""
    tenant_db_dir = os.getenv("ISUCON_TENANT_DB_DIR", "../tenant_db")
    return tenant_db_dir + f"/{id}.db"


def connect_to_tenant_db(id: int) -> Engine:
    """テナントDBに接続する"""
    path = tenant_db_path(id)
    print(path)
    engine = create_engine(f"sqlite:///{path}")
    return engine


for i in range(1, 101):
    tenant_db = connect_to_tenant_db(i)
    tenant_db.execute("CREATE INDEX tenant_id_idx_competition ON competition (tenant_id)")
    tenant_db.execute("CREATE INDEX tenant_id_idx_player ON player (tenant_id)")
    tenant_db.execute("CREATE INDEX score_idx ON player_score (tenant_id, competition_id, player_id)")
