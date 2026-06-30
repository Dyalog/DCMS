# Dependencies
Developing this project requires:
- .NET SDK for the version of Dyalog in use
- Tatin packages
- NuGet packages

These can be updated using an installed Dyalog system with Tatin activated.

The [dev script](../dev) and [Jenkins job](../Jenkinsfile) activate Tatin and install the Tatin and NuGet packages in directories that persist between container runs.

## Jarvis
DCMS is built on the [Jarvis](https://dyalog.github.io/Jarvis) web service framework, which exposes APL functions as HTTP endpoints.

## Stark
[Stark](https://github.com/dyalog-labs/stark) is a REST router layered on Jarvis. It maps HTTP methods and paths to the APL functions that handle them, and assembles the OpenAPI specification served at `/openapi.json`. See [Routing](../CONTRIBUTING.md#routing) for how DCMS uses it.

## HttpCommand
The [HttpCommand](https://dyalog.github.io/HttpCommand) package is used to interact with external HTTP APIs.

## NuGet
The [Dyalog/NuGet](https://github.com/Dyalog/nuget) package installs NuGet packages and makes them callable from APL.

## Porter2Stemmer NuGet Package
The [Porter2Stemmer](https://www.nuget.org/packages/Porter2Stemmer) NuGet package is used so that search queries can be stemmed, for example "packages" becomes "package", so that results are less dependent on exact spelling.
