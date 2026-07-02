#!/bin/bash

set -e

./docker/install.sh
./git/install.sh
./java/install.sh
./mysql/install.sh
./redis/install.sh
./nginx/install.sh
./jenkins/install.sh
