#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(dbh hash_password create_user);

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

if ($q->request_method eq 'GET') {
    print_form();
    exit;
}

# POST: register
my $username = $q->param('username') // '';
my $email = $q->param('email') // '';
my $password = $q->param('password') // '';

if ($username eq '' || $password eq '' || $email eq '') {
    return print_error('Please provide username, email, and password');
}

my ($password_hash, $salt) = hash_password($password);

my $dbh = dbh();
my $res = create_user($username, $password_hash, $salt, $email);
if ($res->{ok}) {
    print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Registered</title></head>
<body>
  <p>Registration successful. <a href="/login.pl">Login</a></p>
</body></html>
HTML
} else {
    print_error($res->{error} || 'Registration failed');
}

sub print_form {
    print <<HTML;
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Register</title>
  <link rel="stylesheet" href="/public/css/styles.css">
</head>
<body>
  <header class="site-header"><h1>Register</h1></header>
  <main>
    <form method="post" action="/register.pl">
      <label>Username: <input type="text" name="username"></label><br>
      <label>Email: <input type="email" name="email"></label><br>
      <label>Password: <input type="password" name="password"></label><br>
      <button type="submit">Register</button>
    </form>
    <p><a href="/login.pl">Login</a></p>
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
<head><meta charset="utf-8"><title>Register Error</title></head>
<body>
  <p style="color:red">$msg</p>
  <p><a href="/register.pl">Back to register</a></p>
</body>
</html>
HTML
    exit;
}
