CREATE TABLE `organisation` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `name` varchar(256) NOT NULL,
  `url` varchar(4096),
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)    
);
CREATE TABLE `category` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `category` varchar(256) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
