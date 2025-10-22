# Installation and Configuration
The system is developed using Link with Dyalog in a Docker container. This page contains information relevant to anybody modifying to system to run in a different environment.

## Install ODBC drivers on the host system
!!!Warning
	You **MUST** use the [**MySQL ODBC Driver**](https://dev.mysql.com/downloads/connector/odbc/), as the type conversions in `src/sql/type_conversions.csv` and consequently `#.GLOBAL.type_conversions` and `#.GLOBAL.type_sqapl` (set in `#.DCMS.SQL.ProcessTableInformation`) rely on the numbers in the `DATA_TYPE` column of `#.(SQA.Columns DCMS.SQL.db)`.

!!!Failure
	If a type which has no conversion defined in `src/sql/type_conversions.csv` is present in the database, setup will fail with an error 106 "Uknown column type in rows: ", listing the row numbers in `1↓2⊃#.SQA.Columns #.DCMS.SQL.db` (`d` in ProcessTableInformation) with the problem data types.

If you use a different driver, check the output of `#.SQA.Columns #.DCMS.SQL.db` and change the numeric values in the 3rd column of `src/sql/type_conversions.csv`.

You can find out which `DATA_TYPE` numbers should be used with:

```APL
      ]view 2(↑⍤1)2⊃#.SQA.TypeInfo #.DCMS.SQL.db
```

and relating the `TYPE_NAME` column to those specified in `src/sql/type_conversions.csv`.

To see only types used in the database, try:

```APL
      {∪1↓⍵[;(1⌷⍵)⍳⊆'DATA_TYPE' 'TYPE_NAME']}2⊃#.SQA.Columns db
```

## Install and configure MariaDB on the host system
Install mariadb and set your database root user passowrd:

```bash
sudo apt install mariadb-server
sudo mysql_secure_installation
```

Next create the database `dyalog_cms`, create user `dcms` and grant privileges.

You'll want to generate a secure password some how. That password should be used in the next step when creating the user `dcms`, and also set as an environment variable before launching the service.

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

## debug
Global debug flag. Used as `#.GLOBAL.debug` in order to not have to re-read environment.

This controls behaviour of errors (error number > 0) and warnings (error number < 0) in terms of resignalling and logging.

|Value|Behaviour|
|---|---|
|0|Catch all errors, print errors and warnings to the session log and attempt to carry on.
|1|Stop on errors but just print warnings to the session log|
|2|Stop on errors and warnings|

