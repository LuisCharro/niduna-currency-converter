#!/usr/bin/env bash

# Capture a manual screenshot from the Android emulator/device to
# .tmp/screens/android/<name>-<HHMMSS>.png and print the path.
# Android counterpart to sim_screenshot.sh.
#
# Usage:   ./.devtools/android_screenshot.sh [name]
# Env:     ANDROID_SERIAL (default: booted -> auto-detect, prefers emulator)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${repo_root}/scripts/common.sh"

serial="$(resolve_android_serial)"
if [[ -z "${serial}" ]]; then
  echo "ERROR: No Android device found. Start an emulator first." >&2
  exit 1
fi

name="${1:-screenshot}"
timestamp="$(date +%H%M%S)"
out_dir="${repo_root}/.tmp/screens/android"
mkdir -p "${out_dir}"
outfile="${out_dir}/${name}-${timestamp}.png"

run_adb -s "${serial}" exec-out screencap -p > "${outfile}"
echo "${outfile}"
