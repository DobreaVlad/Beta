# Stripe Integration

This document describes the Stripe payment integration for PropertySite.

## Overview

The site integrates with Stripe (https://stripe.com/) to process subscription payments for Basic, Professional, and Enterprise plans. Stripe is a leading payment processor used by millions of businesses worldwide.

## Configuration

Add the following environment variables to your `.env` file:

```bash
# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Application Base URL (for webhooks and redirects)
APP_BASE_URL=http://localhost:8080
```

### Getting Stripe Credentials

1. Sign up at https://stripe.com/
2. Go to https://dashboard.stripe.com/apikeys
3. Copy your **Publishable key** (starts with `pk_test_`)
4. Click "Reveal test key" and copy your **Secret key** (starts with `sk_test_`)
5. For webhooks, go to https://dashboard.stripe.com/webhooks
6. Add endpoint: `https://yourdomain.com/payment/callback.html`
7. Select events: `checkout.session.completed`
8. Copy the **Signing secret** (starts with `whsec_`)

## Database Schema

The integration uses two tables:

### subscriptions
- Tracks user subscription plans and status
- Links to users table
- Stores plan type, pricing, and validity dates

### payments
- Records all payment transactions
- Links to subscriptions and users
- Stores Stripe session IDs and payment status
- Includes payment data and error messages for debugging

Run the SQL schema:
```bash
docker compose exec db mysql -u root -pexample myapp < /var/www/html/sql/create_tables.sql
```

## Payment Flow

1. **User selects plan** (`/pricing/`)
   - Displays pricing options with "Get Started" buttons
   - All prices in USD

2. **Checkout page** (`/payment/checkout.html?plan=basic`)
   - Requires user authentication (redirects to login if needed)
   - Displays plan summary and pricing
   - Creates subscription record
   - Redirects to payment processor

3. **Payment processing** (`/payment/process.html?subscription_id=XXX`)
   - Calls Stripe API to create Checkout Session
   - Creates payment record with session ID
   - Redirects user to Stripe's hosted checkout page
   - User enters card details securely on Stripe

4. **Stripe Checkout**
   - User completes payment on Stripe's secure page
   - Stripe handles all payment processing and PCI compliance
   - User redirected back after completion

5. **Payment webhook** (`/payment/callback.html`)
   - Stripe sends `checkout.session.completed` event
   - Webhook verifies Stripe signature
   - Updates payment and subscription status in database
   - Logs all webhooks for debugging

6. **Payment confirmation** (`/payment/confirm.html?session_id=XXX`)
   - User returns after payment
   - Displays payment status and next steps
   - Shows success/failure message

## Plan Pricing

Current plans (in USD):
- **Basic**: $29/month
- **Professional**: $99/month  
- **Enterprise**: $299/month

## Testing in Test Mode

When using test API keys (`sk_test_` and `pk_test_`):
- Use Stripe test card numbers
- No real charges are made
- Test cards: https://stripe.com/docs/testing

Common test cards:
- **Success**: 4242 4242 4242 4242
- **Requires authentication**: 4000 0025 0000 3155
- **Declined**: 4000 0000 0000 9995
- Use any future expiry date and any CVV

## Checking Subscription Status

Use the AppLib function:
```perl
my $subscription = get_user_subscription($user_id);
if ($subscription && $subscription->{status} eq 'active') {
    # User has active subscription
    my $plan_type = $subscription->{plan_type}; # basic, professional, enterprise
}
```

## Troubleshooting

### Webhook not received
- Check that `APP_BASE_URL` is publicly accessible
- Use Stripe CLI for local testing: `stripe listen --forward-to localhost:8080/payment/callback.html`
- Verify webhook endpoint in Stripe Dashboard
- Check `/var/www/html/logs/stripe_webhook.log` for incoming requests

### Payment stuck in pending
- Check Stripe Dashboard for payment status
- Verify webhook is configured and receiving events
- Check database `payments` table for error messages
- Look at webhook logs

### Test mode not working
- Ensure using test API keys (starting with `sk_test_` and `pk_test_`)
- Use official Stripe test card numbers
- Check Stripe Dashboard is in test mode (toggle in top-left)

### Signature verification failing
- Verify `STRIPE_WEBHOOK_SECRET` matches webhook signing secret
- Check webhook secret is from correct endpoint
- Ensure raw POST data is passed to verification function

## Local Development with Webhooks

For local testing, use Stripe CLI:

```bash
# Install Stripe CLI: https://stripe.com/docs/stripe-cli
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:8080/payment/callback.html

# Use the webhook signing secret provided by the CLI
# Add it to your .env file
```

Or use ngrok:
```bash
ngrok http 8080

# Update .env with ngrok URL:
APP_BASE_URL=https://your-id.ngrok.io

# Add webhook endpoint in Stripe Dashboard with ngrok URL
```

## Going to Production

1. Get live API credentials from Stripe Dashboard
2. Switch from test keys to live keys:
   ```
   STRIPE_SECRET_KEY=sk_live_...
   STRIPE_PUBLISHABLE_KEY=pk_live_...
   ```
3. Update webhook endpoint URL in Stripe Dashboard to production domain
4. Get new webhook signing secret for production endpoint
5. Ensure SSL/TLS is properly configured
6. Test with real (small amount) transaction first
7. Monitor webhook logs regularly

## Stripe Dashboard

Monitor your payments at:
- Test mode: https://dashboard.stripe.com/test/payments
- Live mode: https://dashboard.stripe.com/payments

View webhooks at:
- https://dashboard.stripe.com/webhooks

## Security Notes

- Never commit `.env` file to git
- Keep API keys secure - they provide full access to your Stripe account
- Use HTTPS in production
- Webhook signature verification is implemented and required
- Stripe handles all card data - you never touch sensitive payment info
- PCI compliance handled by Stripe

## API Documentation

- Stripe Checkout: https://stripe.com/docs/payments/checkout
- Webhooks: https://stripe.com/docs/webhooks
- API Reference: https://stripe.com/docs/api
- Testing: https://stripe.com/docs/testing

## Support

- Stripe Documentation: https://stripe.com/docs
- Stripe Support: https://support.stripe.com/
- Integration uses Stripe Checkout Sessions API
- Webhook logs: `/var/www/html/logs/stripe_webhook.log`

---

**Integration complete!** Your site now supports subscription payments via Stripe. 🎉
