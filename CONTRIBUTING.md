# Contributing to DCMS

<!-- Banner image slot: drop a contributor banner here once it has been sourced (REPO.md, step 11). -->

This guide covers getting set up, the change workflow, and where to look in the
code for the most common contributions. For the full development setup see
**[docs/dev.md](docs/dev.md)**; for the architecture overview and a guide to the
other docs see **[docs/README.md](docs/README.md)**.

## Getting Started

The whole stack runs in Docker. From a local clone:

1. Create `secrets/secrets.json5` — see [config.md](docs/config.md#secrets).
   Placeholder values work for local development.
2. Install dependencies and start the stack:
   ```sh
   ./dev -i
   ```
   Drop `-i` on later runs. Connect to RIDE at `http://localhost:4502` to work
   in the running session. See **[docs/dev.md](docs/dev.md)** for what `dev` does
   and the day-to-day workflow.

### Running Tests

In the RIDE session, against the running server:

```apl
Admin.(Tests.Run GetEnv'URL')
```

The full CI scenario (install dependencies, start the stack, run the suite):

```sh
./CI/run-tests-in-docker.sh
```

## Reporting Issues

Search the [open issues](https://github.com/Dyalog/DCMS/issues) before filing a
new one. A useful bug report includes:

- The DCMS version, from [`/version`](https://dcms.dyalog.com/version).
- A minimal reproducible example: the request, or the APL expression, that
  triggers it.
- What you expected, and what happened instead.

For a substantial change, open an issue to discuss the approach before writing
code.

## Submitting Changes

DCMS uses a fork-and-pull-request workflow:

1. **Fork** the repository and clone your fork.
2. **Branch** from `master` for your change.
3. Commit, push to your fork, and open a **pull request** against `master`.

New to this? GitHub's [contributing-to-a-project guide](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project)
walks through every step.

Before you open the pull request:

- Keep it to a single logical change; split unrelated work into separate PRs.
- Match the conventions of the code around you.
- Update the docs and tests your change affects, and run the suite (see
  [Running Tests](#running-tests)).
- By contributing, you agree your work is licensed under the repository's
  [LICENSE](LICENSE) (MIT).

Production deploys from `master` via the [Jenkinsfile](Jenkinsfile), so keep
`master` releasable.

## Routing

DCMS routes requests with [Stark](https://github.com/dyalog-labs/stark), a thin
layer over Jarvis that maps an HTTP method and path (e.g. `GET /version`) to the
APL function that serves it (**[APLSource/Version.aplf](APLSource/Version.aplf)**,
called as `DCMS.Version`). Stark also serves the API specification as JSON at
`/openapi.json`.

### Registering a Route

Every route is registered in **[APLSource/Run.aplf](APLSource/Run.aplf)**, using
the [Stark routing methods](https://github.com/dyalog-labs/stark/blob/master/docs/stark-router.md#single-route-methods).
Use the helper method for the HTTP verb — `router.Get`, `.Post`, `.Put`,
`.Patch`, `.Delete`. The left argument is the route path; the right argument is
the handler function name, paired with the endpoint's OpenAPI specification:

```apl
'/version' router.Get('Version' (Version'⍠SPEC'))
⍝  │           │         │         └─ handler called with the sigil → returns its OpenAPI spec
⍝  │           │         └─────────── handler function name
⍝  │           └───────────────────── registration method (HTTP verb)
⍝  └──────────────────────────────────route path
```

Handlers take the [Jarvis request object](https://dyalog.github.io/Jarvis/1.21/request/)
as right argument, but most return their OpenAPI specification instead when
called with the `'⍠SPEC'` sigil. Stark assembles those into the `/openapi.json`
spec.

A path segment in `{braces}` is a _path parameter_. In `/crud/{table}`, the
segment at `{table}` is passed to the handler as `req.PathParams.table`. A
handler reads the request through three members: `req.Endpoint` (the matched
path), `req.PathParams`, and `req.QueryParams`.

### Access Control

`ControlAccess` (**[APLSource/AUTH/ControlAccess.aplf](APLSource/AUTH/ControlAccess.aplf)**)
gates every request before Stark dispatches it, as Jarvis's `AuthenticateFn`. It
matches the request path against two prefix lists:

- **`public`** endpoints are served without authentication (`/version`, `/videos`, …).
- **`authed`** endpoints are served only with a valid `X-API-Key` (`/crud`, `/admin`, …).

A path under neither prefix is rejected with `404` here, before routing. So a
new route under an existing prefix needs no change; a new top-level prefix (say
`/stats`) must be added to one of the lists. A path that clears the prefix check
but matches no registered route gets its `404` from Stark instead.

### Errors

The handler call runs inside an error trap whose behaviour follows the debug
controls. On an untrapped error Stark calls its `OnErrorFn`, which DCMS sets to
`HandleError`, turning the error into an HTTP response. See
**[docs/error-handling.md](docs/error-handling.md)** for more details.

## Error Handling

DCMS uses a call-down, signal-up scheme. A handler calls lower functions that
validate the request and `⎕SIGNAL` an error tagged `Vendor:'DCMS'`, with an `EN`
equal to the intended HTTP status. The router's `OnErrorFn`,
**[HandleError.aplf](APLSource/HandleError.aplf)**, turns that into the response:

```apl
⎕SIGNAL⊂('EN' 404)('Message' 'Video not found')('Vendor' 'DCMS')
```

Three independent `DCMS.GLOBAL` controls (`logging`, `suspend`, `trace`) govern what
you see while developing. Set them with **[SetDebug.aplf](APLSource/SetDebug.aplf)**,
called as `DCMS.SetDebug logging suspend trace`:

| Control   | Effect                                                                                    |
| --------- | ----------------------------------------------------------------------------------------- |
| `logging` | print `Log` lines to the session                                                          |
| `suspend` | `0` trap every error into a response, `1` suspend on bugs only, `2` suspend on all errors |
| `trace`   | `1` suspends on request entry, so you can step through a handler                          |

`Run`'s preset scalars cover the common combinations: `0` production `(0 0 0)`,
`1` development `(1 1 0)`, `2` strict `(1 2 0)`. The full classification scheme,
and how the controls map onto the Stark and Jarvis debug bitmasks, are in
**[docs/error-handling.md](docs/error-handling.md)**.

## Search and Recommendations

Both features read from an in-memory cache (`DCMS.CACHE`) instead of querying SQL
per request. **[QUERY/BuildCache.aplf](APLSource/QUERY/BuildCache.aplf)** builds
it: it pulls the joined video, presenter, and event tables from SQL, normalises
the searchable text (`Unidecode.NormaliseText`, with datetimes converted to
Dyalog Day Numbers), and stores the result under `CACHE.videos`. The cache is
rebuilt by **[ADMIN/RefreshData.aplf](APLSource/ADMIN/RefreshData.aplf)** on a
24-hour timer and on `POST /admin/refresh`, after fresh data is imported from
YouTube.

### Search

The `GET /videos` handler is **[QUERY/VIDEOS/Query.aplf](APLSource/QUERY/VIDEOS/Query.aplf)**:

1. **Filter** the cached rows by the query parameters: date range
   (**[FilterDateTimes.aplf](APLSource/QUERY/VIDEOS/FilterDateTimes.aplf)**),
   presenter (**[FilterPresenter.aplf](APLSource/QUERY/VIDEOS/FilterPresenter.aplf)**),
   and event.
2. **Rank** the survivors against the `search` terms with
   **[Rank.aplf](APLSource/QUERY/VIDEOS/Rank.aplf)**, which scores each row by how
   often the terms occur, weighted down by how common each term is across all
   videos (a TF-IDF measure), and returns the rows in descending score order.
   Terms are normalised and stemmed (`Porter2Stemmer`) first; with no `search`
   term, every filtered row is kept.
3. **Sort** (`newest` / `oldest`) and paginate, then return JSON.

**[RLTB.aplf](APLSource/QUERY/VIDEOS/RLTB.aplf)** ("remove leading and trailing
blanks") is a small helper used while building the text index.

### Recommendations

Per-video recommendations are precomputed, not calculated per request.
**[ComputeRecommendations.aplf](APLSource/QUERY/VIDEOS/ComputeRecommendations.aplf)**
tokenises each video's title, description, and presenter, then computes a cosine
similarity matrix across all videos; each row lists the most similar videos by
index. This is expensive, so `BuildCache` runs it in an
[isolate](http://docs.dyalog.com/latest/Parallel%20Language%20Features.pdf) and
stores the result (a future) in `CACHE.videos.recommendations`.

The `GET /videos/{youtube_id}/recommendations` handler,
**[Recommendations.aplf](APLSource/QUERY/VIDEOS/Recommendations.aplf)**, looks up
the precomputed row for the requested video and returns its top `n` matches.
