#!/usr/bin/env bash

cd "$(dirname $0)"

./build_ta-lib.docker.sh

TA_LIB_VERSION="${TA_LIB_VERSION:-0.4.0}"
SRC=$(docker create ta-lib:${TA_LIB_VERSION})
sudo docker cp "${SRC}":/tmp/build_artifacts/ta-lib_${TA_LIB_VERSION}/.  /usr/
sudo ldconfig
docker rm "${SRC}"
