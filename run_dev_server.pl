#!/usr/bin/perl
use strict;
use warnings;
use FindBin;
use HTTP::Server::Simple::CGI;
use File::Spec;
use Cwd qw(getcwd);

{
    package MyWebServer;
    use base qw(HTTP::Server::Simple::CGI);

    sub handle_request {
        my ($self, $cgi) = @_;
        my $path = $cgi->path_info || '/';
        $path =~ s{^/}{};
        $path = 'index.pl' if $path eq '';
        my $root = $FindBin::Bin;
        my $full = File::Spec->catfile($root, $path);

        if (-f $full && $full =~ /\.pl$/i) {
            # Execute the .pl using the perl interpreter and stream output
            open my $fh, '-|', $^X, $full or do { print "HTTP/1.0 500 Internal Server Error\r\n\r\n"; return; };
            while (<$fh>) { print $_ }
            close $fh;
            return;
        } elsif (-f $full) {
            my $mime = 'text/plain';
            $mime = 'text/html' if $full =~ /\.html?$/i;
            $mime = 'text/css' if $full =~ /\.css$/i;
            $mime = 'application/javascript' if $full =~ /\.js$/i;
            print "HTTP/1.0 200 OK\r\n";
            print "Content-Type: $mime\r\n\r\n";
            open my $fh, '<', $full; print while <$fh>; close $fh;
            return;
        } else {
            print "HTTP/1.0 404 Not Found\r\n\r\nNot Found\n";
        }
    }
}

my $port = shift || 8080;
print "Starting dev server on http://localhost:$port\n";
MyWebServer->new($port)->run();
