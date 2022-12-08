# WordPress synchronisation
Some pages and widgets on wordpress are to be generated programmatically from data stored in DCMS. For example, the Team Dyalog grid/list and individual `/team-dyalog/` pages are generated in this way.

## How DCMS data becomes WordPress content
On the wordpress side, we use **Advanced Custom Fields** (ACF) in **Custom Post Types** (CPT) using the **ACF** and **CPT UI** plugins.

### Create a post type and associate custom fields
In the main WordPress menu, on the left hand side of the admin interface, go to **CPT UI** to add the custom post type. Ensure that **Show in REST API** is set to **True**. You may want to set **Show in Nav Menus** to **False** if the post type is used to create parts of another page, rather than a page in itself.

Then go to **Custom Fields**. From here you can add and edit field groups.

1. Add the desired custom fields. These can be changed later. Only remove existing fields if you are certain that they are not being used.
1. Set the **Field Group Title**
1. Scroll down to  **Settings**
	1. In the **Location Rules** tab, set to **Show this field group if** post is equal to the CPT we just created
	1. In the **Group Settings** tab, enable **Show in REST API**

### Push data from DCMS to WordPress via REST
We *push* data up to wordpress via its REST API, to populate the CPT fields. This is done by `DCMS.wp_.CPTPush[entity]` functions. For example, `CPTPushTeamDyalogVideos` creates and updates the **Team Dyalog Videos** posts.

A custom content type contains the ID into the relevant SQL table. For example, the `person` CCT contains fields:

- `_ID` (ID in WordPress jet-cct table), 
- `dcms_id` (ID into `person` endpoint in DCMS API)
- `name` (Name just for easy manual identification for debugging)

This data is pushed to WordPress via the REST API in the `#.DCMS.wp_` namespace. The data is simply supplied as JSON.

The `/refresh` endpoint can be used to trigger a rebuild of the API data and an update of wordpress CCT items. 

### Authentication
A WordPress user `DCMS` has permission to edit others' posts. This Access Capabilitiy (`edit_others_posts`) is set in the settings for the Custom Content Type. You can create a password (`#.GLOBAL.api.wordpress_token` in the [secrets](secrets.md)) from Wordpress via **Users → Profile → Application Password**.

