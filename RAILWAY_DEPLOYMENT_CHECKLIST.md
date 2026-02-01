# Railway Deployment Checklist

## ✅ Cleaned Up Old Production Configs

The following changes have been made to prepare for Railway deployment:

### Files Modified
- [x] `docker-compose.yml` - Simplified for Railway (removed nginx, mailhog, adminer, local db)
- [x] `deploy.sh` - Replaced with Railway-focused script
- [x] `.env.example` - Updated with Railway-specific variables
- [x] `DEPLOYMENT_GUIDE.md` - Completely rewritten for Railway
- [x] `README.md` - Updated with Railway deployment instructions
- [x] `sql/migrate_to_production.sql` - Marked as deprecated

### Files Created
- [x] `RAILWAY_SETUP.md` - Quick Railway deployment guide
- [x] `railway.json` - Railway configuration file
- [x] `.railwayignore` - Exclude unnecessary files from deployment

### Old Configs Removed
- ✓ Old production database names (beta_db, datesantiere)
- ✓ Hard-coded production passwords
- ✓ Local development-only services (mailhog, adminer, nginx)
- ✓ Docker Compose database service (Railway provides MySQL)
- ✓ Old backup scripts and migration logic

## 🚀 Next Steps for Railway Deployment

### 1. Verify Local Setup
```bash
# Copy environment file
cp .env.example .env

# Edit with your settings
# Test build (optional)
./deploy.sh
```

### 2. Push to GitHub
```bash
git add .
git commit -m "Configure for Railway deployment"
git push origin main
```

### 3. Create Railway Project
1. Go to https://railway.app
2. Sign up / Log in
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your repository

### 4. Add MySQL Database
1. In Railway project, click "+ New"
2. Select "Database" → "Add MySQL"
3. Copy credentials to use in next step

### 5. Configure Environment Variables
In Railway dashboard, add these variables:

**From MySQL Plugin:**
```
DB_HOST=<from MySQL plugin>
DB_NAME=railway
DB_USER=root
DB_PASS=<from MySQL plugin>
```

**Application Settings:**
```
APP_ENV=production
APP_BASE_URL=https://<your-app>.railway.app
PORT=80
```

**Email (choose a provider):**
```
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_FROM=noreply@yourdomain.com
```

**Stripe (from dashboard.stripe.com):**
```
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 6. Initialize Database
After first deployment:
```bash
# Use Railway's MySQL credentials
mysql -h <DB_HOST> -u root -p<DB_PASS> railway < sql/create_tables.sql
```

Or use Railway's built-in MySQL client in the dashboard.

### 7. Verify Deployment
- [ ] Application loads without errors
- [ ] Database connection works
- [ ] Pages render correctly
- [ ] Login/registration works
- [ ] Payment flow works (if configured)

## 📋 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| DB_HOST | Railway MySQL host | `containers-us-west-xxx.railway.app` |
| DB_NAME | Database name | `railway` |
| DB_USER | Database user | `root` |
| DB_PASS | Database password | `<from Railway>` |
| SMTP_HOST | Email server | `smtp.sendgrid.net` |
| SMTP_PORT | Email port | `587` |
| SMTP_FROM | From email address | `noreply@yourdomain.com` |
| APP_ENV | Environment | `production` |
| APP_BASE_URL | Your app URL | `https://myapp.railway.app` |
| STRIPE_SECRET_KEY | Stripe secret key | `sk_live_...` |
| STRIPE_PUBLISHABLE_KEY | Stripe public key | `pk_live_...` |
| STRIPE_WEBHOOK_SECRET | Webhook secret | `whsec_...` |
| PORT | Application port | `80` (Railway auto-assigns) |

## 🔧 Troubleshooting

### Build Fails
- Check Railway build logs
- Ensure Dockerfile is present
- Verify all dependencies are listed

### Database Connection Issues
- Verify DB credentials from MySQL plugin
- Check if database is running in Railway
- Ensure create_tables.sql was executed

### Application Won't Start
- Check environment variables are set correctly
- Review application logs in Railway
- Verify PORT is configured (usually automatic)

### Email Not Sending
- Verify SMTP credentials
- Check SMTP provider is configured correctly
- Review email service logs

## 📚 Documentation

- [RAILWAY_SETUP.md](RAILWAY_SETUP.md) - Quick setup guide
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Detailed instructions
- [STRIPE_INTEGRATION.md](STRIPE_INTEGRATION.md) - Payment setup
- Railway Docs: https://docs.railway.app

## ⚠️ Important Notes

- Railway automatically provides HTTPS
- Database credentials are managed by Railway
- Never commit secrets to git
- Use production Stripe keys for live deployment
- Monitor costs in Railway dashboard
- Enable automatic backups in MySQL settings

## 🎉 Ready to Deploy!

Your application is now configured for Railway. Follow the steps above to deploy.
