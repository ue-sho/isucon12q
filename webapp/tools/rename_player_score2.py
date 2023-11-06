import os
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine


def tenant_db_path(id: int) -> str:
    """テナントDBのパスを返す"""
    tenant_db_dir = os.getenv("ISUCON_TENANT_DB_DIR", "../../initial_data")
    return tenant_db_dir + f"/{id}.db"


def connect_to_tenant_db(id: int) -> Engine:
    """テナントDBに接続する"""
    path = tenant_db_path(id)
    engine = create_engine(f"sqlite:///{path}")
    return engine


def rename_player_score(id: int):
    tenant_db = connect_to_tenant_db(id)
    tenant_db.execute("DROP TABLE player_score")
    tenant_db.execute("ALTER TABLE player_score2 RENAME TO player_score")


def main():
    for i in range(1, 101):
        print(i)
        rename_player_score(i)


if __name__ == "__main__":
    main()
