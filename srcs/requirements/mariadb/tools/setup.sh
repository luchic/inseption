#!/bin/bash


if [[ -z "$DB_PASSWORD_FILE" ]]; then
	echo "no secret: DB_PASSWORD_FILE"
	exit 1
else
	DB_PASSWORD=$(cat "$DB_PASSWORD_FILE")
fi

if [[ -z "$DB_ADMIN_PASSWORD_FILE" ]]; then
	echo "no secret: DB_ADMIN_PASSWORD_FILE"
	exit 1
else
	DB_ADMIN_PASSWORD=$(cat "$DB_ADMIN_PASSWORD_FILE")
fi

if [[ -z "$DB_ADMIN_USER_FILE" ]]; then
	echo "no secret: DB_ADMIN_USER_FILE"
	exit 1
else
	DB_ADMIN_USER=$(cat "$DB_ADMIN_USER_FILE")
fi

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

mysqld --user=root &

until mysqladmin ping --silent; do
    echo "Waiting for MariaDB to start..."
    sleep 1
done

echo "Try to Initializing database..."

    mysql -u root <<EOF
create database if not exists ${DB_NAME};

create user if not exists '${DB_USER}'@'%' identified by '${DB_PASSWORD}';
grant all privileges on ${DB_NAME}.* to '${DB_USER}'@'%';

create user if not exists '${DB_ADMIN_USER}'@'%' identified by '${DB_ADMIN_PASSWORD}';
grant all privileges on *.* to '${DB_ADMIN_USER}'@'%' with grant option;

EOF

echo "Is finished..."
mysqladmin -u root shutdown

exec "$@"


# create database if not exists ${DB_NAME};

# create user if not exists ${DB_USER}@'%' identified by '${DB_PASSWORD}';
# grant all privileges on '${DB_NAME}'.* to '${DB_USER}'@'%';

# create user if not exists ${DB_ADMIN_USER}@'%' identified by '${DB_ADMIN_PASSWORD}';
# grant all privileges on *.* to '${DB_ADMIN_USER}'@'%' with grant option;

