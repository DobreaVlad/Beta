FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache and build tools for DBD::mysql
RUN apt-get update \
  && apt-get install -y apache2 libapache2-mod-perl2 default-libmysqlclient-dev build-essential cpanminus libssl-dev wget openssl \
  && a2dismod mpm_event \
  && a2enmod mpm_prefork perl \
  && rm -rf /var/lib/apt/lists/*

# Install Perl modules (may take time)
RUN cpanm --notest DBI DBD::mysql Authen::Passphrase::BlowfishCrypt Net::SMTP CGI HTML::Mason HTML::Mason::ApacheHandler \
    LWP::UserAgent LWP::Protocol::https JSON Digest::HMAC_SHA1 HTTP::Request || true

# Apache vhost
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy site into web root
COPY . /var/www/html/
COPY mason /var/www/mason/
RUN chown -R www-data:www-data /var/www/html /var/www/mason \
    && find /var/www/html -name "*.pl" -exec chmod +x {} \; \
    && mkdir -p /tmp/mason_data \
    && mkdir -p /var/www/html/logs \
    && chown www-data:www-data /tmp/mason_data /var/www/html/logs

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
