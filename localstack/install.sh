#!/bin/bash
set -euo pipefail

##################################################
# LocalStack Docker Install Script
##################################################

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

check_root

DOCKER_COMPOSE_DIR="$SCRIPT_DIR/../localstack"

########################################
# Docker Compose
########################################
cd "$DOCKER_COMPOSE_DIR" || {
    log_error "Failed to change directory to $DOCKER_COMPOSE_DIR"
    exit 1
}

COMPOSE_FILE="$DOCKER_COMPOSE_DIR/docker-compose.yml"

if [ ! -f "$COMPOSE_FILE" ]; then
    log_error "docker-compose.yml not found: $COMPOSE_FILE"
    exit 1
fi

########################################
# Load configuration from Docker Compose
########################################

CONTAINER_NAME=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.container_name')

IMAGE_NAME=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.image')

HOST_PORT=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.ports[0].published')

CONTAINER_PORT=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.ports[0].target')

SERVICES=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.environment.SERVICES')

AWS_DEFAULT_REGION=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.environment.AWS_DEFAULT_REGION')

VOLUME_NAME=$(sudo docker compose config --format json \
    | jq -r '.services.localstack.volumes[0].source')

########################################
# Docker Information
########################################

IMAGE_ID=$(sudo docker images -q "$IMAGE_NAME")
CONTAINER_ID=$(sudo docker ps -aqf "name=^${CONTAINER_NAME}$")

echo
log_step "Current Docker Information"
echo "IMAGE        : $IMAGE_NAME"
echo "IMAGE_ID     : $IMAGE_ID"
echo "CONTAINER    : $CONTAINER_NAME"
echo "CONTAINER_ID : $CONTAINER_ID"
echo "HOST_PORT    : $HOST_PORT"
echo "REGION       : $AWS_DEFAULT_REGION"
echo "SERVICES     : $SERVICES"
echo "VOLUME       : $VOLUME_NAME"
echo

########################################
# Firewall
########################################

log_info "Firewall Check"

if sudo ufw status | grep -qw inactive; then
    log_warn "UFW is inactive."
    sudo ufw enable
fi

sudo ufw allow "${HOST_PORT}"

########################################
# Stop & Remove Container
########################################

echo
log_step "Remove Existing Container"

if [ -n "$CONTAINER_ID" ]; then
    sudo docker stop "$CONTAINER_NAME" || true
    sudo docker rm "$CONTAINER_NAME" || true
fi

########################################
# Remove Image
########################################

echo
log_step "Remove Existing Image"

if [ -n "$IMAGE_ID" ]; then
    sudo docker rmi "$IMAGE_ID" || true
fi

########################################
# Pull LocalStack Image
########################################

echo
log_step "Pull LocalStack Image"

sudo docker pull "$IMAGE_NAME"

########################################
# Create Volume
########################################

echo
log_step "Create Docker Volume"

if ! sudo docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    sudo docker volume create "$VOLUME_NAME"
fi

########################################
# Run LocalStack
########################################

echo
log_step "Run LocalStack Container"

sudo docker compose up -d || {
    log_error "LocalStack Container Start Failed"
    exit 1
}

log_info "LocalStack Container Started Successfully"

########################################
# Health Check
########################################

echo
log_step "LocalStack Health Check"

LOCALSTACK_HEALTH_URL="http://localhost:${HOST_PORT}/_localstack/health"

for i in {1..30}; do

    if curl -sf "$LOCALSTACK_HEALTH_URL" >/dev/null 2>&1; then
        break
    fi

    sleep 2
done

if ! curl -sf "$LOCALSTACK_HEALTH_URL" >/dev/null 2>&1; then

    log_error "LocalStack Health Check Failed"

    echo
    log_info "LocalStack Container Logs"
    sudo docker logs "$CONTAINER_NAME"

    exit 1
fi

########################################
# LocalStack Status
########################################

echo
log_step "LocalStack Status"

sudo docker ps | grep "$CONTAINER_NAME"

echo

log_success "LocalStack Install Complete."

echo
log_info "Connection Information"
print_separator
echo "Endpoint : http://localhost:${HOST_PORT}"
echo "Region   : ${AWS_DEFAULT_REGION}"
echo "Services : ${SERVICES}"
echo

log_info "Health Check"
curl -s "$LOCALSTACK_HEALTH_URL"

echo