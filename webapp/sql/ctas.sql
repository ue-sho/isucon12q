
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;
DROP TABLE IF EXISTS competition;

CREATE TABLE `player` (
    `id` varchar(255) NOT NULL,
    `tenant_id` bigint NOT NULL,
    `display_name` text NOT NULL,
    `is_disqualified` tinyint(1) NOT NULL,
    `created_at` bigint NOT NULL,
    `updated_at` bigint NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_player_tenant_id` (`tenant_id`)
);

CREATE TABLE `player_score` (
    `id` varchar(255) NOT NULL,
    `tenant_id` bigint NOT NULL,
    `player_id` varchar(255) NOT NULL,
    `competition_id` varchar(255) NOT NULL,
    `score` bigint NOT NULL,
    `row_num` bigint NOT NULL,
    `created_at` bigint NOT NULL,
    `updated_at` bigint NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_player_score_all` (`tenant_id`,`competition_id`,`player_id`)
);

CREATE TABLE `competition` (
    `id` varchar(255) NOT NULL,
    `tenant_id` bigint NOT NULL,
    `title` text NOT NULL,
    `finished_at` bigint DEFAULT NULL,
    `created_at` bigint NOT NULL,
    `updated_at` bigint NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_competition_tenant_id` (`tenant_id`)
);

INSERT INTO player SELECT * FROM player_init;
INSERT INTO player_score SELECT * FROM player_score_init;
INSERT INTO competition SELECT * FROM competition_init;
