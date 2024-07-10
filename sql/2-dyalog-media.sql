CREATE TABLE `person` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `post_id` int(10) unsigned,
  `name` varchar(128) NOT NULL,
  `role` varchar(128),             /* current role at organisation */
  `organisation` varchar(256),     /* current organisation */
  `role_summary` text,             /* summary of role at organisation */
  `description` text,              /* general person description or biography */
  `location` varchar(128),         /* e.g. country in which person is mostly based */
  `picture` varchar(128),          /* URL to image file */
  `url_slug` varchar(128),
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `event` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `title` varchar(256) NOT NULL,
  `start` datetime,            /* Time and date of event start if applicable */
  `end` datetime,              /* Time and date of event end if applicable */
  `type` int(10),              /* Choose from drop-down of available events */
  `url_slug` varchar(256),     /* Human-readable identifier for use in URLs */
  `location` varchar(512),     /* Location of event, physical address/venue, online or name of media to use */
  `physical` boolean,          /* Is it a physical event? */
  `digital` boolean,           /* Is it a digital event? */
  `early_bird` datetime,       /* Date and time when early bird registration ends */
  `signup_url` varchar(256),   /* Date and time of when event should appear in the news section */
  `logo` varchar(256),         /* Dyalog text logo with event name/location/year */
  `icon` varchar(256),         /* Mythical icon e.g. ship,hammer,snake */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `event_type` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `type` varchar(256) NOT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `presentation` (         /* Key table for media e.g. videos/podcasts */
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(10) unsigned,       /* From dropdown of events */
  `code` varchar(10),                /* Unique code within this event */
  `title` varchar(256),              /* Presentation title */
  `presented_at` datetime,           /* Time and date of presentation start */
  `abstract` varchar(256),           /* Short summary/description */
  `description` text,                /* Long description */
  `category_id` int(10) unsigned,    /* ID link to presentation_category table */
  `type_id` int(10) unsigned,        /* ID link to presentation_type table */
  `location` varchar(512),           /* Can be used to add sub-location e.g. room,auditorium */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `presentation_type` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL,
  `type` varchar(256) NOT NULL,   /* Human-readable type e.g. Dyalog Presentations */
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `presentation_category` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(256) NOT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `presenter` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `presentation_id` int(10) unsigned,     /* ID key into presentations table */
  `person_id` int(10) unsigned,           /* ID key into persons table */
  `affiliation` varchar(256),   /* Role/organisation etc. at time of presentation */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128),
  UNIQUE (presentation_id, person_id)
);
CREATE TABLE `presentation_media` (
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `presentation_id` int(10) NOT NULL,
  `type` varchar(64) NOT NULL, /* name of table e.g. youtube_video */
  `media_id` int(10) NOT NULL, /* ID into table for that media type */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);
CREATE TABLE `media_general` ( /* Links to any media e.g. slides PDF or PPTX */
  PRIMARY KEY (`id`),
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `text` text, /* Link text */
  `url` text,  /* Link URL */
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` varchar(128)
);