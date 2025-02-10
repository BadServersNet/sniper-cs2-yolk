#!/bin/bash

CSGO_FOLDER="/home/container/game/csgo"

log() {
  echo -e "\033[1m\033[33m[$1]\033[0m $2"
}

output_info() {
  log "info" "Current Timezone: ${TZ}"
  log "info" "Current External IP: $(curl -s ifconfig.me)"
  
  log "info" "FULL_INSTALL_KZ: ${FULL_INSTALL_KZ}"
  log "info" "AUTO_UPDATE: ${AUTO_UPDATE}"
  log "info" "VALIDATE: ${VALIDATE}"
}

install_metamod() {
  log "install_metamod" "Fetching the latest Metamod master version..."

  DOWNLOAD_PAGE="https://mms.alliedmods.net/mmsdrop/2.0/"
  METAMOD_FILE_NAME=$(curl -s "$DOWNLOAD_PAGE" | grep -oP 'href="\K.*?(?=")' | grep 'mmsource-.*-linux.tar.gz' | head -n 1)
  METAMOD_DOWNLOAD_URL="${DOWNLOAD_PAGE}${METAMOD_FILE_NAME}"

  if [ -z "$METAMOD_DOWNLOAD_URL" ]; then
    log "install_metamod" "Failed to fetch the latest Metamod master version. Exiting."
    exit 1
  fi

  log "install_metamod" "Latest master version found: $METAMOD_DOWNLOAD_URL"
  log "install_metamod" "Downloading $METAMOD_DOWNLOAD_URL to $CSGO_FOLDER ..."

  curl -Lqs "$METAMOD_DOWNLOAD_URL" | tar -xz -C "$CSGO_FOLDER"

  if [ $? -ne 0 ]; then
    log "install_metamod" "Failed to download and extract Metamod."
    exit 1
  fi

  GAMEINFO_PATH="${CSGO_FOLDER}/gameinfo.gi"

  if grep -qF "metamod" "$GAMEINFO_PATH"; then
    log "install_metamod" "Metamod addon include already exists. Skipping."
  else
    sed -i "/Game_LowViolence/ a\\
\t\t\tGame\tcsgo/addons/metamod\n" "$GAMEINFO_PATH"
    if [ $? -ne 0 ]; then
      log "install_metamod" "Failed to add Metamod addon include."
      exit 1
    fi
    log "install_metamod" "Metamod addon include added successfully."
  fi

  log "install_metamod" "Metamod installation complete."
}

update_cs2kz() {
  log "update_cs2kz" "Installing CS2 KZ..."

  CS2KZ_REPO_OWNER="KZGlobalTeam"
  CS2KZ_REPO_NAME="cs2kz-metamod"
  CS2KZ_LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${CS2KZ_REPO_OWNER}/${CS2KZ_REPO_NAME}/releases" | jq 'sort_by(.created_at) | reverse | .[0]')

  if [ $? -ne 0 ]; then
    log "update_cs2kz" "Failed to fetch CS2 KZ latest release."
    exit 1
  fi

  if [ "${FULL_INSTALL_KZ}" == "1" ] || [ "${FULL_INSTALL_KZ}" == "true" ]; then
    CS2KZ_FILE_NAME="master.tar.gz"
    log "update_cs2kz" "FULL_INSTALL_KZ is set. Installing full package."
  elif [ -f "$CSGO_FOLDER/cfg/cs2kz-server-config.txt" ]; then
    CS2KZ_FILE_NAME="upgrade.tar.gz"
    log "update_cs2kz" "CS2 KZ config file found. Upgrading CS2 KZ."
  else
    CS2KZ_FILE_NAME="master.tar.gz"
    log "update_cs2kz" "CS2 KZ config file not found. Installing full package."
  fi

  CS2KZ_DOWNLOAD_URL=$(echo "$CS2KZ_LATEST_RELEASE" | jq -r ".assets[] | select(.name | endswith(\"${CS2KZ_FILE_NAME}\")) | .browser_download_url")

  if [ -z "$CS2KZ_DOWNLOAD_URL" ]; then
    log "update_cs2kz" "Error: Unable to find CS2 KZ release download URL."
    exit 1
  fi

  log "update_cs2kz" "Downloading $(echo "$CS2KZ_LATEST_RELEASE" | jq -r ".assets[] | select(.name | endswith(\"${CS2KZ_FILE_NAME}\")) | .name")"
  log "update_cs2kz" "Downloading $(echo "$CS2KZ_LATEST_RELEASE" | jq -r ".assets[] | select(.name | endswith(\"${CS2KZ_FILE_NAME}\")) | .browser_download_url")"

  curl -Lqs "$CS2KZ_DOWNLOAD_URL" | tar -xz -C "$CSGO_FOLDER"

  if [ $? -ne 0 ]; then
    log "update_cs2kz" "Failed to download and extract CS2 KZ."
    exit 1
  fi

  log "update_cs2kz" "CS2 KZ installation complete."
}

main() {
  output_info
  install_metamod
  update_cs2kz
}

main
