#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: sim_tap.sh <x> <y> [delay_seconds]"
  echo "  Tap at screen coordinates (x, y) on the iOS Simulator."
  echo "  Optional delay after tap (default: 0.5s)."
  exit 1
fi

x="$1"
y="$2"
delay="${3:-0.5}"

cliclick c:${x},${y}
sleep "${delay}"
