# API Reference

## Endpoints
GET endpoints are defined in `/src/read_/endpoints.json5`.

Programmatically, endpoint switches are explicit in `#.DCMS.Get` and `#.DCMS.Post`.

Most implement a REST-like scheme, in which /endpoint lists all available items, possilbly with querying available, and /endpoint/id lists a single specific item within that endpoint.

### GET

#### /videos
Used by the video library

**Query:**

- `search` free text search of titles, descriptions, presenters and events
- `from` videos no earlier than date of form `YYYY-MM-DD`
- `to` videos no more recent than date of form `YYYY-MM-DD`
- `event` short name of event (e.g. Dyalog '22 → Dyalog22)

#### Video by YouTube ID
e.g. /videos/_EcoRpYr3FE

Returns a JSON object containing:

- category (string)
- description (string)
- event (string)
- event_shortname (string)
- presenter (string)
- published_at (datetime)
- thumbnail (string)   # URL
- title (string)
- url (string)
- youtube_id (string)
- youtube_url (string)

#### /persons

**Query:**

- id
- organisation

Returns a **LIST**:

- description           
- evangelism_description
- id                    
- join_dyalog_date      
- leave_dyalog_date     
- location              
- name                  
- organisation          
- picture               
- short_description     
- media (empty unless `id` specified)

**Single video**  
Use `/videos/youtube_id`

#### More
- GET /events  
	all event details
- GET /dtv_events  
	Events where some are grouped to make Dyalog TV (video library) interface less cluttered
- GET /persons
- GET /presenters
- GET /refresh  
    Update the API data from the database. Requires authentication.
- GET /tables  
    A list of all database tables

The POST endpoints are used by the admin functions. They all require authentication.

- POST /event
- POST /person
- POST /videos

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

## sort
`sort=[newest/oldest]`

This does not seem to affect change in dyalog.tv/api/v1, but perhaps it is used in the video-library React front end?

## Date range
date_from=
date_to=

## Pagination

**Query:**
Endpoints which return lists can be paginated

- `page` which page to return
- `per_page` number of items per page

Return a JSON object with the following members:

- `current_page` (integer)
- `data` (JSON list of relevant records)
- `last_page` (integer)
- Page URLs currently only apply to whole resource on dyalog.tv, not query results. 
    - to do: check which, if any, are used and how
    - to do: is URL hard coded or can server be told?
    - first_page_url (string)
    - last_page_url (string)
    - prev_page_url (string)
    - next_page_url (string)
    - path (string url of the resource with no query paramters)
- `from` (integer) first entry in the list of query results that appears on this page
- `to` (integer) last entry in the list of query results that appears on this page
- `per_page` (integer)
- `total` (integer)
- `links` (JSON list) to previous, next, label for "...", first 10 pages and last two pages
    each item is an object containing
    - `url` (string)
    - `label` (string)
    - `active` (boolean)


to do service.url from config file
to do snippets from youtube_import

### TODO
if you create a staging branch, then you can pretty much copy the IF statement in the deployment, ideally, we'll probably move the Credentials for that section too so we can run the staging in Bramley rather than in Gosport, change the URL and the name / ID and it will just happen (I need to set the ID up first)
as for the database, it will use the same dockerfile - so either you'd have a staging dockerfile, or persistent data - what you could do is have an admin command on a post so you can do something like curl -X POST -d "CLEARDATABASE" http://dcms.dyalog.bramley/api/v1/admin/commands
that's just an example, but if you have the commands there to do a DROP TABLE.... followed by your migrations, then you're probably in a good spot to reset it when you need to