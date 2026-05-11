#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"

resolve_sim_id() {
  if [[ "${simulator_id}" != "booted" ]]; then
    printf '%s\n' "${simulator_id}"
    return
  fi
  xcrun simctl list devices booted | grep -Eo '[A-F0-9-]{36}' | head -n 1
}

resolved="$(resolve_sim_id)"
if [[ -z "${resolved}" ]]; then
  echo "ERROR: No booted simulator found" >&2
  exit 1
fi

bundle_id="com.niduna.currencyConverter"

echo "Uninstalling ${bundle_id} from simulator ${resolved}..."
xcrun simctl uninstall "${resolved}" "${bundle_id}" 2>&1 || true
echo "Done. App uninstalled."
