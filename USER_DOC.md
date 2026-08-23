# User Documentation

## 1. Overview

This project provides a Docker-based web infrastructure containing:

- **Nginx** — secure HTTPS entry point and reverse proxy.
- **WordPress** — the main website.
- **MariaDB** — database used by WordPress.
- **Redis** — object cache for WordPress.
- **FTP / vsftp** — file transfer access to persistent WordPress files.
- **Adminer** — web interface for MariaDB administration.
- **OnLogs** — web interface for viewing container logs.
- **Static website/service** — additional non-PHP web service.

The services run in separate containers and communicate through the Docker network.

## 2. Starting the project

Open a terminal in the repository root.

Build and start the infrastructure:

```bash
make
```

If the images have already been built:

```bash
make up
```

The equivalent Docker Compose commands are:

```bash
docker compose build
docker compose up -d
```

Check the status:

```bash
docker compose ps
```

All required services should eventually show a running state.

## 3. Stopping the project

To stop the containers:

```bash
make down
```

or:

```bash
docker compose down
```

Stopping the containers does not normally delete persistent database or WordPress data.

## 4. Accessing the services

### WordPress

Open:

```text
https://<DOMAIN_NAME>
```

The domain is configured in the project's environment and Nginx configuration.

### WordPress administration

The WordPress administration panel is normally available at:

```text
https://<DOMAIN_NAME>/wp-admin/
```

Use the WordPress administrator credentials created during the initial setup.

### Adminer

Open:

```text
https://<DOMAIN_NAME>/adminer/
```

Use the MariaDB database host, database name, database user, and password configured for WordPress.

The database host from inside the Docker network is normally:

```text
mariadb
```

The default MariaDB port inside the network is:

```text
3306
```

### OnLogs

Open:

```text
https://<DOMAIN_NAME>/onlogs/
```

This service can be used to inspect logs from the Docker services.

### FTP / vsftp

Use an FTP client configured with the FTP credentials defined by the project.

The FTP service points to the persistent WordPress data, allowing administrators to manage website files.

## 5. Credentials

Credentials must not be hard-coded into source files or committed to Git.

Depending on the configuration, credentials are stored in:

- Docker secret files under the project's secrets directory.
- Non-sensitive configuration in `.env`.
- WordPress administrator configuration created during initialization.

Check the project's `.gitignore` before committing changes and make sure secret files are excluded.

Never publish database passwords, WordPress administrator passwords, or other private credentials in the repository.

## 6. Checking that services work

### Check container status

```bash
docker compose ps
```

### Check all logs

```bash
docker compose logs
```

### Follow logs for one service

```bash
docker compose logs -f nginx
docker compose logs -f wordpress
docker compose logs -f mariadb
```

### Check running containers

```bash
docker ps
```

### Check Docker networks

```bash
docker network ls
```

### Check volumes

```bash
docker volume ls
```

### Check a specific container

```bash
docker inspect <container_name>
```

## 7. Basic troubleshooting

### Website does not open

Check:

```bash
docker compose ps
docker compose logs nginx
docker compose logs wordpress
```

Verify that the domain resolves to the machine and that Nginx is listening on the HTTPS port.

### WordPress cannot connect to the database

Check MariaDB:

```bash
docker compose logs mariadb
```

Then check the WordPress configuration and confirm that the database host is the Compose service name:

```text
mariadb
```

### Nginx returns 502 Bad Gateway

Check whether the upstream service is running:

```bash
docker compose ps
docker compose logs wordpress
docker compose logs nginx
```

A 502 generally means Nginx cannot reach the configured upstream.

### Adminer does not work

Check:

```bash
docker compose logs adminer
docker compose logs nginx
```

Confirm that Nginx forwards `/adminer/` to the Adminer PHP-FPM service correctly.

### OnLogs returns an error

Check:

```bash
docker compose logs onlogs
docker compose logs nginx
```

Confirm that the OnLogs container is listening on its internal port and that the Nginx `/onlogs/` proxy configuration matches the application's expected URL prefix.

## 8. Data safety

The important persistent data is stored outside the temporary writable layer of individual containers.

The main persistent data includes:

- MariaDB database files.
- WordPress files/uploads.
- Other service-specific persistent data if configured.

Do not delete the Docker volumes or host-backed data directories unless you intentionally want to remove the stored data.
