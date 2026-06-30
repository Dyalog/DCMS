-- Events and their types.

CREATE TABLE `event_type` (
  `id`          int unsigned NOT NULL AUTO_INCREMENT,
  `type`        varchar(256) NOT NULL,
  `description` text,
  `url_slug`    varchar(128),
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`  varchar(128),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_event_type_slug` (`url_slug`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `event` (
  `id`         int unsigned NOT NULL AUTO_INCREMENT,
  `title`      varchar(256) NOT NULL,
  `type_id`    int unsigned,                       -- was `type`
  `start`      datetime,                           -- event start
  `end`        datetime,                           -- event end
  `url_slug`   varchar(256),                       -- human-readable id for URLs
  `location`   varchar(512),
  `logo`       varchar(256),
  `icon`       varchar(256),
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_event_slug` (`url_slug`),
  CONSTRAINT `fk_event_type` FOREIGN KEY (`type_id`)
    REFERENCES `event_type`(`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
