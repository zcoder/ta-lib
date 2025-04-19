#!/usr/bin/env bash

cd "$(dirname $0)"

./build_ta-lib.docker.sh

SRC=$(docker create ta-lib:runtime)
sudo docker cp "${SRC}":/tmp/build_artifacts/ta-lib_main/.  /usr/
docker rm "${SRC}"
