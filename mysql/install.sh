#!/bin/bash
set -euo pipefail

##################################################
# MySQL Auto Install Script (VM / Instance)
##################################################

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

# ===== 기본 설정 =====
ENV_FILE="./mysql.env"

MYSQL_CNF="/etc/mysql/mysql.conf.d/mysqld.cnf"
MYSQL_SERVICE="mysql"
MYSQL_PORT=3306

##################################################
# 1. 환경 변수 로딩 or 사용자 입력
##################################################

log_step "환경 변수 관련 초기 설정을 시작합니다..."

if [ -f "$ENV_FILE" ]; then
    log_info "mysql.env 파일을 로드합니다."
    source "$ENV_FILE"
else
    log_info "환경 파일이 없어 사용자 입력을 받습니다."

    read -sp "Root Password: " ROOT_PASSWORD
    echo
    read -sp "New Username: " NEW_USERNAME
    echo
    read -sp "New Password: " NEW_PASSWORD
    echo
fi

# 필수값 체크
if [ -z "${ROOT_PASSWORD:-}" ] || [ -z "${NEW_USERNAME:-}" ] || [ -z "${NEW_PASSWORD:-}" ]; then
    log_error "필수 값이 비어 있습니다."
    exit 1
fi

##################################################
# 2. UFW 방화벽 설정
##################################################

log_step "방화벽 설정 확인 중..."

if sudo ufw status | grep -qw inactive; then
    log_info "UFW가 비활성 상태 → 활성화 진행"
    sudo ufw enable
fi

log_info "MySQL 포트 허용 (${MYSQL_PORT})"
sudo ufw allow ${MYSQL_PORT}

##################################################
# 3. MySQL 설치
##################################################

log_step "MySQL 설치 시작"

sudo apt-get update -y
sudo apt-get install -y mysql-server

##################################################
# 4. MySQL 서비스 설정
##################################################

log_step "MySQL 서비스 시작 및 활성화"

sudo systemctl start ${MYSQL_SERVICE}
sudo systemctl enable ${MYSQL_SERVICE}

##################################################
# 5. MySQL 초기 사용자 설정
##################################################

log_step "MySQL 사용자 및 권한 설정"

sudo mysql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

CREATE USER IF NOT EXISTS '${NEW_USERNAME}'@'%' IDENTIFIED BY '${NEW_PASSWORD}';

GRANT ALL PRIVILEGES ON *.* TO '${NEW_USERNAME}'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

##################################################
# 6. 외부 접속 설정 (bind-address)
##################################################

log_step "bind-address 설정 변경"

if grep -q "^bind-address" "$MYSQL_CNF"; then
    sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' "$MYSQL_CNF"
else
    echo "bind-address = 0.0.0.0" | sudo tee -a "$MYSQL_CNF" > /dev/null
fi

##################################################
# 7. MySQL 재시작
##################################################

log_step "MySQL 재시작"

sudo systemctl restart ${MYSQL_SERVICE}

##################################################
# 8. 상태 확인
##################################################

log_step "MySQL 설치 완료 상태 확인"

sudo systemctl status mysql --no-pager | head -n 10

echo
log_success "MySQL 설치 완료!"
print_separator
echo "PORT     : ${MYSQL_PORT}"
echo "ROOT     : root (password set)"
echo "USER     : ${NEW_USERNAME}"
echo "ACCESS   : % (remote enabled)"
print_separator