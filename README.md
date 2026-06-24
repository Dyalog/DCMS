# Dyalog Content Management System

DCMS is an APL application that supplies data for the upcoming Dyalog website and video library via a publicly available API. It runs as an HTTP service powered by Dyalog APL and [Jarvis](https://github.com/Dyalog/Jarvis), backed by MariaDB, with the entire stack running in Docker. Documentation is version-locked to `APLSource/Version.aplf`.

- [Live service](https://dcms.dyalog.com)
- [API Reference](docs/api.md)

## Documentation

- [dev.md](docs/dev.md) — getting started, running tests, deployment
- [config.md](docs/config.md) — configuration parameters and debug flags
- [database.md](docs/database.md) — ODBC drivers and host-native MariaDB setup
- [dependencies.md](docs/dependencies.md) — Tatin and NuGet packages

## YouTube API

While the system does not itself collect or store any user data, this system uses YouTube API Services to access videos and their descriptions — by using this system, users agree to the [YouTube Terms of Service](https://www.youtube.com/t/terms).
