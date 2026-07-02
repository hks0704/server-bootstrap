#!/bin/bash

set -euo pipefail

########################################
# log.sh, check.sh 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"

check_root

########################################
# 이미 설치되어 있는지 확인
########################################
if command -v git >/dev/null 2>&1; then
    log_info "Git is already installed."
    git --version
    exit 0
fi

########################################
# Git 설치
########################################
log_step "[1/3] Updating package index..."
apt-get update

log_step "[2/3] Installing Git..."
apt-get install -y git

########################################
# 설치 확인
########################################
log_step "[3/3] Verifying installation..."

if ! command -v git >/dev/null 2>&1; then
    log_error "Git installation failed."
    exit 1
fi

echo
echo "========================================="
log_success "Git installation completed successfully."
git --version
echo "========================================="
