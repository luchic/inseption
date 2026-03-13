#!/bin/bash

# mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;"

if [[ -z "$DB_PASSWORD_FILE" ]]; then
	echo "no secret: DB_PASSWORD_FILE"
	exit 1
else
	DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
fi

until mysql -h"$DB_HOST" -P 3306 -u"$DB_USER" -p"$DB_PASSWORD" -D"$DB_NAME" -e "SELECT 1;" > /var/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done


if [[ ! -f /var/www/html/wp-config-sample.php ]]; then
	echo "Try to download wordpress files ..."

	mkdir -p /var/www/html
	
	
	if ! wget https://wordpress.org/latest.tar.gz -q -P /tmp; then
		echo "Couldn't download wordpress files"
		exit 1
	fi

	tar -xzf /tmp/latest.tar.gz -C /tmp/
	cp -a /tmp/wordpress/. /var/www/html
	rm -fr /tmp/wordpress /tmp/latest.tar.gz

fi

cd /var/www/html

if [ ! -f wp-config.php ]; then
	echo "Try to Setup wp-config..."

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$DB_NAME/" wp-config.php
    sed -i "s/username_here/$DB_USER/" wp-config.php
    sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
    sed -i "s/localhost/$DB_HOST/" wp-config.php

	echo "define('WP_REDIS_HOST', 'redis');" >> wp-config.php
	echo "define('WP_REDIS_PORT', 6379);" >> wp-config.php
fi

if [ ! -f /var/www/html/.initialized ]; then
    chown -R www-data:www-data /var/www/html
    touch /var/www/html/.initialized
fi

echo "Finished to setup wordpress"

exec "$@"