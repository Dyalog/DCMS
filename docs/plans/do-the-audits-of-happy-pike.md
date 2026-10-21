# Run the Style Audit and the Docs Audit

## Context

Step 1.4 of `docs/plans/i-am-looking-to-curious-falcon.md`. `docs/code-style.md` and `docs/writing-style.md` are agreed and committed on `style-guide`. The two audits bring the existing code and docs into line with them, so that `/crev` and `/drev` start from a clean baseline. Each audit is one commit on `style-guide`. The guides were re-checked against the current tree; the corrected counts are below.

Leave alone: the `dev.dcfg` edit, `docs/plans/` (untracked), anything in the _Follow-up PRs_ and _Deferred reviews_ sections of the master plan (`##.` conversion, `SetDebug`'s EN 11, `GetVideos` EN 202, `SQL.apln` codes, prose patterns W2–W6).

## Commit 1: Style Audit (code)

1. **Trailing whitespace.** Strip it from the 16 files:
   - `APLSource/`: `ADMIN/WriteCache`, `CRUD/Delete`, `QUERY/Events`, `QUERY/VIDEOS/Query`, `QUERY/VIDEOS/Recommendations`, `ReadJSON`, `SQL.apln`
   - `Admin/`: `MOCKYT/Run`, `TESTS/CRUD/Test_05_BadTransaction`, `TESTS/MOCK/TestGetCacheHeaders`, `TESTS/MOCK/Test_GETVideo_NotFound`, `…_Recommendations_BadID`, `…_Recommendations_Count`, `…_Recommendations_NotFound`, `TESTS/MOCK/Test_GETVideos`, `TESTS/REFRESH/Test_GETRefreshStatus_Fields`
2. **`⎕SIGNAL` option order.** Reorder the 40 calls from `('EN')('Vendor')('Message')` to `('EN')('Message')('Vendor')`. They are in `CRUD/{Create,Read,Update,Delete,Schema}`, `QUERY/{CacheControl,Events}`, `QUERY/VIDEOS/{Single,Recommendations}`, `CACHE/Build`, `PROFILING/Toggle`, `WEB/Static` and `SQL.apln`, including the 2 `⎕DMX.(('EN'EN)('Vendor' 'DCMS')('Message'Message))` forms at `SQL.apln:183,204`. Leave `HandleError.aplf:28` (re-signal with `EM`) and `SetDebug.aplf:13` (deferred) as they are.
3. **Header locals in ASCII order** (codepoint order: upper, `_`, lower, `⎕`) for the 17 headers: `CRUD/Delete`, `IMPORT/CreateUpdate`, `PROFILING/{Data,Toggle}`, `Run`, `SQL.apln:36,60,78`, `WEB/Static`, `WP/{Delete,Post}`, and the tests `CRUD/Test_01_Create`, `CRUD/Test_02_Read`, `MAIN/TestGetRoot_ServesHTML`, `MAIN/TestOpenAPI`, `MAIN/Test_PUTProfiling_Idempotent`, `MAIN/Test_Profile_Body`, `MAIN/Test_ProfilingHappyPath`. Re-run the checker script (`/tmp/claude-1000/-workspace/4a5a3248-3d27-494f-9726-6286f62e972b/scratchpad/locals.py`) afterwards; it must print nothing.
4. **`monitorUrl` → `monitor_url`** in `APLSource/ADMIN/Refresh.aplf` (lines 13, 16, 39, 41, 44) and `Admin/TESTS/REFRESH/Test_POSTRefresh_Accepted.aplf:17`. Bump `APLSource/Version.aplf` from `5.0.0` to **`6.0.0`** because of this API change.
5. **Rename the 5 tests to `Test_`.** Use `git mv` and update line 1 to match, because Link needs the file name and the function name to agree. Discovery (`_Test.aplo`) matches `Test`, and nothing else refers to these names. Follow the `Test_<Method><Resource>_<Case>` pattern:
   - `MAIN/TestGetCORSHeader` → `Test_GETVersion_CORSHeader`
   - `MAIN/TestGetEndpoints` → `Test_GETEndpoints`
   - `MAIN/TestGetRoot_ServesHTML` → `Test_GETRoot_ServesHTML`
   - `MAIN/TestOpenAPI` → `Test_GETOpenAPI`
   - `MOCK/TestGetCacheHeaders` → `Test_GETCacheHeaders`
6. **Client-facing messages as full sentences:**
   - `QUERY/VIDEOS/Query.aplf:72`: `'Query parameters "from" and "to" must be date-times in the format YYYY-MM-DD hh:mm:ss.'` (chosen by the user)
   - `WEB/Static.aplf:32` and `AUTH/ControlAccess.aplf:13`: `'Not found'` → `'Resource not found.'`
   - `Run.aplf:75`: `'I am a teapot'` → `'I am a teapot.'` (the OpenAPI `description` at line 79 stays as it is)

   No test checks these strings (checked with grep).

7. **Issue and RFC citations.** Rewrite the comments at `MAIN/Test_PushTeamDyalog_MultiPresenter.aplf:2`, `MAIN/Test_PushTeamDyalog_MultiPresenterUpdate.aplf:2` and `MOCK/TestGetCacheHeaders.aplf:47` so that each states the behaviour and drops "Issue #108" and "RFC 9110 §15.4.5". `DT/HTTPDate2DDN.aplf:2` stays.
8. **Guide examples match the source.** Replace line 2 of `CACHE/Valid.aplf` (both sentences) with `⍝ Check whether a cache namespace read from file is valid.` The other examples were checked and already match (`HandleError` header, the `Valid` end-of-line comments, the test names). `GBL←#.DCMS.GLOBAL` waits for the `##.` follow-up.
9. **12 functions without a header comment.** The user approved this text. Apply it exactly as written, using 5-space indentation for dfn bodies:
   - `APLSource/CACHE/Build.aplf`: line 3 starts the header block. Move the four description lines (currently lines 8–11) up under a new lead line, then the argument docs, then the unchanged 3-line localisation note:
     ```apl
     ⍝ Build the cache namespace from the database.
     ⍝ Store pre-joined tables for API endpoints and query results
     ⍝ Create character and numeric matrices for filters
     ⍝ Compute BM25F score matrix for search
     ⍝ Compute cosine similarity matrix for recommendations
     ⍝ opt: using and app_dir, set by the main process
     ⍝ cache: cache namespace for wholesale replacement
     ⍝ The external dependencies above are localised so that Setup's assignments appear as
     ⍝ Build's locals and vanish on return, otherwise certain names (e.g. .NET class instances)
     ⍝ prevent the CACHE namespace from being serialised into isolate processes.
     ```
   - `APLSource/DT/FormatDateTime.aplf`: change it to a multi-line dfn:
     ```apl
      FormatDateTime←{
     ⍝ Format Dyalog Day Numbers ⍵ with the 1200⌶ pattern ⍺.
          ⍺(1200⌶)⍵
      }
     ```
   - `APLSource/IMPORT/YOUTUBE/GetVideos.aplf`, new line 2: `⍝ Fetch metadata for YouTube video IDs ⍵ from the YouTube Data API, one row per video.`
   - `APLSource/QUERY/Paginate.aplf`, new line 2 (above `(ep pg ppg)←args`): `⍝ Return one page of results with its page details and links, or results unchanged if per_page is empty.`
   - `APLSource/SetDebug.aplf`: delete the blank line 2, so the existing description becomes line 2. Add no new text.
   - `APLSource/WP/Delete.aplf`, new line 2: `⍝ Delete Team Dyalog Video post post_id from WordPress and report whether it succeeded.`
   - `APLSource/WP/Post.aplf`, new line 2: `⍝ POST info to WordPress at info.endpoint and return the response data.`
   - `APLSource/WP/PushTeamDyalogVideos.aplf`, new line 2: `⍝ Sync each Team Dyalog member's n most recent videos (default 10) to WordPress posts.`
   - `Admin/GetEnv.aplf`: change it to a multi-line dfn:
     ```apl
      GetEnv←{
     ⍝ Get value of configuration parameter or environment variable.
          ⊢2 ⎕NQ #'GetEnvironment'⍵
      }
     ```
   - `Admin/MOCKYT/Get.aplf`, new line 2: `⍝ Serve the mock YouTube GET /videos, returning a snippet for each requested video ID.`
   - `Admin/TESTS/ClearData.aplf`: replace the blank line 2 with `⍝ Delete every row from every table except migrations.`
   - `Admin/TESTS/Run.aplf`, new line 2: `⍝ Run every test suite against the server at url and return 1 if all tests pass.`
10. **Comment corrections found while drafting point 9.** The user approved these:
    - `APLSource/WP/Delete.aplf`: in the end-of-line comment on the `:If 0≡post_id` line, change "info is a prototype" to "post_id is a prototype".
    - `APLSource/IMPORT/YOUTUBE/GetVideos.aplf`: the `⍝ ←:` result comment lists columns the function doesn't return. Replace it with `⍝ ←: id  title  description  channel_id  channel  category_id  published_at  thumbnail`.
    - `APLSource/GetEnv.aplf:2`: correct "paramater" to "parameter", and end the line with a full stop so it matches `Admin/GetEnv`.
    - `APLSource/CACHE/Valid.aplf`: add an end-of-line comment to the `:Trap 0` line: `:Trap 0   ⍝ Any missing member means invalid`.

**Verify:** run `dyalogscript` on every touched `.aplf` (`⎕FX⊃⎕NGET f 1`) and on `SQL.apln` (`2⎕FIX'file://…'`), then rerun the trailing-whitespace grep, the `⎕SIGNAL` order grep and `locals.py`, each of which must report nothing. Ask the user for `./CI/run-tests-in-docker.sh` on the host; this container can't run it. `CI/check_version.sh` must pass against `master`.

## Commit 2: Docs Audit (prose)

Scope: `README.md`, `CONTRIBUTING.md`, `docs/*.md` (not `docs/plans/`). The audit doesn't change what any doc says.

1. **Unwrap (W12).** Hard-wrapped paragraphs remain in `CONTRIBUTING.md` (~81 continuation lines), `docs/README.md` (~41), `docs/config.md` (4) and `docs/dev.md` (2). `code-style.md` and `writing-style.md` are already unwrapped. Join each paragraph or list item onto one line, leaving fences, tables, callouts and nested list indentation as they are. Check with `git diff --word-diff` that only whitespace changed.
2. **Unbold file links (W13).** `**[x](y)**` → `[x](y)`: 60 links (`docs/README.md` 31, `CONTRIBUTING.md` 23, `docs/wp.md` 5, `README.md` 1). Leave non-link bold alone.
3. **Heading case (W11).** `README.md`: "Run Locally with Dummy Data", "Run with Real Data (Optional)", "Calling the API". `docs/wp.md`: "Push Data from DCMS to WordPress via REST". `docs/README.md`: "Manual Setup (without Docker)" (the earlier plan missed this one). GitHub anchors are lowercase, so no links break.
4. **"RIDE" → "Ride" (W10):** `README.md:25`, `docs/dev.md:29,33,54`, `CONTRIBUTING.md:24`. `RIDE_INIT` stays.
5. **Code fences (W15)**, all in `docs/database.md`: `bash` → `sh` (lines 9, 16); `APL` → `apl` and drop the six-space indent (lines 35, 43). The `js` and `json5` fences and the unlabelled diagram in `docs/README.md` stay. **Italics:** `*pushes*` → `_pushes_` at `docs/wp.md:25`.
6. **Em-dashes (W8):** keep to at most one in five paragraphs. Thin `docs/README.md` (13), `docs/error-handling.md` (7) and `CONTRIBUTING.md` (5) with commas, colons, brackets or full stops. Check `README.md` (2) and `docs/dev.md` (1) against the ratio too.
7. **Small fixes:** close the parenthesis after the `WriteCache` link at `CONTRIBUTING.md:179`, and add the trailing newline to `docs/migrations.md`.

**Verify:** rerun the checks used for this plan (the bold-link count, the heading regex, `RIDE` without `_INIT`, the fence labels, the continuation-line awk and the em-dash counts). All Markdown links must still resolve; check the relative paths of any link touched during unwrapping. Read the diff of each file once.

## After Both Commits

Mark step 1.4 ✅ in `docs/plans/i-am-looking-to-curious-falcon.md` and update the counts it quotes (40 `⎕SIGNAL` calls, 60 bold links). Don't push and don't open a PR unless the user asks.
