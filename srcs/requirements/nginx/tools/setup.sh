#!/bin/bash

export SSL_FOLDER="/etc/nginx/ssl" 

echo "Try to setup certificates ..."


if [ ! -d "$SSL_FOLDER" ]; then
  echo "Creating ssl folder ${SSL_FOLDER}"
  mkdir -p "$SSL_FOLDER"
fi

if [[ -z "$NGNIX_CRT_FILE" ]]; then
	echo "Error: no certificate for ngnix"
	exit 1
else
	cp /run/secrets/ngnix_crt "${SSL_FOLDER}/nginx.crt"
fi

if [[ -z "$NGNIX_KEY_FILE" ]]; then
	echo "Error: no key for certificate"
	exit 1
else
	cp /run/secrets/ngnix_key "${SSL_FOLDER}/nginx.key"
fi

# ssl_certificate      /etc/nginx/ssl/nginx.crt;
# ssl_certificate_key  /etc/nginx/ssl/nginx.key;

# NGNIX_CRT_FILE=/run/secrets/ngnix_crt
# NGNIX_KEY_FILE=/run/secrets/ngnix_key

# chown -R www-data:www-data /var/www/html

echo "Starting ngninix ..."

exec "$@"