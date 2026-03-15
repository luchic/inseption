# Inception — User Documentation

## 1. Overview

Inception is a self-hosted web infrastructure stack built with **Docker**. It provides
the following services:

| Service       | Role                                                                 |
|---------------|----------------------------------------------------------------------|
| **NGINX**     | Reverse-proxy and TLS termination (HTTPS on port **8443**)          |
| **WordPress** | Content-management system served via PHP-FPM on port 9000           |
| **MariaDB**   | Relational database that stores all WordPress data                  |

All three services run as isolated Docker containers on a private bridge network
called `inseption`. Only the NGINX container exposes a port to the host.

```
Browser ──HTTPS:8443──▶ NGINX ──FastCGI:9000──▶ WordPress (PHP-FPM)
                                                       │
                                                       ▼
                                                   MariaDB :3306
```

---

## 2. Starting and Stopping the Project

All commands are run from the **project root** directory
(`/home/nluchini/core/projects/inseption`).

### Optional: automatic environment setup

Before first start, you can generate `.env`, secrets, and TLS files with:

```bash
make setup
```

This runs `scripts/setup-env.sh`.

The script also asks your login, creates `/home/<login>/data/`, and updates
`srcs/docker-compose.yml` for `volumes -> web-data -> device`.

If you do not use the script, you must set this path manually in
`srcs/docker-compose.yml` to match your host.

### Start (build & run)

```bash
make up
```

This builds every Docker image (if needed) and starts all containers in the
foreground. Add `-d` manually if you want to run in detached mode:


### Stop

```bash
make down
```

Stops and removes the running containers, but **preserves** volumes (your data
is safe).

### Full Clean (stop + delete volumes)

```bash
make clean
```

Removes containers/networks/images, but keeps volumes.

To also remove volumes:

```bash
make fclean
```

> ⚠️ **Warning** — `make fclean` removes Docker volumes, meaning your database
> data will be **permanently deleted**.

### Rebuild from Scratch

```bash
make re
```

Equivalent to `make clean` followed by `make up`.

---

## 3. Accessing the Website

### WordPress Front-End

Open your browser and navigate to:

```
https://localhost:8443
```

> Because the certificate is self-signed your browser will show a security
> warning. Click **Advanced → Proceed** (or **Accept the Risk**) to continue.

If DNS is configured (e.g. in `/etc/hosts`), you can also use:

```
https://nluchini.42.fr:8443
```

### WordPress Administration Panel

```
https://localhost:8443/wp-admin
```

Log in with the WordPress admin credentials you configured during the initial
WordPress setup wizard (or that were pre-configured in `wp-config.php`).

---

## 4. Credentials

### Where Credentials Are Stored

All sensitive values are stored as **Docker secrets** inside the `srcs/secrets/`
directory:

| File                              | Purpose                                          |
|-----------------------------------|--------------------------------------------------|
| `secrets/db_password.txt`         | Password for the WordPress database user         |
| `secrets/db_admin_password.txt`   | Password of the MariaDB admin account            |
| `secrets/ftp_passwor.txt`         | Password for the FTP user                        |
| `secrets/ssl/nginx.crt`          | TLS certificate used by NGINX                    |
| `secrets/ssl/nginx.key`          | TLS private key used by NGINX                    |

### Default Database Accounts

| Account          | Username      | Password file                  | Scope                  |
|------------------|---------------|--------------------------------|------------------------|
| WordPress DB user| `wordpress`   | `secrets/db_password.txt`      | `wordpress` database   |
| MariaDB admin    | *(see file)*  | `secrets/db_admin_password.txt`| All databases          |

---

## 5. Checking That Services Are Running

### List Running Containers

```bash
docker compose ps
```

### View Logs

```bash
# All services
docker compose logs

# A single service (e.g. nginx)
docker compose logs nginx

# Follow logs in real time
docker compose logs -f
```

### Quick Health Checks

| Check                        | Command                                                                                      |
|------------------------------|----------------------------------------------------------------------------------------------|
| NGINX responds on 8443       | `curl -k https://localhost:8443`                                                             |
| WordPress PHP is processing  | `curl -k https://localhost:8443/wp-login.php` (should return the login page HTML)            |
| MariaDB is accepting connections | `docker exec mariadb mysqladmin ping`                                                    |
| Database exists              | `docker exec mariadb mysql -u wordpress -pHello12345 -e "SHOW DATABASES;"`                   |

> Replace the password above with the actual value from `secrets/db_password.txt`
> if you changed it.

### Common Issues

| Symptom                                | Likely Cause                                  | Fix                                            |
|----------------------------------------|-----------------------------------------------|-------------------------------------------------|
| Browser says "connection refused"      | Containers are not running                    | Run `make up`                                  |
| "502 Bad Gateway" from NGINX           | WordPress/PHP-FPM has not finished starting   | Wait a few seconds and refresh                 |
| "Access denied" in MariaDB logs        | Password mismatch between secret and wp-config| Sync `db_password.txt` with `wp-config.php`    |
| Certificate warning in browser         | Self-signed certificate                       | Expected — accept and proceed                  |
