#!/bin/bash

mkdir -p /var/www/html

cd /var/www/html

MYSQL_PASSWORD=$(cat /run/secrets/db_password.txt)
SECRET_FILE="/run/secrets/credentials.txt"
WP_ADMIN=$(grep "^WP_ADMIN=" "$SECRET_FILE" | cut -d'=' -f2)
WP_ADMIN_PASSWORD=$(grep "^WP_ADMIN_PASSWORD=" "$SECRET_FILE" | cut -d'=' -f2)
WP_ADMIN_EMAIL=$(grep "^WP_ADMIN_EMAIL=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER=$(grep "^WP_USER=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER_PASSWORD=$(grep "^WP_USER_PASSWORD=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER_EMAIL=$(grep "^WP_USER_EMAIL=" "$SECRET_FILE" | cut -d'=' -f2)


# Wait for MariaDB
until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent
do
    sleep 2
done

if [ ! -f wp-config.php ]; then

    wp core download --allow-root

    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$MYSQL_HOST \
        --allow-root

    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --allow-root

    wp user create \
        $WP_USER \
        $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
fi

mkdir -p /run/php

exec php-fpm8.2 -F
