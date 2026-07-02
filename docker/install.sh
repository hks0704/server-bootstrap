#!/bin/bash

set -euo pipefail

########################################
# check.sh, log.sh 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"

TARGET_USER="${SUDO_USER:-$USER}"

check_root

if command -v docker >/dev/null 2>&1; then
    log_info "Docker is already installed."
    exit 0
fi

log_step "[1/6] Updating package index..."
apt-get update

log_step "[2/6] Installing dependencies..."
apt-get install -y \
    ca-certificates \
    curl

log_step "[3/6] Adding Docker repository..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

log_step "[4/6] Installing Docker..."

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

log_step "[5/6] Starting Docker service..."

systemctl enable docker
systemctl start docker

log_step "[6/6] Verifying installation..."

docker run hello-world

docker container prune -f >/dev/null
docker image rm hello-world >/dev/null 2>&1 || true

usermod -aG docker "$TARGET_USER"

echo
echo "========================================="
log_success "Docker installation completed successfully."
docker --version
docker compose version
echo
log_info "User '$TARGET_USER' has been added to the docker group."
echo "Please log out and log back in to use Docker without sudo."
echo "========================================="
