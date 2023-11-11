CREATE TABLE `visit_history_tmp` (
  `player_id` varchar(255) NOT NULL,
  `tenant_id` bigint unsigned NOT NULL,
  `competition_id` varchar(255) NOT NULL,
  `created_at` bigint NOT NULL,
  `updated_at` bigint NOT NULL,
  KEY `tenant_id_idx` (`tenant_id`),
  KEY `idx_all_cover` (`tenant_id`,`competition_id`,`player_id`,`created_at`)
);

INSERT INTO visit_history_tmp SELECT * FROM visit_history;

TRUNCATE visit_history;

INSERT INTO visit_history SELECT player_id, tenant_id, competition_id, min(created_at) AS created_at, min(updated_at) AS updated_at FROM visit_history_tmp GROUP BY player_id, tenant_id, competition_id;
