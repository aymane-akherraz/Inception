#!/bin/bash

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MARIADB_PASSWORD=$(cat /run/secrets/db_password)
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql
fi

mariadbd --user=mysql &
pid=$!

until [ -S /run/mysqld/mysqld.sock ]; do
    sleep 1
done

echo "MariaDB is ready."

MYSQL="mysql -u root -p${MARIADB_ROOT_PASSWORD}"

$MYSQL -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"

$MYSQL -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"

$MYSQL -e "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

$MYSQL -e "ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

$MYSQL -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';"

$MYSQL -e "FLUSH PRIVILEGES;"

echo "MariaDB: Configuration complete."

mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

wait "$pid"

exec mariadbd --user=mysql