package AppLib;
use strict;
use warnings;
use DBI;
use Digest::SHA qw(sha256_hex);
use MIME::Base64 qw(encode_base64);

use Exporter 'import';
our @EXPORT_OK = qw(
    dbh hash_password verify_password create_session get_user_by_session
    delete_session create_user send_email create_password_reset
    get_user_by_reset_token consume_password_reset update_user_password
    create_subscription create_payment update_payment_status get_user_subscription
    create_stripe_checkout_session verify_stripe_signature get_stripe_session
    format_date_ro
);

# Database configuration
my $MYSQL_URL = $ENV{MYSQL_URL};
my ($DB_HOST, $DB_NAME, $DB_USER, $DB_PASS);

if ($MYSQL_URL) {
  # Parse mysql://user:pass@host:port/database
  if ($MYSQL_URL =~ m|mysql://([^:]+):([^@]+)@([^:/]+)(?::(\d+))?/(.+)|) {
    $DB_USER = $1;
    $DB_PASS = $2;
    $DB_HOST = $3;
    $DB_NAME = $5;
  }
} else {
  # Fallback to individual env vars (for local dev)
  $DB_HOST = $ENV{DB_HOST} || 'db';
  $DB_NAME = $ENV{DB_NAME} || 'myapp';
  $DB_USER = $ENV{DB_USER} || 'root';
  $DB_PASS = $ENV{DB_PASS} || '';
}

# SMTP configuration
my $SMTP_HOST = $ENV{SMTP_HOST} || 'localhost';
my $SMTP_PORT = $ENV{SMTP_PORT} || 1025;
my $SMTP_FROM = $ENV{SMTP_FROM} || 'noreply@example.com';

# Stripe configuration
my $STRIPE_SECRET_KEY = $ENV{STRIPE_SECRET_KEY} || '';
my $STRIPE_PUBLISHABLE_KEY = $ENV{STRIPE_PUBLISHABLE_KEY} || '';
my $STRIPE_WEBHOOK_SECRET = $ENV{STRIPE_WEBHOOK_SECRET} || '';

sub dbh {
    return DBI->connect(
        "DBI:mysql:database=$DB_NAME;host=$DB_HOST",
        $DB_USER,
        $DB_PASS,
        { RaiseError => 1, AutoCommit => 1, mysql_enable_utf8 => 1 }
    );
}

sub hash_password {
    my ($password) = @_;
    my $salt = encode_base64(pack('H*', sha256_hex(rand() . time() . $$)), '');
    my $hash = sha256_hex($password . $salt);
    return ($hash, $salt);
}

sub verify_password {
    my ($password, $stored_hash, $salt) = @_;
    my $hash = sha256_hex($password . $salt);
    return $hash eq $stored_hash;
}

sub create_session {
    my ($user_id) = @_;
    my $session_id = sha256_hex(rand() . time() . $$ . $user_id);
    my $dbh = dbh();
    $dbh->do('INSERT INTO sessions (session_id, user_id) VALUES (?, ?)', undef, $session_id, $user_id);
    return $session_id;
}

sub get_user_by_session {
    my ($session_id) = @_;
    return undef unless $session_id;
    my $dbh = dbh();
    my $sth = $dbh->prepare('SELECT u.* FROM users u JOIN sessions s ON u.id = s.user_id WHERE s.session_id = ? AND s.expires_at > NOW()');
    $sth->execute($session_id);
    return $sth->fetchrow_hashref;
}

sub delete_session {
    my ($session_id) = @_;
    return unless $session_id;
    my $dbh = dbh();
    $dbh->do('DELETE FROM sessions WHERE session_id = ?', undef, $session_id);
}

sub create_user {
    my ($name, $password_hash, $salt, $email) = @_;
    my $dbh = dbh();
    eval {
        $dbh->do('INSERT INTO users (name, email, password_hash, salt) VALUES (?, ?, ?, ?)',
            undef, $name, $email, $password_hash, $salt);
    };
    if ($@) {
        return { ok => 0, error => 'Name or email already exists' };
    }
    return { ok => 1 };
}

sub send_email {
    my ($to, $subject, $body) = @_;
    eval {
        require Net::SMTP;
        my $smtp = Net::SMTP->new($SMTP_HOST, Port => $SMTP_PORT, Timeout => 10);
        return (0, 'Cannot connect to SMTP server') unless $smtp;
        $smtp->mail($SMTP_FROM);
        $smtp->to($to);
        $smtp->data();
        $smtp->datasend("From: $SMTP_FROM\n");
        $smtp->datasend("To: $to\n");
        $smtp->datasend("Subject: $subject\n");
        $smtp->datasend("\n");
        $smtp->datasend($body);
        $smtp->dataend();
        $smtp->quit;
    };
    return $@ ? (0, $@) : (1, '');
}

sub create_password_reset {
    my ($user_id) = @_;
    my $token = sha256_hex(rand() . time() . $$ . $user_id);
    my $dbh = dbh();
    $dbh->do('INSERT INTO password_resets (user_id, token) VALUES (?, ?)', undef, $user_id, $token);
    return $token;
}

sub get_user_by_reset_token {
    my ($token) = @_;
    return undef unless $token;
    my $dbh = dbh();
    my $sth = $dbh->prepare('SELECT u.* FROM users u JOIN password_resets pr ON u.id = pr.user_id WHERE pr.token = ? AND pr.expires_at > NOW() AND pr.consumed = FALSE');
    $sth->execute($token);
    return $sth->fetchrow_hashref;
}

sub consume_password_reset {
    my ($token) = @_;
    my $dbh = dbh();
    $dbh->do('UPDATE password_resets SET consumed = TRUE WHERE token = ?', undef, $token);
}

sub update_user_password {
    my ($user_id, $password_hash, $salt) = @_;
    my $dbh = dbh();
    $dbh->do('UPDATE users SET password_hash = ?, salt = ? WHERE id = ?', undef, $password_hash, $salt, $user_id);
}

sub create_subscription {
    my ($user_id, $plan_type, $price, $currency) = @_;
    $currency ||= 'RON';
    my $dbh = dbh();
    my $sth = $dbh->prepare('INSERT INTO subscriptions (user_id, plan_type, price, currency, status) VALUES (?, ?, ?, ?, ?)');
    $sth->execute($user_id, $plan_type, $price, $currency, 'pending');
    return $dbh->last_insert_id(undef, undef, 'subscriptions', 'id');
}

sub create_payment {
    my ($user_id, $subscription_id, $amount, $currency, $stripe_session_id) = @_;
    $currency ||= 'usd';
    my $dbh = dbh();
    my $sth = $dbh->prepare('INSERT INTO payments (user_id, subscription_id, amount, currency, stripe_session_id, status) VALUES (?, ?, ?, ?, ?, ?)');
    $sth->execute($user_id, $subscription_id, $amount, $currency, $stripe_session_id, 'pending');
    return $dbh->last_insert_id(undef, undef, 'payments', 'id');
}

sub update_payment_status {
    my ($stripe_session_id, $status, $payment_data, $error_message) = @_;
    my $dbh = dbh();
    
    # Update payment
    $dbh->do('UPDATE payments SET status = ?, payment_data = ?, error_message = ?, updated_at = NOW() WHERE stripe_session_id = ?',
        undef, $status, $payment_data, $error_message, $stripe_session_id);
    
    # If payment completed, activate subscription
    if ($status eq 'completed') {
        my $sth = $dbh->prepare('SELECT subscription_id FROM payments WHERE stripe_session_id = ?');
        $sth->execute($stripe_session_id);
        my $row = $sth->fetchrow_hashref;
        
        if ($row && $row->{subscription_id}) {
            $dbh->do('UPDATE subscriptions SET status = ?, start_date = NOW(), end_date = DATE_ADD(NOW(), INTERVAL 1 MONTH) WHERE id = ?',
                undef, 'active', $row->{subscription_id});
        }
    }
    
    return 1;
}

sub get_user_subscription {
    my ($user_id) = @_;
    my $dbh = dbh();
    my $sth = $dbh->prepare('SELECT * FROM subscriptions WHERE user_id = ? AND status = ? AND end_date > NOW() ORDER BY end_date DESC LIMIT 1');
    $sth->execute($user_id, 'active');
    return $sth->fetchrow_hashref;
}

sub create_stripe_checkout_session {
    my ($user_id, $subscription_id, $plan_type, $amount, $currency) = @_;
    $currency ||= 'usd';
    
    use LWP::UserAgent;
    use JSON;
    use HTTP::Request;
    
    # Read Stripe key from environment
    my $stripe_key = $ENV{STRIPE_SECRET_KEY} || $STRIPE_SECRET_KEY;
    
    # Return error if no API key
    return (0, undef, 'Stripe API key not configured') unless $stripe_key;
    
    my $base_url = $ENV{APP_BASE_URL} || 'http://localhost:8080';
    
    my $ua = LWP::UserAgent->new(timeout => 30);
    my $request = HTTP::Request->new(POST => 'https://api.stripe.com/v1/checkout/sessions');
    $request->authorization_basic($stripe_key, '');
    $request->header('Content-Type' => 'application/x-www-form-urlencoded');
    
    # Convert amount to cents for Stripe
    my $amount_cents = int($amount * 100);
    
    my $content = "mode=payment";
    $content .= "&success_url=$base_url/payment/confirm.html?session_id={CHECKOUT_SESSION_ID}";
    $content .= "&cancel_url=$base_url/payment/checkout.html?plan=$plan_type";
    $content .= "&line_items[0][price_data][currency]=$currency";
    $content .= "&line_items[0][price_data][product_data][name]=PropertySite " . ucfirst($plan_type) . " Plan";
    $content .= "&line_items[0][price_data][unit_amount]=$amount_cents";
    $content .= "&line_items[0][quantity]=1";
    $content .= "&client_reference_id=$user_id";
    $content .= "&metadata[user_id]=$user_id";
    $content .= "&metadata[subscription_id]=$subscription_id";
    $content .= "&metadata[plan_type]=$plan_type";
    
    $request->content($content);
    
    my $response = $ua->request($request);
    
    if ($response->is_success) {
        my $result = decode_json($response->content);
        return (1, $result->{id}, $result->{url});
    } else {
        return (0, undef, $response->status_line);
    }
}

sub verify_stripe_signature {
    my ($payload, $sig_header) = @_;
    use Digest::SHA qw(hmac_sha256_hex);
    
    return 0 unless $sig_header && $STRIPE_WEBHOOK_SECRET;
    
    # Parse signature header
    my %sig_parts;
    foreach my $part (split /,/, $sig_header) {
        my ($key, $value) = split /=/, $part, 2;
        $sig_parts{$key} = $value;
    }
    
    my $timestamp = $sig_parts{t};
    my $signature = $sig_parts{v1};
    
    return 0 unless $timestamp && $signature;
    
    # Verify timestamp is recent (within 5 minutes)
    my $current_time = time();
    return 0 if abs($current_time - $timestamp) > 300;
    
    # Compute expected signature
    my $signed_payload = "$timestamp.$payload";
    my $expected = hmac_sha256_hex($signed_payload, $STRIPE_WEBHOOK_SECRET);
    
    return $signature eq $expected;
}

sub get_stripe_session {
    my ($session_id) = @_;
    
    use LWP::UserAgent;
    use JSON;
    use HTTP::Request;
    
    my $stripe_key = $ENV{STRIPE_SECRET_KEY} || $STRIPE_SECRET_KEY;
    return undef unless $stripe_key;
    
    my $ua = LWP::UserAgent->new(timeout => 10);
    my $request = HTTP::Request->new(GET => "https://api.stripe.com/v1/checkout/sessions/$session_id");
    $request->authorization_basic($stripe_key, '');
    
    my $response = $ua->request($request);
    
    if ($response->is_success) {
        return decode_json($response->content);
    }
    
    return undef;
}

sub format_date_ro {
    my ($date) = @_;
    
    return '' unless defined $date && $date ne '';
    
    my @months = ('', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie', 'Mai', 'Iunie',
                  'Iulie', 'August', 'Septembrie', 'Octombrie', 'Noiembrie', 'Decembrie');
    
    # Parse MySQL TIMESTAMP format: 2026-02-01 14:30:00
    if ($date =~ /^(\d{4})-(\d{2})-(\d{2})/) {
        my ($year, $month, $day) = ($1, $2, $3);
        $day =~ s/^0//;  # Remove leading zero
        my $month_name = $months[int($month)];
        return "$day $month_name $year";
    }
    
    return $date;
}

1;
