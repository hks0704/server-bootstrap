#!/bin/bash

set -euo pipefail

########################################
# common utils 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

echo
log_step "Docker Cleanup Utility"

log_warn "This will remove ALL Docker containers, images, volumes, and networks."
log_warn "This action is NOT reversible."

# read -p "Type 'yes' to continue: " CONFIRM

# if [[ "$CONFIRM" != "yes" ]]; then
#     log_info "Cleanup cancelled."
#     exit 0
# fi

if ! confirm "Install Docker?"; then
    exit 0
fi

########################################
# 1. 컨테이너 전체 정리
########################################
log_step "[1/4] Stopping and removing all containers"

if [[ -n "$(docker ps -aq)" ]]; then
    docker stop $(docker ps -aq) >/dev/null 2>&1 || true
    docker rm -f $(docker ps -aq) >/dev/null 2>&1 || true
    log_success "All containers removed"
else
    log_info "No containers to remove"
fi

########################################
# 2. 이미지 정리
########################################
log_step "[2/4] Removing all images"

if [[ -n "$(docker images -q)" ]]; then
    docker rmi -f $(docker images -q) >/dev/null 2>&1 || true
    log_success "All images removed"
else
    log_info "No images to remove"
fi

########################################
# 3. 볼륨 정리
########################################
log_step "[3/4] Removing all volumes"

if [[ -n "$(docker volume ls -q)" ]]; then
    docker volume rm -f $(docker volume ls -q) >/dev/null 2>&1 || true
    log_success "All volumes removed"
else
    log_info "No volumes to remove"
fi

########################################
# 4. 네트워크 정리 (bridge 제외)
########################################
log_step "[4/4] Removing custom networks"

NETWORKS=$(docker network ls --format "{{.Name}}" | grep -v "bridge\|host\|none" || true)

if [[ -n "$NETWORKS" ]]; then
    echo "$NETWORKS" | while read -r net; do
        docker network rm "$net" >/dev/null 2>&1 || true
        log_info "Removed network: $net"
    done
    log_success "Custom networks removed"
else
    log_info "No custom networks to remove"
fi

########################################
# 완료
########################################
echo
log_success "Docker cleanup completed successfully"
log_info "System is now in clean state"
