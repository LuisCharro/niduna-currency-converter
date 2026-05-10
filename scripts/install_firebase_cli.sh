#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

install_firebase_cli() {
  if command -v firebase >/dev/null 2>&1; then
    echo "Firebase CLI already installed: $(command -v firebase)"
    return
  fi

  if command -v npm >/dev/null 2>&1; then
    echo "Installing Firebase CLI via npm..."
    npm install -g firebase-tools
    echo "Firebase CLI installed: $(command -v firebase)"
    return
  fi

  echo "ERROR: Neither Firebase CLI nor npm found." >&2
  echo "Install one of:" >&2
  echo "  npm install -g firebase-tools" >&2
  echo "  or download from https://firebase.google.com/docs/cli" >&2
  exit 1
}

install_firebase_cli "$@"
