CREATE TABLE IF NOT EXISTS `migrations` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(10) NOT NULL,
  `exec_ts` datetime DEFAULT CURRENT_TIMESTAMP  
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
