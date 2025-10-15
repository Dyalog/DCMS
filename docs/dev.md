# Development
DCMS is developed using Dyalog in Docker. This allows us to develop and deploy with the same environment.

## Development, Testing and Deployment
Three [configuration files](https://docs.dyalog.com/20.0/unix-installation-and-configuration-guide/configuration-parameters/configuration-files/) are used to launch the system for the purposes of development, testing and deployment.

1. The [**dev.dcfg**](../dev.dcfg) configuration is used for development. The script [**dev**](../dev) can be used on Linux to set required environment variables and launch Dyalog from this configuration file.  
    ```sh
    ./dev
    ```
2. The [**CI/testing.dcfg**](../CI/testing.dcfg) is used to launch the application and execute the test suite. The script [**CI/run-tests-in-docker.sh**](../CI/run-tests-in-docker.sh) can be used on Linux to run these tests using Docker.  
    ```sh
    ./CI/run-tests-in-docker.sh
    ```
3. The [**run.dcfg**](../run.dcfg) configuration is used to launch the application in production.

## Test scenarios and the Mock YouTube service
The **Admin** namespace includes the **MockYT** service that lets us test using the YouTube API with dummy data. This service is started by **dev.dcfg** and **testing.dcfg** if the environment variable `YOUTUBE` contains `'localhost'`.

While developing in Dyalog, you can run tests with:

```apl
Admin.(Tests.Run GetEnv'URL')
```

This will test HTTP endpoints, insert dummy data into the database, rebuild the cache (calling the mock YouTube service to get e.g. video description data) and test the HTTP endpoints again.

The `Admin.Tests.Test` function takes a namespace of functions that begin with `Test` and runs them, printing to the session in the case of an error or failure. The overall function returns `1` if all tests pass and `0` otherwise.

The `Admin.Tests.General` test suite should pass when the system is newly started with a fresh database and when the service has data in the cache ready to serve. These are like regression tests.

The `Admin.Tests.DummyData` is more like an integration test suite.
