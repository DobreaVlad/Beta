# Railway Deployment - Quick Start

This application is configured for Railway deployment with MySQL database support.

## Quick Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/new)

## Setup Steps

### 1. Create Railway Project
- Connect your GitHub repository to Railway
- Railway will auto-detect the Dockerfile

### 2. Add MySQL Plugin
- Click "+ New" in your project
- Select "Database" → "Add MySQL"
- Railway generates credentials automatically

### 3. Set Environment Variables

Copy these variables from Railway's MySQL plugin to your web service:

**Required Variables:**
```
DB_HOST=<from MySQL Variables tab>
DB_NAME=railway
DB_USER=root  
DB_PASS=<from MySQL Variables tab>
```

**Application Variables:**
```
APP_ENV=production
APP_BASE_URL=https://<your-app>.railway.app
SMTP_HOST=<your-smtp-host>
SMTP_PORT=587
SMTP_FROM=noreply@yourdomain.com
```

**Payment Variables (Stripe):**
```
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 4. Initialize Database

After first deployment, use Railway's MySQL interface or connect via CLI:
```bash
mysql -h <DB_HOST> -u root -p<DB_PASS> railway < sql/create_tables.sql
```

### 5. Deploy

Push to main branch - Railway auto-deploys:
```bash
git push origin main
```

## Connecting to Services

### SMTP Setup
Use a service like:
- SendGrid (recommended)
- Mailgun
- AWS SES
- Postmark

### Database Access
- Use Railway's built-in MySQL client in the dashboard
- Or connect via any MySQL client with the provided credentials

## Monitoring

- **Logs**: Railway Dashboard → Deployments → View Logs
- **Metrics**: Railway Dashboard → Metrics tab
- **Database**: MySQL plugin → Data tab

## Custom Domain

1. Railway Dashboard → Settings → Domains
2. Add your domain
3. Configure DNS records as shown
4. Update `APP_BASE_URL` variable

## Cost Estimate

Railway pricing (as of 2026):
- Hobby Plan: $5/month + usage
- MySQL Plugin: ~$5/month for small database
- Estimated total: $10-20/month for small/medium traffic

## Support

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
