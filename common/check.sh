#!/bin/bash

########################################
# log.sh 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root."
        exit 1
    fi
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "$1 is required but not installed."
        exit 1
    }
}

check_file_exists() {
    [[ -f "$1" ]] || {
        log_error "File not found: $1"
        exit 1
    }
}

check_directory_exists() {
    [[ -d "$1" ]] || {
        log_error "Directory not found: $1"
        exit 1
    }
}
