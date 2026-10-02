FROM registry.gitlab.steamos.cloud/steamrt/sniper/sdk
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

RUN sed -i 's|http://deb.debian.org/debian-security |https://snapshot.debian.org/archive/debian-security/20260831T000000Z/ |g' /etc/apt/sources.list \
  && apt-get -o Acquire::Check-Valid-Until=false update \
  && apt-get install -y iproute2 python3 \
  && rm -rf /var/lib/apt/lists/* \
  && adduser --disabled-password --home /home/container container

USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
COPY ./startup.py /startup.py
CMD [ "/bin/bash", "/entrypoint.sh" ]
