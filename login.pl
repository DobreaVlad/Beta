#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(dbh verify_password create_session get_user_by_session);

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

if ($q->request_method eq 'GET') {
    print_html_form();
    exit;
}

# POST: process login
my $username = $q->param('username') // '';
my $password = $q->param('password') // '';

if ($username eq '' || $password eq '') {
    print_error('Please provide both username and password');
}

my $dbh = dbh();
my $sth = $dbh->prepare('SELECT id, username, password_hash, salt FROM users WHERE username = ?');
$sth->execute($username);
my $user = $sth->fetchrow_hashref;

unless ($user) {
    print_error('Invalid username or password');
}

unless (verify_password($password, $user->{password_hash}, $user->{salt})) {
    print_error('Invalid username or password');
}

# create session
my $session_id = create_session($user->{id});

# set cookie and redirect
my $cookie = cookie(-name => 'SESSION', -value => $session_id, -path => '/', -expires => '+7d', -httponly => 1);
print $q->redirect(-uri => '/', -cookie => $cookie);

sub print_html_form {
    print <<HTML;
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Login</title>
  <link rel="stylesheet" href="/public/css/styles.css">
</head>
<body>
  <header class="site-header"><h1>Login</h1></header>
  <main>
    <form method="post" action="/login.pl">
      <label>Username: <input type="text" name="username"></label><br>
      <label>Password: <input type="password" name="password"></label><br>
      <button type="submit">Login</button>
    </form>
    <p><a href="/register.pl">Register</a></p>
  </main>
</body>
</html>
HTML
}

sub print_error {
    my ($msg) = @_;
    print <<HTML;
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Login Error</title></head>
<body>
  <p style="color:red">$msg</p>
  <p><a href="/login.pl">Back to login</a></p>
</body>
</html>
HTML
    exit;
}
