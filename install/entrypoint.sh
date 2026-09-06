#!/bin/bash
set -Eeuo pipefail
# steamcmd Base Installation Script
#
# Server Files: /mnt/server

## just in case someone removed the defaults.
if [ -z "${STEAM_USER:-}" ]; then
  STEAM_USER=anonymous
  STEAM_PASS=""
  STEAM_AUTH=""
fi

## download and install steamcmd
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -fsSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

## install game using steamcmd
steam_login=(+login "${STEAM_USER}" "${STEAM_PASS:-}" "${STEAM_AUTH:-}")
steam_update=(+app_update "${APPID}")
./steamcmd.sh +force_install_dir /mnt/server "${steam_login[@]}" "${steam_update[@]}" +quit

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so
