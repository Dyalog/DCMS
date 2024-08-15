# API Reference

## Endpoints
Field names and SQL queries for CACHE items used by GET endpoints are defined in `/APLSource/read_/endpoints.json5`.

Programmatically, endpoint switches are explicit in `#.DCMS.Get` and `#.DCMS.Post`.

Most implement a REST-like scheme, in which /endpoint lists all available items, possilbly with querying available, and /endpoint/id lists a single specific item within that endpoint.

## GET

Endpoints:
- [videos](#videos)
- [person](#person)
- [event](#event)
- [event_type](#event_type)
- [presentation](#presentation)
- [presentation_type](#presentation_type)
- [presenters](#presenters)
- [dtv_events](#dtv_events)

### /version
Returns a string of the running DCMS version.

```JSON5
""
```

### /videos
Returns a list of video objects

```JSON5
[{
    category: "",
    description: "",
    event: "",
    event_shortname: "",
    presented_at: "", // Year and month of presentation as "YYYY-MM-DD hh:mm:ss"
    presenter: "",   // Comma-separated list of presenter names
    published_at: "", // YouTube video publish date as "YYYY-MM-DD hh:mm:ss"
    thumbnail: "",
    title: "",
    url: "",
    youtube_id: ""
}]
```

### Query parameters

#### search
`?search=q` where `q` is a list of search terms separated by URL-encoded space (`'%20'`), comma (`','`) or plus (`'+'`). Free text search of titles, descriptions, presenters and events.

#### filter by date range
`?from=date` for videos no earlier than `date` of form `YYYY-MM-DD`
`?to=date` for videos no more recent than `date` of form `YYYY-MM-DD`

#### filter by event
`?event=e` where `e` is the URL slug / short name of event (e.g. Dyalog '22 → dyalog-22)

#### pagination
`?per_page=n` where n is a positive integer. Optionally, `?page=k` where k is a positive integer.

Using the `per_page` and optional `page` parameters results in a paginated response which follows the template described in the next code block. The `data` item is a list of video results with the same structure described under [/videos](#videos).

```JSON5
{
    path: "",     // The URL for this endpoint
    per_page: 0,
    current_page: 0,
    data: [{}],   // List of video results with the same structure described under /videos
    from: 0,      // Ordinal number of the first result on this page
    to: 0,        // Ordinal number of the last result on this page
    total: 0,     // Total count of results for this query
    first_page: 0,
    last_page: 0,
    first_page_url: "",
    prev_page_url: "",
    next_page_url: "",
    last_page_url: "",
    links: [{   // Link objects describe numbered, previous and next buttons used on paginated results pages
        active: false,
        label: "",
        url: ""
    }],
}
```

For total query results n and current page p, the links provided in the response (as a list called "links") are one of three variations:
- `1..n                             if 10≥≢pages`
- `(⍳10) ... n-1 n                  if 10>this page`
- `1 2 ... p(-,+)3 ... n-1 n        if 10<≢pages and this page is more than 10 from the end`
- `1 2 ... n-9..n                   if 10<≢pages and this page is 10 or less from the end`

### Video by YouTube ID
e.g. `/videos/_EcoRpYr3FE`

Returns a JSON object.

```JSON5
{
    category: "",
    description: "",
    event: "",
    event_shortname: "",
    presented_at: "YYYY-MM-DD hh:mm:ss",
    presenter: "",
    published_at: "YYYY-MM-DD hh:mm:ss",
    thumbnail: "",  // URL to image file
    title: "",
    url: "",
    youtube_id: ""
}
```

### /videos/recommended
Returns a list of video objects. 

```JSON5
[{
    category: "",
    event: "",
    event_shortname: "",
    presented_at: "YYYY-MM-DD hh:mm:ss",
    presenter: "",
    thumbnail: "",  // URL to image file
    title: "",
    url: "",
    youtube_id: ""
}]
```

#### Query parameters

##### v
`?v=youtube_id` get video recommendations based on the video with this YouTube ID.

##### n
`?n=` where `n` is a positive integer. Return `n` results.

### /person
Returns a list of person objects.

```JSON5
[{
    id: 0,
    name: "",
    organisation: "",
    location: "",
    description: "",
    role: "",
    role_summary: "",
    url_slug: "",
    updated_at: "",
    updated_by: "",
    created_at: "YYYY-MM-DD hh:mm:ss"
}]
```

### /event_type
Returns a list of event_type objects.

```JSON5
[{
    id: 0,
    type: "",
    description: "",
    created_at: "YYYY-MM-DD hh:mm:ss",
    updated_at: "YYYY-MM-DD hh:mm:ss",
    updated_by: ""
}]
```

### /event
Returns a list of event objects.

```JSON5
[{
    id: 0,
    title: "",
    location: "",
    url_slug: "",  // AKA event_shortname
    icon: "",      // URL of image file
    logo: "",      // URL of image file
    physical: 0,   // Boolean: physical in-person event?
    digital: 0,    // Boolean: digital/online event?
    type: 0,       // ID into event_type table
    start: "YYYY-MM-DD hh:mm:ss",
    end: "YYYY-MM-DD hh:mm:ss",
    early_bird: "YYYY-MM-DD hh:mm:ss",   // Date and time end of early bird registration
    signup_url: "",
    created_at: "YYYY-MM-DD hh:mm:ss",
    updated_at: "YYYY-MM-DD hh:mm:ss",
    updated_by: ""
}]
```

### /presenters
Returns a list of strings. These are [persons](#person) who are in the presenter table.

```JSON5
[""]
```

### /presentation
Returns a list of presentation objects.

```JSON5
[{
    id:           0,
    title:       "",
    code:        "",   // Alphanumeric code for this presentation, unique within this event
    event_id:     0,   // ID into event table
    abstract:    "",   // Short summary found on Dyalog website
    description: "",
    location:    "",
    type_id:      0,   // ID into presentation_type table
    category_id:  0,   // ID into presentation_category table
    presented_at: "YYYY-MM-DD hh:mm:ss",   // Year and month during which this was presented
    created_at:   "YYYY-MM-DD hh:mm:ss",
    updated_at:   "YYYY-MM-DD hh:mm:ss",
    updated_by:   ""
}]
```

### /presentation_type
Returns a list of presentation type objects.

```JSON5
[{
    id: 0,
    type: "",
    description: "",
    created_at:   "YYYY-MM-DD hh:mm:ss",
    updated_at:   "YYYY-MM-DD hh:mm:ss",
    updated_by:   ""
}]
```

### /dtv_events
Returns a list of objects. These are events which have at least one video associated with a presentation and therefore should be listed in the video library dropdown.

```JSON5
[{
    id: 0,        // ID in event table
    title: "",
    type: "",     // Type from presentation_type table
    url_slug: "", // AKA shortname, the URL friendly event name
}]
```

## POST
All POST requests require authentication.

### /refresh
Trigger the building of CACHE items and re-compute [recommended videos](#videosrecommended).

Some [GET](#get) endpoints do a simple SQL SELECT query. Others involve more complex joins and recommendations are computed using cosine similarity over large amounts of text. For performance, these computations are performed and the result stored in the cache namespace. GET requests then retrieve data from this cache rather than computing each time.

### /wp_update_team_dyalog_videos
Trigger pushing Team Dyalog Videos custom posts to website.

`?n=` where `n` is a positive integer (default 10). Push up to `n` latest videos per person.

This will get up to the `n` latest videos for each Team Dyalog member and list them on their team pages.
