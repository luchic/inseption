#!/bin/bash
# version 0.1

SECRET_FOLDER="srcs/secrets"
PSW_FILE="${SECRET_FOLDER}/db_password.txt"
ADMIN_NAME_FILE="${SECRET_FOLDER}/db_admin_user.txt"
PSW_ADMIN_FILE="${SECRET_FOLDER}/db_admin_password.txt"

SSL_FOLDER="${SECRET_FOLDER}/ssl"
CERTIFICATE_KEY_FILE="$SSL_FOLDER/nginx.key"
CERTIFICATE_CRT_FILE="$SSL_FOLDER/nginx.crt"
SSL_CONFIG="openssl-certificate-generation.conf"

ENV_FOLDER="srcs/env"
ENV_FILE="$ENV_FOLDER/.env"

generate_secret_password()
{
	local file=$1
	local message=$2

	if [[ ! -f "$file" ]]; then
		read -s -p "$message" password
		echo
		if [[ -n "$password" ]]; then
			echo "$password" > "$file"
		else
			openssl rand -base64 16 > "$file"	
		fi
	
	fi
}

# maybe I can use set -e for exit on error, but I'm not sure.
#set -e

echo "Setting up environment..."

if [[ ! -d "$SECRET_FOLDER" ]]; then
	mkdir -p "$SECRET_FOLDER"
fi

if [[ ! -d "$SSL_FOLDER" ]]; then
	mkdir -p "$SSL_FOLDER"
fi


read -p "Enter database name (default: wordpress): " db_name
db_name=${db_name:-wordpress}

read -p "Enter database user (default: wordpress): " db_user
db_user=${db_user:-wordpress}

generate_secret_password "$PSW_FILE" \
			s"Enter password (leave empty to generate): "

read -p "Enter admin user (default: admin): " db_admin
db_admin=${db_admin:-admin}

generate_secret_password "$PSW_ADMIN_FILE" \
			"Enter admin password (leave empty to generate): "


if [[ ! -f "$ENV_FILE" ]]; then
	cat > "$ENV_FILE" <<EOF
NGNIX_CRT_FILE=/run/secrets/ngnix_crt
NGNIX_KEY_FILE=/run/secrets/ngnix_key

DB_NAME=$db_name

DB_USER=$db_user
DB_PASSWORD_FILE=/run/secrets/db_password

DB_ADMIN_USER=$db_admin
DB_ADMIN_PASSWORD_FILE=/run/secrets/db_admin_password

DB_HOST=mariadb
EOF

fi

if [[ ! -f "$CERTIFICATE_CRT_FILE" ]]; then
    echo "Generating TLS certificate..."

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$CERTIFICATE_KEY_FILE" \
        -out "$CERTIFICATE_CRT_FILE" \
        -config "$SSL_CONFIG"

	echo ""
fi

echo "Environment ready."