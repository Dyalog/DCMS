# DCMS Dev Container Setup — Prompt for Claude Code

## Context

I'm working on the DCMS project (a Video Search and Viewing Application built in Dyalog APL). The project has an existing `docker-compose.yml` that runs a Dyalog APL container and a MariaDB container, plus a `./dev` bash script that sets environment variables, optionally installs dependencies, and starts the containers.

I'm now working from inside a VS Code dev container ("Claude Code") on Windows, launched via WSL. The DCMS codebase is mounted into this dev container at `/projects/DCMS`. I have the Docker CLI and docker compose plugin installed inside this dev container, and the host Docker socket is mounted at `/var/run/docker.sock`, so `docker compose` commands here talk to Docker Desktop on the host.

## What I need

1. **Examine** the existing `./dev` script and `docker-compose.yml` in `/projects/DCMS` to understand the current setup (environment variables, services, volumes, dependencies, install stage).

2. **Create or adapt** a workflow so I can bring up the DCMS stack (Dyalog + MariaDB) from inside this dev container with a single command or script. The project uses a `.env` file for secrets and credentials — this should continue to work.

3. **Key constraints:**
   - Do NOT use docker-in-docker. The host Docker socket is already mounted; `docker compose` should just work.
   - The DCMS source code is at `/projects/DCMS` inside this container. The docker-compose services need to mount the source code correctly — paths in docker-compose may need adjusting since the compose file was originally written for a different host context (a Linux VM where the repo was in the working directory).
   - Preserve the simplicity of the original `./dev` workflow — ideally a single command to get everything running.
   - The `.env` file should remain the mechanism for secrets/credentials.

4. **Document** the setup clearly enough that it could be explained to a mixed audience: some are APL developers new to Docker/containers, others are generally technical developers who happen to use APL. The documentation should cover:
   - Why we use Docker (dev environment mirrors production)
   - What the dev container gives us (consistent tooling, editor integration, Claude Code access)
   - How to start the DCMS stack
   - How the pieces fit together (dev container → host Docker → DCMS containers)

## Important details about the architecture

- The Dyalog container runs a Jarvis HTTP server (the APL API backend)
- MariaDB is the persistent data store
- The APL code is developed using Link (source as text files in namespaces), so the source directory needs to be mounted into the Dyalog container
- There is a React frontend but it is served/embedded separately via WordPress
- The project uses SQAPL for database access, HttpCommand for HTTP client operations, Isolates for concurrent computation, and the .NET bridge for a Porter stemmer

## Please start by

Reading the `./dev` script and `docker-compose.yml` (and any `.env.example` or similar files), then propose the minimal changes needed to make this work from `/projects/DCMS` inside the dev container. Ask me questions if anything is unclear before making changes.