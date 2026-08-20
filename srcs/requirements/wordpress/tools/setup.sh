#!/bin/bash

mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

MARIADB_PASSWORD=$(cat /run/secrets/db_password)
SECRET_FILE="/run/secrets/credentials"
WP_ADMIN=$(grep "^WP_ADMIN=" "$SECRET_FILE" | cut -d'=' -f2)
WP_ADMIN_PASSWORD=$(grep "^WP_ADMIN_PASSWORD=" "$SECRET_FILE" | cut -d'=' -f2)
WP_ADMIN_EMAIL=$(grep "^WP_ADMIN_EMAIL=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER=$(grep "^WP_USER=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER_PASSWORD=$(grep "^WP_USER_PASSWORD=" "$SECRET_FILE" | cut -d'=' -f2)
WP_USER_EMAIL=$(grep "^WP_USER_EMAIL=" "$SECRET_FILE" | cut -d'=' -f2)

until mysqladmin ping -h "$MARIADB_HOST" -u"$MARIADB_USER" -p"$MARIADB_PASSWORD" --silent >/dev/null 2>&1; do
    sleep 2
done

su -s /bin/bash www-data -c "
cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download

    wp config create \
        --dbname=\"$MARIADB_DATABASE\" \
        --dbuser=\"$MARIADB_USER\" \
        --dbpass=\"$MARIADB_PASSWORD\" \
        --dbhost=\"$MARIADB_HOST\"
fi

if ! wp core is-installed --url=\"$DOMAIN_NAME\"; then
    wp core install \
        --url=\"$DOMAIN_NAME\" \
        --title=\"$WP_TITLE\" \
        --admin_user=\"$WP_ADMIN\" \
        --admin_password=\"$WP_ADMIN_PASSWORD\" \
        --admin_email=\"$WP_ADMIN_EMAIL\"

fi

if ! wp plugin is-installed redis-cache; then
    wp config set WP_REDIS_HOST redis
    wp config set WP_REDIS_PORT 6379 --raw

    wp plugin install redis-cache --activate
    wp redis enable
fi

if ! wp user get \"$WP_USER\" >/dev/null 2>&1; then
    wp user create \
        \"$WP_USER\" \
        \"$WP_USER_EMAIL\" \
        --user_pass=\"$WP_USER_PASSWORD\"
fi
"

mkdir -p /run/php

exec php-fpm8.2 -F
