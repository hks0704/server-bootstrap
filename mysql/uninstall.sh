#!/bin/bash

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

echo

log_step "MySQL Uninstall"

log_warn "This will remove ALL MySQL Database Systems."
log_warn "This action is NOT reversible."

if ! confirm "Uninstall MySQL?"; then
    log_info "Uninstall cancelled."
    exit 0
fi

log_step "MySQL 클린 삭제를 시작합니다..."

log_info "MySQL 서비스 중지..."
sudo systemctl stop mysql

log_info "MySQL 패키지 및 관련 패키지 제거..."
sudo apt-get remove --purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo apt-get autoremove -y
sudo apt-get autoclean -y

log_info "MySQL 설정 파일 및 데이터베이스 디렉토리 삭제"
sudo rm -rf /etc/mysql /var/lib/mysql

log_info "MySQL 로그 파일 삭제"
sudo rm -rf /var/log/mysql

log_info "MySQL 사용자 및 그룹 삭제 (선택적)"
sudo deluser mysql
sudo delgroup mysql

log_success "MySQL이 시스템에서 완전히 제거되었습니다."