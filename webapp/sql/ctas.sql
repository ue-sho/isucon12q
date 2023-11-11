
DROP TABLE IF EXISTS player;
DROP TABLE IF EXISTS player_score;
DROP TABLE IF EXISTS competition;
DROP TABLE IF EXISTS billing_report;

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
    KEY `idx_player_score_tenant_competition` (`tenant_id`,`competition_id`),
    KEY `idx_player_score_tenant_player` (`tenant_id`,`player_id`)
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

CREATE TABLE `billing_report` (
  `tenant_id` bigint unsigned NOT NULL,
  `competition_id` varchar(255) NOT NULL,
  `competition_title` varchar(255) NOT NULL,
  `player_count` bigint NOT NULL,
  `visitor_count` bigint NOT NULL,
  `billing_player_yen` bigint NOT NULL,
  `billing_visitor_yen` bigint NOT NULL,
  `billing_yen` bigint NOT NULL,
  PRIMARY KEY (`tenant_id`,`competition_id`)
);

INSERT INTO player SELECT * FROM player_init;
INSERT INTO player_score SELECT * FROM player_score_init;
INSERT INTO competition SELECT * FROM competition_init;
INSERT INTO billing_report SELECT * FROM billing_report_init;
