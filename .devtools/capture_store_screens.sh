#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

source "${repo_root}/scripts/common.sh"

android_serial="${ANDROID_SERIAL:-booted}"
output_base="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/store}"
provider_profile="${PROVIDER_PROFILE:-release_safe}"
app_dev_mode="${APP_DEV_MODE:-false}"

resolve_android_serial() {
  if [[ "${android_serial}" != "booted" ]]; then
    printf '%s\n' "${android_serial}"
    return
  fi

  local detected
  detected="$({ run_adb devices | awk '$2 == "device" && $1 ~ /^emulator-/ { print $1; exit }'; } || true)"
  if [[ -n "${detected}" ]]; then
    printf '%s\n' "${detected}"
    return
  fi

  detected="$({ run_adb devices | awk '$2 == "device" { print $1; exit }'; } || true)"
  if [[ -n "${detected}" ]]; then
    printf '%s\n' "${detected}"
  fi
}

android_serial="$(resolve_android_serial)"

if [[ -z "${android_serial}" ]]; then
  echo "No Android device available. Set ANDROID_SERIAL or start an emulator." >&2
  exit 1
fi

restore_light=true
cleanup() {
  if [[ "${restore_light}" == "true" ]]; then
    run_adb -s "${android_serial}" shell "cmd uimode night no" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

light_dir="${output_base}/light"
dark_dir="${output_base}/dark"

echo "=== Capturing LIGHT mode into ${light_dir} ==="
SCREEN_OUTPUT_DIR="${light_dir}" \
  PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE="${app_dev_mode}" \
  bash "${script_dir}/capture_android_screens.sh"

echo "=== Switching to DARK mode ==="
run_adb -s "${android_serial}" shell "cmd uimode night yes"
sleep 2

echo "=== Capturing DARK mode into ${dark_dir} ==="
SCREEN_OUTPUT_DIR="${dark_dir}" \
  PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE="${app_dev_mode}" \
  bash "${script_dir}/capture_android_screens.sh"

restore_light=false
run_adb -s "${android_serial}" shell "cmd uimode night no"

echo "Done."
echo "  Light: ${light_dir}/"
echo "  Dark:  ${dark_dir}/"
