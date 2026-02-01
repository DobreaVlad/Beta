#!/bin/bash
set -e

# Run database initialization script
/var/www/html/docker/init-db.sh

# Start Apache in foreground
exec apachectl -D FOREGROUND
