#!/bin/bash

set -e

echo "Setting up environment..."

# create env file if missing
if [[ ! -f srcs/.env ]]; then
    echo "Creating .env file..."
    cp srcs/.env.example srcs/.env
fi

# create secrets if missing
if [[ ! -d srcs/secrets ]]; then
	mkdir -p srcs/secrets
fi

if [[ ! -f srcs/secrets/db_password.txt ]]; then
    echo "Generating DB password..."
    openssl rand -base64 16 > srcs/secrets/db_password.txt
fi

if [[ ! -f srcs/secrets/db_admin_password.txt ]]; then
    echo "Generating admin password..."
    openssl rand -base64 16 > srcs/secrets/db_admin_password.txt
fi

# create certificates if missing
if [[ ! -f srcs/secrets/ssl/nginx.crt ]]; then
    echo "Generating TLS certificate..."

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout srcs/secrets/ssl/nginx.key \
        -out srcs/secrets/ssl/nginx.crt \
        -subj "/CN=localhost"
fi

echo "Environment ready."