-- Media content store. youtube_video is populated by the YouTube import.
-- (Free-text presentation links live directly on presentation_media, in 04.)

CREATE TABLE `youtube_video` (
  `id`           int unsigned NOT NULL AUTO_INCREMENT,
  `youtube_id`   varchar(11) NOT NULL,
  `title`        varchar(256),    -- often overwritten by DCMS; may differ from YouTube
  `description`  text,
  `caption`      text,
  `channel_id`   varchar(128),
  `channel`      varchar(128),
  `category_id`  int,             -- YouTube's own category id (not a DCMS FK)
  `published_at` datetime,
  `thumbnail`    varchar(2048),
  `url`          varchar(2048),
  `created_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by`   varchar(128),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_youtube_id` (`youtube_id`),
  KEY `idx_youtube_published_at` (`published_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
