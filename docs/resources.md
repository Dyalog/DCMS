# Data resources and database table information

## Imported Resources
Resources imported to obtain certain media information. An external resource is defined by:

- an SQL table, created and updated during one or more [migrations](migrations.md)
- a function in the `import` namespace which handles communication with the external resource and marshalling into the correct database table

## YouTube data
YouTube API data must be refreshed after no more than 30 days. The table `CACHE.youtube_last_refresh` maps between youtube IDs and the last time the YouTube API data was refreshed for that video. In the namespace `import.youtube`, the function `import.youtube.ImportVideos` updates this via `LastFetch`, and `CheckCacheExpiry` is run every 24 hours from startup via the `youtube_api_timer` object.
