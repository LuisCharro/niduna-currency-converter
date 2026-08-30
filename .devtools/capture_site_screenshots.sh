#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
app_repo="$(cd "${script_dir}/.." && pwd)"
niduna_root="$(cd "${app_repo}/../.." && pwd)"
site_repo="${SITE_REPO_PATH:-${niduna_root}/niduna-site}"

android_avd="${ANDROID_AVD:-Pixel7_EN}"
android_port="${ANDROID_PORT:-5556}"
android_serial="${ANDROID_SERIAL:-emulator-${android_port}}"
output_root="${SCREEN_OUTPUT_DIR:-${app_repo}/.tmp/screens/android/site-paid}"
target_path="${CAPTURE_TARGET_PATH:-integration_test/screenshot_gallery_test.dart}"
provider_profile="${PROVIDER_PROFILE:-dev_coinpaprika}"
app_dev_mode="${APP_DEV_MODE:-true}"
start_emulator="${START_EMULATOR:-1}"
boot_timeout_seconds="${BOOT_TIMEOUT_SECONDS:-180}"

capture_script="${app_repo}/.devtools/capture_android_screens.sh"
emulator_log="${EMULATOR_LOG_PATH:-${app_repo}/.tmp/emulator-${android_avd}.log}"

find_adb() {
  if [[ -n "${ADB_BIN:-}" ]]; then
    if [[ ! -x "${ADB_BIN}" ]]; then
      echo "ADB_BIN is set but not executable: ${ADB_BIN}" >&2
      exit 1
    fi
    printf '%s\n' "${ADB_BIN}"
    return
  fi

  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return
  fi

  local default_adb="${HOME}/Library/Android/sdk/platform-tools/adb"
  if [[ -x "${default_adb}" ]]; then
    printf '%s\n' "${default_adb}"
    return
  fi

  echo "adb was not found. Install Android platform-tools or set ADB_BIN." >&2
  exit 1
}

find_emulator() {
  if [[ -n "${EMULATOR_BIN:-}" ]]; then
    if [[ ! -x "${EMULATOR_BIN}" ]]; then
      echo "EMULATOR_BIN is set but not executable: ${EMULATOR_BIN}" >&2
      exit 1
    fi
    printf '%s\n' "${EMULATOR_BIN}"
    return
  fi

  local sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-${HOME}/Library/Android/sdk}}"
  local default_emulator="${sdk_root}/emulator/emulator"
  if [[ -x "${default_emulator}" ]]; then
    printf '%s\n' "${default_emulator}"
    return
  fi

  echo "Android emulator was not found. Set EMULATOR_BIN." >&2
  exit 1
}

device_is_ready() {
  local state boot_completed
  state="$("${adb_bin}" -s "${android_serial}" get-state 2>/dev/null || true)"
  boot_completed="$("${adb_bin}" -s "${android_serial}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
  [[ "${state}" == "device" && "${boot_completed}" == "1" ]]
}

device_is_listed() {
  "${adb_bin}" devices | awk -v serial="${android_serial}" '$1 == serial { found = 1 } END { exit(found ? 0 : 1) }'
}

wait_for_device() {
  local elapsed=0
  while ! device_is_ready; do
    if (( elapsed >= boot_timeout_seconds )); then
      echo "Timed out waiting for ${android_serial} to finish booting." >&2
      echo "Emulator log: ${emulator_log}" >&2
      tail -60 "${emulator_log}" 2>/dev/null || true
      exit 1
    fi
    if (( elapsed == 0 || elapsed % 20 == 0 )); then
      echo "Waiting for ${android_serial} to boot (${elapsed}s/${boot_timeout_seconds}s)..."
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
}

ensure_device() {
  "${adb_bin}" start-server >/dev/null

  if device_is_ready; then
    echo "Reusing ready Android target ${android_serial}."
    return
  fi

  if device_is_listed; then
    echo "Android target ${android_serial} is listed but not ready; waiting for it."
    wait_for_device
    return
  fi

  if [[ "${start_emulator}" != "1" ]]; then
    echo "${android_serial} is not connected and START_EMULATOR is not 1." >&2
    "${adb_bin}" devices -l >&2
    exit 1
  fi

  local emulator_bin
  emulator_bin="$(find_emulator)"
  mkdir -p "$(dirname "${emulator_log}")"
  echo "Starting AVD ${android_avd} on ${android_serial}; log: ${emulator_log}"
  nohup "${emulator_bin}" \
    -avd "${android_avd}" \
    -port "${android_port}" \
    -no-boot-anim \
    -no-snapshot-save \
    -gpu swiftshader_indirect \
    >"${emulator_log}" 2>&1 &
  wait_for_device
}

check_screen_size() {
  local screen_size
  screen_size="$("${adb_bin}" -s "${android_serial}" shell wm size | tr -d '\r')"
  if [[ "${screen_size}" != *"1080x2400"* ]]; then
    echo "Expected a 1080x2400 Android target for site assets, got: ${screen_size}" >&2
    exit 1
  fi
  echo "Verified site capture size: 1080x2400 (${android_serial})."
}

capture_mode() {
  local mode="$1"
  local dark_define="$2"
  local mode_dir="${output_root}/${mode}"

  mkdir -p "${mode_dir}"
  echo "Capturing ${mode} paid gallery..."
  ANDROID_SERIAL="${android_serial}" \
    SCREEN_OUTPUT_DIR="${mode_dir}" \
    CAPTURE_TARGET_PATH="${target_path}" \
    SCREENSHOT_DARK="${dark_define}" \
    PROVIDER_PROFILE="${provider_profile}" \
    APP_DEV_MODE="${app_dev_mode}" \
    "${capture_script}"
}

copy_asset() {
  local source_path="$1"
  local destination_path="$2"
  if [[ ! -f "${source_path}" ]]; then
    echo "Expected capture was not generated: ${source_path}" >&2
    exit 1
  fi
  cp "${source_path}" "${destination_path}"
  echo "Updated ${destination_path}"
}

sync_site_assets() {
  local site_assets="${site_repo}/assets"
  if [[ ! -d "${site_assets}" ]]; then
    echo "Site assets directory not found: ${site_assets}" >&2
    exit 1
  fi

  copy_asset "${output_root}/light/01-convert.png" "${site_assets}/screenshot-convert.png"
  copy_asset "${output_root}/dark/01-convert.png" "${site_assets}/screenshot-convert-dark.png"
  copy_asset "${output_root}/dark/02-chart-btc.png" "${site_assets}/screenshot-chart.png"
  copy_asset "${output_root}/light/03-favorites.png" "${site_assets}/screenshot-favorites.png"
  copy_asset "${output_root}/dark/03-favorites.png" "${site_assets}/screenshot-favorites-dark.png"
}

main() {
  if [[ ! -x "${capture_script}" ]]; then
    echo "Android capture driver is not executable: ${capture_script}" >&2
    exit 1
  fi
  if [[ ! -d "${site_repo}" ]]; then
    echo "Site repository not found: ${site_repo}" >&2
    exit 1
  fi

  adb_bin="$(find_adb)"
  ensure_device
  check_screen_size
  capture_mode light ""
  capture_mode dark true
  sync_site_assets

  echo
  echo "Site screenshots are ready in ${site_repo}/assets."
  echo "The emulator was left running for visual inspection."
}

main "$@"
