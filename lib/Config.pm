package Config;
use strict;
use warnings;
use DBI;
use Digest::SHA qw(sha256_hex);
use Authen::Passphrase::BlowfishCrypt;
use Time::Piece;
use Time::HiRes qw(gettimeofday);
use MIME::Base64 qw(encode_base64);
use Net::SMTP;

use Exporter 'import';
our @EXPORT_OK = qw(dbh hash_password verify_password create_session get_user_by_session create_user update_user_password delete_session create_password_reset get_user_by_reset_token consume_password_reset send_email);

# EDIT THESE (or use environment variables in Docker)
my $DB_NAME = $ENV{DB_NAME} || 'myapp';
my $DB_HOST = $ENV{DB_HOST} || '127.0.0.1';
my $DB_USER = $ENV{DB_USER} || 'root';
my $DB_PASS = $ENV{DB_PASS} || '';

# SMTP settings for password reset emails (use MailHog in Docker)
my $SMTP_HOST = $ENV{SMTP_HOST} || '';
my $SMTP_PORT = $ENV{SMTP_PORT} || 25;
my $SMTP_USER = $ENV{SMTP_USER} || '';
my $SMTP_PASS = $ENV{SMTP_PASS} || '';
my $SMTP_FROM = $ENV{SMTP_FROM} || 'no-reply@localhost';

sub dbh {
    my $dbh = DBI->connect("DBI:mysql:database=$DB_NAME;host=$DB_HOST", $DB_USER, $DB_PASS, { RaiseError => 1, PrintError => 0, mysql_enable_utf8 => 1 });
    return $dbh;
}

sub hash_password {
    my ($password) = @_;
    # Use bcrypt via Authen::Passphrase::BlowfishCrypt
    my $p = Authen::Passphrase::BlowfishCrypt->new(cost => 8, passphrase => $password);
    my $crypt = $p->as_crypt; # format like $2a$..
    return ($crypt, ''); # salt column is unused when storing bcrypt crypt string
}

sub verify_password {
    my ($password, $hash, $salt) = @_;
    return 0 unless $hash;
    my $ok = 0;
    eval {
        my $p = Authen::Passphrase::BlowfishCrypt->from_crypt($hash);
        $ok = $p->match($password);
    };
    return $ok;
}

sub create_user {
    my ($username, $password_hash, $salt, $email) = @_;
    my $dbh = dbh();
    eval {
        my $sth = $dbh->prepare('INSERT INTO users (username, email, password_hash, salt, created_at) VALUES (?, ?, ?, ?, NOW())');
        $sth->execute($username, $email, $password_hash, $salt);
    };
    if ($@) {
        return { ok => 0, error => $@ };
    }
    return { ok => 1 };
}

sub create_session {
    my ($user_id) = @_;
    my $session_id = sha256_hex(time . rand . $$ . gettimeofday() . int(rand(1_000_000)));
    my $expires = Time::Piece->new()->add_days(7)->strftime('%Y-%m-%d %H:%M:%S');
    my $dbh = dbh();
    my $sth = $dbh->prepare('INSERT INTO sessions (session_id, user_id, expires_at) VALUES (?, ?, ?)');
    $sth->execute($session_id, $user_id, $expires);
    return $session_id;
}

sub get_user_by_session {
    my ($session_id) = @_;
    return unless $session_id;
    my $dbh = dbh();
    my $sth = $dbh->prepare('SELECT u.id, u.username FROM users u JOIN sessions s ON u.id = s.user_id WHERE s.session_id = ? AND s.expires_at > NOW() LIMIT 1');
    $sth->execute($session_id);
    my $user = $sth->fetchrow_hashref;
    return $user;
}

sub delete_session {
    my ($session_id) = @_;
    return unless $session_id;
    my $dbh = dbh();
    my $sth = $dbh->prepare('DELETE FROM sessions WHERE session_id = ?');
    $sth->execute($session_id);
}

sub update_user_password {
    my ($user_id, $password_hash, $salt) = @_;
    my $dbh = dbh();
    my $sth = $dbh->prepare('UPDATE users SET password_hash = ?, salt = ? WHERE id = ?');
    $sth->execute($password_hash, $salt, $user_id);
    return 1;
}

sub create_password_reset {
    my ($user_id) = @_;
    my $token = sha256_hex(time . rand . $$ . gettimeofday() . int(rand(1_000_000)));
    my $expires = Time::Piece->new(time + 3600)->strftime('%Y-%m-%d %H:%M:%S'); # 1 hour
    my $dbh = dbh();
    my $sth = $dbh->prepare('INSERT INTO password_resets (user_id, token, expires_at, used, created_at) VALUES (?, ?, ?, 0, NOW())');
    $sth->execute($user_id, $token, $expires);
    return $token;
}

sub get_user_by_reset_token {
    my ($token) = @_;
    return unless $token;
    my $dbh = dbh();
    my $sth = $dbh->prepare('SELECT u.id, u.username, u.email FROM users u JOIN password_resets r ON u.id = r.user_id WHERE r.token = ? AND r.expires_at > NOW() AND r.used = 0 LIMIT 1');
    $sth->execute($token);
    my $user = $sth->fetchrow_hashref;
    return $user;
}

sub consume_password_reset {
    my ($token) = @_;
    return unless $token;
    my $dbh = dbh();
    my $sth = $dbh->prepare('UPDATE password_resets SET used = 1 WHERE token = ?');
    $sth->execute($token);
}

sub send_email {
    my ($to, $subject, $body) = @_;
    eval {
        my $smtp = Net::SMTP->new(($SMTP_HOST || 'localhost'), Port => ($SMTP_PORT || 25), Timeout => 30) or die "SMTP connect failed";
        if ($SMTP_USER && $SMTP_PASS) {
            $smtp->auth($SMTP_USER, $SMTP_PASS) or die "SMTP auth failed";
        }
        $smtp->mail($SMTP_FROM || 'no-reply@localhost');
        $smtp->to($to);
        $smtp->data();
        $smtp->datasend("From: " . ($SMTP_FROM || 'no-reply@localhost') . "\n");
        $smtp->datasend("To: $to\n");
        $smtp->datasend("Subject: $subject\n\n");
        $smtp->datasend($body);
        $smtp->dataend();
        $smtp->quit;
    };
    if ($@) {
        warn "send_email failed: $@";
        return (0, $@);
    }
    return (1);
}

1;
