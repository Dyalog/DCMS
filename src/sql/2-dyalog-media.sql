CREATE TABLE `news` (
    PRIMARY KEY (`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `headline` varchar(256),
    `snippet` varchar(512),
    `url` varchar(256),
    `type` varchar(128),
    `image` varchar(512),
    `start` datetime,
    `duration` int(8),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `event` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` varchar(256) NOT NULL,
    `start` datetime,            /* Time and date of event start if applicable */
    `end` datetime,              /* Time and date of event end if applicable */
    `has_time` boolean,          /* Event start and end should be specified with times as well as dates */
    `type` varchar(128),         /* Choose from drop-down of available events */
    `url_slug` varchar(256),     /* Human-readable identifier for use in URLs */
    `location` varchar(512),     /* Location of event, physical address/venue, online or name of media to use */
    `physical` boolean,          /* Is it a physical event? */
    `digital` boolean,           /* Is it a digital event? */
    `early_bird` datetime NULL DEFAULT NULL,       /* Date and time when early bird registration ends */
    `signup_url` varchar(256),   /* Date and time of when event should appear in the news section */
    `news_start` datetime,       /* URL of page to sign up */
    `news_duration` int(8),      /* Number of days the event appears in the news section of website */
    `event_logo` varchar(256),   /* Dyalog text logo with event name/location/year */
    `icon` varchar(256),         /* Mythical icon e.g. ship,hammer,snake */
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `presentation` (         /* Key table for media e.g. videos/podcasts */
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` varchar(256),              /* Presentation title */
    `start` datetime,                  /* Time and date of presentation start */
    `end` datetime,                    /* Time and date of presentation end */
    `abstract` varchar(256),           /* Short summary/description */
    `description` text,                /* Long description */
    `category_id` int(11),             /* ID link to category table */
    `event_id` int(11),                /* From dropdown of events */
    `location` varchar(512),           /* Can be used to add sub-location e.g. room,auditorium */
    `news_start` datetime,             /* Date and time of when presentation should appear in the news section */
    `news_duration` int(8),            /* Number of days the presentation appears in the news section of website */
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `person` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(128) NOT NULL,
    `role` varchar(128),             /* current role at organisation */
    `organisation` varchar(256),     /* current organisation */
    `description` text,
    `country` varchar(128),
    `join_dyalog_date` date,
    `leave_dyalog_date` date,                
    `picture` varchar(128),          /* URL to image file */
    `short_description` text,        /* Appearing in list views of multiple persons and at the top of personal page */
    `evangelism_description` text,   /* Short description provided alongside presentation listings */
    `url_slug` varchar(128),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `community` (
    PRIMARY KEY (`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(256),
    `description` text,
    `url` varchar(256),
    `contact` varchar(256),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `presenter` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `presentation_id` int(11),     /* ID key into presentations table */
    `person_id` int(11),           /* ID key into persons table */
    `role` varchar(128),           /* Role at time of presentation. From persons table, but allow manual override */
    `organisation` varchar(256),   /* Organisation (e.g. company, university) at time of presentation */
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `media` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `type` char(32) NOT NULL,      /* Name of table for corresponding media table e.g. youtube_videos,podcasts */
    `title` varchar(256) NOT NULL,
    `url` varchar(256),            /* Maybe better to ID into separate table for each media type? */
    `media_id` int(11),            /* ID into table for type e.g. youtube_video, podcast etc. */
    `publication_date` datetime,
    `presentation_id` int(11),     /* ID key into presentations table */
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `category` (
    PRIMARY KEY (`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `category` varchar(128),
    `description` varchar(256),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `some` (   /* Social Media */
    PRIMARY KEY(`id`),
    `id` int(11),
    `name` varchar(128),
    `icon` varchar(128),
    `url` varchar(128),
    `description` varchar(256),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `personalsome` (
    `person_id` int(11),
    `some_id` int(11),
    `url` varchar(256),
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
