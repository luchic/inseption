#!/bin/bash

if [[ -z "$FTP_USER" ]]; then
	echo "no user setup for ftp server"
	exit 1
fi

if [[ -z "$FTP_PASSWORD_FILE" ]]; then
	echo "no secret: DB_PASSWORD_FILE"
	exit 1
fi

FTP_PASSWORD=$(cat "$FTP_PASSWORD_FILE")

if ! id "$FTP_USER" &>/dev/null; then
    echo "Creating ftp user ..."
	useradd -m -s /bin/bash "$FTP_USER"
	echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

chown root /etc/vsftpd.conf

echo "Runn ftp server ..."
exec "$@"
