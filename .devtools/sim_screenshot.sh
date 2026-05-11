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

name="${1:-screenshot}"
timestamp="$(date +%H%M%S)"
out_dir="${repo_root}/.tmp/screens/ios"
mkdir -p "${out_dir}"

resolved="$(resolve_sim_id)"
if [[ -z "${resolved}" ]]; then
  echo "ERROR: No booted simulator found" >&2
  exit 1
fi

outfile="${out_dir}/${name}-${timestamp}.png"
xcrun simctl io "${resolved}" screenshot "${outfile}"
echo "${outfile}"
