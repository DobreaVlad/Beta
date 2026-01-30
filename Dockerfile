FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache and build tools for DBD::mysql
RUN apt-get update \
  && apt-get install -y apache2 libapache2-mod-perl2 default-libmysqlclient-dev build-essential cpanminus libssl-dev wget openssl \
  && a2enmod cgi rewrite headers \
  && rm -rf /var/lib/apt/lists/*

# Install Perl modules (may take time)
RUN cpanm --notest DBI DBD::mysql Authen::Passphrase::BlowfishCrypt Net::SMTP || true

# Apache vhost
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy site into web root
COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -name "*.pl" -exec chmod +x {} \;

EXPOSE 80
CMD ["apachectl", "-D", "FOREGROUND"]
