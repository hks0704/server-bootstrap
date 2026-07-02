#!/bin/bash
set -euo pipefail

##################################################
# Redis Docker Install Script
##################################################

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

# ==========================
# Variables
# ==========================
REDIS_PASSWORD="your_redis_password"

IMAGE_NAME="redis:7.2" # 안정적 실습을 위한 버전 고정
CONTAINER_NAME="server-redis"

HOST_PORT=6379
CONTAINER_PORT=6379

VOLUME_NAME="redis-data"

##################################################
# Docker Information
##################################################

IMAGE_ID=$(sudo docker images -q $IMAGE_NAME)
CONTAINER_ID=$(sudo docker ps -aqf "name=^${CONTAINER_NAME}$")

echo
log_step "Current Docker Information"
echo "IMAGE      : $IMAGE_NAME"
echo "IMAGE_ID   : $IMAGE_ID"
echo "CONTAINER  : $CONTAINER_NAME"
echo "CONTAINER_ID : $CONTAINER_ID"
echo

##################################################
# Firewall
##################################################

log_info "Firewall Check"

if sudo ufw status | grep -qw inactive; then
    log_warn "UFW is inactive."
    sudo ufw enable
fi

sudo ufw allow ${HOST_PORT}

##################################################
# Stop & Remove Container
##################################################

echo
log_step "Remove Existing Container"

if [ -n "$CONTAINER_ID" ]; then

    sudo docker stop $CONTAINER_NAME || true
    sudo docker rm $CONTAINER_NAME || true

fi

##################################################
# Remove Image
##################################################

echo
log_step "Remove Existing Image"

if [ -n "$IMAGE_ID" ]; then
    sudo docker rmi $IMAGE_ID
fi

##################################################
# Pull Latest Image
##################################################

echo
log_step "Pull Redis Image"

sudo docker pull $IMAGE_NAME

##################################################
# Create Volume
##################################################

echo
log_step "Create Docker Volume"

if ! sudo docker volume inspect $VOLUME_NAME >/dev/null 2>&1; then
    sudo docker volume create $VOLUME_NAME
fi

##################################################
# Run Redis
##################################################

echo
log_step "Run Redis Container"

sudo docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v ${VOLUME_NAME}:/data \
    $IMAGE_NAME \
    redis-server \
    --appendonly yes \
    --requirepass "${REDIS_PASSWORD}" || {

        log_error "Redis Container Start Failed"
        exit 1
    }

##################################################
# Health Check
##################################################

sleep 3

echo
log_step "Redis Status"

sudo docker ps | grep $CONTAINER_NAME

echo

log_success "Redis Install Complete."
echo
log_info "Connection Information"
print_separator
echo "Host     : localhost"
echo "Port     : 6379"
echo "Password : $REDIS_PASSWORD"
echo