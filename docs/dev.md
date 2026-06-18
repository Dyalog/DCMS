# Developing DCMS

DCMS (Dyalog Content Management System) is an APL application that supplies data for the Dyalog website and video library via a publicly available API hosted on https://dcms.dyalog.com. It runs as an HTTP service powered by Dyalog APL and Jarvis, backed by MariaDB.

The entire stack runs in Docker, so development, testing and production all use the same environment.

## Getting started

### Prerequisites
- Docker Desktop (or Docker Engine on Linux)
- The DCMS repository cloned locally

### First-time setup

1. Create a secrets file at `secrets/secrets.json5` — see [config.md](config.md#secrets) for the format.

2. Run the dev script with `-i` to install [dependencies](dependencies.md) (Tatin and NuGet packages):
   ```sh
   ./dev -i
   ```
   This activates Tatin, installs all packages, then starts the stack. You only need `-i` on first run or when dependencies change.

### Day-to-day development

```sh
./dev
```

This starts the Dyalog web server and MariaDB. Connect to RIDE in your browser at `http://localhost:4502` to interact with the running APL session.

## How `dev` works

1. Writes the `env` file with container configuration (database credentials, paths, RIDE port)
2. Pulls the latest Docker images
3. If `-i` was passed, runs the `install` service to activate Tatin and install dependencies
4. Runs `docker compose up web db`

The services are defined in [docker-compose.yml](../docker-compose.yml):

| Service   | Image                       | Purpose                                    |
|-----------|-----------------------------|--------------------------------------------|
| `web`     | `dyalog/techpreview:latest` | Dyalog APL + Jarvis HTTP server            |
| `db`      | `mariadb:10.8.2`            | MariaDB database                           |
| `install` | Built from `Dockerfile`     | One-off dependency installer               |

## Configuration

The `SUSPEND` flag controls request handling behaviour from full error trapping to suspending execution for debugging. See [error-handling.md](error-handling.md) for the full scheme and [config.md](config.md) for all configuration parameters.

## Running tests

### During development

In the RIDE session:

```apl
Admin.(Tests.Run GetEnv'URL')
```

### CI-style tests locally

To run the full deployment testing scenario (install dependencies, start the stack, run tests):

```sh
./CI/run-tests-in-docker.sh
```

If you are inside the VS Code dev container, use the dev container variant instead:

```sh
./CI/run-tests-in-dev-container.sh
```

These scripts are for local testing only — the Jenkinsfile orchestrates Docker directly for CI.

## Deployment

Deployment is handled automatically by a Jenkins job configured in the [Jenkinsfile](../Jenkinsfile). Commits to the `master` branch trigger a build and deploy to production.

## VS Code dev container

If you use VS Code, there is an optional [dev container](dev-container.md) setup. The dev container provides a consistent development toolbox without installing anything on your host beyond Docker Desktop and VS Code. See [dev-container.md](dev-container.md) for details.
