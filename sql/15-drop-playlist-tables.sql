-- Drop unused playlist tables.
-- These were created speculatively but never used by any endpoint or import handler.
-- See https://github.com/Dyalog/DCMS/issues/110
DROP TABLE `youtube_playlist_video`;
DROP TABLE `youtube_playlist`;
