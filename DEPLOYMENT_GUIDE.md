# Railway Deployment Guide

## Prerequisites

1. Railway account (https://railway.app)
2. GitHub repository with your code
3. MySQL database credentials (from Railway MySQL plugin)
4. SMTP service credentials (SendGrid, Mailgun, or similar)
5. Stripe API keys (for payments)

## Step-by-Step Deployment

### 1. Prepare Your Repository

Ensure all files are committed to your GitHub repository:
```bash
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

### 2. Create Railway Project

1. Go to https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub repo"
4. Choose your repository
5. Railway will automatically detect the Dockerfile

### 3. Add MySQL Database

1. In your Railway project, click "+ New"
2. Select "Database" → "Add MySQL"
3. Railway will create a MySQL instance
4. Note the connection details from the "Variables" tab

### 4. Configure Environment Variables

In Railway dashboard, go to your web service → Variables tab and add:

```
DB_HOST=<from MySQL plugin>
DB_NAME=railway
DB_USER=root
DB_PASS=<from MySQL plugin>
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_FROM=noreply@yourdomain.com
APP_ENV=production
APP_BASE_URL=https://your-app.railway.app
STRIPE_SECRET_KEY=sk_live_your_key
STRIPE_PUBLISHABLE_KEY=pk_live_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret
PORT=80
```

### 5. Initialize Database

After first deployment, connect to your MySQL database and run:
```sql
-- Use Railway's MySQL connection details
mysql -h <DB_HOST> -u root -p<DB_PASS> railway < sql/create_tables.sql
```

Or use Railway's MySQL plugin interface to execute the SQL file.

### 6. Deploy

Railway will automatically deploy on every push to your main branch.
Monitor the deployment logs in the Railway dashboard.

### 7. Verify Deployment

Visit your Railway app URL and check:
- [ ] Homepage loads correctly
- [ ] Database connection works
- [ ] Projects page displays
- [ ] Login/Register functionality works
- [ ] Admin panel is accessible

### 8. Configure Custom Domain (Optional)

1. In Railway dashboard, go to Settings → Domains
2. Add your custom domain
3. Update DNS records as instructed
4. Update `APP_BASE_URL` environment variable

## Troubleshooting

### Check Logs
```bash
# In Railway dashboard, go to Deployments → View Logs
```

### Database Connection Issues
- Verify DB_HOST, DB_USER, DB_PASS are correct
- Ensure MySQL plugin is running
- Check if create_tables.sql was executed

### Application Not Starting
- Check build logs for errors
- Verify PORT is set (Railway usually handles this automatically)
- Check Dockerfile is present in repository root

## Local Development

For local testing before Railway deployment:

```bash
# Copy environment template
cp .env.example .env

# Edit .env with your local settings
# Then build and test locally
./deploy.sh
```

## Important Notes

- Railway automatically redeploys on git push
- Database credentials are available in MySQL plugin variables
- Use Railway's provided PORT variable (default: 80 in our setup)
- Monitor deployment logs for any errors
- Keep sensitive keys secure in Railway dashboard, not in code
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
EOF
```

## Monitorizare Post-Deployment

### 1. Monitorizează Logs
```bash
# Docker logs
docker-compose logs -f web

# Apache logs (dacă nu folosești Docker)
tail -f /var/log/apache2/error.log
tail -f /var/log/apache2/access.log
```

### 2. Monitorizează Performance
```bash
# Check MySQL queries
docker exec -it beta_db mysql -u root -p -e "SHOW PROCESSLIST;"

# Check disk space
df -h

# Check memory
free -h
```

## Checklist Final

- [ ] Backup bază de date creat și verificat
- [ ] Migrare rulată cu succes
- [ ] Toate tabelele au structura corectă
- [ ] Datele existente sunt intacte
- [ ] Site-ul se încarcă corect
- [ ] Toate funcționalitățile sunt testate
- [ ] Logs arată fără erori
- [ ] Performance este acceptabil
- [ ] Backup stocat în loc sigur
- [ ] Documentația actualizată

## Suport

În caz de probleme:
1. Verifică logs: `docker-compose logs -f`
2. Verifică baza de date: `docker exec -it beta_db mysql`
3. Verifică permisiuni fișiere
4. Rollback la versiunea anterioară dacă e necesar

## Note Importante

- **ÎNTOTDEAUNA** creează backup înainte de deployment
- Testează mai întâi pe un environment de staging
- Monitorizează logs după deployment
- Păstrează backup-urile pentru minim 30 de zile
- Documentează orice modificări specifice serverului tău
