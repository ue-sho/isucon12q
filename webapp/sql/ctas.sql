
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;
DROP TABLE IF EXISTS competition;

CREATE TABLE player AS SELECT * FROM player_init;
CREATE TABLE player_score AS SELECT * FROM player_score_init;
CREATE TABLE competition AS SELECT * FROM competition_init;
