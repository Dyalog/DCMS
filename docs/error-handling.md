# Error Handling

DCMS uses a call-down, signal-up error handling scheme. Request-handling functions may call lower-level functions that check for invalid request conditions or trap anticipated errors. When such a condition is detected, the lower function signals an error using `⎕SIGNAL` with `Vendor:'DCMS'`. The Stark router's `OnErrorFn` (`HandleError`) then decides how to respond.

## Debug Controls

Error-handling behaviour is governed by three **independent** variables in `DCMS.GLOBAL`, set via `DCMS.SetDebug`, which also propagates them to the Stark router (`router.Debug`) and Jarvis (`jarvis.Debug`):

| Variable         | Values    | Controls                                                     |
| ---------------- | --------- | ------------------------------------------------------------ |
| `GLOBAL.logging` | 0 / 1     | whether `Log` lines print to the session                     |
| `GLOBAL.suspend` | 0 / 1 / 2 | which classes of error suspend vs are trapped into responses |
| `GLOBAL.trace`   | 0 / 1     | whether execution suspends on request entry (step-through)   |

`GLOBAL.suspend` which errors suspend:

| Value    | Expected errors (DCMS-signalled)                  | Unexpected errors (bugs)                                 |
| -------- | ------------------------------------------------- | -------------------------------------------------------- |
| 0 (none) | trapped → HTTP response (status = signalled `EN`) | trapped → 500 response (+ pre-filled issue link), logged |
| 1 (bugs) | trapped → HTTP response                           | left to suspend in the debugger                          |
| 2 (all)  | left to suspend                                   | left to suspend                                          |

- **0** — production / tests: nothing suspends; every error becomes a response.
- **1** — development: routine 4xx/5xx still answer the client; unexpected errors open the debugger.
- **2** — strict: every error suspends, including the deliberately-signalled ones.

The three are orthogonal: e.g. logging can be enabled in production (`logging 1, suspend 0`), or a request stepped through while errors are still trapped into responses (`trace 1, suspend 0`).

## Setting the Controls

`SetDebug (logging suspend trace)` is the single entry point. It sets the three `GLOBAL` variables, sets `SQL.debug` to follow `logging`, and maps the controls onto the framework bitmasks:

- `router.Debug` bit 1 (disable Stark's dispatch trap) is set only when `suspend=2`; bit 64 (stop before routing) is set when `trace=1`.
- `jarvis.Debug` bit 1 (let an error reach the debugger) is set when `suspend>0`.

`jarvis.Debug` must be set **after** `router.Start` (Stark forwards its own bit 1 to Jarvis at start time), which `Run` ensures.

`Run` accepts either an explicit `(logging suspend trace)` triple or a preset scalar — `0` = production `(0 0 0)`, `1` = development `(1 1 0)`, `2` = strict `(1 2 0)`. The configs (`dcms.dcfg`, `dev.dcfg`, `CI/test.dcfg`) pass the values via the `LOGGING` / `SUSPEND` / `TRACE` keys. To retune a running server, call `DCMS.SetDebug` directly.

## How Lower Functions Signal Expected Errors

When a function detects an anticipated condition (missing parameter, unauthorised access, resource not found, upstream API failure, etc.) it signals with `Vendor:'DCMS'` and an `EN` equal to the intended HTTP status:

```apl
⎕SIGNAL⊂('EN' 404)('Message' 'Video not found')('Vendor' 'DCMS')
```

## HandleError

`HandleError` (the router's `OnErrorFn`) classifies every trapped error:

- **Expected** — `Vendor≡'DCMS'`. A 4xx `EN` becomes a response with that status; any other `EN` (5xx, etc.) becomes a 500 response. The signalled `Message` is preserved.
- **Unexpected** — no DCMS vendor tag (a genuine bug). Always logged via `Log`. With `suspend=0` it becomes a generic 500 response carrying a pre-filled GitHub issue link; with `suspend=1` it is re-signalled so it propagates to the debugger (Jarvis does not trap it).

### Where the Debugger Suspends (`suspend=1`)

Because Stark's dispatch trap must stay active to classify and respond to _expected_ errors, an unexpected error is caught there first and then re-signalled from `HandleError`. The debugger therefore suspends at the re-signal point, not the original fault site; the cloned `⎕DMX` (and the log line) retain `EN`/`EM`/`Message`/`DM`. For a live suspension at the exact fault site, use `suspend=2`, which disables trapping entirely — but then expected errors suspend too.
