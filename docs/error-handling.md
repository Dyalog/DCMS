# Error Handling

DCMS uses a tiered error handling scheme controlled by the `#.GLOBAL.debug` flag. Request-handling functions may call lower-level functions that check for invalid request conditions or trap anticipated errors. When such a condition is detected, the lower function signals an error using an HTTP status code (400--599) as the APL event number. The Stark router's `OnErrorFn` then decides what to do based on the debug level and the event number.

## Debug levels

For all levels 1 and above, the request object is retained in the active workspace for inspection.

| `#.GLOBAL.debug` | Behaviour |
|---|---|
| 0 | **Production.** All errors are trapped. If the event number is an HTTP status code (400--599), respond with that status. Otherwise respond 500. |
| 1 | **Development.** HTTP-status-code signals are handled as in level 0. Any other error suspends execution for debugging. |
| 2 | **Strict debugging.** All errors suspend execution, including HTTP-status-code signals. |
| 3 | **Tracing.** Execution suspends on request entry so the developer can step through the full request. This is passed to the Stark router as debug mode 2, not handled in `OnErrorFn`. |

## How lower functions signal expected errors

When a function detects an invalid request condition (missing parameter, unauthorised access, resource not found, etc.) or catches an anticipated error, it signals using the appropriate HTTP status code as the event number:

```apl
⎕SIGNAL⊂('EN' 404)('Message' 'Video not found')
```

`OnErrorFn` checks whether the event number falls in the 400--599 range to distinguish expected errors from unexpected ones.
