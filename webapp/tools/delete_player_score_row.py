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


def delete_player_score_row(id: int):
    tenant_db = connect_to_tenant_db(id)
    player_scores = tenant_db.execute("SELECT * FROM player_score ORDER BY row_num DESC").fetchall()

    last_score_dict = {}
    for player_score in player_scores:
        player_id = player_score["player_id"]
        if player_id in last_score_dict:
            continue
        last_score_dict[player_id] = player_score

    tenant_db.execute("""
CREATE TABLE player_score2 (
    id VARCHAR(255) NOT NULL PRIMARY KEY,
    tenant_id BIGINT NOT NULL,
    player_id VARCHAR(255) NOT NULL,
    competition_id VARCHAR(255) NOT NULL,
    score BIGINT NOT NULL,
    row_num BIGINT NOT NULL,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
)
""")

    with tenant_db.connect() as conn:
        for player_score in last_score_dict.values():
            conn.execute("""
    INSERT INTO player_score2 (id, tenant_id, player_id, competition_id, score, row_num, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (player_score["id"], player_score["tenant_id"], player_score["player_id"], player_score["competition_id"], player_score["score"], player_score["row_num"], player_score["created_at"], player_score["updated_at"]))


def main():
    for i in range(1, 101):
        print(i)
        delete_player_score_row(i)


if __name__ == "__main__":
    main()