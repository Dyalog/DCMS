-- Presentations, their types/categories, presenters, and media links.
-- Depends on: event (02), person + organisation (01), youtube_video (03).
--   presentation_video : direct presentation <-> youtube_video link
--                         (replaces polymorphic presentation_media type='youtube_video')
--   presentation_media  : free-text link rows (slides, PDFs, …) attached directly
--                         to a presentation (replaces media_general + the join)

CREATE TABLE `presentation_type` (
  `id`          int unsigned NOT NULL AUTO_INCREMENT,
  `type`        varchar(256) NOT NULL,
  `description` text,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`  varchar(128),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `presentation_category` (
  `id`          int unsigned NOT NULL AUTO_INCREMENT,
  `category`    varchar(256) NOT NULL,
  `description` text,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`  varchar(128),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `presentation` (
  `id`           int unsigned NOT NULL AUTO_INCREMENT,
  `event_id`     int unsigned,
  `code`         varchar(10),         -- unique code within the event
  `title`        varchar(256),
  `presented_at` datetime,
  `abstract`     varchar(256),
  `description`  text,
  `category_id`  int unsigned,
  `type_id`      int unsigned,
  `location`     varchar(512),        -- sub-location e.g. room/auditorium
  `created_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`   varchar(128),
  PRIMARY KEY (`id`),
  KEY `idx_presentation_presented_at` (`presented_at`),
  CONSTRAINT `fk_presentation_event` FOREIGN KEY (`event_id`)
    REFERENCES `event`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_presentation_type` FOREIGN KEY (`type_id`)
    REFERENCES `presentation_type`(`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_presentation_category` FOREIGN KEY (`category_id`)
    REFERENCES `presentation_category`(`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `presenter` (
  `id`              int unsigned NOT NULL AUTO_INCREMENT,
  `presentation_id` int unsigned NOT NULL,
  `person_id`       int unsigned NOT NULL,
  `organisation_id` int unsigned,        -- was `affiliation`: org at time of presentation
  `created_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`      varchar(128),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_presenter` (`presentation_id`, `person_id`),
  CONSTRAINT `fk_presenter_presentation` FOREIGN KEY (`presentation_id`)
    REFERENCES `presentation`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_presenter_person` FOREIGN KEY (`person_id`)
    REFERENCES `person`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_presenter_organisation` FOREIGN KEY (`organisation_id`)
    REFERENCES `organisation`(`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `presentation_video` (
  `id`               int unsigned NOT NULL AUTO_INCREMENT,
  `presentation_id`  int unsigned NOT NULL,
  `youtube_video_id` int unsigned NOT NULL,
  `created_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`       varchar(128),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_presentation_video` (`presentation_id`, `youtube_video_id`),
  CONSTRAINT `fk_pv_presentation` FOREIGN KEY (`presentation_id`)
    REFERENCES `presentation`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_pv_video` FOREIGN KEY (`youtube_video_id`)
    REFERENCES `youtube_video`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `presentation_media` (
  `id`              int unsigned NOT NULL AUTO_INCREMENT,
  `presentation_id` int unsigned NOT NULL,
  `text`            varchar(512),    -- link text
  `url`             varchar(2048),   -- link URL
  `created_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`      varchar(128),
  PRIMARY KEY (`id`),
  -- No UNIQUE on url: a 2048-char utf8mb4 column exceeds the index key limit.
  -- Use UNIQUE (presentation_id, url(255)) if duplicate links must be prevented.
  CONSTRAINT `fk_pm_presentation` FOREIGN KEY (`presentation_id`)
    REFERENCES `presentation`(`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
