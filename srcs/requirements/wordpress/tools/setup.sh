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

cd /var/www/html/wordpress

echo "Try to Setup wp-config..."

if [ ! -f wp-config.php ]; then
	echo "Setuping wp-config..."

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$DB_NAME/" wp-config.php
    sed -i "s/username_here/$DB_USER/" wp-config.php
    sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
    sed -i "s/localhost/$DB_HOST/" wp-config.php
fi

echo "Finished to setup wp-config..."

# chmod -R 766 /var/www/html
chown -R www-data:www-data /var/www/html

mv /conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

exec "$@"