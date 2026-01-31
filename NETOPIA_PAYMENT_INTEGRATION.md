# Netopia Payments Integration

This document describes the Netopia Payments integration for PropertySite.

## Overview

The site integrates with Netopia Payments (https://netopia-payments.com/) to process subscription payments for Basic, Professional, and Enterprise plans.

## Configuration

Add the following environment variables to your Docker configuration:

```bash
# Netopia Payments Configuration
NETOPIA_API_KEY=your_api_key_here
NETOPIA_MERCHANT_ID=your_merchant_id_here
NETOPIA_SIGNATURE_KEY=your_signature_key_here
NETOPIA_SANDBOX=1  # Set to 0 for production

# Application Base URL (for callbacks)
APP_BASE_URL=http://localhost
```

### Getting Netopia Credentials

1. Sign up at https://netopia-payments.com/
2. Complete merchant verification
3. Get your API credentials from the merchant dashboard:
   - API Key
   - Merchant ID
   - Signature Key

## Database Schema

The integration adds two new tables:

### subscriptions
- Tracks user subscription plans and status
- Links to users table
- Stores plan type, pricing, and validity dates

### payments
- Records all payment transactions
- Links to subscriptions and users
- Stores Netopia order IDs and payment status
- Includes payment data and error messages for debugging

Run the updated SQL schema:
```bash
docker-compose exec web mysql -u root -p myapp < /var/www/html/sql/create_tables.sql
```

## Payment Flow

1. **User selects plan** (`/pricing/`)
   - Displays pricing options
   - Links to checkout page with selected plan

2. **Checkout page** (`/payment/checkout.html?plan=basic`)
   - Requires user authentication (redirects to login if needed)
   - Displays plan summary and pricing
   - Creates subscription and payment records
   - Redirects to payment processor

3. **Payment processing** (`/payment/process.html?order_id=XXX`)
   - Calls Netopia API to initiate payment
   - Redirects user to Netopia secure payment page
   - User enters card details on Netopia's site

4. **Payment callback** (`/payment/callback.html`)
   - Netopia sends payment status via IPN (Instant Payment Notification)
   - Updates payment and subscription status in database
   - Logs all callbacks for debugging

5. **Payment confirmation** (`/payment/confirm.html?order_id=XXX`)
   - User returns after payment
   - Displays payment status and next steps
   - Shows success/failure message

## Plan Pricing

Current plans (in RON):
- **Basic**: 139 RON/month (~$29 USD)
- **Professional**: 479 RON/month (~$99 USD)
- **Enterprise**: 1449 RON/month (~$299 USD)

## Testing in Sandbox Mode

When `NETOPIA_SANDBOX=1`:
- Use Netopia test card numbers
- No real charges are made
- Test URL: https://sandbox.netopia-payments.com

Common test cards:
- **Successful payment**: 4111111111111111 (Visa)
- **Failed payment**: 4000000000000002 (Visa)

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

### Callback not received
- Check that `APP_BASE_URL` is publicly accessible
- Verify Netopia dashboard has correct notification URL
- Check `/var/www/html/logs/netopia_callback.log` for incoming requests

### Payment stuck in pending
- Check Netopia merchant dashboard for payment status
- Verify callback URL is accessible
- Check database `payments` table for error messages

### Test mode not working
- Ensure `NETOPIA_SANDBOX=1`
- Verify using test API credentials
- Use official Netopia test card numbers

## Security Notes

- Never commit API keys to version control
- Use environment variables for all credentials
- Signature verification is implemented for callbacks
- All payment data is encrypted by Netopia (PCI DSS compliant)
- User never enters card details on your site

## Support

- Netopia Documentation: https://netopia-payments.com/en/developers
- Netopia Support: support@netopia-payments.com
- Integration uses Netopia REST API v1
