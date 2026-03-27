-- Drop category table as duplicate of presentation_category
-- See https://github.com/Dyalog/DCMS/issues/111
DROP TABLE `category`;
ALTER TABLE `presentation` ADD CONSTRAINT FOREIGN KEY (`category_id`) REFERENCES `presentation_category`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT;
