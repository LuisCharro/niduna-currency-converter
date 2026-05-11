#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/common.sh"

output_path="$(repo_root)/web/seed_data.json"
seed_days="${SEED_DAYS:-90}"
seed_today="${SEED_TODAY:-}"

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

args=(.devtools/generate_web_seed_data.dart --days "${seed_days}")
if [[ -n "${seed_today}" ]]; then
  args+=(--today "${seed_today}")
fi

run_dart "${args[@]}" > "${output_path}"
echo "Generated web seed data at ${output_path}"
