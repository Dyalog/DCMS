-- Change event.type foreign key from CASCADE to SET NULL
-- Deleting an event_type should not delete all events of that type
ALTER TABLE `event` DROP FOREIGN KEY `event_ibfk_1`;
ALTER TABLE `event` ADD CONSTRAINT `event_ibfk_1` FOREIGN KEY (`type`) REFERENCES `event_type`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT;
