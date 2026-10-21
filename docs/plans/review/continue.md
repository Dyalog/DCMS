# Prose Review: Continue Here

Notes for resuming the prose review (master plan step 1.5). The process is in [../i-think-every-document-playful-haven.md](../i-think-every-document-playful-haven.md). For each document, present before → after pairs in chat, apply only what the user approves, then re-run the mechanical checks. Make one `prose review` commit at the end.

## Status

- **Done and committed:** `docs/writing-style.md` and `docs/code-style.md` (`7d88960`, renamed in `525c737`), and `CONTRIBUTING.md`, `docs/README.md` and the `req.Fail 304` comment in `APLSource/QUERY/CacheControl.aplf` (`78f3434`).
- **Pending approval:** `README.md`. The drafted changes are in [README.md](README.md).
- **Not yet reviewed:** `docs/wp.md`, `docs/dev.md`, `docs/config.md`, `docs/database.md`, `docs/dependencies.md`, `docs/migrations.md`.
- **Deferred:** `docs/error-handling.md`, to the error-handling review in the master plan's _Deferred Reviews_.

## Decisions from Earlier Reviews to Apply

Rules added to `docs/writing-style.md` during this review:

- **Name What You Mean**: name the thing instead of "it", "this", "those" or "ones". This is a strong preference, not a hard rule.
- **Say It Once**, within a document. A summary that repeats another document is fine.
- Clipped clauses joined by semicolons read as slogans.
- No hyphen after an "-ly" adverb.
- No colon that holds back a point for suspense.
- A serial comma where a list item has parts of its own. An optional serial comma is allowed, so don't flag it.

How the user applied the rules:

- **A description of how something is, or should be, is fine.** Don't turn it into an instruction. Examples: "Variables are lowercase…", "A test takes the base URL…", "When a handler is called with `'⍠SPEC'`, it returns its OpenAPI specification". Use the imperative only where the reader is the one who acts.
- **Documents don't act.** Rewrite "X covers", "X has the details", "X walks through", "X documents" as "See X for …".
- **Production, a cold start or start-up doesn't act.** Write "Production is deployed from…", "After a cold start, DCMS serves…", "DCMS reads the file back at start-up".
- **Bold lead-ins:** keep at most one set per document, where they name steps or stages (**Filter/Rank/Sort**, **Ingest/Persist/Serve/Publish**). Unbold the others. Keep bold where it defines a term (**refresh serialisation lock**) or marks a warning (**after**).
- **Wording already chosen, to reuse across documents for consistency:**
  - "is also a worked example", not "doubles as"
  - "is in", not "lives in"
  - "send requests to", not "hit"
  - "Install dependencies and start the stack"
  - "the filtered rows", not "the survivors"
- **304 wording:** a `304` isn't a failure. `CacheControl` sets the status to `304 Not Modified`, and the client uses its own copy.
- **Expected errors** include both client errors (4xx) and known server failures (5xx). An expected 4xx or 5xx `EN` keeps its status. Don't repeat the old "5xx becomes 500" wording.
- Don't change what a document says. List content issues for the user instead of fixing them.

## Items Already Known for the Remaining Documents

- **`docs/config.md`, _Debug Controls_ (L25–37):** this section overlaps `docs/error-handling.md`, which is deferred. L27 has the same bold **independent** that was flagged in `error-handling.md` (fix 9 there), and the same "is governed by" wording. Ask the user whether to review this section now or defer it to the error-handling review along with `error-handling.md`.
- **`docs/dev.md` L48:** describes `SUSPEND` ("from full error trapping to suspending execution"). Check it against the error-handling scheme, and treat it like the `config.md` section above.
- **`docs/dev.md` L15:** has an em-dash ("Create a secrets file … — see config.md"). `README.md` L15 and `CONTRIBUTING.md` L9 have the same one. It is within the ratio and was kept in both, so keep it here too.
- **`docs/wp.md` and `docs/database.md`:** their 3 GitHub callouts stay (W16).
- **`docs/wp.md`:** has non-link bold, such as **Team Dyalog Videos**, that the docs audit left alone. Check it against _Use Emphasis Sparingly_.
- **The diagram fence in `docs/README.md` stays unlabelled.** This is noted only so that it isn't flagged again in the final checks.

## After the Last Document

1. Re-run the docs audit checks over all 12 files: bold links, heading case, `RIDE` without `_INIT`, fence labels, the continuation-line check, em-dash counts and relative links.
2. Commit the remaining documents as `prose review: <files>`. Don't push.
3. Update the master plan:
   - mark step 1.5 ✅
   - add the new rules to the W list: W6 now bans suspense colons, plus serial commas, Name What You Mean, Say It Once, clipped clauses and "-ly" hyphens
