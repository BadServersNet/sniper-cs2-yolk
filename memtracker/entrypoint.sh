#!/bin/bash

sleep 1

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

if [ "${STEAM_USER}" == "" ]; then
  echo -e "steam user is not set.\n"
  echo -e "Using anonymous user.\n"
  STEAM_USER=anonymous
  STEAM_PASS=""
  STEAM_AUTH=""
else
  echo -e "user set to ${STEAM_USER}"
fi

if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
  if [ ! -z ${APPID} ]; then
    ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +app_update ${APPID} $([[ ${VALIDATE} -eq 0 ]] || printf %s "validate") +quit
  else
    echo -e "No appid set. Starting Server"
  fi
else
  echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

export LD_PRELOAD="/usr/local/lib/libcs2memtracker.so${LD_PRELOAD:+:${LD_PRELOAD}}"

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
exec env ${PARSED}
