# Developing DCMS

DCMS (Dyalog Content Management System) is an APL application that serves the Dyalog website and video library through a public API at https://dcms.dyalog.com. It runs as an HTTP service written in Dyalog APL with Jarvis, and stores its data in MariaDB.

The entire stack runs in Docker, so development, testing and production all use the same environment.

## Getting Started

### Prerequisites
- Docker Desktop (or Docker Engine on Linux)
- The DCMS repository cloned locally

### First-Time Setup

1. Create a secrets file at `secrets/secrets.json5` — see [config.md](config.md#secrets) for the format.

2. Run the dev script with `-i` to install [dependencies](dependencies.md) (Tatin and NuGet packages):
   ```sh
   ./dev -i
   ```
   This activates Tatin, installs all packages, then starts the stack. You only need `-i` on first run or when dependencies change.

### Day-to-Day Development

```sh
./dev
```

This starts the Dyalog web server and MariaDB. Connect to RIDE in your browser at `http://localhost:4502` to interact with the running APL session.

## How `dev` Works

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

## Running Tests

### During Development

In the RIDE session:

```apl
Admin.(Tests.Run GetEnv'URL')
```

### CI-Style Tests Locally

To run the full deployment testing scenario (install dependencies, start the stack, run tests):

```sh
./CI/run-tests-in-docker.sh
```

This script is for local testing only. The Jenkinsfile orchestrates Docker directly for CI.

## Deployment

Deployment is handled automatically by a Jenkins job configured in the [Jenkinsfile](../Jenkinsfile). Commits to the `master` branch trigger a build and deploy to production.
