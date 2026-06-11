-- People & organisations.

CREATE TABLE `organisation` (
  `id`         int unsigned NOT NULL AUTO_INCREMENT,
  `name`       varchar(256) NOT NULL,
  `url`        varchar(2048),
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `person` (
  `id`              int unsigned NOT NULL AUTO_INCREMENT,
  `name`            varchar(128) NOT NULL,
  `role`            varchar(128),   -- current role at organisation
  `role_summary`    text,           -- summary of role at organisation
  `description`     text,           -- general biography
  `location`        varchar(128),   -- e.g. country mostly based in
  `organisation_id` int unsigned,
  `created_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`      varchar(128),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_person_organisation` FOREIGN KEY (`organisation_id`)
    REFERENCES `organisation`(`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
