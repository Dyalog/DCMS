CREATE TABLE `migrations` (
  PRIMARY KEY (`id`),
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  `exec_ts` datetime DEFAULT CURRENT_TIMESTAMP  
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `dtv_videos` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `youtube_id` varchar(11),
    `title` varchar(256) NOT NULL,
    `presenter` varchar(256),
    `default` boolean,
    `order` int(11),
    `category_id` varchar(10),
    `event` varchar(128),
    `event_id` int(10),
    `external` boolean,
    `description` text,
    `publishedAt` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128),
    `created_at` datetime
);

CREATE TABLE `dtv_events` (
    PRIMARY KEY (`id`),
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `event` varchar(128),
    `header` varchar(256),
    `footer` varchar(256),
    `background` varchar(256),
    `user_meeting_logo` varchar(256),
    `dyalog_logo` varchar(256),
    `order` int(11),
    `short_name` varchar(128),
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128),
    `created_at` datetime
);

CREATE TABLE `dtv_categorys` (
    PRIMARY KEY (`id`),
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `category` varchar(128),
    `order` int(11),
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128),
    `created_at` datetime
);