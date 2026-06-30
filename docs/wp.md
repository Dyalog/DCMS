# WordPress Synchronisation
Some pages and widgets on the Dyalog website are generated programmatically from data stored in DCMS. For example, the videos listed on each Team Dyalog member's page are generated this way.

> [!NOTE]
> The WordPress integration is for internal Dyalog use: it publishes DCMS data
> to the Dyalog website. You can stand up your own WordPress site to try it, but
> it is probably not worth the effort if you are just exploring how a Dyalog app
> is built.

## How DCMS Data Becomes WordPress Content
On the WordPress side, we use **Advanced Custom Fields** (ACF) in **Custom Post Types** (CPT) using the **ACF** and **CPT UI** plugins.

### Create a Post Type and Associate Custom Fields
In the main WordPress menu, on the left hand side of the admin interface, go to **CPT UI** to add the custom post type. Ensure that **Show in REST API** is set to **True**. You may want to set **Show in Nav Menus** to **False** if the post type is used to create parts of another page, rather than a page in itself.

Then go to **Custom Fields**. From here you can add and edit field groups.

1. Add the desired custom fields. These can be changed later. Only remove existing fields if you are certain that they are not being used.
1. Set the **Field Group Title**
1. Scroll down to **Settings**
	1. In the **Location Rules** tab, set to **Show this field group if** post is equal to the CPT we just created
	1. In the **Group Settings** tab, enable **Show in REST API**

### Push Data From DCMS to WordPress via REST
DCMS *pushes* data to WordPress through its REST API to populate the CPT fields. The push is triggered by `POST /admin/wp-push` (handled by **[ADMIN.WPPush](../APLSource/ADMIN/WPPush.aplf)**) and currently covers one post type, **Team Dyalog Videos**.

**[WP.PushTeamDyalogVideos](../APLSource/WP/PushTeamDyalogVideos.aplf)** runs the whole cycle:

1. Read the existing `team-dyalog` member posts and `team-dyalog-videos` posts from WordPress, to map DCMS IDs onto WordPress post IDs.
2. Query MariaDB for the most recent videos per team member (up to `n`, default 10, set with the `?n=` query parameter).
3. **[WP.BuildVideoPosts](../APLSource/WP/BuildVideoPosts.aplf)** turns each row into a `team-dyalog-videos` post body, mapping the SQL columns onto the ACF fields and computing the derived fields (the HTML `<img>` thumbnail, the video-library URL, the event link, and the readable date). Videos with no matching Team Dyalog member are dropped.
4. Existing posts are updated and new ones created in batches through the WordPress `batch/v1` endpoint (**[WP.DoBulk](../APLSource/WP/DoBulk.aplf)**); posts no longer returned by the query are deleted.

The handler returns one `{post_id, action, success}` object per create, update, or delete.

The SQL statement lives in **[PushTeamDyalogVideos.aplf](../APLSource/WP/PushTeamDyalogVideos.aplf)**; the field mapping lives in **[BuildVideoPosts.aplf](../APLSource/WP/BuildVideoPosts.aplf)**. Each `team-dyalog-videos` post carries a `title`, a `date` (set to the presentation date), a `status` of `publish`, and these ACF fields:

| ACF field | Meaning |
| --------- | ------- |
| `media_id` | DCMS `youtube_video` table ID |
| `url` | Video-library watch URL |
| `thumbnail` | HTML `<img>` tag |
| `description` | Video description |
| `presentation_date` | Presentation date, `YYYY-MM-DD hh:mm:ss` |
| `readable_date` | Human-readable date, e.g. `March 2024` |
| `event_slug` | Event URL slug |
| `event_title` | Event title |
| `event` | HTML link to the event search |
| `person_id` | DCMS `person` table ID |
| `post_id` | The team member's Team Dyalog post ID |

### Authentication
A WordPress user has permission to edit others' posts. You can create a password (`DCMS.GLOBAL.secrets.wordpress.token` in the [secrets](config.md#secrets)) from WordPress via **Users → Profile → Application Password**. DCMS authenticates each request with the WordPress user and token from `DCMS.GLOBAL.secrets.wordpress`.
