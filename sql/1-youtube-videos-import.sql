CREATE TABLE `youtube_video` (
  PRIMARY KEY (`id`),
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `youtube_id`   varchar(11) NOT NULL UNIQUE,
  `title`        varchar(256), /* Often overwritten by DCMS so different from title on YouTube */
  `description`  text,
  `caption`      text,
  `channel_id`   varchar(128),
  `channel`      varchar(128),
  `category_id`  int(10),
  `published_at` datetime,
  `thumbnail`    varchar(256),
  `url`          varchar(256),
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `youtube_playlist` (
  PRIMARY KEY (`youtube_id`),
  `youtube_id` varchar(128) NOT NULL,
  `title`      varchar(256),
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `youtube_playlist_video` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `video`      int(10) NOT NULL,   /* ID into youtube_videos */
  `playlist`   varchar(128),    /* ID into youtube_playlists */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);