# Developer Documentation

## 1. Project Structure

A typical project structure is:

```text
.
├── Makefile
├── docker-compose.yml
├── .env
├── secrets/
├── srcs/
│   ├── requirements/
│   │   ├── mariadb/
│   │   ├── nginx/
│   │   ├── wordpress/
│   │   └── bonus/
│   │       ├── redis/
│   │       ├── vsftp/
│   │       ├── adminer/
│   │       ├── onlogs/
│   │       └── website/
│   └── ...
├── USER_DOC.md
├── DEV_DOC.md
└── README.md
```

The exact paths can differ if the repository uses a slightly different organization.

## 2. Prerequisites

Install the following:

- Linux environment.
- Docker Engine.
- Docker Compose v2.
- GNU Make.
- Git.

Verify the installation:

```bash
docker --version
docker compose version
make --version
git --version
```

The Docker daemon must be running.

## 3. Configuration

### Environment variables

Create the project's `.env` file from the expected configuration.

Environment variables should contain configuration that is not considered secret, for example:

- domain name;
- WordPress site title;
- database name;
- database username;
- WordPress administrator username;
- service configuration.

Do not commit passwords or other sensitive values to `.env`.

### Docker secrets

Create the required secret files according to the Compose configuration.

For example, if the Compose file declares database password secrets, the corresponding files must exist before starting the stack.

Secret files should contain only the secret value and should be excluded from Git.

A typical structure is:

```text
secrets/
├── credentials
├── db_password
├── db_root_password
└── ...
```

Use the actual secret names declared by `docker-compose.yml`.

## 4. Build and launch

From the repository root:

```bash
make
```

or use Docker Compose directly:

```bash
docker compose build
docker compose up -d
```

To rebuild after changing a Dockerfile:

```bash
docker compose build --no-cache <service>
docker compose up -d <service>
```

To rebuild the complete stack:

```bash
docker compose build --no-cache
docker compose up -d
```

## 5. Makefile commands

The Makefile provides shortcuts for common operations.

Typical commands are:

```bash
make
make up
make down
make clean
make fclean
make re
```

Check the repository's Makefile for the exact targets implemented by this project.

Do not assume that a target deletes persistent data. Read its commands before using destructive cleanup targets.

## 6. Docker Compose commands

### List services

```bash
docker compose config --services
```

### Check status

```bash
docker compose ps
```

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Rebuild

```bash
docker compose build
```

### Restart one service

```bash
docker compose restart <service>
```

### Follow logs

```bash
docker compose logs -f <service>
```

### Execute a command inside a container

```bash
docker compose exec <service> <command>
```

For example:

```bash
docker compose exec wordpress bash
```

If the image does not contain Bash, use:

```bash
docker compose exec wordpress sh
```

## 7. Container management

List all containers:

```bash
docker ps -a
```

Inspect a container:

```bash
docker inspect <container>
```

Inspect environment variables:

```bash
docker exec <container> printenv
```

Open a shell:

```bash
docker exec -it <container> bash
```

or:

```bash
docker exec -it <container> sh
```

## 8. Networking

The services communicate through the project's Docker bridge network.

Check networks:

```bash
docker network ls
```

Inspect the Compose network:

```bash
docker network inspect <network>
```

Internal service communication should normally use Compose service names rather than host IP addresses.

Examples:

```text
mariadb:3306
wordpress:9000
onlogs:8798
```

Only services that must be reachable from outside Docker should have host ports published.

## 9. Persistent data

Persistent data is separated from the container's temporary filesystem.

Important data includes:

### MariaDB

The MariaDB data directory contains the WordPress database and must persist across container recreation.

Typical container path:

```text
/var/lib/mysql
```

### WordPress

The WordPress volume contains the application files, themes, plugins, and uploads.

Typical container path:

```text
/var/www/html
```

### Inspect volumes

```bash
docker volume ls
```

Inspect one:

```bash
docker volume inspect <volume>
```

If the project uses host-backed volume configuration, the host-side location is defined in the Compose volume configuration. Review `docker-compose.yml` rather than assuming the path.

## 10. Volumes and data lifecycle

`docker compose down` removes the containers and the Compose network, but named volumes normally remain.

To remove volumes explicitly:

```bash
docker compose down -v
```

This is potentially destructive because it can remove persistent application data.

Before using `-v`, make sure that the data is backed up or intentionally disposable.

## 11. Nginx

Nginx is the public entry point.

Its responsibilities include:

- accepting HTTPS connections;
- serving the static website where configured;
- forwarding WordPress requests;
- forwarding Adminer requests;
- forwarding OnLogs requests;
- handling TLS certificates.

After changing Nginx configuration, rebuild/restart the Nginx service as appropriate.

Useful commands:

```bash
docker compose logs nginx
docker compose exec nginx nginx -t
```

`nginx -t` should report a successful configuration test before relying on the new configuration.

## 12. WordPress and PHP-FPM

WordPress runs behind Nginx and communicates with PHP-FPM.

The WordPress container is responsible for:

- installing/downloading WordPress;
- creating `wp-config.php`;
- connecting to MariaDB;
- installing the WordPress site;
- configuring WordPress-related services such as Redis when enabled.

WP-CLI commands can be executed inside the WordPress container when WP-CLI is installed:

```bash
docker compose exec wordpress wp --allow-root core is-installed
```

## 13. MariaDB

MariaDB stores the WordPress database.

Check its logs:

```bash
docker compose logs mariadb
```

Connect from inside the MariaDB container using the configured credentials when required.

The database should not be exposed publicly just for internal service communication. WordPress and Adminer can access it through the Docker network.

## 14. Redis

Redis is used as a WordPress object cache.

Check Redis:

```bash
docker compose logs redis
```

If `redis-cli` is installed:

```bash
docker compose exec redis redis-cli ping
```

A healthy Redis instance should respond:

```text
PONG
```

## 15. FTP / vsftp

The FTP service provides access to the persistent WordPress files.

Check:

```bash
docker compose logs vsftp
```

If passive FTP is configured, make sure the required passive port range is correctly exposed and configured on both Docker and the FTP server.

## 16. Adminer

Adminer provides a web interface for database administration.

Its Nginx route is:

```text
/adminer/
```

Internally, Adminer communicates with MariaDB through the Docker network.

When connecting, use:

```text
Server: mariadb
Port: 3306
```

and the appropriate database credentials.

## 17. OnLogs

OnLogs is an additional service used to inspect Docker logs through a web interface.

The service listens internally on its configured port, for example:

```text
8798
```

Nginx exposes it under:

```text
/onlogs/
```

The Nginx proxy configuration and the application's prefix configuration must agree. If the application expects `/onlogs/`, Nginx must forward requests without accidentally producing an incompatible path.

Check:

```bash
docker compose logs onlogs
```

and:

```bash
docker compose exec onlogs printenv
```

## 18. Debugging workflow

When a service fails, use the following order:

1. Check container status:

```bash
docker compose ps
```

2. Check the service logs:

```bash
docker compose logs <service>
```

3. Inspect the container:

```bash
docker inspect <container>
```

4. Check network connectivity:

```bash
docker network inspect <network>
```

5. Enter the container if necessary:

```bash
docker compose exec <service> sh
```

6. Verify configuration files and environment variables.

7. Rebuild the service if its Dockerfile or build context changed.

## 19. Cleaning and rebuilding

To remove stopped containers and rebuild:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

For a complete cleanup, first understand which resources contain persistent data.

Commands such as:

```bash
docker compose down -v
docker system prune
```

can delete resources and should not be used casually.

## 20. Git and secrets

Never commit:

- passwords;
- private keys;
- TLS private keys;
- secret files;
- generated database data;
- unnecessary Docker build artifacts.

Use `.gitignore` for files that must remain local.

Before pushing:

```bash
git status
git diff --cached
```

Check carefully for credentials before committing.

## 21. Development workflow

For a service change:

```bash
docker compose build <service>
docker compose up -d <service>
docker compose logs -f <service>
```

For a configuration-only change that is mounted into a running container, restart the affected service if necessary.

For Dockerfile changes, rebuild the image.

For persistent data changes, verify the relevant volume before deleting or recreating containers.

## 22. Persistence model

The important distinction is:

```text
Container filesystem
    -> temporary

Docker volume / host-backed persistent storage
    -> survives container recreation
```

The database and WordPress files must therefore live in persistent storage.

This allows the application containers to be recreated without losing the website or database data.
