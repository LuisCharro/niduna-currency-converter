#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
driver_path="test_driver/screenshots_driver.dart"
target_path="${CAPTURE_TARGET_PATH:-integration_test/currency_smoke_test.dart}"
output_dir="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/ios}"
bundle_id="${IOS_BUNDLE_ID:-com.niduna.currencyConverter}"

source "${repo_root}/scripts/common.sh"

mkdir -p "${output_dir}"

resolve_simulator_id() {
  if [[ "${simulator_id}" != "booted" ]]; then
    printf '%s\n' "${simulator_id}"
    return
  fi

  local booted_id
  booted_id="$(
    xcrun simctl list devices booted available |
      grep -Eo '[A-F0-9-]{36}' |
      head -n 1
  )"
  if [[ -n "${booted_id}" ]]; then
    printf '%s\n' "${booted_id}"
    return
  fi

  xcrun simctl list devices available |
    sed -n '/iPhone/p' |
    grep -Eo '[A-F0-9-]{36}' |
    head -n 1
}

main() {
  local resolved_simulator_id
  resolved_simulator_id="$(resolve_simulator_id)"
  if [[ -z "${resolved_simulator_id}" ]]; then
    echo "Could not resolve an iOS simulator id." >&2
    exit 1
  fi

  echo "Capturing integration-test screenshots into ${output_dir} on ${resolved_simulator_id}..."
  export SCREEN_OUTPUT_DIR="${output_dir}"
  run_flutter drive \
    --driver="${driver_path}" \
    --target="${target_path}" \
    -d "${resolved_simulator_id}"
  xcrun simctl terminate "${resolved_simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
}

main "$@"