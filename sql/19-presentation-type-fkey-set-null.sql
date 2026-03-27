-- Change presentation.type_id foreign key from CASCADE to SET NULL
-- Deleting a presentation_type should not delete all presentations of that type
ALTER TABLE `presentation` DROP FOREIGN KEY `presentation_ibfk_2`;
ALTER TABLE `presentation` ADD CONSTRAINT `presentation_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `presentation_type`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT;
