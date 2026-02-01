# Railway Deployment Troubleshooting Guide

## Quick Diagnostics

### Step 1: Check Build Status
1. Go to Railway Dashboard → Your Project → Web Service
2. Click "Deployments" tab
3. Look at the latest deployment:
   - ✅ Green = Build succeeded
   - ❌ Red = Build failed

### Step 2: Check Deployment Logs
Click on the deployment → "View Logs"

**Look for these common errors:**

---

## Common Issues and Solutions

### Issue 1: "Application failed to respond" or "502 Bad Gateway"

**Symptoms:** Site loads but shows error page, logs show "exited with code 1"

**Causes:**
- Database connection failed
- Missing environment variables
- Port configuration issue

**Solution:**
```bash
# In Railway Dashboard → Variables, ensure these are set:
DB_HOST=<your-mysql-host>      # From MySQL plugin
DB_NAME=railway
DB_USER=root
DB_PASS=<your-mysql-password>   # From MySQL plugin
APP_BASE_URL=https://your-app.railway.app
APP_ENV=production

# These can be empty for now if not using:
SMTP_HOST=
SMTP_PORT=
SMTP_FROM=
STRIPE_SECRET_KEY=
STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=
```

### Issue 2: Database Connection Errors

**Log shows:** "ERROR: MySQL is not available" or "Access denied for user"

**Solution A - Check MySQL Plugin:**
1. Go to Railway Project
2. Click on MySQL plugin
3. Go to "Variables" tab
4. Copy EXACTLY these values:
   - `MYSQLHOST` → use as `DB_HOST`
   - `MYSQLUSER` → use as `DB_USER`
   - `MYSQLPASSWORD` → use as `DB_PASS`
   - `MYSQLDATABASE` → use as `DB_NAME`

**Solution B - MySQL Not Added:**
1. Click "+ New" in Railway project
2. Select "Database" → "Add MySQL"
3. Wait for it to start
4. Copy credentials to your web service

### Issue 3: "create_tables.sql not found"

**Log shows:** "WARNING: create_tables.sql not found"

**Solution:**
Ensure `sql/create_tables.sql` exists in your repository and push:
```bash
git add sql/create_tables.sql
git commit -m "Add database schema"
git push origin main
```

### Issue 4: Build Fails - "Cannot find Dockerfile"

**Solution:**
Ensure `Dockerfile` is in the root of your repository:
```bash
ls -la Dockerfile
git add Dockerfile
git commit -m "Add Dockerfile"
git push origin main
```

### Issue 5: Application Starts but Shows Blank Page

**Causes:**
- Apache configuration issue
- Mason template errors
- Missing files

**Debug Steps:**
1. Check logs for Apache errors
2. Verify `mason/` directory exists
3. Check file permissions

### Issue 6: Port Issues - "Failed to bind to port"

Railway automatically assigns a PORT. If you see port errors:

**Solution:**
In Railway Variables, ensure PORT is NOT set or set to 80:
```
PORT=80
```

### Issue 7: "Permission denied" Errors

**Log shows:** Permission errors for files/directories

**Solution:**
The Dockerfile should handle this, but if needed, rebuild:
```bash
git commit --allow-empty -m "Trigger rebuild"
git push origin main
```

---

## Debugging Steps

### 1. Enable Verbose Logging

Add to Railway Variables:
```
DEBUG=1
```

Then check logs again.

### 2. Test Database Connection Manually

In Railway Dashboard:
1. Click MySQL plugin
2. Click "Data" tab
3. Try to connect
4. Run query: `SHOW TABLES;`

If this fails, your MySQL instance has issues.

### 3. Check Environment Variables

In Railway Dashboard → Your service → Variables:
```bash
# Required (from MySQL plugin):
DB_HOST=containers-us-west-xxx.railway.app
DB_NAME=railway
DB_USER=root
DB_PASS=<long-password>

# Optional but recommended:
APP_ENV=production
APP_BASE_URL=https://your-app.railway.app
```

### 4. Simplify Configuration

Temporarily remove optional variables:
- Remove Stripe keys (if not using payments yet)
- Remove SMTP settings (if not using email yet)

Just keep database variables and redeploy.

### 5. Check Recent Changes

If it was working before:
1. Check what changed in your last commit
2. Review Railway deployment logs for differences
3. Consider rolling back to previous deployment

---

## Manual Database Setup

If automatic initialization fails, manually create tables:

### Option A: Using Railway's MySQL Client
1. Railway Dashboard → MySQL plugin → "Data" tab
2. Click "Connect" or use the Query interface
3. Copy-paste contents of `sql/create_tables.sql`
4. Execute

### Option B: Using MySQL Client Locally
```bash
# Get credentials from Railway MySQL Variables tab
mysql -h <MYSQLHOST> -u <MYSQLUSER> -p<MYSQLPASSWORD> <MYSQLDATABASE> < sql/create_tables.sql
```

### Option C: Using Railway CLI
```bash
railway link
railway run mysql -h $MYSQLHOST -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE < sql/create_tables.sql
```

---

## Testing Deployment

After fixing issues:

1. **Trigger Redeploy:**
   ```bash
   git commit --allow-empty -m "Redeploy"
   git push origin main
   ```

2. **Wait for Build:**
   - Watch build logs in Railway dashboard
   - Wait for "Deployment succeeded" message

3. **Test Application:**
   - Visit your Railway URL
   - Check homepage loads
   - Try a few pages

4. **Verify Database:**
   - Try to register/login
   - Check if data persists

---

## Getting Help

### Share These Details:

1. **Error Message from Logs:**
   ```
   [Copy the exact error from Railway logs]
   ```

2. **Environment Variables (sanitized):**
   ```
   DB_HOST=<set? yes/no>
   DB_NAME=<set? yes/no>
   DB_USER=<set? yes/no>
   DB_PASS=<set? yes/no>
   ```

3. **Build Status:**
   - Did build succeed? Yes/No
   - Did deployment start? Yes/No
   - Is MySQL plugin added? Yes/No

### Railway Support:
- Discord: https://discord.gg/railway
- Docs: https://docs.railway.app
- Community Forum: https://help.railway.app

---

## Quick Fix Checklist

- [ ] MySQL plugin added to Railway project
- [ ] All DB_* variables copied from MySQL to web service
- [ ] `Dockerfile` exists in repository root
- [ ] `sql/create_tables.sql` exists in repository
- [ ] Latest code pushed to GitHub
- [ ] Build succeeded (green checkmark)
- [ ] Deployment logs show Apache started
- [ ] Application URL returns something (not 404)

If all checked and still not working, share your Railway logs for specific help!
