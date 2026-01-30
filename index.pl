#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(get_user_by_session);

my $q = CGI->new;
print $q->header(-type=>'text/html', -charset=>'utf-8');

# check session cookie
my $session_cookie = cookie('SESSION') || '';
my $user = get_user_by_session($session_cookie);

my $nav;
if ($user) {
    $nav = "<a href=\"/\">Home</a> | <a href=\"/logout.pl\">Logout</a>";
} else {
    $nav = "<a href=\"/\">Home</a> | <a href=\"/login.pl\">Login</a> | <a href=\"/register.pl\">Register</a>";
}

my $user_html = $user ? "<p>Logged in as " . escapeHTML($user->{username}) . "</p>" : "<p>Please <a href=\"/login.pl\">login</a>.</p>";

print <<HTML;
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>My Perl Website</title>
  <link rel="stylesheet" href="/public/css/styles.css">
  <script src="/public/js/app.js"></script>
</head>
<body>
  <header class="site-header">
    <h1><a href="/">My Perl Website</a></h1>
    <nav>$nav</nav>
  </header>
  <main>
    <h2>Welcome</h2>
    <p>This is a simple homepage powered by CGI scripts in Perl.</p>
    $user_html
  </main>
  <footer>
    <p>&copy; My Perl Website</p>
  </footer>
</body>
</html>
HTML
