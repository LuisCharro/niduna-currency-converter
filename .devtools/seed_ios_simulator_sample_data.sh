#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
bundle_id="${IOS_BUNDLE_ID:-${BUNDLE_ID:-com.niduna.currencyConverter}}"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
seed_days="${SEED_DAYS:-90}"
launch_after_seed="${LAUNCH_AFTER_SEED:-1}"
temp_plist=""

source "${repo_root}/scripts/common.sh"

cleanup() {
  if [[ -n "${temp_plist}" && -f "${temp_plist}" ]]; then
    rm -f "${temp_plist}"
  fi
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
    if [[ -x "${dart_bin}" ]]; then
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
  local container
  local prefs_dir
  local prefs_file

  temp_plist="$(mktemp)"
  run_dart .devtools/generate_sample_prefs.dart --days "${seed_days}" --format ios-plist > "${temp_plist}"

  container="$(xcrun simctl get_app_container "${simulator_id}" "${bundle_id}" data 2>/dev/null || true)"
  if [[ -z "${container}" || ! -d "${container}" ]]; then
    echo "App container for ${bundle_id} was not found on simulator ${simulator_id}." >&2
    echo "Run the app on the iOS simulator first, then try again." >&2
    exit 1
  fi

  prefs_dir="${container}/Library/Preferences"
  prefs_file="${prefs_dir}/${bundle_id}.plist"
  mkdir -p "${prefs_dir}"

  xcrun simctl terminate "${simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
  cp "${temp_plist}" "${prefs_file}"
  plutil -convert binary1 "${prefs_file}"

  if [[ "${launch_after_seed}" == "1" ]]; then
    xcrun simctl launch "${simulator_id}" "${bundle_id}" >/dev/null
  fi

  echo "Seeded ${seed_days} rolling days of sample data into ${bundle_id} on simulator ${simulator_id}."
  echo "Profile and data now use dates ending on the current day."
}

trap cleanup EXIT

main "$@"
