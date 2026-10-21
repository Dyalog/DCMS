# Make DCMS developer- and LLM-friendly

## Context

DCMS already gives every OS the same runtime through Docker (`Dockerfile`,
`docker-compose.yml`, `./dev`, `CI/`). The LLM tooling, though, is private.
`.claude/` and `.devcontainer/` are hidden by `.git/info/exclude`, so none of it
is published, and most of it came from someone else's generic setup:

- `.devcontainer/devcontainer.json` builds from
  `../../dev-environment/.devcontainer/Dockerfile`, which is outside the repo. The
  local `.devcontainer/Dockerfile` is never used.
- `.claude/settings.local.json` allows commands under
  `/Users/stefan/work/dev-environment/switch-toolchain.py`.
- The commands are templates. `/crev` and `/merge` run `true` where the real
  checks should be. `/merge` merges locally into `main`, but this repo uses
  `master` and fork-and-PR. `/rules` and `/merge` point to
  `docs/coderules*.md`, which doesn't exist.
- Two worktrees can't run stacks side by side, because `docker-compose.yml`
  hard-codes the host ports `4502:4502` and `8081:8081`.

**Decided with the user:**

- The repo holds the project, its runtime environment, a slim project-specific
  devcontainer, and the LLM guidance: `CLAUDE.md`, a code style guide, a writing
  style guide, `/crev`, a new docs-review command, and the two Dyalog skills.
- The repo should work with worktrees, plus a short note on running them.
- The full worktree-and-devcontainer workflow goes in a separate guide, outside
  this repo.
- `/make-issues`, `/merge` and `/rules` are dropped.
- The style guides are written **together** with the user. I draft them from
  existing conventions and we iterate before `/crev` and `/drev` enforce them.

## Order of work

The sections after this one are grouped by topic, not by sequence. Work in this
order:

1. **Style guides.** `/crev` and `/drev` enforce these guides, so they come
   first.
   1. **Code style rules** (`docs/code-style.md`). Every point on the agenda is
      decided. ✅
   2. **Writing style** (`docs/writing-style.md`). Go through the _Writing style
      guide_ agenda one point at a time with the user. This comes before the
      code guide is finished because the code guide is itself prose. ✅
   3. **Code style prose pass.** Rewrite `docs/code-style.md` to follow
      `docs/writing-style.md`, then get the user's approval. ✅
   4. **Audits.** Run the _Style audit_ (code) and the _Docs audit_. ✅
   5. **Prose review.** Review every tracked Markdown document against
      `docs/writing-style.md`, one document at a time with the user's approval.
      Plan: `docs/plans/i-think-every-document-playful-haven.md`. Progress
      and notes for resuming: `docs/plans/review/continue.md`. In progress:
      7 documents remain, and `docs/error-handling.md` is deferred to the
      error-handling review (_Deferred Reviews_).
2. **The rest of the LLM tooling.** `CLAUDE.md`, `/crev`, `/drev`, the skill
   edits, `.claude/settings.json` and the `.gitignore` changes (_Publish the LLM
   tooling_).
3. **Devcontainer.** The slim rewrite (_Devcontainer audit and slim rewrite_).
   Independent of steps 1–2. The user rebuilds it on the host to verify.
4. **Worktree-ready stack.** The compose port variables and the `docs/dev.md`
   note.
5. **`CONTRIBUTING.md`.** The _Using an AI Assistant_ section. It links to
   everything above, so it comes last.
6. **Local cleanup, with the user's OK.** Edit `.git/info/exclude`, move the
   personal settings to `~/.claude/settings.json`, and then (after merge) trim
   memory.

_External guide_ is not part of this work; it is written later, outside the
repo.

## Devcontainer audit and slim rewrite

Rewrite `.devcontainer/devcontainer.json` and `.devcontainer/Dockerfile` so they
are self-contained and hold only what DCMS work needs.

**Keep (project-specific):**

- Dyalog 20.0 `.deb`, which provides `dyalogscript`.
- .NET **8** SDK only. NuGet targets `net8.0`, and Porter2Stemmer needs it.
- `docsearch` and the Dyalog docs DB.
- Claude Code (native installer).
- `git`, `gh`, `jq`, `less`, `procps`, `locales`, `ca-certificates`, `unzip`.
- The `GH_TOKEN` remoteEnv.
- The `/home/node/.claude` config volume, so the login survives rebuilds.
- The `anthropic.claude-code` extension.
- The workspace bind mount at `/workspace`.

**Remove (hangovers from a generic multi-language setup):**

| Item                                                                              | Why it goes                                                                                                    |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `dockerfile: ../../dev-environment/...`                                           | Points outside the repo. Use the local `Dockerfile`.                                                           |
| Go in the final image, `golang.go`, `gopls`                                       | No Go in DCMS. Go only builds docsearch, so move that to a builder stage.                                      |
| .NET 10 SDK, `csharp-ls`                                                          | No C# source. 8.0 is enough.                                                                                   |
| `typescript`, `typescript-language-server`, eslint and prettier extensions        | No JS or TS in the repo.                                                                                       |
| `formatOnSave` with prettier as the default formatter                             | Would reformat `.md`, `.json` and `.yml` on save.                                                              |
| `python3-pip`, `python3-venv`, `pipx`, `python-lsp-server`, `ms-python.python`    | No Python in DCMS.                                                                                             |
| `NODE_OPTIONS=--max-old-space-size`, `POWERLEVEL9K_*`                             | Personal or Node-specific.                                                                                     |
| `zsh-in-docker`, `fzf`, `git-delta`, `nano`/`vim`, bash-history volume, `gitlens` | Personal shell and editor taste. Move to a VS Code `dotfiles.repository` (per user, applies to any container). |
| `TZ` default `America/Los_Angeles`                                                | Use `${localEnv:TZ}` and fall back to UTC.                                                                     |
| `node ALL=(ALL) NOPASSWD:ALL` sudo                                                | Gives Claude root in permissive modes. Drop it, and say so in the PR.                                          |
| `ENABLE_LSP_TOOL`                                                                 | No LSPs are left for this repo's languages.                                                                    |

**Shape:**

- Two stages. A `golang:1.24-bookworm` stage builds `docsearch`/`bundle-docs` and
  generates `dyalog-docs.db`. The final stage copies those in.
- Base: keep `node:20` (bookworm). It already has the `node` user, which the
  existing volume paths expect. Node itself is harmless.
- Keep Dyalog pinned to `20.0.x`, matching `Dockerfile` (`dyalog/dyalog:20.0`).
- Add a header comment to `devcontainer.json`. The container is for editing and
  for LLM work with `dyalogscript`/`docsearch`. It has **no Docker access**, so
  `./dev` and `CI/run-tests-in-docker.sh` run on the host.
- Not done here: basing the devcontainer on the project `Dockerfile` image. The
  `dyalog/dyalog` entrypoint makes that riskier, and the gain is small.

## Worktree-ready stack (minimal)

- `docker-compose.yml`: change the `web` ports to
  `"${DCMS_RIDE_PORT:-4502}:4502"` and `"${DCMS_WEB_PORT:-8081}:8081"`. The
  defaults don't change. Container-internal ports, `RIDE_INIT` and
  `SERVICE_PORT` stay as they are.
- Compose already names the project after the directory, so each worktree gets
  its own containers and volumes. `./dev` writes `env` into its own directory.
  No script changes are needed.
- `docs/dev.md`: add a short section, **Working on Several Branches at Once**:
  - `git worktree add ../DCMS-foo -b foo`
  - copy `secrets/` into the new worktree
  - `./dev -i` there (the packages are gitignored)
  - start it with `DCMS_WEB_PORT=8082 DCMS_RIDE_PORT=4503 ./dev`
  - stop the stacks you aren't using

  About 10 lines. The devcontainer and Claude `--worktree` mechanics stay in the
  external guide.

## Publish the LLM tooling

**Git hygiene:**

- Remove the `.claude/` and `.devcontainer/` lines from `.git/info/exclude`.
  This is local; I'll tell the user.
- Add to `.gitignore`: `.claude/settings.local.json`, `.claude/worktrees/`.

**`.claude/settings.json` (new, shared):** project-scoped only.

- `permissions.allow`: `Bash(docsearch:*)`, `Bash(gh issue view:*)`,
  `Bash(gh pr view:*)`, `Bash(gh pr diff:*)`.
- Nothing else.

**Personal settings that move out of the repo** (to the user's
`~/.claude/settings.json`, which persists in the config volume):

- `statusLine` and `statusline.sh`
- `plansDirectory`, `includeCoAuthoredBy`, `spinnerTipsEnabled`,
  `prefersReducedMotion`, `showThinkingSummaries`
- the `env` flags
- every `switch-toolchain` permission is deleted

I'll show the user the exact move before deleting the local file.

**`CLAUDE.md` (new, root):** short, about 60–80 lines.

- One paragraph on what DCMS is, with a link to `docs/README.md` and
  `CONTRIBUTING.md` for the architecture, not a copy of it.
- **Layout:** `APLSource/` (`#.DCMS`, Link-imported), `Admin/` (tests, MockYT),
  `CI/`, `docs/`, `sql/`.
- **Verify:**
  - syntax-check with `dyalogscript` (`⎕FX⊃⎕NGET file 1` for `.aplf`,
    `2⎕FIX'file://…'` for `.apln`)
  - the full suite needs the Docker stack on the host: `Admin.RunTests 1` in
    RIDE, or `./CI/run-tests-in-docker.sh`
  - the devcontainer can't run Docker
- **Conventions:** follow `docs/code-style.md` (code) and `docs/writing-style.md` (docs).
  Match the code around you.
- **Gotchas**, moved from personal memory so every contributor's assistant gets
  them:
  - In an isolate, `##` resolves to the parent process's `#`. Isolates have no
    `⎕SE.Link` or `⎕SE.Tatin`, and an inherited `RIDE_INIT` collides on port 4502.
  - APL→.NET calls made from any APL thread other than thread 0 cost 7–11× as
    much, so stem the unique words, not every occurrence.
  - If a test passes in-session but fails under `run-tests-in-docker.sh`, the
    cause is the environment, not the code. Check VS Code's port forwarding of
    8088 (MockYT) first.

**`docs/code-style.md` (new):** the code style guide, built point by point. See
_Code style guide_.

**`docs/writing-style.md` (new):** the writing style guide, built after the code
style guide. See _Writing style guide_.

**`.claude/commands/crev.md` (rewrite):**

- **Input:** an issue number, PR number or branch. Default: the current branch
  against `master`.
- **Context:**
  - `gh issue view` / `gh pr view` / `gh pr diff`, or
    `git diff master...HEAD`
  - the docs the change touches
- **Review against `docs/code-style.md`:** cite the rule for each finding.
- **Bug fixes:** confirm the fix reaches the root cause and that there is a
  regression test under `Admin/Tests`.
- **Checks:**
  - `dyalogscript` syntax-check of every changed `.aplf`/`.apln`
  - the test suite can't run in the devcontainer: ask the user for a
    `./CI/run-tests-in-docker.sh` result, or read the Jenkins comment on the PR
- **If `.md` files changed:** suggest `/drev`.
- **Output:** findings in the terminal (Critical / Major / Minor / Note) and a
  recommendation. Offer to post them with `gh pr review --comment`. Don't
  create `docs/reviews/` files.
- **Dropped:** the two-stage TDD flow, unless the user wants it back.

**`.claude/commands/drev.md` (new, docs review):** the same shape as `/crev`.

- **Scope:** changed `.md` files, or the paths given.
- **Review against `docs/writing-style.md`:**
  - check that links and file paths resolve
  - check that code references (function names, endpoints, config keys) still
    exist
  - check that each doc matches its audience

**Skills (keep, light edits):**

- `.claude/skills/dyalog-script/SKILL.md`:
  - add a "Prerequisite: `dyalogscript` (Dyalog 20; included in the
    devcontainer)" line
  - add the DCMS file syntax-check recipe
  - add the dfn early-return pitfall (a bare expression in a dfn returns early)
- `.claude/skills/dyalog-docsearch/SKILL.md`: add a prerequisite line covering
  the devcontainer and the upstream `xpqz/bundle-docs`.

**`CONTRIBUTING.md`:** add a short **Using an AI Assistant** section.

- `CLAUDE.md`, the two style guides, `/crev` and `/drev` are in the repo.
- The devcontainer is optional and sandboxes the assistant.
- You are responsible for every line you submit. Review it, run the suite, and
  keep PRs to the usual standard.

**Memory cleanup (after merge):** trim the personal memories whose content now
lives in the repo. These are the Log/print convention, terse comments, resist
complexity, VS Code port forwarding, diagnose-env, isolate gotchas and the .NET
surcharge. The memories would point at the repo docs instead. The UCmdAlias
memory stays personal.

## External guide (separate, not in this repo)

Outline only, to be written later wherever the user keeps personal or team
guides:

- devcontainer and worktree layout
- worktrees inside the mount vs mounting the parent directory
- absolute `.git` worktree pointers breaking across host and container (git
  2.39 in the container has no `--relative-paths`; that needs 2.48 or later)
- `claude --worktree`, which creates worktrees under `.claude/worktrees/`
- running parallel stacks with the port variables
- dotfiles for personal shell setup

## Out of scope / leave alone

- The uncommitted local edit to `dev.dcfg` (`PUBLIC_URL`, `YOUTUBE`). Don't
  commit it with this work.
- Jenkins and CI changes.

## Verification

- **Devcontainer** (the user runs these on the host, because there's no Docker
  here): VS Code "Rebuild Container", then in the container:
  - `echo "⎕←2+2" | dyalogscript /dev/stdin` prints 4
  - `docsearch -s '⎕FIX' -l 3` returns hits
  - `dotnet --list-sdks` shows 8.0 only
  - `claude --version`, `gh auth status` and `git status` all work
  - `which go node python3 pipx` shows only node
  - `sudo -n true` fails
- **Compose:**
  - `docker compose config` shows `4502`/`8081` by default and the overridden
    ports with the variables set
  - two worktrees with different ports both answer `curl localhost:<port>/version`
  - `./CI/run-tests-in-docker.sh` still passes on the defaults
- **Claude:**
  - a fresh session shows `CLAUDE.md` under `/memory`
  - `/crev` on a recent merged PR gives findings that cite `docs/code-style.md`
  - `/drev docs/dev.md` checks links and references
  - both skills appear in the skills list
- **Git:** `git status` shows `.claude/settings.local.json` ignored and the new
  files tracked, and `git ls-files .claude .devcontainer` lists the published
  set.

## Code style guide (`docs/code-style.md`): agenda

We go through these points in order, one at a time. Each one says what is in
the code now, what is **Decided** and what is still **Open**. Decided points go
straight into the draft. Open points are settled when we reach them. We don't
fix existing code while drafting; those fixes are collected into the _Style
audit_ at the end.

### Naming

1. **Modules.** **Decided:** namespaces that are modules are UPPERCASE
   (`QUERY`, `CACHE`, `SQL`). A bucket of globals counts as a module
   (`GLOBAL`). A namespace passed as an argument to a function is a variable
   (`req`, `cache`, `build_opt`) and follows variable naming. **Decided:** the
   rule covers only modules in `#.DCMS`. Imported modules keep their own names:
   Tatin packages, .NET classes, and `Unidecode`, which is to become a Tatin
   package. The roots `DCMS` and `Admin` are unchanged. ✅
2. **Functions** are PascalCase, including local dfns. Settled.
3. **Locals** are lowercase snake_case or terse names. Uppercase locals are
   aliases: `NL←⎕UCS 10`, `GBL←##.GLOBAL`. Settled. Point 6 may change aliases
   like `GBL`.
4. **Globals** are `GLOBAL.snake_case`, and JSON and OpenAPI keys are
   snake_case. **Decided:** OpenAPI keywords and `operationId` values are
   camelCase. Rename `monitorUrl` to `monitor_url` in the _Style audit_ (an
   API change). ✅
5. **Header local lists.** **Decided:** ASCII order is required. Sort the 17
   unsorted headers in the _Style audit_. ✅

### References Between Modules

6. **Absolute references.** **Decided:** DCMS is one application in control of
   itself, so it refers to other modules absolutely, as `#.DCMS.SQL` and
   `#.DCMS.GLOBAL`, not `##.` or `##.##.`. Today APLSource has 142 `##.` uses
   (CRUD 34, ADMIN 25, root 24, QUERY 20, IMPORT 12, WP 10, PROFILING 9, WEB 3,
   CACHE 3, AUTH 2) and 27 `#.DCMS.` uses. **Decided:** ✅
   - **Across modules only.** References to another module, to the `#.DCMS`
     root and to Tatin packages are absolute. Within a module, names are bare,
     and a sub-namespace may use `##.` to reach its own module. Never chain
     `##.##.`.
   - **Isolate code.** Code that runs in the cache-build isolate reaches its
     dependencies only through the names `CACHE.Setup` binds. Setup's
     main-process branch and `CACHE.Valid` follow the normal rule.
   - **Conversion** of the existing references is a **separate PR**, not part of
     the _Style audit_. See _Follow-up PRs_.

### Function Shape

7. **Tradfns** for handlers and side effects; **dfns** with guards for small
   pure helpers. Handlers branch on `req≡'⍠SPEC'`. Settled.
8. **Exits and nesting.** **Noted for later review; not decided in this
   work.** You are considering goto and labels instead of nested control
   structures in some cases. For example, the `:If req≡'⍠SPEC' … :Return`
   branch pushes a handler's whole body one level in. Until that review, the
   guide records current practice: `:Return` (32 uses), with `→0` in
   `WP/Post.aplf` and `WP/Delete.aplf`. See _Deferred reviews_.
9. **Layout.** Tradfn bodies are indented 1 space, with blocks at +4. `.apln`
   files nest at 4 spaces. No tabs. Settled.
10. **Line length.** **Decided:** not enforced. `/crev` can flag long lines when
    asked. Today 287 lines are over 100 characters.

### Comments

11. **Header comment.** A `⍝` block starts on line 2. **Decided:** flag the 12
    files that have none for us to review in the _Style audit_:
    - `APLSource/CACHE/Build.aplf`
    - `APLSource/DT/FormatDateTime.aplf`
    - `APLSource/IMPORT/YOUTUBE/GetVideos.aplf`
    - `APLSource/QUERY/Paginate.aplf`
    - `APLSource/SetDebug.aplf`
    - `APLSource/WP/Delete.aplf`
    - `APLSource/WP/Post.aplf`
    - `APLSource/WP/PushTeamDyalogVideos.aplf`
    - `Admin/GetEnv.aplf`
    - `Admin/MOCKYT/Get.aplf`
    - `Admin/TESTS/ClearData.aplf`
    - `Admin/TESTS/Run.aplf`
12. **End-of-line comments.** **Decided:** aligned 3 spaces after the longest
    code line in the group of lines they comment on.
13. **Argument docs.** You asked whether the style depends on tradfn vs dfn.
    Mostly it doesn't: it is one form, `⍝ name: description :: type`, where
    `name` is whatever the argument is called. In a dfn that is `⍺`, `⍵` or
    `←`. In a tradfn it is the declared names, e.g. `cache:` and `r:` in
    `CACHE/Valid.aplf`. The real inconsistencies:
    - Only 13 of the 33 files with argument docs have the `:: type` suffix.
    - 117 of 148 `.aplf` files have no argument docs at all.
    - The `::` column alignment varies.
    - A result shape is sometimes listed with no type
      (`IMPORT/YOUTUBE/GetVideos.aplf`).

    **Decided:** document an argument only where its shape or type isn't
    obvious. `:: type` is optional, for when the description doesn't make the
    type clear. No sweep. ✅
14. **What comments leave out.** Rationale for a change goes in commits and
    PRs. No issue numbers or RFC citations. **Correction to the earlier
    draft:** OpenAPI `description:` strings are *not* an exception to this. My
    source was a personal memory note saying descriptions are published API
    docs and may carry user-facing detail that a comment shouldn't. No
    `description:` string in the code cites an issue or RFC. The only hit is
    `SPEC.apln:44`, which describes the `report_url` field. These comments
    break the rule; we review them in the _Style audit_:
    - `Admin/TESTS/MAIN/Test_PushTeamDyalog_MultiPresenter.aplf:2`: "Issue
      #108"
    - `Admin/TESTS/MAIN/Test_PushTeamDyalog_MultiPresenterUpdate.aplf:2`:
      "Issue #108"
    - `Admin/TESTS/MOCK/TestGetCacheHeaders.aplf:47`: "RFC 9110 §15.4.5"
    - `APLSource/DT/HTTPDate2DDN.aplf:2`: "RFC 9110 IMF-fixdate". This names a
      format rather than giving a reason, so it is arguably fine.

    **Decided:** naming a standard format is allowed, so `HTTPDate2DDN` stays.
    Citing an issue or RFC section is not allowed, tests included. Rewrite the 3
    test comments to state the behaviour in the _Style audit_. ✅

### Errors and Logging

15. **`⎕SIGNAL` form.** **Decided:**
    `⎕SIGNAL⊂('EN' n)('Message' '…')('Vendor' 'DCMS')`. The 41 calls that use
    EN/Vendor/Message get reordered in the _Style audit_. **Decided:** no
    mechanical enforcement yet. You plan to use a static analysis tool later.
    For now `/crev` checks the mechanical rules by reading the code. When
    enforcement does come, it will be one script, run both by a tracked
    `.githooks/pre-commit` (opt-in through `core.hooksPath`) and by a GitHub
    Action on PRs. See _Follow-up PRs_. ✅
16. **`EN` values and the wider error scheme.** **Deferred** to the separate
    error-handling review (see _Deferred reviews_). For now the guide states the
    current rule: `EN` is the HTTP status, and `HandleError.aplf` is the
    reference.
17. **Logging.** `Log` lines carry bracketed tags (`[REQ]`, `[REFRESH]`,
    `[ERR]`, `[AUTH]`). `Log` is for suppressible dev and test information. Bare
    `⎕←` is for failures, unless they would flood. Use LF, not CR. Settled.
    Under point 6, `##.Log` becomes `#.DCMS.Log`. SQL's own `Debug` is deferred
    to the SQL review.
18. **Traps.** `:Trap 0`, or `0::` in dfns, with a comment saying why the trap
    is there. Settled.

### Tests

19. **Prefix.** **Decided:** `Test_`. Rename these 5 files in the _Style
    audit_:
    - `MAIN/TestGetCORSHeader`
    - `MAIN/TestGetEndpoints`
    - `MAIN/TestGetRoot_ServesHTML`
    - `MAIN/TestOpenAPI`
    - `MOCK/TestGetCacheHeaders`

    Discovery matches the `Test` prefix, so nothing else changes.
20. **Shape.** Each test takes the URL and returns a Boolean. Dfn tests use
    `Assert cond:` guards. Tradfn tests use `r←0 … :Trap 0 … r←1` and tear
    down explicitly. Settled.

### Process

21. **Simplicity.** New state, config keys and abstractions must justify
    themselves. Flag test-only production state, test-only config knobs,
    rare-failure recovery machinery and dead-until-later code. Settled.
22. **Bug fixes** go to the root cause and come with a regression test under
    `Admin/TESTS`. Settled.

### Style Audit

This is one commit, made once the guide is agreed. Only the `monitor_url`
rename changes behaviour. The PR needs a version bump (`CI/check_version.sh`).

- Strip trailing whitespace from these 16 files:
  - `ADMIN/WriteCache`, `CRUD/Delete`, `QUERY/Events`, `QUERY/VIDEOS/Query`,
    `QUERY/VIDEOS/Recommendations`, `ReadJSON`, `SQL.apln`
  - `Admin/MOCKYT/Run`
  - `Admin/TESTS`: `CRUD/Test_05_BadTransaction`, `MOCK/TestGetCacheHeaders`,
    `MOCK/Test_GETVideo_NotFound`, `MOCK/Test_GETVideo_Recommendations_BadID`,
    `MOCK/Test_GETVideo_Recommendations_Count`,
    `MOCK/Test_GETVideo_Recommendations_NotFound`, `MOCK/Test_GETVideos`,
    `REFRESH/Test_GETRefreshStatus_Fields`
- Reorder the 41 `⎕SIGNAL` calls (point 15).
- Sort the local lists in the 17 tradfn headers that aren't in ASCII order
  (point 5).
- Rename `monitorUrl` to `monitor_url` in `ADMIN/Refresh.aplf` and
  `Test_POSTRefresh_Accepted` (point 4). This is the one change that alters the
  API.
- Rename the 5 test files (point 19).
- Review list for the user: the 12 files with no header comment (point 11).
- Make client-facing error messages full sentences ending with a full stop
  (the `Message` rule under _Errors_ in `docs/code-style.md`):
  - `QUERY/VIDEOS/Query.aplf:72`: "Invalid date-time". The new wording should
    say which format is expected; confirm it with the user.
  - `WEB/Static.aplf:32`: "Not found" becomes "Not found."
  - `AUTH/ControlAccess.aplf:13`: "Not found", the pre-routing 404 payload.
    It isn't signalled, but it is the same client-facing message.
  - `Run.aplf:75`: "I am a teapot" becomes "I am a teapot."

  No test checks these strings. Internal messages wait for the error-handling
  and `SQL.apln` reviews.
- Keep the source in step with the examples in `docs/code-style.md`. In
  `APLSource/CACHE/Valid.aplf`, replace header line 2 ("Is a cache namespace
  read back from file valid? DCMS should not serve an invalid cache
  namespace.") with the guide's version: "Check whether a cache namespace read
  from file is valid." Before the audit, check every other code example in the
  guide against its source file in the same way.
- Rewrite the 3 test comments that cite "Issue #108" or "RFC 9110 §15.4.5" so
  they state the behaviour instead (point 14).
- Error-handling meaning and `SQL.apln` behaviour stay as they are.
- **Verify:** `⎕FX` or `2⎕FIX` every touched file with `dyalogscript`, then
  run the full suite on the host.

## Follow-up PRs (rules agreed here, code changed later)

- **Absolute references (point 6).** Convert cross-module `##.` and `##.##.`
  references to absolute paths, and switch `CACHE.Setup`'s `File2Ref` to
  `#.DCMS.`. Run the full suite.
- **CacheControl ordering in the architecture docs.** This came out of the
  style guide, but it is architecture, not style. Add to `CONTRIBUTING.md`'s
  "Persistence and Conditional Requests" section that a handler must validate
  its parameters before calling `QUERY.CacheControl`, so that a malformed
  request fails with 400 instead of 304 (see the comment at
  `QUERY/VIDEOS/Query.aplf:68`).
- **Regular logging scheme.** Consider replacing the `Log` / bare `⎕←` split
  with a dyadic `Log` that takes a level as its left argument
  (`'error' Log msg`). A setting would control which levels are output, and
  admin endpoints would let you change the level and query the log. Model them
  on the profiling API: `GET`/`PUT /admin/profiling` for the status and toggle,
  and `GET`/`DELETE /admin/profile` for the data (`APLSource/PROFILING`, routes
  in `Run.aplf:69-72`). This would replace the `GLOBAL.logging` flag and the
  `Log` vs `⎕←` rule in `docs/code-style.md`, and make the bracketed area tags
  (`[REQ]`, `[REFRESH]`) more regular. It overlaps with the error-handling
  review, which covers `SetDebug`'s logging control.
- **Natural-prose guide for LLMs (W4).** Once the basic points are in
  `docs/writing-style.md`, write a separate guide with before-and-after examples.
  It should help LLMs vary grammatical structure and framing, and avoid
  their habitual patterns. Decide then where it goes: a section of
  `writing-style.md`, a skill, or a file that `/drev` reads. Worked examples from
  the code-block rule in `writing-style.md`:
  - "Give a code fence that holds only input a language": the verb is odd, the
    object is split, and "input" reads first as a verb.
  - "The exception is a code block that…": an announced exception. Write a
    condition instead: "If a code block shows a session, …".
  - Describing the same thing twice in consecutive sentences.
- **Mechanical style checks (point 15).** Wait for the static analysis tool.
  Candidate rules: `⎕SIGNAL` option order, trailing whitespace, sorted header
  locals, and the `Test_` prefix. Deliver them as one script, run by both a
  pre-commit hook and CI.

## Deferred Reviews (separate from this work)

- **Error handling.** Aim: a deliberate scheme, documented and implemented
  the same way. Leave `SQL.apln` out; it has its own review below. Make an
  issue for this and do the work later. Points raised during the prose review:
  - **Expected vs unexpected. Decided:** an expected error is a case that
    DCMS deliberately handles. An unexpected error is a bug or an oversight.
    Keep two classes, but state in the docs that expected errors include both
    client errors (4xx) and known server failures (5xx).
  - **Error detail in responses. Decided:** don't hide database or other
    internal details from the client. The API is public, and so is its data.
  - **`EN` values that aren't HTTP statuses. Needs discussion before a
    decision:** `202` in `IMPORT/YOUTUBE/GetVideos.aplf` (trapped by
    `ADMIN/RefreshData.aplf`'s `:Trap 202 404`), `400` for an internal
    mismatch in `CACHE/Build.aplf`, and `SetDebug`'s `EN 11` with no Vendor.
    Decide whether `EN` must always be an HTTP status, and how to signal an
    error that never reaches a client.
  - **Logging consistency. Decided:** make it consistent. Some bare `⎕←` lines
    are tagged (`[REFRESH]`, `[ERR]`, `[DEBUG]`) and others aren't (start-up).
    Keep the rule in `docs/code-style.md`: `Log` for information that may be
    suppressed, and `⎕←` for failures that must be reported even in
    production, unless they could flood the log. This overlaps with the
    _Regular logging scheme_ follow-up.
  - **Drift in `docs/error-handling.md`:**
    - The doc says a 5xx `EN` becomes a 500. The code
      (`HandleError.aplf:21`) keeps any `EN` from 400 to 599, deliberately:
      the cache-building `503` and the WordPress `502` depend on it. Fix the
      doc, and the "client error" comment on that line.
    - The doc says unexpected errors are logged only with `Log`. With
      `suspend=0`, `HandleError` also prints the full `⎕DMX` with `⎕←`.
      Describe both, and state the `Log` vs `⎕←` rule.
  - **Prose review of `docs/error-handling.md`:** deferred from the prose
    review (`docs/plans/i-think-every-document-playful-haven.md`) to this
    review, because the doc will be rewritten. Ten prose fixes were drafted
    there (a verbless sentence at L15, pronouns at L3/L27/L31/L36/L53, "the
    configs pass" at L38, bold "independent" at L7, the example message's
    full stop at L45). Apply them as part of the rewrite.
- **`SQL.apln`:** its own `Debug` logging and its error codes, including
  `EN 101`, and the 11 `EN 500` signals that `HandleError` treats as expected
  and logs only with `Log`, so a database failure leaves no trace in the
  production log.
- **Control flow:** goto and labels vs nested control structures, including
  the spec-sigil branch in handlers (point 8).

## Writing Style Guide (`docs/writing-style.md`): agenda

Same process as the code style guide: go through it one point at a time with
the user. The prose points come first, because they are why we switched to this
guide and they also govern the prose in `docs/code-style.md`. Each point is marked
**Settled** (observed and uncontroversial), **Proposed** (my suggestion, to be
confirmed) or **Open**.

### Readers

W1. **Audience split.** `README.md` is for developers building a frontend
    against the API. `CONTRIBUTING.md` and `docs/` are for people working on
    DCMS. `CLAUDE.md` is for an LLM working on DCMS. Settled.

### Prose (LLM patterns)

The user raised these while reviewing the `docs/code-style.md` draft.

W2. **Literal verbs.** Use the verb for the actual action, not a metaphor:
    "merged", "released" or "fixed", not "landed"; "is stored in", not "lives
    in". Likewise avoid "surfaces", "ships", "bites", "owns" and "sits".
    Decided.
W3. **Say who acts.** Don't give documents, environments or changes human
    actions. Bad examples: "when this guide is silent", "production turns it
    off", "changes must justify themselves", "it says what the data is".
    Either name the real actor, which is usually the reader ("Justify any new
    state"), or describe the state ("Logging is off in production"). Code may be
    the subject only when it literally does the action: "`HandleError` converts
    the error to a response." **Decided.** ✅
W4. **Vary the structure.** Vary both the grammatical structure and the framing
    so that prose reads naturally and isn't tiring. **Decided.** ✅ Follow-up:
    once the basic points are in the guide, write a separate guide with examples
    that helps LLMs keep to a natural style. See _Follow-up PRs_.
W5. **Slogans and fragments.** Use them very sparingly; this is not a ban.
    **Decided.** ✅
W6. **Emphasis.** Use colon reveals and bold lead-ins very sparingly; this is
    not a ban. **Decided.** ✅
W7. **Rules are instructions.** **Decided:** in guides, write rules in the
    imperative. ✅
W8. **Em-dashes.** **Decided:** at most one in five paragraphs. The _Docs
    audit_ thins out `docs/README.md` (14), `error-handling.md` (7) and
    `CONTRIBUTING.md` (5). ✅

### Language

W9. **British spelling** (behaviour, normalise, serialisation). Code
    identifiers keep their own spelling (`responses.unauthorized`). Settled.
W10. **Product names and terms.** "RIDE" (5 uses) or "Ride" (1); "start-up"
     (consistent). **Decided:** "Ride", as Dyalog's current docs write it, and
     `RIDE_INIT` for the parameter. The audit fixes the 5 uses of "RIDE". ✅

### Markdown

W11. **Headings.** Title Case, no deeper than `###`. **Decided:** minor words
     are lowercase. The audit fixes `README.md`'s headings. ✅
W12. **Line wrapping.** **Decided:** no wrapping; each paragraph or list item
     goes on one line. The audit unwraps every doc, including `docs/code-style.md`
     and `docs/writing-style.md`. ✅
W13. **Links to source files.** **Decided:** plain links. The audit removes the
     bold from 62 links in `README.md`, `CONTRIBUTING.md`, `docs/README.md`
     and `docs/wp.md`. ✅
W14. **Inline code** for identifiers, paths, status codes and config keys.
     Settled.
W15. **Code fences** always name a language. `APL` (2) and `bash` (2) differ
     from `apl` (10) and `sh` (5). **Decided:** `apl` and `sh`, and `_x_` for
     italics. A fence that shows a session (input at the six-space prompt plus
     its displayed result) has no language. Input-only code blocks drop the
     six-space prompt indent. The audit fixes 4 code blocks in `database.md`
     (labels, and the indent on 2 of them) and 1 italic in `wp.md`. ✅
W16. **GitHub callouts** (`> [!NOTE]`). **Decided:** use them rarely, only
     for a hazard or limit the reader must not miss. The existing 3 in `wp.md`
     and `database.md` stay. ✅

### Docs Audit

This is one commit, made once the guide is agreed. It covers `README.md`,
`CONTRIBUTING.md` and `docs/*.md`, and changes no meaning. It:

- unwraps every paragraph and list item onto one line (W12)
- removes the bold from file links (W13)
- lowercases articles, conjunctions and prepositions in headings (W11):
  `README.md` "Calling The API", "Run Locally With Dummy Data" and "Run With
  Real Data (Optional)", and `wp.md` "Push Data From DCMS to WordPress via
  REST"
- changes "RIDE" to "Ride" (W10)
- normalises fences to `apl`/`sh` and italics to `_x_` (W15)
- thins em-dashes to at most one in five paragraphs (W8)
- fixes the unclosed parenthesis in `CONTRIBUTING.md` and the missing trailing
  newline in `migrations.md`

The prose patterns (W2–W6) aren't swept in this commit. The prose review
(step 1.5) sweeps them, and the natural-prose follow-up deals with them in
depth.

**Drift `/drev` should catch (good first test case, not fixed in this work):**

- `docs/error-handling.md` says a 5xx `EN` "becomes a 500". In fact
  `HandleError` passes any status from 400 to 599 through. The fix belongs to
  the error-handling review.
- An unclosed parenthesis in `CONTRIBUTING.md`'s "Persistence" paragraph.
- `docs/migrations.md` has no trailing newline.
