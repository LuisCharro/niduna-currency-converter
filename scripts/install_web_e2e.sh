#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
e2e_dir="$repo_root/web-e2e"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required for Playwright web E2E setup." >&2
  exit 1
fi

cd "$e2e_dir"
npm install
npx playwright install --with-deps chromium
