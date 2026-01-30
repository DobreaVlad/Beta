# Basic Perl Website (CGI + MySQL)

This project is a very small demo of a website written in Perl using simple CGI scripts and MySQL as storage.

Files created:
- `index.pl` — homepage (CGI)
- `login.pl`, `register.pl`, `logout.pl` — auth scripts
- `reset_request.pl`, `reset.pl` — password reset flow (email + token)
- `lib/Config.pm` — DB and helper functions (edit DB credentials and SMTP settings)
- `public/css/styles.css`, `public/js/app.js` — static assets
- `sql/create_tables.sql` — tables for users, sessions, and password resets


SMTP & password reset
- The registration flow now collects **email**; it's required for password resets.
- Configure SMTP settings in `lib/Config.pm` (`$SMTP_HOST`, `$SMTP_PORT`, `$SMTP_USER`, `$SMTP_PASS`, `$SMTP_FROM`).
- For local dev, leaving `$SMTP_HOST` empty or unset will show a dev reset link on the reset request page if sending fails.

Setup
1. Install Perl (Strawberry Perl on Windows is easiest) and these modules (CPAN):
   - DBI
   - DBD::mysql
   - Digest::SHA
   - MIME::Base64
   - Authen::Passphrase::BlowfishCrypt   # for bcrypt password hashing
   - HTTP::Server::Simple::CGI          # for running the dev server

   Example (Strawberry Perl):
     cpan DBI DBD::mysql Digest::SHA MIME::Base64 Authen::Passphrase::BlowfishCrypt HTTP::Server::Simple::CGI

2. Create a MySQL database and run `sql/create_tables.sql`.
3. Edit `lib/Config.pm` and set `$DB_NAME`, `$DB_USER`, `$DB_PASS` to match your DB, or use Docker (recommended).

Docker (production-like) setup (recommended)
1. Generate self-signed certs for nginx (dev only):
   - `sh docker/generate_certs.sh`
2. Build and start services:
   - `docker-compose up --build`

Services included in Docker Compose:
- `db` — MySQL 8.0 (accessible to the `web` service)
- `web` — Apache + Perl, serves your CGI scripts on port `8080` by default
- `mailhog` — captures outgoing emails (SMTP on 1025; UI on http://localhost:8025)
- `nginx` — reverse proxy with HTTPS (self-signed certs; HTTPS on `8443` and HTTP on `80`)

Accessing the site:
- HTTP: http://localhost:8080/ (direct to Apache)
- HTTPS through nginx: https://localhost:8443/ (accept the self-signed cert in your browser)

Notes:
- The web container reads DB and SMTP configuration from environment variables (set in `docker-compose.yml` or via an `.env` file).
- After containers are up, run the DB migration: `docker exec -it <compose_project>_db_1 mysql -u root -p myapp < sql/create_tables.sql` (use the root password set in `docker-compose.yml`).

WSL: install Docker Engine inside your distro (optional)
- A helper script is provided at `scripts/install-docker-wsl.sh` to install Docker Engine and the Compose plugin inside an Ubuntu-based WSL distro.
- Usage (from inside WSL):
  1. `bash scripts/install-docker-wsl.sh`
  2. Log out and back in (or run `newgrp docker`) so your user is in the `docker` group.
  3. Verify: `docker version` and `docker compose version`.
- Note: many users prefer Docker Desktop for Windows + WSL integration because it manages the Docker daemon for you and provides an easier experience. If you encounter daemon/startup issues inside WSL, consider using Docker Desktop instead.

Security notes
- This is a minimal example. For production, use HTTPS, stronger session management, CSRF protection, rate-limits, and more secure password hashing (e.g., Argon2 or bcrypt via modules).

Enjoy! ✨
