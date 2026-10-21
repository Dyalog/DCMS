# DCMS Code Style

Follow this guide when writing APL for DCMS. For a style decision not covered here, follow the style of the surrounding code. To review a change against this guide, run `/crev`.

## Naming

- Name the modules in `#.DCMS` in uppercase: `QUERY`, `CACHE`, `SQL`. `GLOBAL`, the namespace that holds globals, is uppercase too, so that it stands out.
- Keep the names of imported modules as they are. These include Tatin packages (`HttpCommand`, `Jarvis`), .NET classes (`Porter2Stemmer`), and `Unidecode`, which we intend to publish as a Tatin package. The roots `#.DCMS` and `#.Admin` also keep their names.
- Name functions in PascalCase, including dfns assigned locally inside a tradfn: `CountTerms`, `URLEncode`.
- Variables are lowercase, in snake_case (`has_videos`, `search_fields`) or terse (`pg`, `res`). Since a namespace passed as an argument is a variable, name it like one: `req`, `cache`, `build_opt`.
- For a constant or a reference used as an alias, use an uppercase local: `NL←⎕UCS 10`.
- Name globals `GLOBAL.snake_case`.
- Write JSON keys in snake_case. OpenAPI keywords (`operationId`, `additionalProperties`) and `operationId` values (`getVideos`) stay in camelCase, as is conventional in OpenAPI.
- List the locals in a tradfn header in ASCII order: uppercase names first, then lowercase, then `⎕` names.

  ```apl
  res←dmx HandleError req;NL;URLEncode;body;detail;json;link;params;repo;reqline;status;suspend;title;⎕IO
  ```

## Module References

DCMS is one application in control of its own workspace, so refer to anything outside the current module by its absolute name. For another module, or a function at the root of `#.DCMS`, write for example `#.DCMS.SQL`, `#.DCMS.GLOBAL.cache` or `#.DCMS.Log`. Tatin packages are loaded into `#`, so write `#.HttpCommand`.

Inside a module, use the names in the current namespace without a prefix. A sub-namespace may use `##.` to refer to its own module: `QUERY.VIDEOS` calls `##.CacheControl`, and the suites in `Admin.TESTS` call `##.Assert`.

If you use a long path more than once, assign it to an uppercase alias:

```apl
GBL←#.DCMS.GLOBAL
```

### The Cache-Build Isolate

Neither absolute nor relative references work as usual inside an isolate. There, `#` refers to the isolate's own root, where `#.DCMS` doesn't exist. Unlike in a normal namespace, `##` refers to the root of the parent process, not to the namespace in which the isolate was created, so a call through `##.` runs in the main process instead of the isolate (see [Parallel Language Features](https://docs.dyalog.com/20.0/files/Parallel_Language_Features.pdf)). In code that runs in the cache-build isolate (`CACHE.Build` and everything it calls), use the names that `CACHE.Setup` binds, never `#.DCMS.` or `##.`. To give the isolate a new dependency, add it to the import list in `CACHE.Setup`.

## Function Shape

- Write handlers, and any function with side effects, as tradfns with control structures.
- Write small pure helpers as dfns with guards.
- When a handler is called with `'⍠SPEC'`, it returns its OpenAPI specification:

  ```apl
  :If req≡'⍠SPEC'
      ...
      :Return
  :EndIf
  ```

- Exit a tradfn early with `:Return`.
- Indent a tradfn body by 1 space, and each control-structure block by 4 more. In `.apln` files, indent each level by 4 spaces. Don't use tabs.
- There is no limit on line length. If you want long lines flagged, ask `/crev` to check them.

## Comments

- Give every function a `⍝` header block, starting on line 2, that describes what the function does.
- Document an argument or result if its shape or type isn't clear from its name, for example a namespace, a nested array or a matrix. Scalars and simple vectors usually need no documentation.
- Write argument docs as `⍝ name: description`, adding `:: type` when the description doesn't make the type clear, and align the `::` column. In a dfn the names are `⍺`, `⍵` and `←`. In a tradfn, use the names declared in the header:

  ```apl
   r←Valid cache;ep;vids
  ⍝ Check whether a cache namespace read from file is valid.
  ⍝ cache: candidate cache namespace :: namespace ref
  ⍝     r: is cache valid            :: Boolean
  ```

- In the body of a function, comment only where the intent of the code is not obvious from reading.
- Align a group of end-of-line comments 3 spaces after the longest line in the group:

  ```apl
   r∧←ep.videos.fields≡vids.fields           ⍝ We have the endpoint fields
   r∧←(≢vids.fields)=⊢/⍴vids.values          ⍝ And as many columns
   r∧←(≢vids.fields)=≢vids.index_cols
   r∧←(⍴vids.search)≡≢¨vids.(values index)   ⍝ BM25F is ≢documents × ≢terms
   r∧←vids.values =⍥≢ vids.recommendations   ⍝ One row per video
  ```

- Put the reason for a change in the commit message and pull request, not in the source. Don't cite issue numbers or RFC sections, even in tests. You may name a standard format, because the name identifies the data: `⍝ Convert a valid RFC 9110 IMF-fixdate to Dyalog Day Number`.

## Errors

Signal a DCMS error with the HTTP status of the response as its `EN`, and list the options in the order `EN`, `Message`, `Vendor`:

```apl
⎕SIGNAL⊂('EN' 404)('Message' 'Video not found.')('Vendor' 'DCMS')
```

The `Message` of an error that reaches an API client is part of the response, so write it as a full sentence ending with a full stop.

See [error-handling.md](error-handling.md) for the full scheme.

Trap errors with `:Trap 0` in a tradfn or `0::` in a dfn, and add a comment explaining why the trap is needed.

## Logging

- Use `Log` for development and test information. Logging is off in production.
- Tag each `Log` line with its area: `[REQ]`, `[REFRESH]`, `[ERR]`, `[AUTH]`.
- When a failure will need diagnosing, report it with a bare `⎕←` so that it appears even when logging is off. If the failure could flood the log, as a per-request client error could, use `Log` instead.
- Separate lines with LF (`⎕UCS 10`), not CR, because `docker logs` doesn't break lines at CR.

## Tests

- Name each test `Test_<Method><Resource>_<Case>`, for example `Test_GETVideo_NotFound`, and put it in a suite under `Admin/TESTS`. Add a number after `Test_` only where the tests must run in order (`Test_01_Create`).
- A test takes the base URL and returns a Boolean.
  - In a dfn test, guard each check with `Assert`, and end with a Boolean expression such as `404=res.HttpStatus`.
  - In a tradfn test, set `r←0`, make the assertions inside `:Trap 0`, set `r←1`, and then tear down explicitly.

## Changes

Keep changes small. Add new state, config keys or abstractions only when you can justify them. Be especially wary of:

- production state that only a test uses
- config settings that exist only for the test suite
- recovery code for a rare failure that restarting the service would fix
- code that does nothing until some later work is done

Fix a bug at its root cause, and add a regression test that fails without the fix.
