#!/bin/bash

mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &

until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

if [ ! -d "/var/lib/mysql/mysql" ]; then

    echo "Initializing database..."
    mysql -u root < /conf/init.sql
fi

mysqladmin -u root shutdown

exec "$@"