#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
bundle_id="${IOS_BUNDLE_ID:-${BUNDLE_ID:-com.niduna.currencyConverter}}"
seed_days="${SEED_DAYS:-90}"

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

  echo "Installing debug app on ${resolved_simulator_id}..."
  xcrun simctl terminate "${resolved_simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
  run_flutter build ios --simulator --debug --target lib/main.dart "${flutter_args[@]}"
  run_flutter install -d "${resolved_simulator_id}" --debug

  echo "Seeding ${seed_days}-day sample dataset..."
  IOS_SIMULATOR_ID="${resolved_simulator_id}" \
    IOS_BUNDLE_ID="${bundle_id}" \
    SEED_DAYS="${seed_days}" \
    LAUNCH_AFTER_SEED=0 \
    FLUTTER_BIN="${FLUTTER_BIN:-}" \
    "${repo_root}/.devtools/seed_ios_simulator_sample_data.sh"

  echo "Launching seeded app on ${resolved_simulator_id}..."
  xcrun simctl terminate "${resolved_simulator_id}" "${bundle_id}" >/dev/null 2>&1 || true
  xcrun simctl launch --terminate-running-process "${resolved_simulator_id}" "${bundle_id}" >/dev/null

  cat <<EOF
Seeded app is ready on simulator ${resolved_simulator_id}.
Use this helper when you want a ${seed_days}-day sample dataset without
running a follow-up \`flutter run\` that may reset local data.
EOF
}

main "$@"
