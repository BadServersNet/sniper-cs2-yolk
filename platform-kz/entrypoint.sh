#!/bin/bash

CSGO_FOLDER="/home/container/game/csgo"

log() {
  echo -e "\033[1m\033[33m[$1]\033[0m $2"
}

initialize() {
  log "initialize" "Initializing..."

  sleep 1

  TZ=${TZ:-UTC}
  export TZ

  INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')

  if [ $? -ne 0 ]; then
    log "initialize" "Failed to get internal IP."
    exit 1
  fi

  export INTERNAL_IP

  cd /home/container || exit 1

  log "initialize" "Initialization complete."
}

parse_startup() {
  log "parse_startup" "Parsing startup command..."

  log "parse_startup" "STARTUP: ${STARTUP}"

  PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

  if [ $? -ne 0 ]; then
    log "parse_startup" "Failed to parse startup command."
    exit 1
  fi

  log "parse_startup" "Startup command parsed."
}


run() {
  log "run" "Running server with command: $PARSED"

  exec env ${PARSED}
}

main() {
  initialize
  parse_startup
  run
}

main
