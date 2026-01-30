#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard -utf8);
use lib 'lib';
use Config qw(dbh delete_session);

my $q = CGI->new;
my $cookie = cookie('SESSION') || '';
if ($cookie) {
    delete_session($cookie);
}
print $q->header(-type=>'text/html', -charset=>'utf-8', -cookie => cookie(-name=>'SESSION', -value=>'', -path=>'/', -expires=>'-1d'));
print <<HTML;
<!doctype html>
<html><head><meta charset="utf-8"><title>Logged out</title></head>
<body>
  <p>You are logged out. <a href="/">Return home</a></p>
</body></html>
HTML
