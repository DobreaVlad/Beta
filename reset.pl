#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(dbh get_user_by_reset_token consume_password_reset hash_password update_user_password);

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

if ($q->request_method eq 'GET') {
    my $token = $q->param('token') // '';
    unless ($token && get_user_by_reset_token($token)) {
        print_invalid();
        exit;
    }
    print_form($token);
    exit;
}

# POST: perform reset
my $token = $q->param('token') // '';
my $password = $q->param('password') // '';
my $password2 = $q->param('password2') // '';

unless ($token && $password && $password eq $password2) {
    print_error('Token invalid or passwords do not match');
}

my $user = get_user_by_reset_token($token);
unless ($user) { print_invalid(); }

my ($password_hash, $salt) = hash_password($password);
update_user_password($user->{id}, $password_hash, $salt);
consume_password_reset($token);

print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Reset complete</title></head>
<body>
  <p>Your password has been updated. <a href="/login.pl">Login</a></p>
</body>
</html>
HTML

sub print_form {
    my ($token) = @_;
    print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Reset password</title></head>
<body>
  <h1>Reset password</h1>
  <form method="post" action="/reset.pl">
    <input type="hidden" name="token" value="$token">
    <label>New password: <input type="password" name="password"></label><br>
    <label>Confirm: <input type="password" name="password2"></label><br>
    <button type="submit">Set password</button>
  </form>
</body>
</html>
HTML
}

sub print_invalid {
    print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Invalid token</title></head>
<body>
  <p>Invalid or expired token. <a href="/reset_request.pl">Request a new one</a></p>
</body>
</html>
HTML
    exit;
}

sub print_error {
    my ($msg) = @_;
    print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Error</title></head>
<body>
  <p style="color:red">$msg</p>
</body>
</html>
HTML
    exit;
}