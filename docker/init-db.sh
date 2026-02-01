#!/bin/bash
set -e

echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --silent; do
    echo "MySQL is unavailable - sleeping"
    sleep 2
done

echo "MySQL is up - checking and creating tables if necessary..."

# Execute the SQL script to create tables (IF NOT EXISTS will prevent errors)
mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < /var/www/html/sql/create_tables.sql

echo "Database initialization complete!"
