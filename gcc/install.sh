#!/bin/bash

set -euo pipefail

########################################
# check.sh, log.sh 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

TARGET_USER="${SUDO_USER:-$USER}"

check_root

if ! confirm "Install GCC?"; then
    log_info "Install cancelled."
    exit 0
fi

if command -v gcc >/dev/null 2>&1; then
    log_info "GCC is already installed."
    exit 0
fi

log_step "[1/2] Updating package index..."
apt-get update

log_step "[2/2] Installing GCC..."

apt-get install -y \
    gcc

echo
print_separator
log_success "GCC installation completed successfully."
gcc --version
echo
print_separator