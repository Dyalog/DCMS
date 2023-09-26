CREATE TABLE `external_video` ( /* Video not hosted on YouTube */
    PRIMARY KEY(`id`),
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `title` varchar(256),    
    `url` varchar(1024),
    `thumbnail` varchar(1024),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
