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

resolve_adb_bin() {
  if [[ -n "${ADB_BIN:-}" ]]; then
    if [[ ! -x "${ADB_BIN}" ]]; then
      echo "ADB_BIN is set but not executable: ${ADB_BIN}" >&2
      exit 1
    fi
    printf '%s\n' "${ADB_BIN}"
    return
  fi

  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return
  fi

  for candidate in \
    "${HOME}/Library/Android/sdk/platform-tools/adb" \
    /opt/homebrew/bin/adb \
    /usr/local/bin/adb; do
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return
    fi
  done

  echo "adb was not found. Install Android platform-tools or set ADB_BIN." >&2
  exit 1
}

run_adb() {
  local adb_bin
  adb_bin="$(resolve_adb_bin)"
  run_in_repo "${adb_bin}" "$@"
}

flutter_app_define_args() {
  local provider_profile="${PROVIDER_PROFILE:-release_safe}"
  local app_dev_mode="${APP_DEV_MODE:-false}"
  local admob_use_test_ads="${ADMOB_USE_TEST_ADS:-true}"
  local admob_android_banner_id="${ADMOB_ANDROID_BANNER_AD_UNIT_ID:-}"
  local admob_ios_banner_id="${ADMOB_IOS_BANNER_AD_UNIT_ID:-}"
  local admob_android_rewarded_id="${ADMOB_ANDROID_REWARDED_AD_UNIT_ID:-}"
  local admob_ios_rewarded_id="${ADMOB_IOS_REWARDED_AD_UNIT_ID:-}"

  printf '%s\n' "--dart-define=PROVIDER_PROFILE=${provider_profile}"
  printf '%s\n' "--dart-define=APP_DEV_MODE=${app_dev_mode}"
  printf '%s\n' "--dart-define=ADMOB_USE_TEST_ADS=${admob_use_test_ads}"

  if [[ -n "${admob_android_banner_id}" ]]; then
    printf '%s\n' "--dart-define=ADMOB_ANDROID_BANNER_AD_UNIT_ID=${admob_android_banner_id}"
  fi
  if [[ -n "${admob_ios_banner_id}" ]]; then
    printf '%s\n' "--dart-define=ADMOB_IOS_BANNER_AD_UNIT_ID=${admob_ios_banner_id}"
  fi
  if [[ -n "${admob_android_rewarded_id}" ]]; then
    printf '%s\n' "--dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=${admob_android_rewarded_id}"
  fi
  if [[ -n "${admob_ios_rewarded_id}" ]]; then
    printf '%s\n' "--dart-define=ADMOB_IOS_REWARDED_AD_UNIT_ID=${admob_ios_rewarded_id}"
  fi
}

require_android_release_admob_config() {
  local use_test_ads="${ADMOB_USE_TEST_ADS:-true}"

  case "${use_test_ads}" in
    false|FALSE|False|0|no|NO|No)
      ;;
    *)
      return
      ;;
  esac

  local missing=()

  if [[ -z "${ADMOB_ANDROID_APP_ID:-}" ]]; then
    missing+=("ADMOB_ANDROID_APP_ID")
  fi

  if [[ -z "${ADMOB_ANDROID_BANNER_AD_UNIT_ID:-}" ]]; then
    missing+=("ADMOB_ANDROID_BANNER_AD_UNIT_ID")
  fi

  if [[ -z "${ADMOB_ANDROID_REWARDED_AD_UNIT_ID:-}" ]]; then
    missing+=("ADMOB_ANDROID_REWARDED_AD_UNIT_ID")
  fi

  if (( ${#missing[@]} > 0 )); then
    echo "Release AdMob config is incomplete while ADMOB_USE_TEST_ADS=false." >&2
    echo "Missing required env vars: ${missing[*]}" >&2
    echo "Either set these vars or keep ADMOB_USE_TEST_ADS=true." >&2
    exit 1
  fi
}

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

required = {"luis", "alina", "openclaw", "jose"}
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
