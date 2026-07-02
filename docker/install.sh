#!/bin/bash

set -euo pipefail

TARGET_USER="${SUDO_USER:-$USER}"

if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Please run this script as root."
    exit 1
fi

if command -v docker >/dev/null 2>&1; then
    echo "[INFO] Docker is already installed."
    exit 0
fi

echo "[1/6] Updating package index..."
apt-get update

echo "[2/6] Installing dependencies..."
apt-get install -y \
    ca-certificates \
    curl

echo "[3/6] Adding Docker repository..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

echo "[4/6] Installing Docker..."

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo "[5/6] Starting Docker service..."

systemctl enable docker
systemctl start docker

echo "[6/6] Verifying installation..."

docker run hello-world

docker container prune -f >/dev/null
docker image rm hello-world >/dev/null 2>&1 || true

usermod -aG docker "$TARGET_USER"

echo
echo "========================================="
echo "Docker installation completed successfully."
docker --version
docker compose version
echo
echo "User '$TARGET_USER' has been added to the docker group."
echo "Please log out and log back in to use Docker without sudo."
echo "========================================="
