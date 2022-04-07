CREATE TABLE `events` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` varchar(256) NOT NULL,
    `start` datetime,            /* Time and date of event start */
    `end` datetime,              /* Time and date of event end */
    `type` varchar(128),         /* Choose from drop-down of available events */
    `url_slug` varchar(256),     /* Human-readable identifier for use in URLs */
    `location` varchar(512),     /* Location of event, physical address/venue, online or name of media to use */
    `physical` boolean,          /* Is it a physical event? */
    `digital` boolean,           /* Is it a digital event? */
    `early_bird` datetime,       /* Date and time when early bird registration ends */
    `signup_url` varchar(256),   /* Date and time of when event should appear in the news section */
    `news_start` datetime,       /* URL of page to sign up */
    `news_duration` int(8),      /* Number of days the event appears in the news section of website */
    `event_logo` varchar(256),   /* Dyalog text logo with event name/location/year */
    `icon` varchar(256),         /* Mythical icon e.g. ship,hammer,snake */
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `presentations` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `title` varchar(256),              /* Presentation title */
    `start` datetime,                  /* Time and date of presentation start */
    `end` datetime,                    /* Time and date of presentation end */
    `abstract` varchar(256),           /* Short summary/description */
    `description` text,                /* Long description */
    `category_id` int(11),             /* ID link to categories table */
    `event_id` int(11),                /* From dropdown of events */
    `location` varchar(512),           /* Can be used to add sub-location e.g. room,auditorium */
    `news_start` datetime,             /* Date and time of when presentation should appear in the news section */
    `news_duration` int(8),            /* Number of days the presentation appears in the news section of website */
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `persons` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(128) NOT NULL,
    `role` varchar(128),                     /* current role at organisation */
    `organisation` varchar(256),             /* current organisation */
    `description` text,
    `country` varchar(128),
    `join_dyalog_date` date,
    `leave_dyalog_date` date,                
    `picture` varchar(128),                  /* URL to image file */
    `short_description` varchar(256),        /* Appearing in list views of multiple persons and at the top of personal page */
    `evangelism_description` varchar(256),   /* Short description provided alongside presentation listings */
    `url_slug` varchar(128),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `communities` (
    PRIMARY KEY (`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `name` varchar(256),
    `description` text,
    `url` varchar(256),
    `contact` varchar(256),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `presenters` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `presentation_id` int(11),
    `presenter` int(11),           /* ID key into persons table */
    `role` varchar(128),           /* Role at time of presentation. From persons table, but allow manual override */
    `organisation` varchar(256),   /* Organisation (e.g. company, university) at time of presentation */
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `media` (
    PRIMARY KEY(`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `type` char(32) NOT NULL,
    `title` varchar(256) NOT NULL,
    `description` text,
    `url` varchar(256),
    `publication_date` datetime,
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `categories` (
    PRIMARY KEY (`id`),
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `category` varchar(128),
    `description` varchar(256),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);

CREATE TABLE `some` (
    PRIMARY KEY(`id`),
    `id` int(11),
    `name` varchar(128),
    `icon` varchar(128),
    `url` varchar(128),
    `description` varchar(256),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
CREATE TABLE `personalsome` (
    `person_id` int(11),
    `some_id` int(11),
    `url` varchar(256),
    `created_at` datetime,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_by` varchar(128)
);
