#!/bin/bash
set -e

echo "Checking database connection..."

# If MYSQL_URL is provided, parse it into DB_* variables
if [ -n "$MYSQL_URL" ] && { [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; }; then
    # Expected format: mysql://user:pass@host:port/database
    if [[ "$MYSQL_URL" =~ ^mysql://([^:]+):([^@]+)@([^:/]+)(:([0-9]+))?/([^?]+) ]]; then
        DB_USER="${BASH_REMATCH[1]}"
        DB_PASS="${BASH_REMATCH[2]}"
        DB_HOST="${BASH_REMATCH[3]}"
        DB_PORT="${BASH_REMATCH[5]}"
        DB_NAME="${BASH_REMATCH[6]}"
    fi
fi

# Default port if not set
DB_PORT=${DB_PORT:-3306}

# Wait for MySQL to be ready (with timeout)
RETRY_COUNT=0
MAX_RETRIES=30

until mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "ERROR: MySQL is not available after $MAX_RETRIES attempts"
        echo "Please check your database connection details:"
        echo "  DB_HOST: $DB_HOST"
        echo "  DB_USER: $DB_USER"
        echo "  DB_NAME: $DB_NAME"
        exit 1
    fi
    echo "MySQL is unavailable (attempt $RETRY_COUNT/$MAX_RETRIES) - sleeping"
    sleep 2
done

echo "MySQL is up - checking database..."

# Check if database exists and has tables
TABLE_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null | wc -l)

if [ "$TABLE_COUNT" -lt 2 ]; then
    echo "Database appears empty, initializing tables..."
    if [ -f /var/www/html/sql/create_tables.sql ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < /var/www/html/sql/create_tables.sql
        echo "Database tables created successfully!"
    else
        echo "WARNING: create_tables.sql not found, skipping database initialization"
    fi
else
    echo "Database already initialized with $TABLE_COUNT tables"
fi

echo "Database initialization complete!"
