# OpenAPI spec does not match the implementation

Eight issues found reviewing the v5 API, all pre-existing.

1. `GET /videos?presenter` is documented as an ID list, but filters on names
    - **Spec**: `type: array, items: integer`, "Comma-separated list of presenter IDs, e.g. `123,456`".
    - **Code**: broken search on space-separated presenter names

    **Fix spec and remove presenter filter.** New parameter is `presenter_id`
2. `GET /videos?presenter_id` is undocumented

    Fixed by (1) above
3. `GET /videos` declares `422` but returns `400`
    - **Spec**: `⍙422` "Invalid query parameters"
    - **Code**: signals `EN 400`

    **Fix spec.** Replace `⍙422` with `⍙400`
4. `GET /videos` declares `404` but never returns it
    - **Spec**: `⍙404` "No videos found matching the query parameters"
    - **Code**: empty result is `200` with empty `data`

    **Fix spec.** Remove `⍙404`
5. `GET /videos/{youtube_id}/recommendations?n` default disagrees
    - **Spec**: `default: 5`
    - **Code**: defaults to 1

    **Decide.** Spec is the better API, but changing the code is a behaviour change
6. `GET /events?has_videos` description does not say what omitting it does
    - **Spec**: "Filter whether events have videos of presentations."
    - **Code**: omitted returns all events

    **Fix spec.** Omitted means all, `false` means events without videos, `true` means events with videos
7. `GET /videos` parameters are declared `required:0`, which is not a boolean
    Serialises to `"required":0`; every other endpoint uses `required:⊂'false'`

    **Fix spec.** Use `required:⊂'false'`
8. `GET /events?has_videos=banana` is silently treated as omitted
    - **Spec**: `type: boolean`
    - **Code**: any unrecognised value returns all events

    **Fix implementation.** Signal 400, as `PROFILING.Toggle` does for `on`
