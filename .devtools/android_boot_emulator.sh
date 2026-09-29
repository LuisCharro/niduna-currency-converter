#!/usr/bin/env bash

# Boot an Android AVD in the background (non-blocking) and wait until it has
# fully booted, then print its serial (e.g. emulator-5556).
# If the AVD is already running, just prints its serial.
#
# Usage:   ./.devtools/android_boot_emulator.sh <avd_name>
#          ./.devtools/android_boot_emulator.sh Small_Screen_API_36
# Env:     EMULATOR_BIN      (default: ~/Library/Android/sdk/emulator/emulator)
#          EMULATOR_HEADLESS (default: false; true adds -no-window)
#          BOOT_TIMEOUT_S    (default: 240)
#
# Emulator output goes to .tmp/emulator-<avd>.log. Each emulator uses 2-4 GB of RAM;
# avoid running several at once on a laptop.
# List AVDs with ./.devtools/list_android_emulators.sh.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${repo_root}/scripts/common.sh"

avd="${1:-}"
if [[ -z "${avd}" ]]; then
  echo "Usage: $0 <avd_name>" >&2
  exit 1
fi

emulator_bin="${EMULATOR_BIN:-${HOME}/Library/Android/sdk/emulator/emulator}"
timeout_s="${BOOT_TIMEOUT_S:-240}"

serial_for_avd() {
  local serial
  for serial in $(run_adb devices | awk '$1 ~ /^emulator-/ { print $1 }'); do
    local name
    name="$(run_adb -s "${serial}" emu avd name 2>/dev/null | head -1 | tr -d '\r')"
    if [[ "${name}" == "${avd}" ]]; then
      printf '%s\n' "${serial}"
      return
    fi
  done
}

serial="$(serial_for_avd || true)"
if [[ -z "${serial}" ]]; then
  if ! "${emulator_bin}" -list-avds | grep -qx "${avd}"; then
    echo "ERROR: AVD '${avd}' not found." >&2
    exit 1
  fi
  mkdir -p "${repo_root}/.tmp"
  extra_args=()
  if [[ "${EMULATOR_HEADLESS:-false}" == "true" ]]; then
    extra_args+=(-no-window)
  fi
  echo "Starting ${avd}..." >&2
  nohup "${emulator_bin}" -avd "${avd}" -no-snapshot-save -no-boot-anim \
    ${extra_args[@]+"${extra_args[@]}"} \
    >"${repo_root}/.tmp/emulator-${avd}.log" 2>&1 &
fi

deadline=$((SECONDS + timeout_s))
while (( SECONDS < deadline )); do
  if [[ -z "${serial}" ]]; then
    serial="$(serial_for_avd || true)"
  fi
  if [[ -n "${serial}" ]]; then
    booted="$(run_adb -s "${serial}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    if [[ "${booted}" == "1" ]]; then
      printf '%s\n' "${serial}"
      exit 0
    fi
  fi
  sleep 3
done

echo "ERROR: ${avd} did not finish booting within ${timeout_s}s." >&2
exit 1
