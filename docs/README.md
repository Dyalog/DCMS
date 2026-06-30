# DCMS Developer Documentation

Architecture and reference for working on DCMS itself. To find your way around
the code when making a change, start with **[../CONTRIBUTING.md](../CONTRIBUTING.md)**.

## The Stack

DCMS doubles as a worked example of how Dyalog's tools fit together: the
[Stark](https://github.com/dyalog-labs/stark) REST router on top of the
[Jarvis](https://github.com/Dyalog/Jarvis) web service framework; SQAPL talking
to MariaDB; the Isolate workspace for concurrent computation; and Docker for
consistent development and deployment environments.

## Architecture

The application is a set of namespaces under `#.DCMS`, linked from
**[../APLSource](../APLSource)** at start-up. **[Run.aplf](../APLSource/Run.aplf)**
connects to the database, registers the routes, and starts the server;
**[Setup.aplf](../APLSource/Setup.aplf)** loads dependencies.

| Module | Responsibility |
| ------ | -------------- |
| **[AUTH](../APLSource/AUTH)** | Authenticates each request and gates it by path prefix (`ControlAccess`). |
| **[QUERY](../APLSource/QUERY)** | Read-optimised public endpoints (video search, recommendations, events, presenters), served from an in-memory cache (`BuildCache`). |
| **[CRUD](../APLSource/CRUD)** | Generic create/read/update/delete over the database tables. |
| **[IMPORT](../APLSource/IMPORT)** | Fetches external data into the database; `IMPORT/YOUTUBE` pulls video metadata from the YouTube Data API. |
| **[ADMIN](../APLSource/ADMIN)** | Operational endpoints: refresh cached data, push content to WordPress. |
| **[WP](../APLSource/WP)** | WordPress REST client that publishes video posts to the Dyalog website (internal use, see [wp.md](wp.md)). |
| **[WEB](../APLSource/WEB)** | Serves the Swagger UI at `/`. |
| **[PROFILING](../APLSource/PROFILING)** | Request-profiling toggle and data endpoints. |
| **[SQL.apln](../APLSource/SQL.apln)** | SQAPL wrapper: connection, schema setup, query execution. |
| **[SPEC.apln](../APLSource/SPEC.apln)** | OpenAPI schema components shared across endpoint specifications. |

### Request Lifecycle

1. Jarvis receives the request. `ControlAccess`, registered as its
   `AuthenticateFn`, checks the path prefix and the `X-API-Key` header.
2. Stark matches the method and path to a handler and calls it with the request
   object.
3. The handler reads `req.PathParams` and `req.QueryParams`, does its work
   (through `SQL` or the cache), and returns a value Jarvis serialises to JSON.
4. An untrapped error reaches Stark's `OnErrorFn`, `HandleError`, which turns it
   into an HTTP response.

The [Routing](../CONTRIBUTING.md#routing) and
[Error Handling](../CONTRIBUTING.md#error-handling) walkthroughs cover steps 2
and 4 in detail.

### Data Flow

```
YouTube Data API ─▶ IMPORT ─▶ MariaDB ─▶ QUERY cache ─▶ read endpoints (/videos, /events, …)
                                 ▲
                                CRUD ─── write endpoints (/crud/…)
                                 │
                                 ▼
                                WP ─▶ Dyalog WordPress site
```

- **Ingest** — `ADMIN.RefreshData` (a 24-hour timer, or `POST /admin/refresh`)
  calls `IMPORT.YOUTUBE.RefreshData` to fetch video metadata into MariaDB, then
  `QUERY.BuildCache` rebuilds the cache the read endpoints serve from.
- **Serve** — read endpoints answer from the cache; CRUD endpoints read and
  write MariaDB directly.
- **Publish** — `ADMIN.WPPush` (`POST /admin/wp-push`) pushes video posts to the
  Dyalog WordPress site through the `WP` client.

## Running the Stack

The primary path is Docker Compose, driven by the **[dev](../dev)** script:
`./dev -i` on the first run (installs Tatin and NuGet dependencies), `./dev`
after. It starts the `web` (Dyalog + Jarvis) and `db` (MariaDB) services. See
**[dev.md](dev.md)** for the full workflow and what `dev` does.

### Manual Setup (Without Docker)

Running MariaDB host-native (for a non-Docker setup, or to debug type
conversions) needs the MySQL ODBC driver and a `dyalog_cms` database. The driver
requirement is strict: the SQAPL type conversions depend on its `DATA_TYPE`
numbers. **[database.md](database.md)** has the setup and the ODBC details;
**[dependencies.md](dependencies.md)** covers the Tatin and NuGet packages.

## Tests

Test code lives in **[../Admin](../Admin)**, loaded as the `Admin` namespace in
development. `Admin.TESTS` holds three suites, run in order against a clean
database:

| Suite  | Covers |
| ------ | ------ |
| `MAIN` | General endpoint behaviour, from a clean start and again after data is loaded. |
| `MOCK` | Queries against inserted dummy data, with `Admin.MOCKYT` standing in for YouTube. |
| `CRUD` | Create, read, update, and delete round-trips. |

`Admin.TESTS.GENERATE` produces the dummy data; `InsertDummyData` loads it.

- **In a development session**, against the running server:
  ```apl
  Admin.(Tests.Run GetEnv'URL')
  ```
- **Full local CI run** — **[CI/run-tests-in-docker.sh](../CI/run-tests-in-docker.sh)**
  builds the stack in Docker, runs the suites, and exits with the test status.
- **Endpoint smoke test** — **[CI/test-endpoints.sh](../CI/test-endpoints.sh)**
  curls a running server and checks the HTTP status code.

## Continuous Integration

| Pipeline | Role |
| -------- | ---- |
| **[.github/workflows/check-version.yml](../.github/workflows/check-version.yml)** | On pull requests to `master`, runs `CI/check_version.sh` to require that `APLSource/Version.aplf` is bumped above the version on `master`. |
| **[Jenkinsfile](../Jenkinsfile)** | The deploy pipeline: build the Dyalog image, install dependencies, run the test service (posting a GitHub comment on failure), publish over FTP, and on `master` deploy with Docker Swarm. |
| **[service.yml](../service.yml)** | The production Docker Swarm stack: the `web` service (behind Traefik at `dcms.dyalog.com`) and `db`, on NFS-backed volumes. |

## Documentation

- **[dev.md](dev.md)** — getting started, running tests, deployment
- **[config.md](config.md)** — configuration parameters and debug flags
- **[error-handling.md](error-handling.md)** — the call-down, signal-up error scheme
- **[database.md](database.md)** — ODBC drivers and host-native MariaDB setup
- **[dependencies.md](dependencies.md)** — Tatin and NuGet packages
- **[migrations.md](migrations.md)** — database schema migrations
- **[wp.md](wp.md)** — WordPress synchronisation (internal Dyalog use)
