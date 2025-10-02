# Installation and Configuration
Development is now in Docker

## Run application for development
1. Install [Docker Compose](https://docs.docker.com/compose/)
1. Open a terminal and change to the **DCMS** directory  
    `cd /path/to/DCMS`
1. Set environment variables
    ```
    SQL_SERVER=db
    SQL_DATABASE=dyalog_cms
    SQL_USER=dcms
    SQL_PASSWORD=apl
    SQL_PORT=3306
    MYSQL_SERVER=db
    MYSQL_DATABASE=dyalog_cms
    MYSQL_USER=dcms
    MYSQL_PASSWORD=apl
    MYSQL_PORT=3306
    SECRETS=/app/secrets/secrets.json5
    RIDE_INIT=HTTP:*:4502
    CONFIGFILE=/app/dev.dcfg
    MYSQL_RANDOM_ROOT_PASSWORD=1
    ```
1. Run the service
    - On Linux/macOS, run **dev** (this sets environment variables as above)
    - On Windows, run **docker compose up**

You can connect to Ride in a web browser using the above configuration, or set `RIDE_INIT=SERVE:*:4502` to be able to connect with standalone Ride.

## Secrets
Secrets are stored in a JSON file. In production these are obtained separately by the Continuous Integration (CI) framework.

**secrets/secrets.json5**
```
{
	youtube: "https://www.googleapis.com/youtube/v3/",
    youtube_key: "YOUTUBE_API_KEY",
	youtube_channels: [
		{ name: "Dyalog Usermeeting", id: "UC89lIdGnKlEozb1WcYQprNw" },
		{ name: "DyalogLtd", id: "UCRFAE1uHnrhXlSkoaAgKsIQ" },
	],
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

This controls behaviour when errors occur.

|Value|Behaviour|
|---|---|
|0|All errors are trapped and the server responds 500.|
|1|Expected errors are trapped and respond 500. Unexpected errors suspend execution.|
|2|All errors suspend execution|
|>2|The APL system throws DOMAIN ERROR and the server does not start.|

## Testing
The tests suite performs the following tests:  
1. Call GET endpoints and check results have correct type.
2. Call POST endpoints and check results have correct content.
3. Call GET endpoints and check results have correct content.

Test scripts enable testing in 2 configurations:  
1. Launch application with a clean database.
2. Launch application with dummy data in the database.

Testing is set up for 2 scenarios:  
1. Development in APL  
    The `Admin` namespace is linked alongside `DCMS` when Dyalog is launched from **dev.dcfg**. `Admin.Tests.Run` to run the test suite. Returns `1` for success or `0` for failure. 
2. Command line  
    Use **CI/run-tests.sh** to run the full test suite locally. These scripts are also used by Jenkins to run tests during deployment.
