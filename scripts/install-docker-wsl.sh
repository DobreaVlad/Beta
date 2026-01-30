#!/usr/bin/env bash
set -euo pipefail

# install-docker-wsl.sh
# Installs Docker Engine + Compose plugin inside an Ubuntu-based WSL distro.
# Usage: sudo ./scripts/install-docker-wsl.sh

if ! grep -qi "microsoft" /proc/sys/kernel/osrelease 2>/dev/null && ! grep -qi "microsoft" /proc/version 2>/dev/null; then
  echo "This script is intended to be run inside WSL (Ubuntu). Aborting."
  exit 1
fi

echo "Updating package lists and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https

echo "Adding Docker's official GPG key and repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "Installing docker engine, cli, containerd and compose plugin..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "Adding current user ($USER) to 'docker' group..."
sudo usermod -aG docker "$USER" || true

echo "You may need to log out and back in or run: 'newgrp docker' to use Docker without sudo."

# Try to enable/start service if systemd is available
if command -v systemctl >/dev/null 2>&1 && systemctl --version >/dev/null 2>&1; then
  echo "Attempting to enable and start docker.service via systemctl..."
  sudo systemctl enable --now docker || echo "systemctl failed to start docker — if your WSL doesn't support systemd, see notes below."
else
  echo "systemd not available in this WSL distro. To run the Docker daemon manually, run:"
  echo "  sudo dockerd &"
fi

# Add alias if not present
if ! grep -q "alias dc=" "$HOME/.bashrc" 2>/dev/null; then
  echo "Adding alias 'dc' to ~/.bashrc"
  echo "alias dc='docker compose'" >> "$HOME/.bashrc"
  # shellcheck disable=SC1090
  source "$HOME/.bashrc" || true
fi

cat <<'EOF'

Done.
Verify the installation:
  docker version
  docker compose version

If Docker commands fail due to permissions, run:
  newgrp docker
or log out and log back in.

Note: For a smoother WSL experience, Docker Desktop for Windows with WSL integration is recommended — it provides a daemon that WSL can use without manual daemon management.
EOF
