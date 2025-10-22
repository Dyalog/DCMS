# Packages
The system depends on some Tatin and NuGet packages. These can be updated using an installed Dyalog system with Tatin activated. Since Tatin is not activated by default in the current version of Dyalog, the packages cannot be updated using the Dyalog Docker container.

Instead, we use the [rikedyp/dyalogci](#) image to install Tatin and NuGet dependencies in production.

## Jarvis
The web service is based on the [Jarvis](https://dyalog.github.io/Jarvis) web service framework which allows APL functions to be exposed as HTTP endpoints.

## HttpCommand
The [HttpCommand](https://dyalog.github.io/HttpCommand) package is used to interact with external HTTP APIs.

## NuGet
The [Dyalog/NuGet](https://github.com/Dyalog/nuget) package is used to facilitate easy use of NuGet packages.

## Porter2Stemmer NuGet Package
The [Porter2Stemmer](https://www.nuget.org/packages/Porter2Stemmer) NuGet package is used so that search queries can be stemmed, for example "packages" becomes "package", so that results are less dependent on exact spelling.
