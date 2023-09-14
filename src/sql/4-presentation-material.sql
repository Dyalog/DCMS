CREATE TABLE `presentation_material` ( /* Generic URL links for PDF, zip, pptx etc. */
    PRIMARY KEY(`id`),
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `text` varchar(256),    /* Link text can describe the material e.g. (video (25 mins) or slides(pdf)) */
    `url` varchar(1024),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
