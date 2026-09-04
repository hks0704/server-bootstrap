#!/bin/bash

set -e

./gcc/install.sh # option
./vim/install.sh # option
./docker/install.sh
./git/install.sh
# ./java/install.sh # 도커 컨테이너에서 설치
./mysql/install.sh
./redis/install.sh
./nginx/install.sh
./jenkins/install.sh
