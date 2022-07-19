# Installation and Configuration
Development config in **dev.dcfg**. Runtime config in **run.dcfg**. The system is developed on a raw system (currently Windows) and deployed in docker on Linux.

## Install and configure MariaDB on the host system

Install mariadb and set your database root user passowrd:

```bash
sudo apt install mariadb-server
sudo mysql_secure_installation
```

Next create the database `dyalog_cms`, create user `dcms` and grant privileges.

You'll want to generate a secure password some how. That password should be used in the next step when creating the user `dcms`, and also pasted into **secrets/secrets.json5** which is shown below.

```bash
sudo mariadb -u root -p
create database dyalog_cms
create user dcms identified by **MARIADB_PASSWORD**
grant all privileges on dyalog_cms to user dcms 
```
 
**secrets/secrets.json5**
```
{
	youtube: "https://www.googleapis.com/youtube/v3/",
    youtube_key: "YOUTUBE_API_KEY",
	youtube_channels: [
		{ name: "Dyalog Usermeeting", id: "UC89lIdGnKlEozb1WcYQprNw" },
		{ name: "DyalogLtd", id: "UCRFAE1uHnrhXlSkoaAgKsIQ" },
	],
	elastic: {
		user: "elastic",
		pass: "ELASTICSEARCH_PASSWORD"
	},
	mariadb: ["Mariadb", "MARIADB_PASSWORD", "dcms"]
}
```

1. Set data sources location in **data_sources.json5**
2. Put API keys into a file **on the server only** in **secrets.json5**
    - You might want to store it somewhere else. In which case, update the file for **dcms_secrets** in **docker-compose.yml**
3. Set application directory, dependencies etc. in **run.dcfg**
    - app_dir
    - service_url

- TODO: also make it securely RIDE-able
- TODO: use github submodule to depend on Jarivs, HttpCommand and XL2APL

## secrets
Docker secrets are used to store:
- External API keys (e.g. YouTube)
- Mariadb login information
- server certificates 

## data sources
Most manually updated source data is specified in **data_sources.json5**.

Some data is fetched from external APIs. API keys are specified

## debug
Global debug flag. Used as `#.GLOBAL.debug` in order to not have to re-read environment.

This controls behaviour of errors (error number > 0) and warnings (error number < 0) in terms of resignalling and logging.

|Value|Behaviour|
|---|---|
|0|Catch all errors, print errors and warnings to the session log and attempt to carry on.
|1|Stop on errors but just print warnings to the session log|
|2|Stop on errors and warnings|

