-- Drop unused columns.
-- These were created speculatively but never used by any endpoint or import handler.
-- See https://github.com/Dyalog/DCMS/issues/113
ALTER TABLE `event` DROP COLUMN `early_bird`, DROP COLUMN `signup_url`, DROP COLUMN `physical`, DROP COLUMN `digital`;
ALTER TABLE `person` DROP COLUMN `url_slug`;
