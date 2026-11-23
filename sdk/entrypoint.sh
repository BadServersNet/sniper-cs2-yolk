#!/bin/bash
set -Eeuo pipefail

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Give everything time to initialize for preventing SteamCMD deadlock
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

## just in case someone removed the defaults.
if [ -z "${STEAM_USER:-}" ]; then
  echo -e "steam user is not set.\n"
  echo -e "Using anonymous user.\n"
  STEAM_USER=anonymous
  STEAM_PASS=""
  STEAM_AUTH=""
else
  echo -e "user set to ${STEAM_USER}"
fi

## if auto_update is not set or to 1 update
if [ -z "${AUTO_UPDATE:-}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
  # Update Source Server
  if [ -n "${APPID:-}" ]; then
    steam_login=(+login "${STEAM_USER}" "${STEAM_PASS:-}" "${STEAM_AUTH:-}")
    steam_update=(+app_update "${APPID}")

    if [ "${VALIDATE:-0}" != "0" ]; then
      steam_update+=(validate)
    fi

    ./steamcmd/steamcmd.sh \
      +force_install_dir /home/container \
      "${steam_login[@]}" \
      "${steam_update[@]}" \
      +quit
  else
    echo -e "No appid set. Starting Server"
  fi

else
  echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

for steam_sdk_arch in 32 64; do
  steam_client_path="/home/container/steamcmd/linux${steam_sdk_arch}/steamclient.so"
  steam_sdk_directory="/home/container/.steam/sdk${steam_sdk_arch}"

  if [[ ! -s "${steam_client_path}" ]]; then
    echo "Steam client library was not found at ${steam_client_path}." >&2
    exit 1
  fi

  mkdir -p -- "${steam_sdk_directory}"
  ln -sfn -- "${steam_client_path}" "${steam_sdk_directory}/steamclient.so"
done

GAMEINFO_PATH="/home/container/game/csgo/gameinfo.gi"
GAMEINFO_ANCHOR="Game_LowViolence"

is_enabled() {
  local value="${1,,}"

  [[ "${value}" == "1" || "${value}" == "true" ]]
}

write_patched_gameinfo() {
  local patch_metamod="$1"
  local patch_swiftlys2="$2"
  local output_path="$3"

  awk \
    -v anchor="${GAMEINFO_ANCHOR}" \
    -v patch_metamod="${patch_metamod}" \
    -v patch_swiftlys2="${patch_swiftlys2}" '
      function is_managed(line) {
        return line ~ /^[[:space:]]*Game[[:space:]]+(csgo\/)?addons\/(metamod|swiftlys2)[[:space:]]*$/
      }

      function is_blank(line) {
        return line ~ /^[[:space:]]*$/
      }

      trimming && (is_blank($0) || is_managed($0)) {
        if (is_blank($0)) {
          saw_blank = 1
        }
        next
      }

      trimming {
        trimming = 0
        if (saw_blank) {
          print eol
        }
      }

      is_managed($0) {
        next
      }

      {
        print
      }

      !inserted && index($0, anchor) {
        eol = /\r$/ ? "\r" : ""
        if (patch_metamod) {
          print "\t\t\tGame\tcsgo/addons/metamod" eol
        }
        if (patch_swiftlys2) {
          print "\t\t\tGame\tcsgo/addons/swiftlys2" eol
        }
        inserted = 1
        trimming = 1
      }
    ' "${GAMEINFO_PATH}" >"${output_path}"
}

patch_gameinfo() {
  local patch_metamod=0
  local patch_swiftlys2=0
  local patched_path="${GAMEINFO_PATH}.patched"

  if is_enabled "${PATCH_GAMEINFO_METAMOD:-0}"; then
    patch_metamod=1
  fi

  if is_enabled "${PATCH_GAMEINFO_SWIFTLYS2:-0}"; then
    patch_swiftlys2=1
  fi

  if [[ "${patch_metamod}" == "0" && "${patch_swiftlys2}" == "0" ]]; then
    return 0
  fi

  if [[ ! -f "${GAMEINFO_PATH}" ]]; then
    echo "gameinfo.gi was not found at ${GAMEINFO_PATH}; skipping gameinfo patch."
    return 0
  fi

  if ! grep -qF "${GAMEINFO_ANCHOR}" "${GAMEINFO_PATH}"; then
    echo "gameinfo.gi has no ${GAMEINFO_ANCHOR} line; skipping gameinfo patch."
    return 0
  fi

  write_patched_gameinfo "${patch_metamod}" "${patch_swiftlys2}" "${patched_path}"

  if cmp -s "${GAMEINFO_PATH}" "${patched_path}"; then
    rm -f -- "${patched_path}"
    echo "gameinfo.gi is already patched (metamod=${patch_metamod}, swiftlys2=${patch_swiftlys2})."
    return 0
  fi

  mv -- "${patched_path}" "${GAMEINFO_PATH}"
  echo "Patched gameinfo.gi (metamod=${patch_metamod}, swiftlys2=${patch_swiftlys2})."
}

patch_gameinfo

exec python3 /startup.py
