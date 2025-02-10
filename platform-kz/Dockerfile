FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

RUN apt install -y iproute2 jq \
  && adduser --disabled-password --home /home/container container

RUN echo "container ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER root
WORKDIR /home/container

ARG CACHE_BUSTER=1

COPY ./setup.sh /setup.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /setup.sh /entrypoint.sh

CMD /setup.sh && su container -c /entrypoint.sh