# Netopia Payments Integration - Quick Setup Guide

## What Has Been Added

### New Files Created:
1. **Payment Pages** (in `mason/payment/`)
   - `checkout.html` - Payment checkout page
   - `process.html` - Netopia API integration handler
   - `confirm.html` - Payment confirmation page
   - `callback.html` - Netopia IPN (callback) handler

2. **Admin Pages**
   - `mason/admin/payments/index.html` - Payment management dashboard

3. **Documentation**
   - `NETOPIA_PAYMENT_INTEGRATION.md` - Complete integration guide
   - `.env.example` - Environment variables template

### Modified Files:
1. **Database Schema** (`sql/create_tables.sql`)
   - Added `subscriptions` table
   - Added `payments` table

2. **Application Library** (`lib/AppLib.pm`)
   - Added payment functions: `create_subscription`, `create_payment`, `update_payment_status`
   - Added utility functions: `get_user_subscription`, `generate_netopia_signature`, `verify_netopia_signature`
   - Added Netopia configuration variables

3. **Pricing Page** (`mason/pricing/index.html`)
   - Updated "Get Started" buttons to link to payment checkout

4. **Profile Page** (`mason/profile/index.html`)
   - Added subscription status display
   - Shows active plan details

5. **Docker Configuration**
   - Updated `Dockerfile` to install required Perl modules (LWP::UserAgent, JSON, etc.)
   - Updated `docker-compose.yml` with Netopia environment variables
   - Created logs directory for payment callback logging

6. **README** (`README.md`)
   - Added payment integration section

## Setup Steps

### 1. Get Netopia Credentials
1. Sign up at https://netopia-payments.com/
2. Complete merchant verification
3. Get your API credentials from dashboard:
   - API Key
   - Merchant ID  
   - Signature Key

### 2. Configure Environment
```bash
# Copy the example file
cp .env.example .env

# Edit .env with your credentials
NETOPIA_API_KEY=your_actual_api_key
NETOPIA_MERCHANT_ID=your_merchant_id
NETOPIA_SIGNATURE_KEY=your_signature_key
NETOPIA_SANDBOX=1  # Use 1 for testing, 0 for production
APP_BASE_URL=http://localhost:8080
```

### 3. Update Database
```bash
# Stop containers if running
docker-compose down

# Rebuild with new Perl modules
docker-compose build

# Start services
docker-compose up -d

# Wait for MySQL to be ready, then run migrations
docker-compose exec db mysql -u root -pexample myapp < /var/www/html/sql/create_tables.sql
```

### 4. Test the Integration

#### In Sandbox Mode:
1. Go to http://localhost:8080/pricing/
2. Click "Get Started" on any plan
3. Register/login if needed
4. Review the checkout page
5. Use Netopia test card numbers:
   - **Success**: 4111 1111 1111 1111 (Visa)
   - **Failure**: 4000 0000 0000 0002 (Visa)

### 5. View Payment History (Admin)
- Navigate to: http://localhost:8080/admin/payments/
- Only accessible by admin users (is_admin = 1)

### 6. Check User Profile
- Go to: http://localhost:8080/profile/
- Should display active subscription if payment completed

## Troubleshooting

### Payments stuck in "pending" status
- Check logs: `docker-compose logs web`
- Check callback log: `docker-compose exec web cat /var/www/html/logs/netopia_callback.log`
- Verify callback URL is accessible from internet (use ngrok for local testing)

### Cannot connect to Netopia API
- Verify `NETOPIA_API_KEY` is set correctly
- Check if sandbox mode matches your credentials (sandbox vs production keys)
- Look for errors in: `docker-compose logs web`

### Database errors
- Ensure migrations ran successfully
- Check table creation: `docker-compose exec db mysql -u root -pexample myapp -e "SHOW TABLES;"`

### Missing Perl modules
- Rebuild Docker image: `docker-compose build --no-cache web`
- Check installed modules: `docker-compose exec web perl -MLWP::UserAgent -e 'print "OK\n"'`

## Testing with ngrok (for callback testing)

Netopia needs to send callbacks to your server. For local testing:

```bash
# Install ngrok
# Then run:
ngrok http 8080

# Update .env with the ngrok URL:
APP_BASE_URL=https://your-ngrok-id.ngrok.io

# Restart containers
docker-compose restart web
```

## Going to Production

1. Get production API credentials from Netopia
2. Update `.env`:
   ```
   NETOPIA_SANDBOX=0
   APP_BASE_URL=https://yourdomain.com
   ```
3. Ensure SSL/TLS is properly configured
4. Test with real (small amount) transaction first
5. Monitor callback logs regularly

## Support

- Netopia API Docs: https://netopia-payments.com/en/developers
- Netopia Support: support@netopia-payments.com
- Check callback logs: `/var/www/html/logs/netopia_callback.log`

## Security Notes

- Never commit `.env` file to git
- Keep API keys secure
- Use HTTPS in production
- Validate all callback signatures (implemented)
- Monitor failed payment attempts for fraud

---

**Integration complete!** Your site now supports subscription payments via Netopia. 🎉
