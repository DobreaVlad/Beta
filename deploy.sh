#!/bin/bash

# Railway Deployment Script
# This script is for local testing before Railway deployment

set -e

echo "========================================="
echo "Railway Deployment Preparation"
echo "========================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning "No .env file found. Copy .env.example to .env and configure it."
    exit 1
fi

print_status "Building Docker image..."
docker build -t railway-app .

print_status "Build completed!"

echo ""
echo "========================================="
echo -e "${GREEN}Ready for Railway deployment!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Push your code to GitHub"
echo "  2. Connect Railway to your GitHub repository"
echo "  3. Add environment variables in Railway dashboard"
echo "  4. Deploy!"
echo ""
echo "Required Railway environment variables:"
echo "  - DB_HOST (from Railway MySQL service)"
echo "  - DB_NAME"
echo "  - DB_USER"
echo "  - DB_PASS"
echo "  - SMTP_HOST"
echo "  - SMTP_PORT"
echo "  - SMTP_FROM"
echo "  - APP_BASE_URL"
echo "  - STRIPE_SECRET_KEY"
echo "  - STRIPE_PUBLISHABLE_KEY"
echo "  - STRIPE_WEBHOOK_SECRET"
echo ""
