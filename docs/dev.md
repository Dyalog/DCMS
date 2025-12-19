# Development
DCMS is developed using Dyalog in Docker. This allows us to develop and deploy with the same environment.

## Development, Testing and Deployment
[Configuration files](https://docs.dyalog.com/20.0/unix-installation-and-configuration-guide/configuration-parameters/configuration-files/) are used to launch the system for the purposes of development, testing and deployment.

The base configuration is in [**dcms.dcfg**](../dcms.dcfg). Other configuration files use this as a base with the "Extend" keyword, and when run in Docker for testing and in production, Dyalog is launched using **dcms.dws** which automatically uses settings found in the base configuration file.

The [**dev.dcfg**](../dev.dcfg) configuration is used for development. The script [**dev**](../dev) can be used on Linux to set required environment variables and launch Dyalog from this configuration file.

```sh
./dev
```

> The first time you run **dev**, pass the `-i` flag to activate Tatin into the **data** folder and install [dependencies](./dependencies.md).  
> `./dev -i`

To run tests during development, do:  

```apl
Admin.(Tests.Run GetEnv'URL')
```

The system is built as a binary workspace **dcms.dws** for testing and deployment. Use the build script [**CI/build-with-docker.sh**](../CI/build-with-docker.sh) to build the application workspace.

Then, to run the deployment testing scenario locally, do:

```sh
./CI/run-tests-in-docker.sh
```

## Packages
This application depends on [Tatin and NuGet packages](./dependencies.md). During development, these are loaded using Tatin and the .NET SDK. For testing and production, the application source and dependencies are loaded into the active workspace which is saved as a binary workspace file.

Using the built application workspace then only requires the .NET runtime.
