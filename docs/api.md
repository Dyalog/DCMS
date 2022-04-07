# API Reference
The API's REST query paramters match that of current Dyalog TV, but may be extended in future.

## Endpoints
By default, every table in the database is exposed as an endpoint `http://localhost:8081/table_name`.

## API functions
These APL functions provide the REST interface.

### read_

#### Query
By default, every table in the database is exposed as an endpoint `http://url_base/table_name`. Any with text columns (text, char or varchar) can also be queried with the `s=` parameter.

The `s=` "search" parameter searches for the presence of all of the words provided. For example, searching "hello world" would return records for which the word "hello" appeared in at least one column and "world" also appeared, even if in a different column. Both words must appear in the record.

Any column can be specifically searched using the `[column_name]=[query]` "column" parameter.

#### Pagination

#### ReturnSingleVideo

### create_

#### AddNewRecord

### update_

## Video by YouTube ID
e.g. dyalog.tv/api/v1/videos/_EcoRpYr3FE

Returns a JSON object containing:
- youtube_id
- title
- presenter
- order
- category_id (string)
- event_id
- created_at
- updated_at
- publishedAt
- category
    - id (integer)
    - event_id (integer)
    - category (string)
    - order (integer)
    - created_at (datetime)
    - updated_at (datetime)
- event
    - id ()
- snippet
    - id (integer)
    - youtube_id (string)
    - channelId (string)
    - channel (string)
    - categoryId (string)
    - title (string)
    - publishedAt (datetime)
    - description
    - raw (JSON string)
    - created_at
    - updated_at

## Unqualified resource
Return the full resource as a JSON list. Each record is an object.

## Search
s=query

Wildcard (SQL %) search the title and presenter columns for this text and return a JSON list, each object is a full record that matches.

## sort
`sort=[newest/oldest]`

This does not seem to affect change in dyalog.tv/api/v1, but perhaps it is used in the video-library React front end?

## Date range
date_from=
date_to=

## Pagination
page=p
paginate=n

Return a JSON object with the following members:
- current_page (integer)
- data (JSON list of relevant records)
- last_page (integer)
- Page URLs currently only apply to whole resource on dyalog.tv, not query results. 
    - to do: check which, if any, are used and how
    - to do: is URL hard coded or can server be told?
    - first_page_url (string)
    - last_page_url (string)
    - prev_page_url (string)
    - next_page_url (string)
    - path (string url of the resource with no query paramters)
- from (integer) first entry in the list of query results that appears on this page
- to (integer) last entry in the list of query results that appears on this page
- per_page (integer)
- total (integer)
- links (JSON list) to previous, next, label for "...", first 10 pages and last two pages
    each item is an object containing
    - url (string)
    - label (string)
    - active (boolean)


to do service.url from config file
to do snippets from youtube_import