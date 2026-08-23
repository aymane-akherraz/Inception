*This project has been created as part of the 42 curriculum by aakherra.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to build a small web infrastructure using Docker and Docker Compose, while understanding how containers, networks, volumes, secrets, reverse proxies, databases, and application services work together.

The stack provides a WordPress website behind an Nginx reverse proxy with HTTPS. MariaDB is used as the database, Redis provides WordPress object caching, and several bonus services are included: FTP access to the WordPress data, Adminer for database administration, a static website/service, and OnLogs for viewing container logs.

The infrastructure is intentionally built from Debian base images rather than relying on ready-made application Docker images. Each service has its own Dockerfile and runs in its own container.

### Services

| Service             | Role                                    |
| ------------------- | --------------------------------------- |
| Nginx               | HTTPS reverse proxy and entry point     |
| WordPress + PHP-FPM | Main website                            |
| MariaDB             | WordPress database                      |
| Redis               | WordPress object cache                  |
| FTP / vsftp         | File transfer access to WordPress files |
| Adminer             | Web-based database administration       |
| OnLogs              | Web-based Docker log viewer             |
| Static website      | Additional non-PHP website/service      |

### Architecture

The main request flow is:

`Browser -> Nginx -> WordPress/PHP-FPM -> MariaDB`

Redis is used by WordPress for object caching. Adminer communicates with MariaDB, FTP accesses the persistent WordPress files, and OnLogs provides access to Docker logs.

## Project Design Choices

### Docker

Docker was chosen because the project requires isolated services that can be built, configured, started, stopped, and connected independently. Docker Compose defines the infrastructure and its dependencies in one place.

Each service has its own container and Dockerfile. Services communicate through a private Docker bridge network instead of exposing every internal port to the host.

### Sources included in the project

The project contains configuration and source files needed to build the infrastructure, including:

- Dockerfiles for the individual services.
- Docker Compose configuration.
- Nginx configuration and TLS setup.
- WordPress initialization scripts.
- MariaDB initialization/configuration.
- Redis configuration.
- FTP configuration.
- Adminer and OnLogs build/setup files.
- Website files for the static service.
- Makefile for common project commands.
- Docker secrets for sensitive credentials.

The project does not depend on Docker Hub application images. Debian is used as the base distribution, and the required services are installed/configured inside their own images.

### Virtual Machines vs Docker

| Virtual Machines                        | Docker                      |
| --------------------------------------- | --------------------------- |
| Virtualizes a complete operating system | Shares the host kernel      |
| Usually heavier                         | Lightweight                 |
| Each VM needs its own OS                | Containers use a base image |
| Slower startup                          | Fast startup                |
| Stronger isolation at OS/VM level       | Process/container isolation |
| More resource usage                     | Lower resource usage        |

For this project, Docker is more appropriate because the goal is to run several lightweight services independently without requiring a complete virtual machine for every service.

### Secrets vs Environment Variables

Environment variables are convenient for non-sensitive configuration such as:

- domain names;
- service names;
- database names;
- ports;
- WordPress titles.

Secrets are preferable for sensitive information such as database passwords. Docker secrets mount the value as a file inside the container, which avoids putting the actual password directly into the Compose environment configuration.

For this project, sensitive database credentials are handled through Docker secrets where possible, while ordinary configuration is provided through environment variables.

### Docker Network vs Host Network

With a Docker bridge network, containers can communicate using service names such as:

`mariadb:3306`

Only ports that must be accessed from outside the Docker network need to be published on the host.

Host networking removes much of this network isolation and makes the container use the host network directly. It can be useful for specific performance or networking requirements, but it is less appropriate for this project because the services should remain isolated.

### Docker Volumes vs Bind Mounts

Docker named volumes are managed by Docker and are well suited for persistent application data.

Bind mounts directly map a host path into a container. They are useful when the project explicitly needs data to live at a known host location.

This project uses persistent storage for important data such as the MariaDB database and WordPress files. The infrastructure can use Docker-managed volumes or host-backed volume configuration depending on the project setup. Persistent data must not be stored only inside a container filesystem because it would disappear when the container is removed.

## Instructions

### Prerequisites

Install:

- Docker Engine
- Docker Compose v2
- GNU Make
- Git

The project is intended to run on a Linux environment.

### Configuration

Before starting the project:

1. Configure the domain name used by the Nginx server.
2. Create the required `.env` configuration file.
3. Create the required Docker secret files.
4. Make sure the persistent data directories exist and have the correct permissions.
5. Review the Docker Compose and Nginx configuration if the local domain or paths differ.

### Build and start

From the repository root:

```bash
make
```

If the images are already built:

```bash
make up
```

To build explicitly with Docker Compose:

```bash
docker compose build
docker compose up -d
```

Check the containers:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
docker compose logs -f nginx
```

### Stop

```bash
make down
```

or:

```bash
docker compose down
```

To remove containers and their associated anonymous resources:

```bash
docker compose down --remove-orphans
```

Persistent named volumes should only be removed when their data is no longer needed.

## Access

The main website is available through the configured domain over HTTPS:

```text
https://<DOMAIN_NAME>
```

Adminer is available through the configured Nginx path:

```text
https://<DOMAIN_NAME>/adminer/
```

The static website is available through:

```text
https://<DOMAIN_NAME>/website/
```

OnLogs is available through:

```text
https://<DOMAIN_NAME>/onlogs/
```

The exact domain is defined by the project configuration.

## Resources

Useful references:

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Docker volumes: https://docs.docker.com/engine/storage/volumes/
- Docker networking: https://docs.docker.com/engine/network/
- Docker secrets: https://docs.docker.com/engine/swarm/secrets/
- Nginx documentation: https://nginx.org/en/docs/
- WordPress documentation: https://developer.wordpress.org/
- WP-CLI documentation: https://developer.wordpress.org/cli/commands/
- MariaDB documentation: https://mariadb.com/docs/
- Redis documentation: https://redis.io/docs/
- vsftpd documentation: https://security.appspot.com/vsftpd.html
- Adminer: https://www.adminer.org/

### AI usage

AI tools were used as a learning and development aid during the project.

They were used for tasks such as:

- understanding Docker and Docker Compose concepts;
- improving shell scripts and Dockerfiles;
- reviewing documentation structure and README requirements.

## Additional Documentation

- [User documentation](USER_DOC.md)
- [Developer documentation](DEV_DOC.md)
