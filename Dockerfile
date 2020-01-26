FROM ubuntu:18.04 as base

RUN apt-get update && \
    apt-get install -y sudo subversion g++ zlib1g-dev build-essential git python python3 libncurses5-dev gawk gettext unzip file libssl-dev wget libelf-dev ecj fastjar java-propose-classpath build-essential libncursesw5-dev python unzip && \
    apt-get clean

RUN useradd -m openwrt &&\
    echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt

USER openwrt
WORKDIR /home/openwrt

ENV OPENWRT_VERSION=18.06.4

# Change this to build for different target hardware.
ENV OPENWRT_CONFIG_SEED_URL=http://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/ar71xx/generic/config.seed

RUN wget -O - https://github.com/openwrt/openwrt/archive/v${OPENWRT_VERSION}.tar.gz | \
  tar --strip=1 -xzvf -
  
FROM base as builder 

COPY --chown=openwrt:openwrt diffconfig .config

RUN scripts/feeds update -a &&\
    wget -O config.seed "$OPENWRT_CONFIG_SEED_URL" &&\
    cat config.seed >> .config &&\
    make defconfig &&\
    cat .config &&\
    make download

USER root
