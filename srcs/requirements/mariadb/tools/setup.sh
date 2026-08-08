#!/bin/bash

    mkdir -p /run/mysqld
    chown mysql:mysql /run/mysqld


# Check if the database is already initialized to prevent overwriting data on restart
if [ ! -d "/var/lib/mysql/$MARIADB_DATABASE" ]; then
    # Start MariaDB temporarily in the background to execute setup commands
    mariadbd --user=mysql&
    pid=$!

    # Wait until the temporary database process is fully awake
    until mysqladmin ping --silent; do
        sleep 1
    done

    MARIADB_PASSWORD=$(cat /run/secrets/db_password)
    MARIADB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

    # Execute SQL commands to configure secure users and databases
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    # Safely shut down the temporary background process	
	kill "$pid"
	wait "$pid"
	# chown mysql:mysql -R /var/lib/mysql/*
fi

echo "MariaDB: Configuration complete! Starting database..."

# Run MariaDB in the foreground as the main container process
exec mariadbd --user=mysql
