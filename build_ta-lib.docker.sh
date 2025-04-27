#!/usr/bin/env bash

TA_LIB_VERSION="${TA_LIB_VERSION:-0.4.0}"

docker build --build-arg TA_LIB_VERSION=${TA_LIB_VERSION} -t ta-lib:${TA_LIB_VERSION} .
