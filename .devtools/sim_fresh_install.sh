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

echo "=== Fresh install: uninstall + run ==="
echo "Uninstalling ${bundle_id}..."
xcrun simctl uninstall "${resolved}" "${bundle_id}" 2>&1 || true
echo "Uninstalled."

source "${script_dir}/../scripts/common.sh" 2>/dev/null || true

echo "Running fresh install..."
nohup flutter run -d "${resolved}" > /tmp/flutter-run.log 2>&1 &
echo "PID: $!"
echo "App launching (wait ~30s for compile)..."
