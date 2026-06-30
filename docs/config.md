# Configuration Reference

## Secrets

Secrets are stored in `secrets/secrets.json5`. This file is gitignored. Each developer creates their own locally, and in production the CI framework provides it separately.

**secrets/secrets.json5**

```json5
{
  youtube: "https://www.googleapis.com/youtube/v3/", // Changes to a localhost dummy server for testing
  youtube_key: "YOUTUBE_API_KEY",
  youtube_channels: [
    { name: "Dyalog Usermeeting", id: "UC89lIdGnKlEozb1WcYQprNw" },
    { name: "DyalogLtd", id: "UCRFAE1uHnrhXlSkoaAgKsIQ" },
  ],
  thumbnails_root: "https://dyalog.com/uploads/video-thumbnails/", // Video thumbnails hosted on the same server as the front end app for GDPR compliance
  upload_token: "", // DCMS API token, only authorised POST requests allowed
  wordpress: {
    // For updating website content
    url: "WP_JSON URL",
    user: "WordPress User",
    token: "User's API token",
  },
}
```

## Debug Controls

Error-handling and developer-debugging behaviour is governed by three **independent**
configuration keys, applied at start-up to `DCMS.GLOBAL.(logging suspend trace)` by
`DCMS.SetDebug`:

```apl
DCMS.SetDebug logging suspend trace   ⍝ 3-element integer vector
```

| Config key | `DCMS.GLOBAL` | Values    | Meaning                                                                    |
| ---------- | ---------- | --------- | -------------------------------------------------------------------------- |
| `LOGGING`  | `logging`  | 0 / 1     | print `Log` lines to the session                                           |
| `SUSPEND`  | `suspend`  | 0 / 1 / 2 | suspend on error: none / bugs only / all (rest are trapped into responses) |
| `TRACE`    | `trace`    | 0 / 1     | suspend on request entry for step-through debugging                        |

See [error-handling.md](error-handling.md) for the full scheme.
