FROM registry.gitlab.steamos.cloud/steamrt/sniper/sdk
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    elfutils \
    heaptrack \
    iproute2 \
    smem \
    sysstat \
  && rm -rf /var/lib/apt/lists/* \
  && adduser --disabled-password --home /home/container container

USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
COPY --chmod=755 ./memory-profile.sh /usr/local/bin/cs2-memory-profile
CMD [ "/bin/bash", "/entrypoint.sh" ]
