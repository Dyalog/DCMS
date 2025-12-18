# Dependencies
Developing this project requires:
- .NET SDK for the version of Dyalog in use
- Tatin packages
- NuGet packages

These can be updated using an installed Dyalog system with Tatin activated.

The [dev script](../dev) and [Jenkins job](../Jenkinsfile) activate Tatin and install the Tatin and NuGet packages in directories that persist between container runs.

## Jarvis
The web service is based on the [Jarvis](https://dyalog.github.io/Jarvis) web service framework which allows APL functions to be exposed as HTTP endpoints.

## HttpCommand
The [HttpCommand](https://dyalog.github.io/HttpCommand) package is used to interact with external HTTP APIs.

## NuGet
The [Dyalog/NuGet](https://github.com/Dyalog/nuget) package is used to facilitate easy use of NuGet packages.

## Porter2Stemmer NuGet Package
The [Porter2Stemmer](https://www.nuget.org/packages/Porter2Stemmer) NuGet package is used so that search queries can be stemmed, for example "packages" becomes "package", so that results are less dependent on exact spelling.
