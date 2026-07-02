#!/bin/bash

set -euo pipefail

########################################
# log.sh 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"

########################################
# 안전장치
########################################
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root."
    exit 1
fi

echo

log_step "Docker Uninstall"

log_warn "This will remove ALL Docker Systems."
log_warn "This action is NOT reversible."

# 1. Docker 서비스 중지
log_step "[1/6] Docker 서비스 중지"
sudo systemctl stop docker || true
sudo systemctl stop docker.socket || true

# 2. Docker 패키지 제거 (engine + cli + containerd)
log_step "[2/6] Docker 패키지 제거"
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io || true

# 3. 불필요 패키지 정리
log_step "[3/6] autoremove"
sudo apt-get autoremove -y

# 4. Docker 관련 디렉토리 완전 삭제 (핵심)
log_step "[4/6] 데이터 디렉토리 삭제"
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker

# 5. 사용자 설정 및 socket 제거
log_step "[5/6] 설정/소켓 제거"
sudo rm -rf /var/run/docker.sock

# 6. systemd 데몬 리로드
log_step "[6/6] systemd 리로드"
sudo systemctl daemon-reload
sudo systemctl reset-failed || true

log_success "== Docker 완전 초기화 완료 =="
log_info "이제 install.sh 다시 실행 가능"
