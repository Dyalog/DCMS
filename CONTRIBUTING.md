# CONTRIBUTING
Development with Docker

## Set up
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
