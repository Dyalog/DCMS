-- Add AUTO_INCREMENT to tables with surrogate integer primary keys that were missing it.
-- Affected tables: person, event, event_type, presentation_type, organisation.
SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `person` MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
ALTER TABLE `event` MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
ALTER TABLE `event_type` MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
ALTER TABLE `presentation_type` MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
ALTER TABLE `organisation` MODIFY `id` int(10) unsigned NOT NULL AUTO_INCREMENT;
SET FOREIGN_KEY_CHECKS=1;
