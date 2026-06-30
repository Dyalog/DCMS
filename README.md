# Dyalog Content Management System

DCMS is a REST API serving the Dyalog website and video library. It provides search and recommendation endpoints over a database of videos, presenters, and events, plus a CRUD interface for managing that content. The service is written in Dyalog APL and runs under Docker, using [Jarvis](https://github.com/Dyalog/Jarvis) for HTTP and MariaDB for storage. DCMS doubles as a worked example of how these Dyalog tools fit together.

This README is for developers building a frontend against the API. Contributors working on DCMS itself should start at **[docs/README.md](docs/README.md)**.

- [Live service](https://dcms.dyalog.com) with interactive API documentation (Swagger UI)
- [OpenAPI specification](https://dcms.dyalog.com/openapi.json)
- [DYNA talk: "An APL App End to End"](https://youtu.be/lawQ2T3nctY)

## Run Locally With Dummy Data

You need [Docker](https://docs.docker.com/get-docker/) and a local clone. No YouTube credentials are required: the mock service `Admin.MOCKYT.Run` starts automatically with the tests so that you can test and develop offline.

1. Create `secrets/secrets.json5`. For local dummy-data use, placeholder values are fine — see [config.md](docs/config.md#secrets) for the format.

2. Build dependencies and start the stack:

   ```sh
   ./dev -i
   ```

   The `-i` installs the Tatin and NuGet [dependencies](docs/dependencies.md); drop it on later runs.

3. Connect to RIDE at `http://localhost:4502` and seed the database:
   ```apl
   Admin.RunTests 1
   ```
   `RunTests` clears the database, inserts 100 rows of generated dummy data (via `InsertDummyData`), builds the search and recommendation caches, and runs the test suite. The `1` keeps the session alive afterwards.

The API is now at `http://localhost:8081`. Reset to an empty database at any time with:

```apl
Admin.TESTS.ClearData
```

## Run With Real Data (Optional)

To work against live YouTube data instead of `MockYT`, obtain a [YouTube Data API v3 key](https://developers.google.com/youtube/v3/getting-started) and set `youtube_key` in `secrets/secrets.json5` (see [config.md](docs/config.md#secrets)). Point the `YOUTUBE` configuration key at the real API; `dev.dcfg` overrides it to the local `MockYT` server by default. With a valid key, `POST /admin/refresh` imports live video data. This is optional — `MockYT` covers normal local use.

## Calling The API

`GET /videos` searches the video library. It needs no authentication and returns a paginated JSON result. Query parameters include `search` (full-text), `event`, `presenter`, `from`, `to`, `sort` (`relevance`, `newest`, `oldest`), `page`, and `per_page`. The [Swagger UI](https://dcms.dyalog.com) and [OpenAPI spec](https://dcms.dyalog.com/openapi.json) document every endpoint and field.

The examples below hit the local stack. Against the live service, replace `http://localhost:8081` with `https://dcms.dyalog.com`.

APL, with [HttpCommand](https://github.com/Dyalog/HttpCommand):

```apl
⎕←(HttpCommand.Get 'http://localhost:8081/videos?search=apl&per_page=5').Data
```

`curl`:

```sh
curl 'http://localhost:8081/videos?search=apl&per_page=5'
```

JavaScript, with `fetch`:

```js
const res = await fetch("http://localhost:8081/videos?search=apl&per_page=5");
const data = await res.json();
```

The query routes (`/videos`, `/events`, `/presenters`, `/version`) are public. The write routes (`/crud` and `/admin`) require an `X-API-Key` request header.

## YouTube API

While the system does not itself collect or store any user data, this system uses YouTube API Services to access videos and their descriptions. By using this system, you agree to the [YouTube Terms of Service](https://www.youtube.com/t/terms).
