#!/usr/bin/env bash

set -euo pipefail

repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
}

run_in_repo() {
  cd "$(repo_root)"
  "$@"
}

run_flutter() {
  if [[ -n "${FLUTTER_BIN:-}" ]]; then
    if [[ ! -x "${FLUTTER_BIN}" ]]; then
      echo "FLUTTER_BIN is set but not executable: ${FLUTTER_BIN}" >&2
      exit 1
    fi
    run_in_repo "${FLUTTER_BIN}" "$@"
    return
  fi

  if command -v flutter >/dev/null 2>&1; then
    run_in_repo flutter "$@"
    return
  fi

  if command -v fvm >/dev/null 2>&1; then
    run_in_repo fvm flutter "$@"
    return
  fi

  echo "Flutter was not found. Install Flutter, use fvm, or set FLUTTER_BIN." >&2
  exit 1
}
