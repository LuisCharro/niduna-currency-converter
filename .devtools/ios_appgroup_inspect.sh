#!/usr/bin/env bash
#
# Inspect the iOS home-screen widget's data path on the simulator. Consolidates
# the checks used when debugging "widget shows no data":
#   1. the App Group container + the shared defaults plist the app writes
#   2. the installed widget extension's embedded entitlements (App Group?)
#   3. recent widget-extension log lines
#
# Usage:
#   IOS_SIMULATOR_ID=<udid> ./.devtools/ios_appgroup_inspect.sh
#   (defaults to the booted simulator)
#
# Env:
#   IOS_SIMULATOR_ID   simulator udid (default: first booted)
#   APP_GROUP_ID       app group (default: group.com.niduna.currencyConverter)
#   BUNDLE_ID          app bundle id (default: com.niduna.currencyConverter)
#   LOG_WINDOW         log lookback for widget logs (default: 2m)

set -euo pipefail

sim="${IOS_SIMULATOR_ID:-}"
group="${APP_GROUP_ID:-group.com.niduna.currencyConverter}"
bundle="${BUNDLE_ID:-com.niduna.currencyConverter}"
log_window="${LOG_WINDOW:-2m}"

if [[ -z "${sim}" ]]; then
  sim="$(xcrun simctl list devices booted | grep -Eo '[A-F0-9-]{36}' | head -n 1)"
fi
if [[ -z "${sim}" ]]; then
  echo "No booted simulator and IOS_SIMULATOR_ID unset." >&2
  exit 1
fi

dev_root="${HOME}/Library/Developer/CoreSimulator/Devices/${sim}"
echo "Simulator: ${sim}"
echo "App group: ${group}"
echo

echo "===== 1. App Group container + shared defaults plist ====="
found=""
for meta in "${dev_root}"/data/Containers/Shared/AppGroup/*/.com.apple.mobile_container_manager.metadata.plist; do
  [[ -f "${meta}" ]] || continue
  gid="$(plutil -p "${meta}" 2>/dev/null | grep -i MCMMetadataIdentifier | sed 's/.*=> //' | tr -d '"')"
  if [[ "${gid}" == "${group}" ]]; then
    dir="$(dirname "${meta}")"
    plist="${dir}/Library/Preferences/${group}.plist"
    echo "container: $(basename "${dir}")"
    if [[ -f "${plist}" ]]; then
      keys="$(plutil -p "${plist}" 2>/dev/null | grep -cE '=>')"
      echo "keys in shared plist: ${keys}"
      plutil -p "${plist}" 2>/dev/null | grep -iE 'pair_|amountLabel|updatedLabel|baseCode' | sed 's/^/   /'
    else
      echo "   (no ${group}.plist yet)"
    fi
    found=1
  fi
done
[[ -n "${found}" ]] || echo "   (no app group container for ${group} — app not launched yet?)"
echo

echo "===== 2. Installed widget extension entitlements ====="
appex="$(find "${dev_root}/data/Containers/Bundle/Application" -name '*.appex' 2>/dev/null | head -n 1)"
if [[ -n "${appex}" ]]; then
  echo "appex: ${appex##*/Application/}"
  ent="$(codesign -d --entitlements :- "${appex}" 2>/dev/null | plutil -p - 2>/dev/null | grep -iE 'application-groups|group\.' | sed 's/^/   /')"
  echo "${ent:-   (no App Group entitlement embedded — widget cannot read the container)}"
else
  echo "   (no .appex installed — widget target not embedded?)"
fi
echo

echo "===== 3. Recent widget-extension logs (last ${log_window}) ====="
xcrun simctl spawn "${sim}" log show --last "${log_window}" --style compact 2>/dev/null \
  | grep -iE 'NidunaWidget|NIDUNA_WIDGET|widgetkit' | tail -15 \
  || echo "   (none)"
