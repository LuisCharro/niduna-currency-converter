#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/common.sh"

if ! command -v firebase >/dev/null 2>&1; then
  echo "firebase CLI is required. Run ./scripts/install_firebase_cli.sh first." >&2
  exit 1
fi

if [[ -z "${FIREBASE_APP_ID_ANDROID:-}" ]]; then
  echo "Set FIREBASE_APP_ID_ANDROID before uploading to Firebase App Distribution." >&2
  exit 1
fi

if [[ -z "${FIREBASE_TESTERS:-}" && -z "${FIREBASE_GROUPS:-}" ]]; then
  echo "Set FIREBASE_TESTERS or FIREBASE_GROUPS before uploading." >&2
  exit 1
fi

repo_dir="$(repo_root)"
artifact="${1:-$repo_dir/build/app/outputs/bundle/release/app-release.aab}"
notes_file="${FIREBASE_RELEASE_NOTES_FILE:-}"

if [[ ! -f "$artifact" ]]; then
  echo "Artifact not found: $artifact" >&2
  exit 1
fi

args=(
  appdistribution:distribute
  "$artifact"
  --app "$FIREBASE_APP_ID_ANDROID"
)

if [[ -n "${FIREBASE_TESTERS:-}" ]]; then
  args+=(--testers "$FIREBASE_TESTERS")
fi

if [[ -n "${FIREBASE_GROUPS:-}" ]]; then
  args+=(--groups "$FIREBASE_GROUPS")
fi

if [[ -n "$notes_file" ]]; then
  if [[ ! -f "$notes_file" ]]; then
    echo "Release notes file not found: $notes_file" >&2
    exit 1
  fi
  args+=(--release-notes-file "$notes_file")
fi

run_in_repo firebase "${args[@]}"
