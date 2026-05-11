#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
e2e_dir="$repo_root/web-e2e"

if [[ ! -d "$e2e_dir/node_modules" ]]; then
  echo "Playwright dependencies are missing. Run ./scripts/install_web_e2e.sh first." >&2
  exit 1
fi

cd "$e2e_dir"
npx playwright test "$@"
