#!/usr/bin/perl
use strict;
use warnings;
use lib '/var/www/html/lib';

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Const -compile => qw(OK);

use HTML::Mason::ApacheHandler;

my $ah = HTML::Mason::ApacheHandler->new(
    comp_root => '/var/www/mason',
    data_dir  => '/tmp/mason_data',
);

sub handler {
    my ($r) = @_;
    return $ah->handle_request($r);
}

1;
