#!/bin/bash

# Script automat de deployment pentru producție
# Usage: ./deploy.sh [staging|production]

set -e  # Exit on error

ENVIRONMENT=${1:-staging}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"
PROJECT_DIR="/var/www/html"

echo "========================================="
echo "Date Santiere - Production Deployment"
echo "Environment: $ENVIRONMENT"
echo "Timestamp: $TIMESTAMP"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Create backup directory
mkdir -p $BACKUP_DIR

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Step 1: Backup current database
print_status "Step 1: Creating database backup..."
if docker-compose ps | grep -q "beta_db"; then
    docker exec beta_db mysqldump -u root -proot datesantiere > "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"
    print_status "Database backup created: $BACKUP_DIR/db_backup_$TIMESTAMP.sql"
else
    print_warning "Database container not running. Skipping backup."
fi

# Step 2: Backup current files
print_status "Step 2: Backing up current files..."
if [ -d "$PROJECT_DIR" ]; then
    tar -czf "$BACKUP_DIR/files_backup_$TIMESTAMP.tar.gz" -C $PROJECT_DIR . 2>/dev/null || true
    print_status "Files backup created: $BACKUP_DIR/files_backup_$TIMESTAMP.tar.gz"
fi

# Step 3: Pull latest changes (if using git)
if [ -d ".git" ]; then
    print_status "Step 3: Pulling latest changes from git..."
    git pull origin main
else
    print_warning "Not a git repository. Skipping git pull."
fi

# Step 4: Stop containers
print_status "Step 4: Stopping containers..."
docker-compose down

# Step 5: Rebuild and start containers
print_status "Step 5: Rebuilding and starting containers..."
docker-compose up -d --build

# Step 6: Wait for MySQL to be ready
print_status "Step 6: Waiting for MySQL to be ready..."
sleep 10
until docker exec beta_db mysqladmin ping -u root -proot --silent; do
    echo "Waiting for database connection..."
    sleep 2
done
print_status "MySQL is ready!"

# Step 7: Run database migration
print_status "Step 7: Running database migration..."
if [ -f "sql/migrate_to_production.sql" ]; then
    docker exec -i beta_db mysql -u root -proot datesantiere < sql/migrate_to_production.sql
    print_status "Database migration completed!"
else
    print_error "Migration file not found: sql/migrate_to_production.sql"
    exit 1
fi

# Step 8: Verify database structure
print_status "Step 8: Verifying database structure..."
docker exec beta_db mysql -u root -proot -e "USE datesantiere; SHOW TABLES;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    print_status "Database structure verified!"
else
    print_error "Database verification failed!"
    exit 1
fi

# Step 9: Check application health
print_status "Step 9: Checking application health..."
sleep 5
if curl -f http://localhost:8080 > /dev/null 2>&1; then
    print_status "Application is responding!"
else
    print_warning "Application health check failed. Check logs with: docker-compose logs -f"
fi

# Step 10: Display logs
print_status "Step 10: Recent logs..."
docker-compose logs --tail=50

echo ""
echo "========================================="
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Monitor logs: docker-compose logs -f"
echo "  2. Test the application: http://localhost:8080"
echo "  3. Check database: docker exec -it beta_db mysql -u root -proot datesantiere"
echo ""
echo "Rollback if needed:"
echo "  Database: mysql -u root -proot datesantiere < $BACKUP_DIR/db_backup_$TIMESTAMP.sql"
echo "  Files: tar -xzf $BACKUP_DIR/files_backup_$TIMESTAMP.tar.gz -C $PROJECT_DIR"
echo ""
