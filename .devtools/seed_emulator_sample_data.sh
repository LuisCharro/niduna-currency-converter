#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
package_name="${ANDROID_PACKAGE_NAME:-com.niduna.currency_converter}"
android_serial="${ANDROID_SERIAL:-emulator-5554}"
seed_days="${SEED_DAYS:-90}"
temp_xml=""

source "${repo_root}/scripts/common.sh"

cleanup() {
  if [[ -n "${temp_xml}" && -f "${temp_xml}" ]]; then
    rm -f "${temp_xml}"
  fi
}

find_adb() {
  if [[ -n "${ADB_BIN:-}" ]]; then
    if [[ ! -x "${ADB_BIN}" ]]; then
      echo "ADB_BIN is set but not executable: ${ADB_BIN}" >&2
      exit 1
    fi
    echo "${ADB_BIN}"
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

run_dart() {
  if [[ -n "${FLUTTER_BIN:-}" ]]; then
    local dart_bin
    dart_bin="$(cd "$(dirname "${FLUTTER_BIN}")" && pwd)/dart"
    if [[ ! -x "${dart_bin}" ]]; then
      echo "Could not find dart next to FLUTTER_BIN: ${FLUTTER_BIN}" >&2
      exit 1
    fi
    run_in_repo "${dart_bin}" "$@"
    return
  fi

  if command -v dart >/dev/null 2>&1; then
    run_in_repo dart "$@"
    return
  fi

  if command -v flutter >/dev/null 2>&1; then
    local flutter_path
    local dart_bin
    flutter_path="$(command -v flutter)"
    dart_bin="$(cd "$(dirname "${flutter_path}")" && pwd)/dart"
    if [[ -x "${dart_bin}" ]; then
      run_in_repo "${dart_bin}" "$@"
      return
    fi
  fi

  if command -v fvm >/dev/null 2>&1; then
    run_in_repo fvm dart "$@"
    return
  fi

  echo "Dart was not found. Install Flutter/Dart or set FLUTTER_BIN." >&2
  exit 1
}

main() {
  local adb_bin
  adb_bin="$(find_adb)"
  temp_xml="$(mktemp)"

  run_dart .devtools/generate_sample_prefs.dart --days "${seed_days}" > "${temp_xml}"

  "${adb_bin}" -s "${android_serial}" wait-for-device

  if ! "${adb_bin}" -s "${android_serial}" shell pm list packages "${package_name}" | grep -q "${package_name}"; then
    echo "Package ${package_name} is not installed on ${android_serial}." >&2
    echo "Run the app on the emulator first, then try again." >&2
    exit 1
  fi

  "${adb_bin}" -s "${android_serial}" shell am force-stop "${package_name}" >/dev/null 2>&1 || true

  cat "${temp_xml}" | "${adb_bin}" -s "${android_serial}" shell \
    "run-as ${package_name} sh -c 'mkdir -p shared_prefs && cat > shared_prefs/FlutterSharedPreferences.xml'"

  "${adb_bin}" -s "${android_serial}" shell monkey -p "${package_name}" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 || true

  echo "Seeded ${seed_days} rolling days of sample data into ${package_name} on ${android_serial}."
  echo "Profile and data now use dates ending on the current day."
}

trap cleanup EXIT

main "$@"
