# Prose Review of Every Markdown Document

## Context

The docs audit (`c62b6ce`) was mechanical: unwrap lines, unbold links, fix heading case, fences, "Ride" and em-dashes. It didn't read the prose against the _Prose_ and _Language_ rules in `docs/writing-style.md`. The user wants every Markdown document reviewed in light of the guide. Before that, they want to know whether any of their prose preferences are missing from the guide, because a rule added afterwards would mean a second pass.

Scope: the 12 tracked Markdown files (~7,000 words). Code and OpenAPI `description:` strings are out of scope. So are `docs/plans/` (untracked) and `.claude/` (rewritten in step 2 of the master plan).

| File | Words | File | Words |
|---|---|---|---|
| `CONTRIBUTING.md` | 1294 | `docs/wp.md` | 616 |
| `docs/code-style.md` | 1105 | `docs/writing-style.md` | 575 |
| `docs/README.md` | 1026 | `docs/dev.md` | 396 |
| `docs/error-handling.md` | 643 | `docs/config.md` | 284 |
| `README.md` | 623 | `docs/database.md` | 263 |
| `docs/dependencies.md` | 170 | `docs/migrations.md` | 68 |

## Part 1: Guide Additions (`docs/writing-style.md`)

These preferences came up during this work but aren't in the guide yet. The user chose to add all four. Present the exact wording below in chat for approval before editing.

- **Name the thing (new `###` under _Prose_).** "Prefer naming what you mean to pointing back at it with "it", "this", "those" or "ones". Write "including expected errors", not "including the deliberately-signalled ones". A pronoun is fine when its referent is in the same sentence and can't be mistaken." Source: the user's comment on the level 2 rewrite ("a strong preference, not a hard rule").
- **Say it once (new `###` under _Prose_).** "Make each point once. If a sentence repeats what the paragraph has already said, cut it or replace it with something the reader doesn't know yet." Source: the recommendations paragraph ("How much does this need explaining anyway?"), and the master plan's W4 note on "describing the same thing twice in consecutive sentences".
- **Clipped clauses (one example added to _Write Full Sentences_).** "Clipped clauses joined by semicolons read as slogans too: write "every error is trapped and returned to the client as an HTTP response", not "nothing suspends; every error becomes a response"." Source: the user's level 0 comment.
- **No hyphen after an "-ly" adverb (one sentence added to _Language_).** "deliberately signalled", not "deliberately-signalled". This is standard British usage, and Claude raised it, not the user.

Keep each addition to one short section or sentence, in the guide's own style: imperative, one example, no em-dashes. Add no rules the user hasn't asked for.

Commit: `writing guide: <summary>` on `style-guide`, on its own, before Part 2.

## Part 2: Prose Review, One Document at a Time

Review order: the two guides first, because `/crev` and `/drev` will read them; then the contributor docs; then the rest, smallest last.

1. `docs/writing-style.md`, `docs/code-style.md`
2. `CONTRIBUTING.md`, `docs/README.md`. `docs/error-handling.md` is deferred to the error-handling review in the master plan's _Deferred Reviews_, because the doc will be rewritten.
3. `README.md`, `docs/wp.md`, `docs/dev.md`, `docs/config.md`, `docs/database.md`, `docs/dependencies.md`, `docs/migrations.md`

For each document:

1. Read it in full against every rule in `docs/writing-style.md` (as amended in Part 1). The _Readers_ section sets the reader: `README.md` is for frontend developers, and the rest are for people working on DCMS. Check in particular:
   - literal verbs, who acts, and varied sentence structure
   - rules written as instructions (guides only)
   - full sentences, not slogans or fragments
   - bold lead-ins, colon reveals and callouts used sparingly; em-dashes at most one in five paragraphs
   - British spelling, "start-up", "Ride", and identifiers spelled as in the code
   - anything added in Part 1
2. Present the findings in chat as before → after pairs, quoting the line number. Group trivial fixes, such as spelling, into one list. Don't edit the file yet.
3. Apply exactly what the user approves, with their changes. If they don't comment on a draft, ask rather than assume.
4. Run the mechanical checks again on that file: no new em-dashes over the ratio, no hard wraps, links resolve, heading case.

Rules for the review:

- Don't change what a document says. If the prose is wrong about the code (for example the known drift in `docs/error-handling.md`, a _Deferred review_), list it under "Content issues, not fixed" for the user, and leave it.
- Don't rewrite for its own sake. Leave a sentence that follows the guide alone, even if it could be phrased differently.
- Keep the diff reviewable: prefer sentence-level changes to rewriting whole paragraphs.

Commit: one commit, `prose review`, after the last document. Don't push.

## Verification

- For each file, `git diff --word-diff` shows only the approved changes.
- Re-run the docs audit checks over all 12 files:
  - bold links
  - heading case
  - `RIDE` without `_INIT`
  - fence labels
  - the continuation-line check (`unwrap.py` finds nothing to join)
  - em-dash counts per paragraph
  - relative links resolve
- Update the master plan: add Part 1's rules to the W list, and note the prose review as done under step 1.
