# Dyalog CMS
I've been thinking about what was said in the planning meetings and subsequent YAG meeting. In particular, about the ability for anyone to contribute to our information ecosystem. Since I am working on this CMS, I think it would be good it if were possible for anyone inside or outside of Dyalog to mark pathways or connections between the different aspects. Essentially, this would be a mechanism to allow us to get the specific knowledge out of Dyalog users' and developers' heads and out into the world, accessible by others.
It was said that one thing, possibly more than specific new writing, that is missing, is links between information that is in separate locations in our systems that are useful for solving a particular task. If you need to do some thing, it is likely that the multiple parts of knowledge of Dyalog and tools are required, and our current documentation system doesn't allow for that to be integrated.

## What is simple and what gets complicated?

### simple
- a dropdown menu for tables
- generate form based on columns
    - search based on field
    - update

### complicated
- updated_by based on logged in user
- "free text" search

## Data Handling Techniques
- bring data size down small as possible
- search should iteratively reduce search space, rather than search all and union/intersec
- dates can be offset by lowest value
- leverage the primitives

## dyalog.tv API
- https://github.com/hashslingrz/dyalog-video-library/blob/master/.env
- https://github.com/hashslingrz/dyalog-video-library/blob/master/src/hooks/dyalogtv/useDyalogTvApiGetVideos.js

We will import data from the Dyalog TV API initially, and also implement a mechanism to update from it, but it should be possible to entirely replace the existing funcitonality with the new CMS.

Some tables in the CMS will be supersets of the Dyalog TV tables

## YouTube API

## Twitter API

## Front end
- lightweight web forms which can be easily integrated into Jason's existing Portal system

# Dyalog Content Management System
With this system, we can expose documentation and media via our API to be used by any number of other tools.

## Road map
- Recreate Dyalog TV API using its data to feed the current new website video library
- Implement web forms to allow manual input/update of data
- Deploy this API to our servers
- Implement security to limit
    - GET requests to particular resources
    - POST requests
- Extend the API to include the resources/tables described in the database schema developed by Gitte and Stine
- Take over the Dyalog TV API, pulling data directly from YouTube and being able to add data from the Admin portal

## To do
- YouTube data import
- Media database setup
    - import sample data
- videos as a view: https://mariadb.com/kb/en/creating-using-views/
- Error handling and logging
- REST API + Video Library sync



- define data imports by SQL
- DCMS.Catch trapping and logging
× svelte demo
- report bug: import array on startup doesn't seem to work
    - argue one should ⊃⎕NGET, but in any case
× Set up basic query
× Get requests with search
- ⎕TRAP 0 'E' 'err #.Report {⍵(⍎⍵)}¨⎕nl¯2'
× Create database from schema migrations
× Import and serve Dyalog TV videos data
× Factor out import of dependencies
× Set up pagination
    - https://dyalog.tv/api/v1/videos?s=morten&page=1&paginate=20&sort=newest&presenter=&event=&
× Test connection of website/video-library with CMS

∘ Set up logging and error handling
∘ refactor out resource columns/types to a single source + convertion function
∘ make API mimick dyalog.tv more exactly (×3)
∘ Post request to update or insert (CRUD)
∘ svelte app mockup of data input interface

∘ Does date_from date_to work?
∘ Youtube import videos and playlists
∘ Set up security
    ∘ SSL certificate
    ∘ Scopes table
    ∘ GET from specific IP addresses
    ∘ OAuth? Talk to Jason

## Tests
∘ All combinations of 'dtv_videos' DCMS.Query req.QueryParams
    ∘ empty
    ∘ page=
    ∘ per_page=
    ∘ s=

## Questions
- the length limits on database columns types (e.g. varchar(256)) feel arbitrary, is there anything to use to decide?

## SQL Errors
- Errors handling SQL are returned as error code 775, which is SQL on a phone numpad

## Building the User Interface
While the system exposes a conventional REST HTTP API for easy adoption into any external system, it also provides information that may allow a front end framework to programmatically generate user interfaces for querying and updating the data.

### Columns
∘ to do: perhaps should be table_info or resource_info?

#### #.GLOBAL.columns

#### api/columns
The **columns** end point returns the table names, column names and column data types for each public-facing table in the database.

## YouTube API
```
curl \
  'https://youtube.googleapis.com/youtube/v3/playlists?part=snippet%2CcontentDetails&channelId=UCRFAE1uHnrhXlSkoaAgKsIQ&maxResults=25&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --compressed

curl \
  'https://youtube.googleapis.com/youtube/v3/playlistItems?part=snippet%2CcontentDetails&playlistId=PLA9gQgjzcpKFKjh0NpnMZP1KLEkaFobbx&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --compressed

```

## Design philosophy
- Testing and documentation up front
    - After initial design and experiments, assume that you want a reliable system that other people (including yourself in the future) can also use.
- Resist premature optimisation and generalisation
    - Get the code working quickly and correctly. Only optimise for performance and generality when necessary. It is likely that refactoring opportunities will have knock-on optimisation.
    - Compute or define things near to where you use them
- Resist premature abstraction
    - Abstraction impedes refactoring by isolating components, preventing possible simplifications. Due to the way APL functions can apply across domains, keeping raw code exposed allows opportunities for simplification to reveal themselves.
- Refactor promptly
    This seems in contrast to the first two points. However, the key is the use of the words "prompt" and "premature". A key benefit of APL in the modern world is the ability to refactor code without fear. Try to implement refactorings as soon as the benefit becomes clear - this is either a necessity (I cannot do X because of how I structured Y) or with foresight (I know I want to do X in the future, so I should structure Y now to facilitate that).

I can start to see the pieces getting longer, so it is time to try and develop the abstraction. In particular, I want:
- As an APL programmer, I can write the entire front end in APL and backend in APL, both tightly coupled and separated
- I want my front end to be connected appropriately, both as an HTMLRenderer-based interface and served to a browser
- I want my generated HTML/CSS/JS to be able to plug in to any other web stack framework I'm using, and vice versa?

## Coding style
- Full references to names outside of this function
- Naming convention: `Function` `array`
- Apart from returning modified arguments, you're not being clever by re-using names, you're just making it harder to re-factor later

## Content management
A good system for consumers facilitates:
- finding the thing you were looking for, even if you don't know exactly where to look
- discovering useful things that you didn't know you were looking for

A good system for creators facilitates:
- easily finding if the thing already exists
- easily creating the new thing and integrating/linking it to the system
    - where you want it displayed
    - so that others can find it

## Development roadmap
The initial system is based on the dyalog.tv API, which handles the data for Dyalog User Meeting videos and Webinars.

1. This plugs in to the current (https://dyalog.tv) and new (https://dyalog3.wpengine.com/video-library/) dyalog video interfaces.

2. There will be automated data retrieval from various sources, such as YouTube, Twitter and Dyalog.TV.

3. There will be a system for manual input of data and relations to improve the search functionality.

4. As the system and content is extended, it will feed data to other parts of the new website.

## System operation overview
Although the system will be run in a development environment with a session, so that we can RIDE into it, it will be deployable as a runtime workspace.

On startup, the system connects to a MariaDB database and uses the database called **dyalog_cms**. It is created if it does not exist.

Next, it checks for existing data. First, it checks the **migrations** table to see if any of the defined migrations have been applied. It applies any remaining migrations in ascending numerical order according to the file names.

The database is mostly append-only, to prevent data loss. However, the system itself has logic to prevent redundancy in API results and provide only what it considers the most relevant or up-to-date information.

Secondly, the system connects to external data sources to update the existing data. If identical information is found in the relevant records, nothing is done.

There will be some triggers to update the data either manually or periodically.

## System installation
The MariaDB database must have utf8mb4 as the connection character set.

## Input forms
Some HTML forms to interact with the system are generated from APL based on the existing tables in the database.

- An APLDOM that compiles to HTML/CSS/JS; I guess that's what Aaron's doing?

## Data source transformation modules
Perhaps we can create a scheme by which any existing or future data source can be used to feed into the CMS.
- sources member of configuration file?
- data_sources.dcfg JSON5 file?
- APL functions?

source: dtv
source.id → dtv_videos.video_id
source.id → videos.id
source.title → dtv_videos.title

Terminology:
- (External) data source
- (Internal) tables

For each data source, we can mark a particular column/property/member/attribute as:
1. the external data overrides internal data
2. the external data does not override internal data; it is ignored
3. the external data is brought in to an alternative column

↑ it would make more sense if the module takes care of this. That is, every external data source has an import table, which is always overridden with external data. The module then selectively copies appropriate data to the location from which it is served/searched/used.