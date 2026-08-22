#!/bin/bash

SECRET_FILE="/run/secrets/credentials"
FTP_USER=$(grep "^FTP_USER=" "$SECRET_FILE" | cut -d'=' -f2)
FTP_PASSWORD=$(grep "^FTP_PASSWORD=" "$SECRET_FILE" | cut -d'=' -f2)

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -m "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

usermod -g www-data "$FTP_USER"
chmod -R g+rwX /var/www/html

mkdir -p /var/run/vsftpd/empty

exec vsftpd /etc/vsftpd.conf
