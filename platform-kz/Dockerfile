FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

RUN apt install -y iproute2 jq \
  && adduser --disabled-password --home /home/container container

RUN echo "container ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
