# Firebase Setup — Currency Converter

> This file documents what is needed to enable Firebase Hosting for currency-converter.
> Not implemented yet — will be added when Phase 1 web preview is needed.
> Based on the multisite setup used in `daily-calorie-needs-calculator`.

---

## Overview

Firebase Hosting in this project uses a **multisite** setup:
- `openclaw` — developer preview
- `luis` — luis's personal preview
- `alina` — alina's personal preview

All three point to the same Flutter web build. The correct channel is selected at deploy time.

---

## Files to Create

### 1. `firebase.json`

```json
{
  "hosting": [
    {
      "target": "openclaw",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "/**", "destination": "/index.html" }
      ]
    },
    {
      "target": "luis",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "/**", "destination": "/index.html" }
      ]
    },
    {
      "target": "alina",
      "public": "build/web",
      "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      "rewrites": [
        { "source": "/**", "destination": "/index.html" }
      ]
    }
  ]
}
```

### 2. `.firebaserc`

```json
{
  "projects": {
    "default": "currency-converter-by-niduna"
  },
  "targets": {
    "currency-converter-by-niduna": {
      "hosting": {
        "openclaw": ["currency-converter-openclaw"],
        "luis": ["currency-converter-luis"],
        "alina": ["currency-converter-alina"]
      }
    }
  }
}
```

### 3. Scripts to Recreate / Copy from Calorie App

| Script | Purpose | Copy from |
|--------|---------|-----------|
| `scripts/common.sh` | Add back `resolve_firebase_bin()`, `run_firebase()`, `require_openclaw_target()` functions | daily-calorie-needs-calculator |
| `scripts/firebase_hosting_preview.sh` | Deploy to preview channel | daily-calorie-needs-calculator |
| `scripts/firebase_hosting_live.sh` | Deploy to production | daily-calorie-needs-calculator |
| `scripts/firebase_app_distribution.sh` | Beta distribution via Firebase App Distribution | daily-calorie-needs-calculator |
| `scripts/install_firebase_cli.sh` | Install Firebase CLI if not present | daily-calorie-needs-calculator |

### 4. Key Function to Restore in `common.sh`

The following function must be added back to `scripts/common.sh` (after `run_flutter`):

```bash
resolve_firebase_bin() {
  if [[ -n "${FIREBASE_BIN:-}" ]]; then
    if [[ ! -x "${FIREBASE_BIN}" ]]; then
      echo "FIREBASE_BIN is set but not executable: ${FIREBASE_BIN}" >&2
      exit 1
    fi
    printf '%s\n' "${FIREBASE_BIN}"
    return
  fi

  if command -v firebase >/dev/null 2>&1; then
    command -v firebase
    return
  fi

  for candidate in /usr/bin/firebase /usr/local/bin/firebase; do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  done

  echo "Firebase CLI was not found. Install it or set FIREBASE_BIN." >&2
  exit 1
}

run_firebase() {
  local firebase_bin
  firebase_bin="$(resolve_firebase_bin)"
  run_in_repo "${firebase_bin}" "$@"
}

require_openclaw_target() {
  if [[ ! -f "$(repo_root)/firebase.json" ]] || [[ ! -f "$(repo_root)/.firebaserc" ]]; then
    echo "Firebase Hosting config is missing in this branch." >&2
    echo "This branch likely does not include the multisite Hosting setup from main." >&2
    echo "Bring in the Firebase multisite config before trying to deploy." >&2
    exit 1
  fi

  python3 - <<'PY'
import json
from pathlib import Path
import sys

firebase_json = json.loads(Path("firebase.json").read_text())
firebaserc = json.loads(Path(".firebaserc").read_text())

hosting = firebase_json.get("hosting")
targets = []
if isinstance(hosting, list):
    targets = [entry.get("target") for entry in hosting if isinstance(entry, dict)]
elif isinstance(hosting, dict):
    targets = [hosting.get("target")]

project_targets = (
    firebaserc.get("targets", {})
    .get("currency-converter-by-niduna", {})
    .get("hosting", {})
)

required = {"luis", "alina", "openclaw"}
present = {target for target in targets if target}
mapped = set(project_targets.keys())

missing_targets = sorted(required - present)
missing_mappings = sorted(required - mapped)
if missing_targets or missing_mappings:
    if missing_targets:
        print(
            "Missing Firebase hosting targets in firebase.json: "
            + ", ".join(missing_targets),
            file=sys.stderr,
        )
    if missing_mappings:
        print(
            "Missing Firebase hosting target mappings in .firebaserc: "
            + ", ".join(missing_mappings),
            file=sys.stderr,
        )
    print(
        "This branch does not contain the required Firebase multisite setup.",
        file=sys.stderr,
    )
    sys.exit(1)
PY
}
```

---

## Firebase Console Steps

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project (or use existing): **`currency-converter-by-niduna`**
3. Enable **Hosting** in the project
4. For each target, create a hosting site:
   - `currency-converter-openclaw`
   - `currency-converter-luis`
   - `currency-converter-alina`
5. Run `firebase init hosting` to link the local project to the Firebase project
6. Use `firebase target:apply hosting <target> <site>` for each target

---

## When to Enable

- When Phase 1 web preview is ready and needs a shareable URL
- Before the first public beta test
- Not needed for local development with `flutter run`

---

## Commands Once Enabled

```bash
# Preview deploy (default: openclaw channel, 7d expiry)
./scripts/firebase_hosting_preview.sh

# With custom target/channel
./scripts/firebase_hosting_preview.sh luis my-feature-branch

# Production live deploy
./scripts/firebase_hosting_live.sh
```