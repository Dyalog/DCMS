# Data resources and database table information

## Imported Resources
Resources imported to obtain certain media information. An external resource is defined by:

- an SQL table, created and updated during one or more [migrations](migrations.md)
- a function in the `fetch_` namespace which handles communication with the external resource and marshalling into the correct database table

## Exposed Resources
Resources exposed by the Dyalog CMS API. They are defined by functions in the `create_`, `read_` and `update_` namespaces, which are called by `Get`, `Post` or `Put` in order to retrieve or insert data.

## Column names and types
Column names and types are defined in the [migrations](./migrations.md) - SQL files which define the tables.

The types defined in these SQL files are mapped to [SQAPL](https://docs.dyalog.com/latest/SQL%20Interface%20Guide.pdf) type conversions, stored in `#.GLOBAL.conversions`.

TODO: nicer way to get SQAPL types? `4 12 93 ¯6 ¯1`

## Default table query
By default, every table in the database is exposed as an endpoint `http://url_base/table_name`. Any with text (text, char or varchar) columns can also be queried with the `s=` parameter. See [the API reference](./api.md#query) for more details.

> TODO: different scopes allow different resources
    - admin (can access all tables, including writing to the "scopes" table)
    - dyalog (possibly to access personal information e.g. email addresses)
    - user (e.g dyalog.com, dyalog.tv)

## Dyalog TV

### Videos

### Events

### Catgegorys

## YouTube
The API URL is the configuration parameter `youtube`.
The API key is the configuration parameter `youtube_key`.

### Tables

- youtube_videos (migration `1-youtube-videos-import.sql`)
- youtube_playlists

### Functions

- `import_.YouTubeImport`
- `read_.ReturnSingleVideo`

### Videos

### Playlists