# Inception — User Documentation

## 1. Overview

This project is a self-hosted Docker stack built around WordPress.

Core services:

| Service       | Role                                                        |
|---------------|-------------------------------------------------------------|
| **NGINX**     | Reverse proxy and TLS termination on host port **8443**     |
| **WordPress** | PHP-FPM application server for the WordPress site           |
| **MariaDB**   | Database used by WordPress                                  |

Bonus services currently enabled in the setup:

| Service        | Role                                                |
|----------------|-----------------------------------------------------|
| **Redis**      | Object cache backend for WordPress                  |
| **FTP**        | FTP access to the shared web files                  |
| **Adminer**    | Database administration UI inside the Docker network|
| **Static site**| Caddy-based static website container                |
| **Loki**       | Log aggregation backend                             |
| **Promtail**   | Log shipper for container logs                      |
| **Grafana**    | Metrics and log visualization                       |

Only the following ports are published to the host by default:

| Service | Host Port | Container Port |
|---------|-----------|----------------|
| NGINX   | 8443      | 443            |
| FTP     | 4321      | 21             |
| FTP     | 60000-60005 | 60000-60005  |

The containers are attached to the Compose bridge network keyed as `inception`.
With the current Compose project name (`name: test`), Docker will create
runtime network names based on that project, for example `test_inception`.

---

## 2. Starting and Stopping the Project

Run commands from the project root:
`/home/nluchini/core/projects/inseption`

### Optional: automatic environment setup

Before the first start, you can generate `.env`, secrets, and TLS files with:

```bash
make setup
```

This runs `scripts/setup-env.sh`.

The script:

- asks for your login and updates the `web-data` bind mount path
- creates `/home/<login>/data/`
- creates missing files in `srcs/env/` and `srcs/secrets/`
- generates passwords only when the secret files do not already exist
- generates TLS files only when they do not already exist

If you do not use the script, you must set the `web-data` bind-mount path
manually in `srcs/docker-compose.yml`.

### Start

```bash
make up
```

This runs `docker compose -f srcs/docker-compose.yml up`, which builds images if
needed and starts the stack in the foreground.

### Stop

```bash
make down
```

This stops and removes the running containers while preserving volumes.

### Clean containers and images

```bash
make clean
```

This runs `docker compose -f srcs/docker-compose.yml down --rmi all`.
Containers, networks, and images are removed, but volumes are kept.

### Remove volumes too

```bash
make fclean
```

This also removes Docker volumes created by Compose.

`web-data` is a host bind mount, so files under `/home/<login>/data/` are not
deleted by `make fclean`.

### Rebuild from scratch

```bash
make re
```

Equivalent to `make clean` followed by `make up`.

---

## 3. Accessing the Services

### WordPress front-end

Open:

```text
https://localhost:8443
```

If you configure local DNS or `/etc/hosts`, you can also use the hostname
present in your certificate.

### WordPress admin panel

```text
https://localhost:8443/wp-admin
```

The database connection is configured automatically by the container setup, but
the WordPress administrator account is created through the WordPress web
installer on first launch.

### FTP

Connect to:

```text
Host: localhost
Port: 4321
Passive ports: 60000-60005
Username: value of FTP_USER in srcs/env/.env
Password: value stored in srcs/secrets/ftp_passwor.txt
```

### Browser certificate warning

The TLS certificate is self-signed, so your browser will show a warning. Accept
it to continue.

---

## 4. Credentials and Configuration Files

### Secret files

Sensitive values are stored under `srcs/secrets/`:

| File                                | Purpose                                |
|-------------------------------------|----------------------------------------|
| `srcs/secrets/db_password.txt`      | WordPress database user password       |
| `srcs/secrets/db_admin_password.txt`| MariaDB admin password                 |
| `srcs/secrets/ftp_passwor.txt`      | FTP user password                      |
| `srcs/secrets/ssl/nginx.crt`        | TLS certificate for NGINX              |
| `srcs/secrets/ssl/nginx.key`        | TLS private key for NGINX              |

Note: `ftp_passwor.txt` is the current filename used by the repo.

### Environment file

Non-secret settings are stored in:

```text
srcs/env/.env
```

Important values include:

- `DB_NAME`
- `DB_USER`
- `DB_ADMIN_USER`
- `FTP_USER`
- `DB_HOST`
- `REDIS_HOST`
- `REDIS_PORT`

### Default accounts

| Account            | Username source          | Password source                        |
|--------------------|--------------------------|----------------------------------------|
| WordPress DB user  | `DB_USER` in `.env`      | `srcs/secrets/db_password.txt`         |
| MariaDB admin user | `DB_ADMIN_USER` in `.env`| `srcs/secrets/db_admin_password.txt`   |
| FTP user           | `FTP_USER` in `.env`     | `srcs/secrets/ftp_passwor.txt`         |

---

## 5. Checking That Services Are Running

From the project root, use:

```bash
docker compose -f srcs/docker-compose.yml ps
```

### View logs

```bash
docker compose -f srcs/docker-compose.yml logs
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs -f
```

### Quick health checks

| Check                    | Command |
|--------------------------|---------|
| NGINX responds on 8443   | `curl -k https://localhost:8443` |
| WordPress login page     | `curl -k https://localhost:8443/wp-login.php` |
| MariaDB accepts requests | `docker exec mariadb mysqladmin ping` |
| Compose services status  | `docker compose -f srcs/docker-compose.yml ps` |

### Common issues

| Symptom                           | Likely cause                                  | Fix |
|-----------------------------------|-----------------------------------------------|-----|
| `docker compose` cannot find file | Command run from root without `-f srcs/docker-compose.yml` | Use the Makefile or add `-f srcs/docker-compose.yml` |
| Browser says connection refused   | Containers are not running                    | Run `make up` |
| NGINX returns an upstream error   | WordPress or PHP-FPM is still starting        | Wait a few seconds and refresh |
| WordPress cannot connect to DB    | Secret and `.env` values do not match service setup | Re-run `make setup` or verify `srcs/env/.env` and `srcs/secrets/` |
| Certificate warning in browser    | Self-signed certificate                       | Expected behavior |
