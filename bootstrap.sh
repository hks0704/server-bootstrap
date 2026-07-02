#!/bin/bash

set -e

./docker/install.sh
./git/install.sh
# ./java/install.sh # 도커 컨테이너에서 설치
./mysql/install.sh
./redis/install.sh
./nginx/install.sh
./jenkins/install.sh
