#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
bundle_id="${IOS_BUNDLE_ID:-${BUNDLE_ID:-com.niduna.currencyConverter}}"
app_path="${IOS_APP_PATH:-build/ios/iphonesimulator/Runner.app}"
build_first="${BUILD_FIRST:-1}"

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
  )" || true

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

  open -a Simulator >/dev/null 2>&1 || true

  local resolved_simulator_id
  resolved_simulator_id="$(resolve_simulator_id)"
  if [[ -z "${resolved_simulator_id}" ]]; then
    echo "Could not resolve an iOS simulator id." >&2
    exit 1
  fi

  echo "Booting iOS simulator ${resolved_simulator_id}..."
  xcrun simctl boot "${resolved_simulator_id}" >/dev/null 2>&1 || true

  if [[ "${build_first}" == "1" ]]; then
    echo "Building iOS simulator app..."
    run_flutter build ios --simulator "${flutter_args[@]}"
  fi

  if [[ ! -d "${repo_root}/${app_path}" ]]; then
    echo "App bundle not found at ${repo_root}/${app_path}" >&2
    echo "Set IOS_APP_PATH or run with BUILD_FIRST=1." >&2
    exit 1
  fi

  # Embed App Group entitlements into the unsigned simulator products so the
  # widget extension can read the shared container (see sign_sim_widget.sh).
  "${repo_root}/.devtools/sign_sim_widget.sh" "${repo_root}/${app_path}" || true

  echo "Reinstalling ${bundle_id} on ${resolved_simulator_id}..."
  xcrun simctl terminate "${resolved_simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
  xcrun simctl uninstall "${resolved_simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
  xcrun simctl install "${resolved_simulator_id}" "${repo_root}/${app_path}"
  xcrun simctl launch "${resolved_simulator_id}" "${bundle_id}"

  echo "Done. App built, installed, and launched."
}

main "$@"
