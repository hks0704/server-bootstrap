#!/bin/bash

# 1. 문자열 및 사용자 입력
# ex: 계속 진행하시겠습니까? (y/N)
confirm() {
    local message="${1:-Continue?}"
    local confirm
    read -rp "$message [y/N]: " confirm
    # 소문자로 통일
    confirm="${confirm,,}"
    [[ "$confirm" == "y" || "$confirm" == "yes" ]]
}

# 2. command 존재 여부
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 3. 서비스 실행 여부
# Docker, Jenkins... 설치시 사용
service_active() {
    systemctl is-active --quiet "$1"
}

# 4. 패키지 설치 여부
# Ubuntu에서 자주 사용
package_installed() {
    dpkg -s "$1" >/dev/null 2>&1
}

# 5. 네트워크 문제 대비 용도 retry()
retry() {
    local retries=3
    local count=0

    until "$@"; do
        count=$((count + 1))

        if [ "$count" -ge "$retries" ]; then
            return 1
        fi

        sleep 2
    done
}

# 6. 다운로드
download_file() {
    local url="$1"
    local output="$2"
    curl -fsSL "$url" -o "$output"
}

# 7. backup
# 설정 파일 수정 전에 대부분 사용
backup_file() {
    local file="$1"
    cp "$file" "${file}.bak.$(date +%Y%m%d_%H%M%S)"
}

# 8. append_if_missing()
append_if_missing() {
    local text="$1"
    local file="$2"
    grep -qxF "$text" "$file" || echo "$text" >> "$file"
}

# 9. wait_for_port()
# CI/CD에서 높은 빈도로 사용
wait_for_port() {
    local host="$1"
    local port="$2"
    until nc -z "$host" "$port"; do
        sleep 1
    done
}

# 10. elapsed time
# 설치 시간 출력
START_TIME=$(date +%s)

print_elapsed() {
    local end
    end=$(date +%s)
    echo "$((end - START_TIME)) seconds"
}

# 11. OS 확인
# Ubuntu만 지원하는 경우
is_ubuntu() {
    grep -qi ubuntu /etc/os-release
}

# 12. architecture 확인
# Docker 설치시 확인
get_arch() {
    dpkg --print-architecture
}

# 13. version 비교
# Java, Docker 버전 체크
version_ge() {
    dpkg --compare-versions "$1" ge "$2"
}

# 14. 공통 separator
print_separator() {
    echo "========================================="
}