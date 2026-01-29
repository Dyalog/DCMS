ALTER TABLE `presentation_media` ADD CONSTRAINT FOREIGN KEY (`presentation_id`) REFERENCES `presentation`(`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT
