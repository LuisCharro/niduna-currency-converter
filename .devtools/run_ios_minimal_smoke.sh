#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
driver_path="test_driver/screenshots_driver.dart"
target_path="integration_test/minimal_smoke_test.dart"

source "${repo_root}/scripts/common.sh"

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
  local provider_profile="${PROVIDER_PROFILE:-dev_coinpaprika}"
  local app_dev_mode="${APP_DEV_MODE:-true}"
  local flutter_args=()
  while IFS= read -r arg; do
    flutter_args+=("${arg}")
  done < <(
    PROVIDER_PROFILE="${provider_profile}" \
      APP_DEV_MODE="${app_dev_mode}" \
      flutter_app_define_args
  )

  local resolved_simulator_id
  resolved_simulator_id="$(resolve_simulator_id)"
  if [[ -z "${resolved_simulator_id}" ]]; then
    echo "Could not resolve an iOS simulator id." >&2
    exit 1
  fi

  echo "Running minimal smoke test on ${resolved_simulator_id}..."
  run_flutter drive \
    --driver="${driver_path}" \
    --target="${target_path}" \
    -d "${resolved_simulator_id}" \
    "${flutter_args[@]}"
}

main "$@"
