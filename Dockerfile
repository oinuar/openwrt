FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y sudo time git-core subversion build-essential gcc-multilib ncurses-base \
                       libncurses5-dev zlib1g-dev gawk flex gettext wget curl unzip python && \
    apt-get clean

RUN useradd -m openwrt &&\
    echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt

USER openwrt
WORKDIR /home/openwrt

ENV OPENWRT_VERSION=18.06.4

# Change this to build for different target hardware.
ENV OPENWRT_CONFIG_SEED_URL=http://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/ar71xx/generic/config.seed

RUN wget -O - https://github.com/openwrt/openwrt/archive/v${OPENWRT_VERSION}.tar.gz | \
  tar --strip=1 -xzvf - && \
  scripts/feeds update -a

COPY --chown=openwrt:openwrt config .config

RUN wget -O config.seed "$OPENWRT_CONFIG_SEED_URL" &&\
    cat config.seed >> .config &&\
    make defconfig

ENV PACKAGES="samba4-server minidlna luci-app-minidlna mwan3 \
  prometheus-node-exporter-lua-nat_traffic \
  prometheus-node-exporter-lua-netstat \
  prometheus-node-exporter-lua-openwrt \
  prometheus-node-exporter-lua-textfile"

USER root
