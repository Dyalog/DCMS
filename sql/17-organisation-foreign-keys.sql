ALTER TABLE `presenter` DROP COLUMN `affiliation`;
ALTER TABLE `presenter` ADD COLUMN `affiliation` int(10) unsigned;
ALTER TABLE `presenter` ADD CONSTRAINT FOREIGN KEY (`affiliation`)
    REFERENCES `organisation`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT;

ALTER TABLE `person` DROP COLUMN `organisation`;
ALTER TABLE `person` ADD COLUMN `organisation_id` int(10) unsigned;
ALTER TABLE `person` ADD CONSTRAINT FOREIGN KEY (`organisation_id`)
    REFERENCES `organisation`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT;
