#!/bin/bash

SECRET_FOLDER="srcs/secrets"
SSL_FOLDER="${SECRET_FOLDER}/ssl"
PSW_FILE="${SECRET_FOLDER}/db_password.txt"
PSW_ADMIN_FILE="${SECRET_FOLDER}/db_admin_password.txt"

set -e

echo "Setting up environment..."

# create env file if missing
if [[ ! -f srcs/.env ]]; then
    echo "Creating .env file..."
    cp srcs/.env.example srcs/.env
fi

# create secrets if missing
if [[ ! -d "${SECRET_FOLDER}" ]]; then
	mkdir -p "${SECRET_FOLDER}"
fi

if [[ ! -d "${SSL_FOLDER}" ]]; then
	mkdir -p "${SSL_FOLDER}"
fi

if [[ ! -f ${PSW_FILE} ]]; then
    echo "Enter passwrod, othewise generate"

	read -s password
	if [[ "$password" != "" ]]; then
		echo "$password" > "${PSW_FILE}"
	else
		openssl rand -base64 16 > "${PSW_FILE}"	
	fi
fi

if [[ ! -f "${PSW_ADMIN_FILE}" ]]; then
	echo "Enter admin passwrod, othewise generate"

	read -s admin_password
	if [[ "$admin_password" != "" ]]; then
		echo "$admin_password" > "${PSW_ADMIN_FILE}"
	else
		openssl rand -base64 16 > "${PSW_ADMIN_FILE}"	
	fi
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