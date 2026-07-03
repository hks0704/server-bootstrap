#!/bin/bash
set -euo pipefail

##################################################
# Nginx Docker Install Script
##################################################

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

##################################################
# Variables
##################################################

IMAGE_NAME="nginx:1.28-alpine"
CONTAINER_NAME="server-nginx"

HOST_PORT=80
CONTAINER_PORT=80

CONFIG_VOLUME="nginx-config"
HTML_VOLUME="nginx-html"
LOG_VOLUME="nginx-logs"

##################################################
# Docker Information
##################################################

IMAGE_ID=$(sudo docker images -q "$IMAGE_NAME")
CONTAINER_ID=$(sudo docker ps -aqf "name=^${CONTAINER_NAME}$")

echo
log_step "Current Docker Information"

echo "IMAGE        : $IMAGE_NAME"
echo "IMAGE_ID     : $IMAGE_ID"
echo "CONTAINER    : $CONTAINER_NAME"
echo "CONTAINER_ID : $CONTAINER_ID"

##################################################
# Firewall
##################################################

echo
log_step "Firewall"

if sudo ufw status | grep -qw inactive; then
    log_warn "UFW is inactive."
    sudo ufw enable
fi

sudo ufw allow ${HOST_PORT}

##################################################
# Remove Existing Container
##################################################

echo
log_step "Remove Existing Container"

if [ -n "$CONTAINER_ID" ]; then

    sudo docker stop $CONTAINER_NAME || true
    sudo docker rm $CONTAINER_NAME || true

fi

##################################################
# Remove Existing Image
##################################################

echo
log_step "Remove Existing Image"

if [ -n "$IMAGE_ID" ]; then
    sudo docker rmi "$IMAGE_ID"
fi

##################################################
# Pull Image
##################################################

echo
log_step "Pull Nginx Image"

sudo docker pull "$IMAGE_NAME"

##################################################
# Create Volumes
##################################################

echo
log_step "Create Docker Volumes"

for volume in \
    "$CONFIG_VOLUME" \
    "$HTML_VOLUME" \
    "$LOG_VOLUME"
do
    if ! sudo docker volume inspect "$volume" >/dev/null 2>&1; then
        sudo docker volume create "$volume"
    fi
done

##################################################
# Run Container
##################################################

echo
log_step "Run Nginx Container"

sudo docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v ${CONFIG_VOLUME}:/etc/nginx \
    -v ${HTML_VOLUME}:/usr/share/nginx/html \
    -v ${LOG_VOLUME}:/var/log/nginx \
    "$IMAGE_NAME" || {

        log_error "Nginx Container Start Failed"
        exit 1
    }

##################################################
# Health Check
##################################################

sleep 3

echo
log_step "Nginx Status"

sudo docker ps | grep "$CONTAINER_NAME"

##################################################
# Complete
##################################################

echo
log_success "Nginx Install Complete."

echo
log_info "Connection Information"

print_separator

echo "Host : localhost"
echo "Port : 80"

print_separator