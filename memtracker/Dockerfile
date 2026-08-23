FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

ADD https://github.com/zer0k-z/cs2-memtracker/releases/latest/download/cs2-memtracker-linux.tar.gz /tmp/cs2-memtracker-linux.tar.gz

RUN apt install -y iproute2 \
  && tar -xzf /tmp/cs2-memtracker-linux.tar.gz -C /usr/local/lib libcs2memtracker.so \
  && chmod 0555 /usr/local/lib/libcs2memtracker.so \
  && rm /tmp/cs2-memtracker-linux.tar.gz \
  && adduser --disabled-password --home /home/container container

USER container
ENV USER=container
ENV HOME=/home/container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
