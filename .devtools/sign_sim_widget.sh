#!/usr/bin/env bash
#
# Re-sign the built simulator app + widget extension WITH their App Group
# entitlements.
#
# Why this exists: `flutter build ios --simulator` builds with
# CODE_SIGNING_ALLOWED=NO, so the products are ad-hoc signed WITHOUT embedded
# entitlements. The main app still reaches its App Group container on the
# simulator (lenient app sandbox), but the widget extension runs in a strict
# "plugin" sandbox and gets NO access to the group container without the
# embedded `com.apple.security.application-groups` entitlement — so it can't
# read the data the app writes and only ever shows the "Open to load"
# placeholder. Re-signing with the entitlements files fixes that.
#
# (On a real device with a proper Apple Developer team + the App Group
# capability, signing already embeds these entitlements and this step is a
# no-op concern — it's specifically for unsigned simulator builds.)
#
# Run AFTER `flutter build ios --simulator` and BEFORE installing.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

app="${1:-${repo_root}/build/ios/iphonesimulator/Runner.app}"
appex="${app}/PlugIns/NidunaWidget.appex"
app_entitlements="${repo_root}/ios/Runner/Runner.entitlements"
widget_entitlements="${repo_root}/ios/Runner/Widgets/NidunaWidget/NidunaWidget.entitlements"

if [[ ! -d "${app}" ]]; then
  echo "sign_sim_widget: app not found at ${app} (build first)" >&2
  exit 1
fi

if [[ ! -d "${appex}" ]]; then
  echo "sign_sim_widget: no NidunaWidget.appex embedded — skipping (widget target not built/embedded)." >&2
  exit 0
fi

# Sign the extension first (inner bundle), then the app (outer bundle), so the
# outer signature stays valid. Ad-hoc identity "-" works for the simulator.
echo "sign_sim_widget: signing widget extension with App Group entitlement"
codesign --force --sign - \
  --entitlements "${widget_entitlements}" \
  --generate-entitlement-der \
  "${appex}"

echo "sign_sim_widget: re-signing app with App Group entitlement"
codesign --force --sign - \
  --entitlements "${app_entitlements}" \
  --generate-entitlement-der \
  "${app}"

echo "sign_sim_widget: done"
