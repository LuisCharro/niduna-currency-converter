#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
android_serial="${ANDROID_SERIAL:-emulator-5554}"
output_dir="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/android}"
driver_path="test_driver/screenshots_driver.dart"
target_path="${CAPTURE_TARGET_PATH:-integration_test/screenshot_gallery_test.dart}"
package_name="${ANDROID_PACKAGE_NAME:-com.niduna.currency_converter}"

source "${repo_root}/scripts/common.sh"

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

main() {
  local adb_bin
  adb_bin="$(find_adb)"

  mkdir -p "${output_dir}"
  rm -f "${output_dir}"/*.png

  "${adb_bin}" -s "${android_serial}" wait-for-device
  "${adb_bin}" -s "${android_serial}" shell am force-stop "${package_name}" >/dev/null 2>&1 || true

  echo "Capturing integration-test screenshots into ${output_dir} on ${android_serial}..."
  SCREEN_OUTPUT_DIR="${output_dir}" run_flutter drive \
    --driver="${driver_path}" \
    --target="${target_path}" \
    -d "${android_serial}"

  "${adb_bin}" -s "${android_serial}" shell am force-stop "${package_name}" >/dev/null 2>&1 || true
}

main "$@"
