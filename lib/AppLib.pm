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
);

# Database configuration
my $DB_HOST = $ENV{DB_HOST} || 'db';
my $DB_NAME = $ENV{DB_NAME} || 'myapp';
my $DB_USER = $ENV{DB_USER} || 'root';
my $DB_PASS = $ENV{DB_PASS} || '';

# SMTP configuration
my $SMTP_HOST = $ENV{SMTP_HOST} || 'localhost';
my $SMTP_PORT = $ENV{SMTP_PORT} || 1025;
my $SMTP_FROM = $ENV{SMTP_FROM} || 'noreply@example.com';

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
    my ($username, $password_hash, $salt, $email) = @_;
    my $dbh = dbh();
    eval {
        $dbh->do('INSERT INTO users (username, email, password_hash, salt) VALUES (?, ?, ?, ?)',
            undef, $username, $email, $password_hash, $salt);
    };
    if ($@) {
        return { ok => 0, error => 'Username or email already exists' };
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

1;
