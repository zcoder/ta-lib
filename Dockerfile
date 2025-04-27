# syntax=docker/dockerfile:1.6

#######################
# Stage 1 — build
#######################
FROM ubuntu:22.04 AS ta_builder

ARG TA_LIB_VERSION=0.4.0
ARG PREFIX=/tmp/build_artifacts/ta-lib_${TA_LIB_VERSION}

ENV DEBIAN_FRONTEND=noninteractive \
    TA_LIB_VERSION=${TA_LIB_VERSION} \
    PREFIX=${PREFIX}

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool \
        wget curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY build_ta-lib.sh /usr/local/bin/build_ta-lib.sh
RUN chmod +x /usr/local/bin/build_ta-lib.sh

WORKDIR /tmp/
RUN build_ta-lib.sh

