CREATE TABLE `youtube_videos` (
    PRIMARY KEY (`id`),
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `youtube_id` varchar(11),
    `title` varchar(256),
    `description` text,
    `channel_id` varchar(128),
    `channel` varchar(128),
    `category_id` int(11),
    `published_at` datetime,
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `youtube_playlists` (
    PRIMARY KEY (`id`),
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    `video_id` int(11) NOT NULL,
    `playlist_id` varchar(128),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);