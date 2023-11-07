
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;
DROP TABLE IF EXISTS competition;

CREATE TABLE player AS SELECT * FROM player_init;
CREATE TABLE player_score AS SELECT * FROM player_score_init;
CREATE TABLE competition AS SELECT * FROM competition_init;

CREATE INDEX idx_player_tenant_id ON player (tenant_id);
CREATE INDEX idx_player_score_all ON player_score (tenant_id, competition_id, player_id);
CREATE INDEX idx_competition_tenant_id ON competition (tenant_id);
