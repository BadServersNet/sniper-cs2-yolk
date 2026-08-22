FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform
LABEL author="BuSheeZy"
LABEL maintainer="BuSheeZy@BadServers.net"
LABEL org.opencontainers.image.source="https://github.com/BadServersNet/sniper-cs2-yolk"

ARG CS2_MEMTRACKER_SHA256=602d226cf8a95683912c0b6dc65b92d5dca4e012902893f83adb8f8583b0cd4c

ADD https://github.com/zer0k-z/cs2-memtracker/releases/download/latest/cs2-memtracker-linux.tar.gz /tmp/cs2-memtracker-linux.tar.gz

RUN apt install -y iproute2 \
  && echo "${CS2_MEMTRACKER_SHA256}  /tmp/cs2-memtracker-linux.tar.gz" | sha256sum --check --status \
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
