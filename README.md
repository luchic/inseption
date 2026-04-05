*This project has been created as part of the 42 curriculum by nluchini.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum focused on building a small self-hosted infrastructure with Docker. The goal is to create and orchestrate multiple isolated services, each running in its own container, and connect them through a dedicated Docker network while keeping persistent data outside of ephemeral container filesystems.

This repository provides a Docker Compose stack centered on a secure WordPress installation:

- `nginx` serves HTTPS traffic and acts as the public entry point.
- `wordpress` runs PHP-FPM and hosts the application.
- `mariadb` stores WordPress data.

The project also includes several bonus services:

- `redis` for WordPress object caching
- `ftp-service` for file transfer access
- `adminer` for database administration
- `my-syte` for a static website served by Caddy
- `loki`, `promtail`, and `grafana` for logs and observability

More detailed operational documentation is available in [USER_DOC.md](/home/nluchini/core/projects/inseption/USER_DOC.md) and [DEV_DOC.md](/home/nluchini/core/projects/inseption/DEV_DOC.md).

## Project Design

### Docker usage in this project

The stack is defined in [srcs/docker-compose.yml](/home/nluchini/core/projects/inseption/srcs/docker-compose.yml). Each service has its own Dockerfile and configuration under `srcs/requirements/` or `srcs/bonus/`. The containers communicate through a custom bridge network named `inception`, and persistent data is stored with Docker volumes or a host bind mount for web files.

Main sources included in the project:

- Dockerfiles for each service in `srcs/requirements/` and `srcs/bonus/`
- service configuration files such as NGINX, PHP-FPM, MariaDB, Redis, Grafana, Loki, Promtail, FTP, and Caddy configs
- bootstrap scripts in `scripts/` and service `tools/setup.sh` files
- additional user and developer documentation in `USER_DOC.md` and `DEV_DOC.md`

### Main design choices

- A custom image is built for each service instead of relying only on preconfigured images.
- HTTPS is terminated by NGINX with a self-signed certificate generated during setup.
- WordPress, MariaDB, and Redis are split into separate containers to keep concerns isolated.
- Sensitive values are passed through Docker secrets when possible.
- Persistent application data is stored outside containers so the stack can be rebuilt without losing content.
- Bonus services extend the mandatory stack without exposing unnecessary ports publicly.

### Virtual Machines vs Docker

- Virtual machines emulate full operating systems and require more resources.
- Docker containers share the host kernel, start faster, and are lighter to rebuild.
- For this project, Docker is a better fit because the objective is service isolation, reproducibility, and orchestration rather than full OS virtualization.

### Secrets vs Environment Variables

- Environment variables are convenient for non-sensitive configuration such as hostnames, ports, and usernames.
- Secrets are more appropriate for confidential data such as database passwords, FTP passwords, and TLS keys.
- In this project, `.env` stores non-secret configuration, while sensitive values are stored under `srcs/secrets/` and mounted as Docker secrets.

### Docker Network vs Host Network

- Host networking removes network isolation and makes services share the host network stack directly.
- A Docker bridge network keeps containers isolated while still allowing service-to-service communication by container name.
- This project uses a bridge network so internal services like MariaDB, Redis, Adminer, Loki, and Grafana stay private unless a port is explicitly published.

### Docker Volumes vs Bind Mounts

- Named Docker volumes are managed by Docker and are ideal for durable service data such as MariaDB, Redis, Loki, and Grafana storage.
- Bind mounts map an exact host path into a container and are useful when the host must directly access files.
- This project uses both: named volumes for service persistence and a bind mount for `web-data` so the WordPress files are shared between services and remain accessible on the host.

## Architecture

### Mandatory part

- `nginx` exposes `443:443`
- `wordpress` serves PHP-FPM internally on port `9000`
- `mariadb` serves the database internally on port `3306`

Traffic flow:

`Client -> NGINX -> WordPress -> MariaDB`

### Bonus part

- `wordpress -> redis`
- `ftp-service -> web-data`
- `adminer -> mariadb`
- `promtail -> loki`
- `grafana -> loki`
- `my-syte` serves an extra static site internally

## Instructions

### Prerequisites

- Docker Engine with Compose V2 support
- GNU Make
- OpenSSL

### Setup

From the repository root, run:

```bash
make setup
```

This script:

- creates `srcs/env/.env` if it does not already exist
- creates the secret files under `srcs/secrets/`
- generates a self-signed TLS certificate under `srcs/secrets/ssl/`
- creates `/home/<login>/data/`
- updates the `web-data` bind mount path in the Compose file

If you prefer to configure everything manually, review [scripts/setup-env.sh](/home/nluchini/core/projects/inseption/scripts/setup-env.sh), [USER_DOC.md](/home/nluchini/core/projects/inseption/USER_DOC.md), and [DEV_DOC.md](/home/nluchini/core/projects/inseption/DEV_DOC.md).

### Build and run

```bash
make up
```

This starts the full stack using:

```bash
docker compose -f srcs/docker-compose.yml up
```

### Stop the project

```bash
make down
```

### Remove containers and images

```bash
make clean
```

### Remove containers, images, and volumes

```bash
make fclean
```

### Rebuild from scratch

```bash
make re
```

## Usage

After startup, the main entry point is:

```text
https://localhost:443
```

Other useful endpoints or access points:

- WordPress admin: `https://localhost:443/wp-admin`
- FTP: `localhost:4321`
- FTP passive ports: `60000-60005`

Because the certificate is self-signed, your browser will show a security warning on first access.

## Repository Structure

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── scripts/
└── srcs/
    ├── docker-compose.yml
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

## Resources

Classic references related to the project topic:

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- Redis documentation: https://redis.io/docs/
- Grafana documentation: https://grafana.com/docs/
- Loki documentation: https://grafana.com/oss/loki/
- Caddy documentation: https://caddyserver.com/docs/
- OpenSSL documentation: https://www.openssl.org/docs/

### AI usage

AI was used as a support tool for documentation and project explanation tasks. In particular, it was used to:

- help draft and refine the repository README
- summarize the project structure and service interactions
- improve wording, clarity, and organization of the written documentation

AI was not used as a substitute for understanding the project architecture; the actual implementation, configuration choices, and validation still depend on the project files and manual review.
