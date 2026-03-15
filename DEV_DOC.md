# Inception — Developer Documentation

## 1. Prerequisites

| Requirement        | Minimum Version | Notes                                         |
|--------------------|-----------------|-----------------------------------------------|
| **Docker Engine**  | 20.10+          | Must support Compose V2 (`docker compose`)    |
| **Docker Compose** | 2.x             | Integrated into Docker CLI as a plugin        |
| **GNU Make**       | 3.81+           | Used to wrap common Docker Compose commands   |
| **OpenSSL**        | 1.1+            | Only needed if you regenerate TLS certificates|
| **Git**            | any             | To clone the repository                       |

---

## 2. Repository Structure

```
inseption/
├── DEV_DOC.md
├── Makefile
├── USER_DOC.md
├── scripts/ 				# Settuping script
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
        ├── redis/
        └── static-website/ #Service with my static web site
```

---

## 3. Setting Up the Environment from Scratch

### 3.1 Clone the Repository

```bash
git clone <repository-url> inseption
cd inseption
```

### 3.2 Create the `.env` File

Docker Compose expects an environment file at `srcs/env/.env`. Create it with the
variables referenced by the containers:

```bash
cat > srcs/env/.env << 'EOF'
# MariaDB / WordPress shared vars
DB_NAME=wordpress
DB_USER=wordpress
DB_HOST=mariadb

# MariaDB admin user (value, not secret file)
DB_ADMIN_USER=admin

# FTP user
FTP_USER=user

# Secret file paths (Docker injects these automatically)
DB_PASSWORD_FILE=/run/secrets/db_password
DB_ADMIN_PASSWORD_FILE=/run/secrets/db_admin_password
FTP_PASSWORD_FILE=/run/secrets/ftp_password

# NGINX certificate paths
NGNIX_CRT_FILE=/run/secrets/ngnix_crt
NGNIX_KEY_FILE=/run/secrets/ngnix_key

# Redis for WordPress object cache
REDIS_HOST=redis
REDIS_PORT=6379
EOF
```

### 3.3 Populate Secrets

Edit each file under `srcs/secrets/` with the desired values:

```bash
echo "YourDbPassword"      > srcs/secrets/db_password.txt
echo "YourAdminPassword"   > srcs/secrets/db_admin_password.txt
echo "YourFtpPassword"     > srcs/secrets/ftp_passwor.txt
```

### 3.4 Generate TLS Certificates (optional — already included)

If you need to regenerate the self-signed certificate:

```bash
cd srcs/secrets/ssl

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx.key \
  -out nginx.crt \
  -config openssl-certificate-generation.conf

cd ../../..
```

The OpenSSL config sets `CN = nluchini.42.fr` with Subject Alternative Names
for `localhost` and `127.0.0.1`.

### 3.5 Create the Host Data Directory

The `web-data` volume is bind-mounted from the host:

```bash
mkdir -p /home/nluchini/data/
```

> This path is hard-coded in `docker-compose.yml` under `volumes → web-data →
> device`. Change it if you are working on a different machine.

---

## 4. Building and Launching

### 4.1 Using the Makefile

The Makefile in the project root wraps Docker Compose commands and already
targets `srcs/docker-compose.yml` using `-f`.

| Command       | Action                                                           |
|---------------|------------------------------------------------------------------|
| `make up`     | Start all containers (`docker compose -f srcs/docker-compose.yml up`) |
| `make down`   | Stop and remove containers                                       |
| `make clean`  | Stop/remove containers and remove images (`--rmi all`)          |
| `make fclean` | `clean` + remove volumes (`-v`)                                 |
| `make re`     | Full rebuild: `clean` then `up`                                  |

### 4.2 Manual Docker Compose Commands

From the `srcs/` directory:

```bash
# Build without starting
docker compose build

# Start in detached mode
docker compose up -d --build

# View running containers
docker compose ps

# Follow combined logs
docker compose logs -f
```

---

## 5. Container Management

### 5.1 Service Details

| Service     | Container Name | Base Image   | Entrypoint            | Exposed Ports        |
|-------------|----------------|--------------|-----------------------|----------------------|
| nginx       | `ngnix`        | debian:12    | `/setup.sh`           | 8443 → 443 (HTTPS)  |
| wordpress   | `wordpress`    | debian:12    | `/setup.sh`           | 9000 (internal)      |
| mariadb     | `mariadb`      | debian:12    | `/setup.sh`           | 3306 (internal)      |
| redis       | `redis`        | debian:12    | redis-server          | 6379 (internal)      |
| ftp-service | `ftp`          | debian:12    | `/setup.sh`           | 4321 → 21, 60000-60005 |
| adminer     | `adminer`      | debian:12    | php-fpm8.2            | 9000 (internal)      |
| my-syte     | `my-syte`      | debian:12    | caddy                 | 80 (internal)        |

### 5.2 Executing Commands Inside Containers

```bash
# Open a shell inside a container
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it ngnix bash

# Run a one-off MySQL query
docker exec mariadb mysql -u wordpress -p<password> -e "SHOW TABLES;" wordpress

# Check PHP-FPM processes
docker exec wordpress ps aux | grep php-fpm

# Test NGINX config
docker exec ngnix nginx -t
```

### 5.3 Restarting a Single Service

```bash
docker compose restart nginx
docker compose restart wordpress
docker compose restart mariadb
```

### 5.4 Rebuilding a Single Service

```bash
docker compose build wordpress
docker compose up -d wordpress
```

---

## 6. Networking

All services are connected to a single Docker bridge network named `inseption`.

```
┌──────────────────────────────────────────────────┐
│  Network: inseption (bridge)                     │
│                                                  │
│   ngnix ──────────▶ wordpress ──────▶ mariadb    │
│   :443  FastCGI:9000           MySQL:3306        │
└──────────────────────────────────────────────────┘
        ▲
        │ host port 8443
        │
    Browser
```

- **NGINX → WordPress**: FastCGI via `wordpress:9000` (configured in
  `defualt.conf`).
- **WordPress → MariaDB**: MySQL TCP via `mariadb:3306` (configured in
  `wp-config.php` with `DB_HOST=mariadb`).
- **WordPress → Redis**: TCP via `redis:6379` (configured with `REDIS_HOST` and
  `REDIS_PORT`).
- Only NGINX's port 443 is published to the host as **8443**.

---

## 7. Data Storage and Persistence

### 7.1 Volumes

| Volume Name  | Type         | Container Mount Point | Host Path                  | Content                          |
|--------------|--------------|-----------------------|----------------------------|----------------------------------|
| `web-data`   | Bind mount   | `/var/www/html`       | `/home/nluchini/data/`     | WordPress files (PHP, uploads)   |
| `data-base`  | Named volume | `/var/lib/mysql`      | Managed by Docker          | MariaDB database files           |
| `redis-data` | Named volume | `/data`               | Managed by Docker          | Redis persistence data           |

### 7.2 Configuration Files (bind-mounted)

| Host Path                                              | Container Path                                     |
|--------------------------------------------------------|----------------------------------------------------|
| `srcs/requirements/nginx/conf/defualt.conf`            | `/etc/nginx/conf.d/defualt.conf`                   |
| `srcs/requirements/wordpress/conf/www.conf`            | `/etc/php/8.2/fpm/pool.d/www.conf`                 |
| `srcs/requirements/mariadb/conf/server.cnf`            | `/etc/mysql/mariadb.conf.d/50-server.cnf`          |

### 7.3 What Happens on `make clean`

Running `make clean` (i.e. `docker compose down --rmi all`) removes:

- Containers, networks, and built images.
- Volumes are preserved (`data-base`, `redis-data`, and bind-mounted `web-data`).

To wipe all persistent data, use `make fclean` and then remove bind-mounted
host files if needed:

```bash
make fclean
sudo rm -rf /home/nluchini/data/*
```

---

## 8. Entrypoint Scripts — How They Work

Core services use a `setup.sh` entrypoint script before handing control to the
main process via `exec "$@"`.

### NGINX (`requirements/nginx/tools/setup.sh`)

1. Creates `/etc/nginx/ssl/` if it doesn't exist.
2. Copies the TLS certificate and key from Docker secrets
   (`/run/secrets/ngnix_crt`, `/run/secrets/ngnix_key`) into the SSL folder.
3. Executes `nginx -g "daemon off;"`.

### MariaDB (`requirements/mariadb/tools/setup.sh`)

1. Reads database and admin passwords from Docker secrets, and admin username
  from environment variable `DB_ADMIN_USER`.
2. Creates the `/var/run/mysqld/` socket directory.
3. Starts `mysqld` temporarily in the background.
4. Waits until MariaDB accepts connections (`mysqladmin ping`).
5. Creates the `wordpress` database, the `wordpress` user, and the admin user
   with appropriate privileges.
6. Shuts down the temporary server and then `exec`s the final `mysqld`.

### WordPress (`requirements/wordpress/tools/setup.sh`)

1. Reads the database password from Docker secrets.
2. Waits for MariaDB to become available (retry loop with `mysql` client).
3. If WordPress is not already installed, downloads and extracts the latest
   release.
4. Generates `wp-config.php` from the sample file, injecting database
   credentials.
5. Sets ownership to `www-data`.
6. Executes `php-fpm8.2 -F` (foreground mode).

---

## 9. Useful Development Commands

```bash
# Full rebuild from scratch
make re

# Check container resource usage
docker stats

# Inspect a volume
docker volume ls | grep -E "data-base|redis-data"

# Prune unused Docker resources (images, containers, networks)
docker system prune -a

# View the full Compose config (with interpolated env vars)
docker compose config

# Tail only error logs from WordPress
docker compose logs wordpress 2>&1 | grep -i error
```
