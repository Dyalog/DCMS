# Error Handling

DCMS uses a call-down, signal-up error handling scheme. Request-handling functions may call lower-level functions that check for invalid request conditions or trap anticipated errors. When such a condition is detected, the lower function signals an error using `⎕SIGNAL` with `Vendor:'DCMS'`. The Stark router's `OnErrorFn` (`HandleError`) then decides how to respond.

## Debug levels

Debug levels are controlled by `#.GLOBAL.debug` and propagated to the Stark router via `router.Debug`. The router handles suspension and trapping behaviour; `HandleError` only runs when errors are trapped.

| `#.GLOBAL.debug` | Behaviour |
|---|---|
| 0 | **Production.** All errors are trapped. `HandleError` is called. |
| 1 | **Development.** Errors suspend execution for debugging. |
| 2 | **Tracing.** Execution suspends on request entry so the developer can step through the full request. |

For all levels 1 and above, the request object is retained in the active workspace for inspection. Debug state can be toggled at development time via the `DebugTrigger` on `#.GLOBAL.debug`, which keeps `GLOBAL.logging`, `router.Debug`, and `jarvis.Debug` in sync. FIXME consider removing the debug state trigger. It's kind of a neat feature but isn't any better than a dedicated function really, and more dangerous in terms of side-effects overall.

## How lower functions signal expected errors

When a function detects an invalid request condition (missing parameter, unauthorised access, resource not found, etc.) it signals with `Vendor:'DCMS'`:

```apl
⎕SIGNAL⊂('EN' 404)('Message' 'Video not found')('Vendor' 'DCMS')
```

## HandleError

`HandleError` distinguishes DCMS-vendor signals from unexpected errors:

- **DCMS-vendor errors** — returned as structured JSON with the signalled status code.
- **Other errors** — logged via `Log`, and a generic 500 response is returned to the client.
