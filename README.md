# Server Bootstrap

새로운 Ubuntu VM 또는 AWS EC2를 몇 분 안에 개발 가능한 상태로 만드는 자동화 스크립트입니다.

## Environment

- Ubuntu 24.04
- AWS EC2
- VMware
- VirtualBox

## Installed Software

- Docker
- Docker Compose
- Jenkins
- MySQL
- Redis
- Nginx
- Git
- Java
- Maven

## Directory Structure

...

## Usage

git clone ...

chmod +x

./bootstrap.sh

## Individual Installation

./docker/install.sh

./mysql/install.sh

...

## Tested Environment

Ubuntu 24.04 LTS

## Future Plans

- Kubernetes
- Terraform
- Ansible
- Prometheus
- Grafana

| 단계 | 기술             | 목적                                         |
| -- | -------------- | ------------------------------------------ |
| 1  | Bash Script    | 서버 초기 설치 자동화                               |
| 2  | Docker Compose | 서비스 구성 자동화                                 |
| 3  | Makefile       | 반복 명령 단순화 (`make bootstrap`, `make clean`) |
| 4  | Ansible        | 여러 서버에 동일한 설정 적용                           |
| 5  | Terraform      | EC2, VPC, 보안 그룹 등 인프라 생성 자동화               |
| 6  | GitHub Actions | 변경 시 스크립트 문법 검사 및 테스트 자동화                  |
