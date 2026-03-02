create database if not exists ${DB_NAME};

create user if not exists '${DB_USER}'@'%' identified by '${DB_PASSWORD}';
grant all privileges on ${DB_NAME}.* to '${DB_USER}'@'%';

create user if not exists '${DB_ADMIN_USER}'@'%' identified by '${DB_ADMIN_PASSWORD}';
grant all privileges on *.* to '${DB_ADMIN_USER}'@'%' with grant option;

