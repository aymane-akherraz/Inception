#!/bin/bash

# Check if the database is already initialized to prevent overwriting data on restart
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then


        # Start MariaDB temporarily in the background to execute setup commands
    mariadbd &
    pid=$!

    # Wait until the temporary database process is fully awake
    until mysqladmin ping --silent; do
        sleep 1
    done

    # Execute SQL commands to configure secure users and databases
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    # Safely shut down the temporary background process	
	kill "$pid"
	wait "$pid"
fi

echo "MariaDB: Configuration complete! Starting database..."

# Run MariaDB in the foreground as the main container process
exec mariadbd
