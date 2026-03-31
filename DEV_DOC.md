# Inception — Developer Documentation

## 1. Prerequisites

| Requirement        | Minimum Version | Notes                                      |
|--------------------|-----------------|--------------------------------------------|
| **Docker Engine**  | 20.10+          | Must support Compose V2                    |
| **Docker Compose** | 2.x             | Available as `docker compose`              |
| **GNU Make**       | 3.81+           | Used for project shortcuts                 |
| **OpenSSL**        | 1.1+            | Used by `scripts/setup-env.sh`             |
| **Git**            | any             | To clone the repository                    |

---

## 2. Repository Structure

```text
inseption/
├── DEV_DOC.md
├── Makefile
├── USER_DOC.md
├── scripts/                      # Setup helpers
│   ├── openssl-certificate-generation.conf
│   └── setup-env.sh
└── srcs/
    ├── docker-compose.yml
    ├── env/
    ├── secrets/
    ├── requirements/
    │   ├── mariadb/
    │   ├── nginx/
    │   └── wordpress/
    └── bonus/
        ├── adminer/
        ├── ftp/
        ├── grafana/
        ├── loki/
        ├── promtail/
        ├── redis/
        └── static-website/
```

---

## 3. Setting Up the Environment from Scratch

### 3.1 Clone the repository

```bash
git clone <repository-url> inseption
cd inseption
```

### 3.2 Quick setup script

Recommended:

```bash
make setup
```

Equivalent:

```bash
./scripts/setup-env.sh
```

The script:

- checks that `srcs/docker-compose.yml` exists
- checks that `scripts/openssl-certificate-generation.conf` exists
- creates missing directories under `srcs/env/` and `srcs/secrets/`
- asks for the host login used for the `web-data` bind mount
- creates `/home/<login>/data/`
- rewrites `volumes.web-data.driver_opts.device` in `srcs/docker-compose.yml`
- asks for DB, admin, and FTP values
- creates secret files only if they do not already exist
- creates `srcs/env/.env` only if it does not already exist
- generates TLS files only if they do not already exist

### 3.3 Manual `.env` file

Compose expects:

```text
srcs/env/.env
```

Current values written by `scripts/setup-env.sh`:

```bash
NGNIX_CRT_FILE=/run/secrets/ngnix_crt
NGNIX_KEY_FILE=/run/secrets/ngnix_key

DB_NAME=wordpress

FTP_USER=user
FTP_PASSWORD_FILE=/run/secrets/ftp_password

DB_USER=wordpress
DB_PASSWORD_FILE=/run/secrets/db_password

DB_ADMIN_USER=admin
DB_ADMIN_PASSWORD_FILE=/run/secrets/db_admin_password

DB_HOST=mariadb

REDIS_HOST=redis
REDIS_PORT=6379
```

Note: the variable names use `NGNIX`, matching the current repo spelling.

### 3.4 Manual secrets

The current repo expects these files:

```bash
echo "YourDbPassword"    > srcs/secrets/db_password.txt
echo "YourAdminPassword" > srcs/secrets/db_admin_password.txt
echo "YourFtpPassword"   > srcs/secrets/ftp_passwor.txt
```

Note: `ftp_passwor.txt` is the current filename used by the Compose file and
setup script.

### 3.5 TLS certificates

Certificates are stored in:

```text
srcs/secrets/ssl/
```

The setup script generates them with:

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout srcs/secrets/ssl/nginx.key \
  -out srcs/secrets/ssl/nginx.crt \
  -config scripts/openssl-certificate-generation.conf
```

Current certificate config defaults:

- `FQDN = example.42.fr`
- SANs include `localhost` and `127.0.0.1`

If you want a different hostname in the certificate, edit
`scripts/openssl-certificate-generation.conf` before generating it.

### 3.6 Host data directory

The `web-data` volume is a bind mount:

```bash
mkdir -p /home/<your-login>/data/
```

The exact path is stored in:
[srcs/docker-compose.yml](/home/nluchini/core/projects/inseption/srcs/docker-compose.yml)

---

## 4. Building and Launching

### 4.1 Using the Makefile

The Makefile wraps Compose commands with `-f srcs/docker-compose.yml`.

| Command       | Action |
|---------------|--------|
| `make up`     | `docker compose -f srcs/docker-compose.yml up` |
| `make down`   | Stop and remove containers |
| `make clean`  | `down --rmi all` |
| `make fclean` | `down -v --rmi all` |
| `make re`     | `make clean` then `make up` |
| `make setup`  | Run `scripts/setup-env.sh` |

### 4.2 Manual Compose commands

From the project root:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker compose -f srcs/docker-compose.yml config
```

From inside `srcs/`:

```bash
docker compose build
docker compose up -d --build
docker compose ps
docker compose logs -f
docker compose config
```

---

## 5. Container Management

### 5.1 Service details

| Service     | Container Name | Base Image | Entrypoint / Command | Ports |
|-------------|----------------|------------|----------------------|-------|
| `nginx`     | `ngnix`        | `debian:12` | `/setup.sh` then `nginx -g "daemon off;"` | `8443:443` |
| `wordpress` | `wordpress`    | `debian:12` | `/conf/setup.sh` then `php-fpm8.2 -F` | internal `9000` |
| `mariadb`   | `mariadb`      | `debian:12` | `/setup.sh` then `mysqld --user=root` | internal `3306` |
| `redis`     | `redis`        | `debian:12` | `redis-server /etc/redis/redis.conf` | internal `6379` |
| `ftp-service` | `ftp`        | `debian:12` | `/setup.sh` | `4321:21`, `60000-60005:60000-60005` |
| `adminer`   | `adminer`      | `debian:12` | `php-fpm8.2 -F` | internal `9000` |
| `my-syte`   | `my-syte`      | `debian:12` | `caddy run --config /etc/caddy/Caddyfile --adapter caddyfile` | internal `80` |
| `loki`      | `loki`         | custom build | image command | internal only |
| `promtail`  | `promtail`     | custom build | image command | internal only |
| `grafana`   | `grafana`      | custom build | image command | internal only |

### 5.2 Running commands in containers

```bash
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it ngnix bash

docker exec mariadb mysql -u wordpress -p'<password>' -e "SHOW TABLES;" wordpress
docker exec wordpress ps aux | grep php-fpm
docker exec ngnix nginx -t
```

### 5.3 Restarting a service

From the project root:

```bash
docker compose -f srcs/docker-compose.yml restart nginx
docker compose -f srcs/docker-compose.yml restart wordpress
docker compose -f srcs/docker-compose.yml restart mariadb
```

### 5.4 Rebuilding a service

```bash
docker compose -f srcs/docker-compose.yml build wordpress
docker compose -f srcs/docker-compose.yml up -d wordpress
```

---

## 6. Networking

All services join the Compose network keyed as `inception`.

Because the Compose file sets:

```yaml
name: test
```

Docker runtime objects are created under that project name, so the actual
runtime network name will be based on `test`, for example `test_inception`.

Main traffic paths:

- `ngnix -> wordpress:9000` via FastCGI
- `wordpress -> mariadb:3306` via MySQL
- `wordpress -> redis:6379` via TCP
- `promtail -> loki`
- `grafana -> loki`

Only NGINX and FTP publish host ports in the current Compose file.

---

## 7. Data Storage and Persistence

### 7.1 Volumes

| Volume Name    | Type         | Mount Point        | Host Path / Storage        | Purpose |
|----------------|--------------|--------------------|----------------------------|---------|
| `web-data`     | Bind mount   | `/var/www/html`    | `/home/<login>/data/`      | Shared web files |
| `data-base`    | Named volume | `/var/lib/mysql`   | Docker-managed             | MariaDB data |
| `redis-data`   | Named volume | `/data`            | Docker-managed             | Redis data |
| `loki-data`    | Named volume | `/loki`            | Docker-managed             | Loki data |
| `grafana-data` | Named volume | `/var/lib/grafana` | Docker-managed             | Grafana data |

### 7.2 Bind-mounted config files

| Host Path | Container Path |
|-----------|----------------|
| `srcs/requirements/nginx/conf/defualt.conf` | `/etc/nginx/conf.d/defualt.conf` |
| `srcs/requirements/wordpress/conf/www.conf` | `/etc/php/8.2/fpm/pool.d/www.conf` |
| `srcs/requirements/mariadb/conf/server.cnf` | `/etc/mysql/mariadb.conf.d/50-server.cnf` |
| `srcs/bonus/ftp/conf/vsftpd.conf` | `/etc/vsftpd.conf` |
| `srcs/bonus/static-website/conf/Caddyfile` | `/etc/caddy/Caddyfile` |
| `srcs/bonus/grafana/grafana.ini` | `/etc/grafana/grafana.ini` |
| `srcs/bonus/redis/conf/redis.conf` | `/etc/redis/redis.conf` |

### 7.3 What `make clean` and `make fclean` remove

`make clean` removes:

- containers
- networks
- images

It keeps:

- named volumes
- bind-mounted host files such as `/home/<login>/data/`

`make fclean` also removes Compose volumes, but it still does not delete files
inside the host bind mount.

To wipe the host bind-mounted files too:

```bash
make fclean
rm -rf /home/<your-login>/data/*
```

---

## 8. Entrypoint Scripts

### NGINX

File:
[srcs/requirements/nginx/tools/setup.sh](/home/nluchini/core/projects/inseption/srcs/requirements/nginx/tools/setup.sh)

Behavior:

1. Creates `/etc/nginx/ssl/` if needed.
2. Copies secrets from `/run/secrets/ngnix_crt` and `/run/secrets/ngnix_key`.
3. Starts NGINX in foreground mode.

### MariaDB

File:
[srcs/requirements/mariadb/tools/setup.sh](/home/nluchini/core/projects/inseption/srcs/requirements/mariadb/tools/setup.sh)

Behavior:

1. Reads DB passwords from Docker secrets.
2. Creates `/var/run/mysqld/`.
3. Starts `mysqld` temporarily.
4. Waits for `mysqladmin ping`.
5. Creates the configured database and users if missing.
6. Stops the temporary server.
7. Executes the final `mysqld`.

### WordPress

File:
[srcs/requirements/wordpress/tools/setup.sh](/home/nluchini/core/projects/inseption/srcs/requirements/wordpress/tools/setup.sh)

Behavior:

1. Reads the DB password from Docker secrets.
2. Waits until MariaDB answers queries.
3. Downloads WordPress if it is not present in `/var/www/html`.
4. Generates `wp-config.php` from the provided sample.
5. Injects DB and Redis settings.
6. Sets ownership to `www-data`.
7. Starts PHP-FPM.

Note: this script does not create the WordPress admin account. That still
happens through the WordPress web installer.

### FTP

File:
[srcs/bonus/ftp/tools/setup.sh](/home/nluchini/core/projects/inseption/srcs/bonus/ftp/tools/setup.sh)

Behavior:

1. Reads `FTP_USER` and `FTP_PASSWORD_FILE`.
2. Creates the FTP user if it does not exist.
3. Starts the FTP server process.

---

## 9. Useful Development Commands

From the project root:

```bash
make re
docker stats
docker volume ls | grep -E "data-base|redis-data|loki-data|grafana-data"
docker compose -f srcs/docker-compose.yml config
docker compose -f srcs/docker-compose.yml logs wordpress 2>&1 | grep -i error
```
