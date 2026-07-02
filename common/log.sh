#!/bin/bash

########################################
# ANSI Color
########################################

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

########################################
# Logging
########################################

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log_info() {
    # echo -e "${GREEN}[INFO]${NC} $*"
    echo -e "$(timestamp) ${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "$(timestamp) ${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "$(timestamp) ${RED}[ERROR]${NC} $*" >&2
}

log_step() {
    echo
    echo -e "${BLUE}========================================${NC}"
    echo -e "${CYAN}$*${NC}"
    echo -e "${BLUE}========================================${NC}"
}

log_success() {
    echo -e "$(timestamp) ${GREEN}[SUCCESS]${NC} $*"
}

########################################
# Exit with error
########################################

error_exit() {
    log_error "$*"
    exit 1
}
