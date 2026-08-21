#!/bin/bash

set -Eeuo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: cs2-memory-profile COMMAND [ARGUMENT]..." >&2
  exit 64
fi

output_directory="${HEAPTRACK_OUTPUT_DIR:-/home/container/heaptrack}"
mkdir -p "$output_directory"

timestamp=$(date -u +%Y%m%dT%H%M%SZ)
output_file="${HEAPTRACK_OUTPUT:-${output_directory}/heaptrack.cs2.${timestamp}.$$}"

echo "Heaptrack profile base: ${output_file}"
exec /usr/bin/heaptrack --output-file "$output_file" "$@"
