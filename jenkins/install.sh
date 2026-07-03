#!/bin/bash
set -euo pipefail
##################################################
# Jenkins Docker Install Script
##################################################

########################################
# common 로드
########################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/log.sh"
source "$SCRIPT_DIR/../common/check.sh"
source "$SCRIPT_DIR/../common/utils.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DOCKERFILE_DIR="${PROJECT_ROOT}/jenkins"

JENKINS_PORT=8081

check_root

##################################################
# Firewall
##################################################

log_info "Firewall Check"

if sudo ufw status | grep -qw inactive; then
    log_warn "UFW is inactive."
    sudo ufw enable
fi

log_info "Jenkins 포트 개방"
sudo ufw allow ${JENKINS_PORT}
sudo ufw reload

IMAGE_NAME="server/jenkins"
CONTAINER_NAME="server-jenkins"

IMAGE_ID=$(sudo docker images -q "$IMAGE_NAME")
CONTAINER_ID=$(sudo docker ps -aqf "name=${CONTAINER_NAME}")

log_step "현재 Docker 상태 확인..."
log_info "$IMAGE_NAME IMAGE_ID: ${IMAGE_ID:-<없음>}"
log_info "$CONTAINER_NAME CONTAINER_ID: ${CONTAINER_ID:-<없음>}"

if [ -n "$CONTAINER_ID" ]; then
    log_info "$CONTAINER_NAME 중지 및 삭제..."
    sudo docker stop $CONTAINER_ID || true
    sudo docker rm $CONTAINER_ID || true
fi

if [ -n "$IMAGE_ID" ]; then
    log_info "$IMAGE_NAME 이미지 삭제..."
    sudo docker rmi $IMAGE_ID || true
fi

# USER_UID=$(id -u $USER)
USER_UID=$(id -u "${SUDO_USER:-$USER}")
DOCKER_GID=$(getent group docker | cut -d: -f3)

if [ -z "$DOCKER_GID" ]; then
    log_error "docker 그룹을 찾을 수 없습니다."
    exit 1
fi

log_step "Docker 이미지 빌드..."
sudo docker build \
    -t "$IMAGE_NAME" \
    -f "$DOCKERFILE_DIR/Dockerfile" \
    "$DOCKERFILE_DIR" \
    --build-arg USER_UID=$USER_UID \
    --build-arg DOCKER_GID=$DOCKER_GID

log_step "Jenkins 컨테이너 실행..."
sudo mkdir -p /var/jenkins_home
sudo chown -R 1000:1000 /var/jenkins_home
sudo docker run -d \
    --restart unless-stopped \
    -p 8081:8080 -p 50000:50000 \
    -v /var/jenkins_home:/var/jenkins_home \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name $CONTAINER_NAME $IMAGE_NAME

if sudo docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    echo
    print_separator
    log_success "Jenkins container installation completed successfully."

    log_info "Access URL:"
    echo "http://localhost:8081"

    log_info "Container Details"
    sudo docker inspect \
        --format='
    Name   : {{.Name}}
    Image  : {{.Config.Image}}
    Status : {{.State.Status}}
    Started: {{.State.StartedAt}}
        ' "$CONTAINER_NAME"
    echo

    log_info "Container Logs:"
    echo "sudo docker logs -f $CONTAINER_NAME"

else
    log_error "Container failed to start."
    exit 1
fi