#!/bin/bash

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

MARIADB_PASSWORD=$(cat /run/secrets/db_password)
MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Initialize MariaDB data directory if necessary
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."

    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB temporarily
mariadbd --user=mysql &
pid=$!

# Wait for MariaDB
until mysqladmin ping --silent; do
    sleep 1
done

echo "MariaDB is ready."

# Set root password
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"

# Create database
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e \
    "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"

# Create WordPress user
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e \
    "CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

# Make sure password is correct even if user already exists
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e \
    "ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"

# Grant access
mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e \
    "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';"

mysql -u root -p"${MARIADB_ROOT_PASSWORD}" -e \
    "FLUSH PRIVILEGES;"

echo "MariaDB: Configuration complete."

# Stop temporary server
mysqladmin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown

wait "$pid"

# Start MariaDB as the main container process
exec mariadbd --user=mysql