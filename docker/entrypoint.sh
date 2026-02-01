#!/bin/bash
set -e

# Only run database initialization if all DB variables are set
if [ -n "$DB_HOST" ] && [ -n "$DB_NAME" ] && [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    echo "Database credentials found, attempting initialization..."
    # Run database initialization script (but don't fail if it errors)
    /var/www/html/docker/init-db.sh || echo "Database initialization skipped or failed - may already be initialized"
else
    echo "Database credentials not set, skipping database initialization"
fi

# Start Apache in foreground
exec apachectl -D FOREGROUND
