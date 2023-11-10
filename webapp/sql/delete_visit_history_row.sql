INSERT INTO visit_history_tmp SELECT * FROM visit_history;

TRUNCATE visit_history;

INSERT INTO visit_history SELECT player_id, tenant_id, competition_id,
  min(created_at) AS created_at, min(updated_at) AS updated_at
  FROM visit_history_tmp GROUP BY player_id, tenant_id, competition_id;
