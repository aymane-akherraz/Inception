#!/bin/bash

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MARIADB_PASSWORD=$(cat /run/secrets/db_password)
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

chown -R mysql:mysql /var/lib/mysql

# Initialize MariaDB data directory if necessary
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mariadb-install-db --user=mysql
fi

# Start MariaDB temporarily
mariadbd --user=mysql &
pid=$!

# Wait for MariaDB
until mysqladmin ping --silent; do
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

# Stop temporary server
mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

wait "$pid"

# Start MariaDB as the main container process
exec mariadbd --user=mysql