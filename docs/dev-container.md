# Developing DCMS in a Dev Container

## Why Docker?
DCMS runs in Docker so that development, testing and production all use the same environment: the same Dyalog version, the same .NET runtime, the same MariaDB.

## What the dev container adds
The VS Code dev container provides a consistent development toolbox without installing anything on your host machine beyond Docker Desktop and VS Code. The DCMS source code is mounted into the dev container, and the host Docker socket is shared in, so `docker compose` commands inside the dev container control Docker Desktop directly.

## How the pieces fit together

```
┌─────────────────────────────────────────────┐
│ Windows / macOS host                        │
│                                             │
│  Docker Desktop                             │
│  ├── Dev container (VS Code, Claude Code)   │
│  │     └── /projects/DCMS (source code)     │
│  │     └── /var/run/docker.sock (shared)    │
│  │                                          │
│  ├── web  (Dyalog APL + Jarvis HTTP server) │
│  │     └── /app  ← source code mounted      │
│  │     └── /data ← Docker volume            │
│  │                                          │
│  ├── db   (MariaDB 10.8.2)                  │
│  │     └── /var/lib/mysql ← Docker volume   │
│  │                                          │
│  └── install (one-off dependency installer) │
│        └── /app, /data ← same mounts as web │
└─────────────────────────────────────────────┘
```

The dev container runs `docker compose` commands that start the `web` and `db` containers as siblings (not nested). All three containers are managed by the same Docker Desktop instance.

## Getting started

### Prerequisites
- Docker Desktop running on the host
- VS Code with the Dev Containers extension
- The DCMS repository cloned locally

### First-time setup

1. Open the DCMS repository in the dev container.

    1. In VS Code, open the DCMS repository folder.

    1. Then, open the command palette (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>) and do "Dev Containers: Reopen in Container".

2. Create a secrets file at `secrets/secrets.json5` — see [config.md](config.md#secrets) for the format.

3. Run with the `-i` flag to install dependencies:
   ```sh
   ./dev-container -i
   ```
   This activates Tatin, installs APL and NuGet [dependencies](dependencies.md), then starts the stack.

### Day-to-day development

```sh
./dev-container
```

This starts the Dyalog web server and MariaDB. Connect to RIDE in your browser at `http://localhost:4502` to interact with the running APL session.

### What `dev-container` does

1. Discovers the host-resolvable path for the project directory (needed because the Docker daemon runs on the host, not inside the dev container)
2. Writes the `env` file with container configuration
3. Runs `docker compose up web db` (or `install` first with `-i`)

It is the dev container equivalent of the `./dev` script described in [dev.md](dev.md).

## Working outside a dev container

If you are running on Linux or WSL directly (not inside a dev container), use `./dev` instead. See [dev.md](dev.md) for the full getting-started guide.

## Named volumes

The database (`dcms_db`) and Dyalog home directory (`dcms_home`) use Docker named volumes rather than bind-mounted host directories. This means:

- Permissions are consistent between the `install` and `web` services
- You don't need to worry about file ownership mismatches between host and container users
- Data persists across container restarts

To reset the Dyalog home (e.g. to force a clean dependency install):
```sh
docker volume rm dcms_dcms_home
```

To reset the database:
```sh
docker volume rm dcms_dcms_db
```

(The `dcms_` prefix is the docker compose project name, derived from the directory name.)
