# Prose Review of `README.md` (Pending Approval)

Part of the prose review in [../i-think-every-document-playful-haven.md](../i-think-every-document-playful-haven.md). The reader is a developer building a frontend against the API. None of these changes has been applied yet.

## Proposed Changes

### Say It Once

1. **L39:** cut the last sentence, "This is optional — `MockYT` covers normal local use." The heading already says "(Optional)" and the first sentence says "instead of `MockYT`". This also removes one of the doc's two em-dashes.

### Say Who Acts, and a Garbled Subject

2. **L79:** the request "answers".
   - Before: A request sent with the tag in an `If-None-Match` header, or the date as `If-Modified-Since`, and an unchanged cache answers `304 Not Modified` with no body:
   - After: If a request sends the tag in an `If-None-Match` header, or the date in `If-Modified-Since`, and the cache hasn't changed, the response is `304 Not Modified` with no body:
3. **L43:**
   - Before: The [Swagger UI](https://dcms.dyalog.com) and [OpenAPI spec](https://dcms.dyalog.com/openapi.json) document every endpoint and field.
   - After: See the [Swagger UI](https://dcms.dyalog.com) and the [OpenAPI spec](https://dcms.dyalog.com/openapi.json) for every endpoint and field.
4. **L39, middle sentence:**
   - Before: Point the `YOUTUBE` configuration key at the real API; `dev.dcfg` overrides it to the local `MockYT` server by default.
   - After: Point the `YOUTUBE` configuration key at the real API; in `dev.dcfg` it is set to the local `MockYT` server by default.

### Literal Verbs

5. **L3:** matches the `docs/README.md` fix. "These" also pointed at a list that includes MariaDB, which isn't a Dyalog tool.
   - Before: DCMS doubles as a worked example of how these Dyalog tools fit together.
   - After: DCMS is also a worked example of how Dyalog's tools fit together.
6. **L45:**
   - Before: The examples below hit the local stack.
   - After: The examples below send requests to the local stack.

### Name What You Mean

7. **L70:** also uses "query", as L66 does, instead of "read/query".
   - Before: The read/query endpoints are served from an in-memory cache rebuilt daily, and carry validation headers:
   - After: The query endpoints are served from an in-memory cache that is rebuilt daily, and their responses carry these validation headers:
8. **L85:**
   - Before: On a cold start with no cache yet to serve, these endpoints answer `503` with `Cache is being built. Retry shortly.`
   - After: On a cold start with no cache yet to serve, the query endpoints respond with `503` and the message `Cache is being built. Retry shortly.`

### Consistency

9. **L17:** L23 and `CONTRIBUTING.md` both say "install".
   - Before: Build dependencies and start the stack:
   - After: Install dependencies and start the stack:

### YouTube Notice (L89)

10. The meaning is unchanged. Before approving, check whether the YouTube API terms require this notice to use particular wording.
    - Before: While the system does not itself collect or store any user data, this system uses YouTube API Services to access videos and their descriptions. By using this system, you agree to the [YouTube Terms of Service](https://www.youtube.com/t/terms).
    - After: DCMS uses YouTube API Services to access videos and their descriptions, but does not itself collect or store any user data. By using DCMS, you agree to the [YouTube Terms of Service](https://www.youtube.com/t/terms).

## Left As It Is

- The em-dash on L15. Once change 1 is applied, it is the only em-dash left.
- The "APL, with HttpCommand:" labels before the code blocks.
- L5, which says who the README is for.

## Review Status

- **Done, uncommitted:** `docs/writing-style.md` (including the new rules), `docs/code-style.md`, `CONTRIBUTING.md`, `docs/README.md`, and one comment in `APLSource/QUERY/CacheControl.aplf`.
- **Deferred:** `docs/error-handling.md`, to the error-handling review in the master plan's _Deferred Reviews_.
- **Pending approval:** `README.md` (this file).
- **Not yet reviewed:** `docs/wp.md`, `docs/dev.md`, `docs/config.md`, `docs/database.md`, `docs/dependencies.md`, `docs/migrations.md`.
- When the review is finished, make one `prose review` commit and update the master plan, as the plan file describes.
