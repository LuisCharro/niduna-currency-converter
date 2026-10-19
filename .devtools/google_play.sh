#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
venv_dir="${GOOGLE_PLAY_VENV_DIR:-${repo_root}/.tmp/google-play-venv}"
cli="${repo_root}/stores/google-play/scripts/google_play.py"
local_command=false
if [[ "${1:-}" == "screenshots" ]]; then
  cli="${repo_root}/stores/google-play/scripts/prepare_screenshots.py"
  local_command=true
  shift
fi

# Argument help is local and dependency-free; it must work before setup/auth.
for argument in "$@"; do
  if [[ "${argument}" == "--help" || "${argument}" == "-h" ]]; then
    exec python3 "${cli}" "$@"
  fi
done

if [[ "${1:-}" == "setup" ]]; then
  command -v python3 >/dev/null 2>&1 || {
    echo "google_play: python3 is required to create the local environment" >&2
    exit 1
  }
  mkdir -p "$(dirname "${venv_dir}")"
  python3 -m venv "${venv_dir}"
  "${venv_dir}/bin/python" -m pip install -r "${repo_root}/stores/google-play/requirements.txt"
  echo "Google Play CLI environment ready at ${venv_dir}"
  exit 0
fi

if [[ ! -x "${venv_dir}/bin/python" ]]; then
  echo "google_play: local environment is missing; run ./.devtools/google_play.sh setup" >&2
  exit 1
fi

if [[ "${local_command}" == "true" ]]; then
  exec "${venv_dir}/bin/python" "${cli}" "$@"
fi

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  echo "google_play: set GOOGLE_APPLICATION_CREDENTIALS to the existing app-scoped key path" >&2
  exit 1
fi
if [[ ! -f "${GOOGLE_APPLICATION_CREDENTIALS}" ]]; then
  echo "google_play: credential file not found; check the path in AGENTS.local.md" >&2
  exit 1
fi

exec "${venv_dir}/bin/python" "${cli}" "$@"
