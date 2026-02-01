# Perl Website with Mason Templates

A Perl web application using Mason templating system, Apache with mod_perl, and MySQL.

## Quick Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new)

See [RAILWAY_SETUP.md](RAILWAY_SETUP.md) for detailed Railway deployment instructions.

## Project Structure

Ready for your custom implementation using Mason templates.

## Features

### User Authentication
- Registration with email verification
- Login/logout functionality
- Password reset via email
- Session management

### Payment Integration (Stripe)
Full Stripe integration for subscription billing. See [STRIPE_INTEGRATION.md](STRIPE_INTEGRATION.md) for details.

### Email Configuration
- SMTP configuration for email notifications
- Password reset emails
- For local development, emails can be tested with mailhog (in local Docker setup)

## Deployment Options

### Option 1: Railway (Recommended for Production)

Railway provides easy deployment with automatic HTTPS and managed MySQL:

1. Fork/clone this repository
2. Create a Railway account
3. Follow [RAILWAY_SETUP.md](RAILWAY_SETUP.md)
4. Configure environment variables in Railway dashboard
5. Deploy!

### Option 2: Local Development with Docker

For local testing and development:

1. Copy environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` with your local settings

3. Start services:
   ```bash
   docker-compose up --build
   ```

Access the application at http://localhost:80

Note: The simplified docker-compose.yml is optimized for Railway. For full local development with mailhog and adminer, you may want to add those services back.

## Environment Variables

Required for both Railway and local deployment:

```bash
# Database
DB_HOST=<your-db-host>
DB_NAME=railway
DB_USER=root
DB_PASS=<your-db-password>

# Email
SMTP_HOST=<your-smtp-host>
SMTP_PORT=587
SMTP_FROM=noreply@yourdomain.com

# Application
APP_ENV=production
APP_BASE_URL=https://your-app.railway.app

# Stripe
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

## Database Setup

Initialize the database with:
```bash
mysql -h <DB_HOST> -u root -p railway < sql/create_tables.sql
```

On Railway, use the MySQL plugin interface or connect via CLI.

## Documentation

- [RAILWAY_SETUP.md](RAILWAY_SETUP.md) - Quick Railway deployment guide
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed deployment instructions
- [STRIPE_INTEGRATION.md](STRIPE_INTEGRATION.md) - Payment integration documentation
- [STRIPE_SETUP_GUIDE.md](STRIPE_SETUP_GUIDE.md) - Stripe configuration guide

## Security Notes

For production deployments:
- Use strong database passwords
- Keep environment variables secure (never commit to git)
- Enable HTTPS (Railway provides this automatically)
- Configure CSRF protection
- Implement rate limiting for API endpoints
- Use production Stripe keys (not test keys)

## Support

For issues or questions:
- Check existing documentation files
- Review Railway logs in the dashboard
- Test locally with Docker first

Enjoy! ✨
