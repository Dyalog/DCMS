# Configuration Reference

## Secrets

Secrets are stored in `secrets/secrets.json5`. This file is gitignored — each developer creates their own locally, and in production the CI framework provides it separately.

**secrets/secrets.json5**
```json5
{
	youtube: "https://www.googleapis.com/youtube/v3/",   // Changes to a localhost dummy server for testing
	youtube_key: "YOUTUBE_API_KEY",
	youtube_channels: [
		{ name: "Dyalog Usermeeting", id: "UC89lIdGnKlEozb1WcYQprNw" },
		{ name: "DyalogLtd", id: "UCRFAE1uHnrhXlSkoaAgKsIQ" },
	],
	thumbnails_root: "https://dyalog.com/uploads/video-thumbnails/",   // Video thumbnails hosted on the same server as the front end app for GDPR compliance
	upload_token: "",   // DCMS API token, only authorised POST requests allowed
	wordpress: {   // For updating website content
		url: "WP_JSON URL",
		user: "WordPress User",
		token: "User's API token",
	},
}
```

## Debug flag

Global debug flag stored in `#.GLOBAL.debug`.

This controls error handling behaviour and developer debugging support. See [error-handling.md](error-handling.md) for the full scheme.

| Value | Behaviour |
|---|---|
| 0 | Production — all errors trapped, HTTP status code responses or 500 |
| 1 | Development — expected errors respond normally, unexpected errors suspend |
| 2 | Strict debugging — all errors suspend execution |
| 3 | Tracing — suspend on request entry for step-through debugging |
