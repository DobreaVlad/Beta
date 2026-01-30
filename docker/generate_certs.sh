#!/bin/sh
set -e
mkdir -p docker/nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout docker/nginx/certs/dev.key -out docker/nginx/certs/dev.crt -subj "/C=US/ST=Dev/L=Dev/O=Dev/OU=Dev/CN=localhost"
chown --reference=docker/nginx docker/nginx/certs || true
echo "Generated self-signed certs at docker/nginx/certs/"