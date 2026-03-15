#!/bin/bash
# version 0.1

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SRCS_FOLDER="$PROJECT_ROOT/srcs"

SECRET_FOLDER="$SRCS_FOLDER/secrets"
PSW_FILE="${SECRET_FOLDER}/db_password.txt"
PSW_ADMIN_FILE="${SECRET_FOLDER}/db_admin_password.txt"
FTP_PSW_FILE="${SECRET_FOLDER}/ftp_passwor.txt"

SSL_FOLDER="${SECRET_FOLDER}/ssl"
CERTIFICATE_KEY_FILE="$SSL_FOLDER/nginx.key"
CERTIFICATE_CRT_FILE="$SSL_FOLDER/nginx.crt"
SSL_CONFIG="$SCRIPT_DIR/openssl-certificate-generation.conf"

ENV_FOLDER="$SRCS_FOLDER/env"
ENV_FILE="$ENV_FOLDER/.env"

generate_secret_password()
{
	local file=$1
	local message=$2

	if [[ ! -f "$file" ]]; then
		read -r -s -p "$message" password
		echo
		if [[ -n "$password" ]]; then
			echo "$password" > "$file"
		else
			openssl rand -base64 16 > "$file"	
		fi
	
	fi
}

get_web_data_dir_from_compose()
{
	if [[ ! -f "$COMPOSE_FILE" ]]; then
		echo "$HOME/data"
		return
	fi

	awk '
		/^volumes:/ { in_volumes = 1 }
		in_volumes && /^  web-data:/ { in_web_data = 1; next }
		in_web_data && /^  [a-zA-Z0-9_-]+:/ && $1 != "web-data:" { in_web_data = 0 }
		in_web_data && $1 == "device:" { print $2; exit }
	' "$COMPOSE_FILE"
}

generate_wordpress_salts()
{
	if [[ ! -f "$WP_CONFIG_SAMPLE" ]]; then
		return
	fi

	if ! grep -q "put your unique phrase here" "$WP_CONFIG_SAMPLE"; then
		return
	fi

	echo "Generating WordPress salts..."

	local tmp_file
	tmp_file=$(mktemp)

	local -a salts=()
	local i
	for i in {1..8}; do
		salts+=("$(openssl rand -hex 32)")
	done

	local salt_index=0
	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$line" == *"put your unique phrase here"* && $salt_index -lt 8 ]]; then
			line="${line/put your unique phrase here/${salts[$salt_index]}}"
			((salt_index += 1))
		fi
		printf '%s\n' "$line" >> "$tmp_file"
	done < "$WP_CONFIG_SAMPLE"

	mv "$tmp_file" "$WP_CONFIG_SAMPLE"
}

# maybe I can use set -e for exit on error, but I'm not sure.
#set -e

echo "Setting up environment..."


if [[ ! -f "$SSL_CONFIG" ]]; then
	echo "Missing SSL config file: $SSL_CONFIG"
	exit 1
fi

if [[ ! -d "$SECRET_FOLDER" ]]; then
	mkdir -p "$SECRET_FOLDER"
fi

if [[ ! -d "$SSL_FOLDER" ]]; then
	mkdir -p "$SSL_FOLDER"
fi

if [[ ! -d "$ENV_FOLDER" ]]; then
	mkdir -p "$ENV_FOLDER"
fi


read -r -p "Enter database name (default: wordpress): " db_name
db_name=${db_name:-wordpress}

read -r -p "Enter database user (default: wordpress): " db_user
db_user=${db_user:-wordpress}

generate_secret_password "$PSW_FILE" \
			"Enter password (leave empty to generate): "

read -r -p "Enter admin user (default: admin): " db_admin
db_admin=${db_admin:-admin}

generate_secret_password "$PSW_ADMIN_FILE" \
			"Enter admin password (leave empty to generate): "

read -r -p "Enter FTP user (default: user): " ftp_user
ftp_user=${ftp_user:-user}

generate_secret_password "$FTP_PSW_FILE" \
			"Enter FTP password (leave empty to generate): "


if [[ ! -f "$ENV_FILE" ]]; then
	cat > "$ENV_FILE" <<EOF
NGNIX_CRT_FILE=/run/secrets/ngnix_crt
NGNIX_KEY_FILE=/run/secrets/ngnix_key

DB_NAME=$db_name

FTP_USER=$ftp_user
FTP_PASSWORD_FILE=/run/secrets/ftp_password

DB_USER=$db_user
DB_PASSWORD_FILE=/run/secrets/db_password

DB_ADMIN_USER=$db_admin
DB_ADMIN_PASSWORD_FILE=/run/secrets/db_admin_password

DB_HOST=mariadb

REDIS_HOST=redis
REDIS_PORT=6379
EOF

fi

if [[ ! -f "$CERTIFICATE_CRT_FILE" || ! -f "$CERTIFICATE_KEY_FILE" ]]; then
    echo "Generating TLS certificate..."

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$CERTIFICATE_KEY_FILE" \
        -out "$CERTIFICATE_CRT_FILE" \
        -config "$SSL_CONFIG"

	echo ""
fi

echo "Environment ready."