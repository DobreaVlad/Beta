# Stripe Payment Integration - Quick Setup Guide

## What Has Been Updated

### Modified Files for Stripe:
1. **Application Library** (`lib/AppLib.pm`)
   - Replaced Netopia functions with Stripe functions
   - Added `create_stripe_checkout_session()`
   - Added `verify_stripe_signature()` for webhook security
   - Updated payment functions to use Stripe session IDs

2. **Payment Pages** (`mason/payment/`)
   - `checkout.html` - Updated pricing to USD, simplified flow
   - `process.html` - Now creates Stripe Checkout Session
   - `confirm.html` - Updated to handle Stripe session_id parameter
   - `callback.html` - Complete rewrite for Stripe webhooks

3. **Admin Pages**
   - `mason/admin/payments/index.html` - Updated to show Stripe session IDs

4. **Database Schema** (`sql/create_tables.sql`)
   - Changed `netopia_order_id` to `stripe_session_id`
   - Updated currency defaults to 'usd'
   - Changed payment_method default to 'stripe'

5. **Configuration Files**
   - `.env.example` - Updated with Stripe variables
   - `docker-compose.yml` - Updated environment variables
   - `README.md` - Updated integration docs

6. **Documentation**
   - Created `STRIPE_INTEGRATION.md` - Complete Stripe guide

## Setup Steps

### 1. Get Stripe Test Credentials (Free)
1. Sign up at https://stripe.com/ (no credit card needed for test mode)
2. After signup, you're automatically in test mode
3. Go to https://dashboard.stripe.com/test/apikeys
4. Copy your keys:
   - **Publishable key**: `pk_test_...`
   - **Secret key**: `sk_test_...` (click "Reveal test key")

### 2. Set Up Webhook (for local testing, do this later)
For now, leave `STRIPE_WEBHOOK_SECRET` empty - payments will work, webhook verification will be skipped.

### 3. Configure Environment
```bash
# In WSL
cd /mnt/c/Projects/Beta

# Copy and edit the env file
cp .env.example .env
nano .env  # or use vi, or edit in VS Code
```

Add your Stripe test keys:
```bash
STRIPE_SECRET_KEY=sk_test_YOUR_KEY_HERE
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_KEY_HERE
STRIPE_WEBHOOK_SECRET=
APP_BASE_URL=http://localhost:8080
```

### 4. Rebuild and Start Docker
```bash
# Stop containers
docker compose down

# Remove old database to recreate with new schema
docker volume rm beta_db_data

# Rebuild with updated environment
docker compose build

# Start everything
docker compose up -d

# Wait for MySQL to start (about 30 seconds)
sleep 30

# Verify containers are running
docker compose ps
```

### 5. Check the database
```bash
# Connect to MySQL
docker compose exec db mysql -u root -pexample myapp

# In MySQL, verify tables exist:
SHOW TABLES;
DESCRIBE payments;
DESCRIBE subscriptions;
exit
```

You should see `stripe_session_id` column in payments table.

### 6. Test the Integration

Open your browser:
1. **View pricing**: http://localhost:8080/pricing/
2. **Click "Get Started"** on any plan
3. **Register/Login** if needed
4. **Review checkout** page - should show plan details
5. **Click "Proceed to Payment"**
6. **You'll be redirected to Stripe** - use test card:
   - Card: `4242 4242 4242 4242`
   - Expiry: Any future date (e.g., `12/34`)
   - CVV: Any 3 digits (e.g., `123`)
7. **Complete payment** and return to site
8. **Check profile**: http://localhost:8080/profile/ - should show active subscription

### 7. View Payment Admin Panel
- Go to: http://localhost:8080/admin/payments/
- Login with admin account (dobreavlad@yahoo.com if you have it)
- Should see the payment record with Stripe session ID

## Testing Without Webhooks Initially

Webhooks update payment status automatically, but for initial testing you can manually update:

```bash
# If payment is stuck in "pending", manually mark as completed:
docker compose exec db mysql -u root -pexample myapp -e "
UPDATE payments SET status='completed' WHERE status='pending';
UPDATE subscriptions SET status='active', start_date=NOW(), end_date=DATE_ADD(NOW(), INTERVAL 1 MONTH) WHERE status='pending';
"
```

## Setting Up Webhooks (Later)

### Option 1: Using Stripe CLI (Recommended for local dev)
```bash
# Install Stripe CLI: https://stripe.com/docs/stripe-cli#install
stripe login

# Forward webhooks to your local server
stripe listen --forward-to localhost:8080/payment/callback.html

# Copy the webhook signing secret (whsec_...) and add to .env
# Restart containers: docker compose restart web
```

### Option 2: Using ngrok (Alternative)
```bash
# Install ngrok, then:
ngrok http 8080

# Update .env with ngrok URL:
APP_BASE_URL=https://your-id.ngrok.io

# Add webhook in Stripe Dashboard:
# https://dashboard.stripe.com/test/webhooks
# Endpoint URL: https://your-id.ngrok.io/payment/callback.html
# Events: checkout.session.completed

# Copy signing secret and add to .env
# Restart containers
```

## Verifying Everything Works

1. **Check logs** for errors:
   ```bash
   docker compose logs web --tail=50
   ```

2. **View Stripe Dashboard**:
   - Payments: https://dashboard.stripe.com/test/payments
   - Should see your test payment

3. **Check webhook log** (after webhook is set up):
   ```bash
   docker compose exec web cat /var/www/html/logs/stripe_webhook.log
   ```

## Common Issues

### "Unable to process payment" error
- Check Stripe keys are correct in `.env`
- Verify keys start with `sk_test_` and `pk_test_`
- Check Docker logs: `docker compose logs web --tail=100`

### Payment stuck in "pending"
- Normal if webhooks not set up yet
- Use manual SQL update above, or
- Set up webhooks with Stripe CLI or ngrok

### Can't access /admin/payments/
- Need admin user (is_admin = 1)
- Create admin:
  ```bash
  docker compose exec db mysql -u root -pexample myapp -e "
  UPDATE users SET is_admin=1 WHERE email='your@email.com';
  "
  ```

## Production Checklist

When ready for production:
- [ ] Get live Stripe keys (not test keys)
- [ ] Update `.env` with live keys
- [ ] Set up production webhook endpoint
- [ ] Configure SSL/HTTPS
- [ ] Test with small real payment
- [ ] Set up monitoring for webhook failures

---

**You're all set!** The site now uses Stripe for payments. Test mode is free and safe to experiment with. 🎉
