#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(dbh create_password_reset send_email);

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

if ($q->request_method eq 'GET') {
    print_form();
    exit;
}

my $email = $q->param('email') // '';
if ($email eq '') {
    print_error('Please provide your email address');
}

my $dbh = dbh();
my $sth = $dbh->prepare('SELECT id, username FROM users WHERE email = ? LIMIT 1');
$sth->execute($email);
my $user = $sth->fetchrow_hashref;

# Always show the same message to avoid account enumeration
my $base = $q->url(-base=>1);
if ($user) {
    my $token = create_password_reset($user->{id});
    my $link = $base . '/reset.pl?token=' . $token;
    my ($ok, $err) = send_email($email, 'Password reset', "Hello $user->{username},\n\nYou can reset your password using the following link (valid for 1 hour):\n\n$link\n\nIf you didn't request this, ignore this email.");
    # If sending failed, show dev link so you can test locally
    if (!$ok) {
        print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Password reset</title></head>
<body>
  <p>If the account exists, an email has been sent with reset instructions.</p>
  <p><strong>DEV NOTE:</strong> Email sending failed ($err). Use this link to reset: <a href="$link">$link</a></p>
</body></html>
HTML
        exit;
    }
}

print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Password reset</title></head>
<body>
  <p>If the account exists, an email has been sent with reset instructions.</p>
</body></html>
HTML

sub print_form {
    print <<HTML;
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Request password reset</title></head>
<body>
  <h1>Password reset</h1>
  <form method="post" action="/reset_request.pl">
    <label>Email: <input type="email" name="email"></label><br>
    <button type="submit">Request reset</button>
  </form>
</body>
</html>
HTML
}

sub print_error {
    my ($msg) = @_;
    print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Error</title></head>
<body>
  <p style="color:red">$msg</p>
  <p><a href="/reset_request.pl">Back</a></p>
</body>
</html>
HTML
    exit;
}
