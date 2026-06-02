# Release & Build Commands Reference

> **What this is:** every command that takes parameters, with usage, what's required, what's optional, and what's missing when it fails. Maintained alongside the `release-prep` branch.
>
> **Convention:** All `IOS_SIMULATOR_ID` defaults shown below match the post-Phase A-D plan (`docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`). Override as needed.

---

## iOS simulator (dev / visual verify)

### Find a booted simulator

```bash
xcrun simctl list devices booted
```

**Returns:** list of booted simulator UUIDs + names. Use the UUID as `IOS_SIMULATOR_ID` in other commands.

### Boot sim + build + install + launch (the workhorse)

```bash
IOS_SIMULATOR_ID=<UUID> \
  BUNDLE_ID=<bundle-id> \
  PROVIDER_PROFILE=<profile> \
  APP_DEV_MODE=<bool> \
  ./.devtools/sim_reinstall_build.sh
```

| Param | Required | Common value | Purpose |
|---|---|---|---|
| `IOS_SIMULATOR_ID` | yes (or it'll auto-pick) | `87FB7A6A-58E4-4F45-A44E-EC071B06BC04` (iPhone 17 Pro) | Which sim to install on |
| `BUNDLE_ID` | yes (or use `IOS_BUNDLE_ID`) | `com.niduna.currencyConverter` | App's bundle identifier |
| `PROVIDER_PROFILE` | yes | `dev_coinpaprika` for local · `release_safe` for release | Which currency/crypto provider config |
| `APP_DEV_MODE` | yes | `true` for local · `false` for release | Show hidden developer section in Settings |
| `BUILD_FIRST` | no | `1` (default) or `0` | Skip rebuild if AAB already built (then it just reinstalls) |
| `FLUTTER_BIN` | no | (uses PATH) | Override Flutter binary if not on PATH |

**Prereqs:** Xcode, Flutter SDK, booted simulator (script will auto-boot if shut down), `pubspec.yaml` deps resolved (`flutter pub get`).

**What you get:** built `build/ios/iphonesimulator/Runner.app`, installed on sim, launched. Process ID printed at the end.

**Common errors:**
- *"Could not resolve an iOS simulator id"* — no booted sim, pass `IOS_SIMULATOR_ID`
- *"Xcode build done"* followed by timeout — usually Flutter dep download; rerun
- Build error in Dart/Kotlin/Glance code — see `flutter test` section to isolate

### Take a screenshot

```bash
./.devtools/sim_screenshot.sh <name>
# Saves to .tmp/screens/ios/<name>-HHMMSS.png
```

| Param | Required | Purpose |
|---|---|---|
| `name` | yes (defaults to `screenshot`) | Prefix for the saved file. **Just a name, not a path** — full path is auto-generated under `.tmp/screens/ios/`. |

**Prereqs:** booted simulator with the app running (or any visible app).

**Gotcha:** if you pass `myname.png` as a path, the script tries to use `myname.png` as a *prefix* and creates `myname.png-HHMMSS.png` in the default output dir. Use just a stem.

### Capture all 4 tabs via integration test

```bash
IOS_SIMULATOR_ID=<UUID> \
  SCREEN_OUTPUT_DIR=.tmp/screens/ios/<dir> \
  ./.devtools/capture_ios_screens.sh
```

| Param | Required | Purpose |
|---|---|---|
| `IOS_SIMULATOR_ID` | yes | Which sim to run on |
| `SCREEN_OUTPUT_DIR` | no (defaults to `.tmp/screens/ios`) | Where to put the captured PNGs |
| `CAPTURE_TARGET_PATH` | no (defaults to `integration_test/currency_smoke_test.dart`) | Override the integration test target |

**Prereqs:** booted sim, app buildable.

**⚠️ Known issue:** this script uses `flutter drive` with `HomeWidgetProvider.pushData` which requires `AppGroupId` to be set. Without it, the first test throws `PlatformException(-7, AppGroupId not set)` and the whole capture aborts. **Workaround:** use `sim_screenshot.sh` per tab + manual navigation, or fix the `AppGroupId` setup in `integration_test/`.

**Slow:** takes 1-3 minutes for the full capture.

### Tap a coordinate via `idb` (iOS-native, recommended)

```bash
IDB=/tmp/idb-venv/bin/idb
COMPANION=/Applications/idb-companion.app/bin/idb_companion
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
$IDB --companion-path "$COMPANION" ui tap --udid <UUID> <x> <y>
```

| Param | Required | Purpose |
|---|---|---|
| `x`, `y` | yes | **Logical points** (1/3 of device native pixels on iPhone 17 Pro = 402×874 logical, 1206×2622 native) |
| `--udid` | yes | Simulator UUID |
| `--companion-path` | yes | Path to the `idb_companion` binary (installed under `.app` bundle) |

**Prereqs:** `idb` CLI + `idb-companion` (see "Install idb" below).

**Why preferred over `sim_tap.sh`:** idb sends the tap to the iOS simulator as a real touch event — no host mouse involvement. Works while the user is using the laptop for other things. The `cliclick`-based `sim_tap.sh` script moves the real mouse cursor and steals focus from whatever else the user is doing.

**Finding coordinates without guessing:** run `$IDB ui describe-all --udid <UUID> > /tmp/ui.json` to get every on-screen element's `AXLabel`, `type`, and `frame` (x, y, width, height in logical points). Then compute the center of the element you want and tap that.

**Gotcha — coordinate scale:** the device's *native* pixel resolution is 3× the logical point size. If you measure a tap on a screenshot, divide by 3 (or by the screenshot's compression ratio × 3) to get the logical point. A tap in physical device pixels will land far off-screen.

### Install idb (one-time, per machine)

The `idb` Python CLI talks to a native `idb_companion` helper that bridges to the iOS simulator. Both must be installed and the right env var set.

```bash
# 1. Python venv (idb 1.1.7 breaks on Python 3.14; 1.0.13 has a protobuf issue — use 3.11)
python3.11 -m venv /tmp/idb-venv
/tmp/idb-venv/bin/pip install fb-idb

# 2. Companion binary (macOS .app bundle, not a single binary)
# Download v1.1.8 from https://github.com/facebook/idb/releases
# Unzip and move to /Applications/idb-companion.app

# 3. Verify it works
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
IDB=/tmp/idb-venv/bin/idb
COMPANION=/Applications/idb-companion.app/bin/idb_companion
$IDB --companion-path "$COMPANION" list-targets
# Should print: iPhone 17 Pro | <UUID> | Booted | simulator | iOS <version> | ...
```

**Why the env var:** on Python 3.11, idb's protobuf layer needs the pure-Python implementation (the C++ one is missing some symbols in the venv). Setting `PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python` is mandatory — without it, idb crashes on the first command.

**Why `/tmp`:** venv is throwaway. Re-run the install block to recreate it. The companion `.app` is a normal install; only the venv is ephemeral.

**Don't add the env var to your shell rc.** It's only needed when running idb commands, and global exports confuse other tools.

### Smoke test workflow: 8 UI polish screenshots (4 tabs × light/dark)

End-to-end script for capturing the release-prep UI polish set without
cliclick. Uses idb for taps, `xcrun simctl ui` for theme, and the project's
`sim_screenshot.sh` for capture. Adapted from the May/June 2026 release-prep run.

```bash
WORKDIR=/Users/luis/Niduna/apps/currency-converter
cd "$WORKDIR"

UDID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04  # iPhone 17 Pro
BUNDLE=com.niduna.currencyConverter
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
IDB=/tmp/idb-venv/bin/idb
COMPANION=/Applications/idb-companion.app/bin/idb_companion

# Tab nav centers in logical points (iPhone 17 Pro = 402×874)
TAB_CONVERT_X=66; TAB_FAVORITES_X=156; TAB_CHART_X=246; TAB_SETTINGS_X=336; NAV_Y=808
# Decimal places "2" button center (in Settings)
DEC2_X=202; DEC2_Y=227

mkdir -p .tmp/screens/ios/ui-polish
mavis-trash .tmp/screens/ios/ui-polish/*.png 2>/dev/null || true

tap()  { $IDB --companion-path "$COMPANION" ui tap --udid $UDID "$1" "$2" >/dev/null; sleep 1.2; }
shot() {
  ./.devtools/sim_screenshot.sh "$1" >/dev/null
  local f=$(ls -t .tmp/screens/ios/${1}-*.png 2>/dev/null | head -1)
  [ -n "$f" ] && mv "$f" ".tmp/screens/ios/ui-polish/${1}.png"
}

# --- LIGHT (4 tabs) ---
xcrun simctl ui $UDID appearance light
xcrun simctl terminate $UDID $BUNDLE; sleep 1
xcrun simctl launch $UDID $BUNDLE; sleep 4

# Reset decimal places to 2 (persisted state from previous runs may differ)
tap $TAB_SETTINGS_X $NAV_Y; sleep 1
tap $DEC2_X $DEC2_Y; sleep 1

shot 01-light-settings
tap $TAB_CONVERT_X   $NAV_Y; shot 02-light-convert
tap $TAB_FAVORITES_X $NAV_Y; shot 03-light-favorites
tap $TAB_CHART_X     $NAV_Y; shot 04-light-chart

# --- DARK (4 tabs) ---
xcrun simctl ui $UDID appearance dark
xcrun simctl terminate $UDID $BUNDLE; sleep 1
xcrun simctl launch $UDID $BUNDLE; sleep 4
# After relaunch, app starts on Convert

shot 05-dark-convert
tap $TAB_FAVORITES_X $NAV_Y; shot 06-dark-favorites
tap $TAB_CHART_X     $NAV_Y; shot 07-dark-chart
tap $TAB_SETTINGS_X  $NAV_Y; shot 08-dark-settings
```

**Why set iOS system theme instead of toggling in-app:** the app's `Dark mode`
switch uses a Cupertino-style `SwitchTile` with val=0 meaning "follows system"
and val=1 meaning "always on". Tapping it via idb works but is fragile (hitbox
is small, the value AX reports doesn't always match what the app actually
renders). `xcrun simctl ui <UDID> appearance dark|light` is a one-shot global
state change that's deterministic.

**Why relaunch the app after appearance change:** the running app caches the
theme at launch. Without `terminate` + `launch`, dark mode shows the previous
theme's colors.

**Gotcha — shell glob trap:** the `shot()` function's `ls` glob
(`.tmp/screens/ios/${1}-*.png`) must NOT be inside double quotes or the `*`
won't expand. If you copy-paste, keep that line unquoted.

**Gotcha — `mavis-trash` vs `rm`:** use `mavis-trash` (recoverable). The
trash tool needs at least one path; an empty dir is fine because of the
`2>/dev/null || true` fallback.

### Tap a coordinate via `cliclick` (FALLBACK — only if idb is broken)

```bash
./.devtools/sim_tap.sh <x> <y> [delay]
```

| Param | Required | Purpose |
|---|---|---|
| `x` | yes | Screen X coordinate in **host** screen pixels (not sim-internal) |
| `y` | yes | Screen Y coordinate in host screen pixels |
| `delay` | no (defaults to `0.5s`) | Wait after tap before returning |

**Prereqs:** `cliclick` installed (`brew install cliclick`).

**⚠️ Reliability warning (from AGENTS.md):** *"UNRELIABLE — uses real mouse, misses target."* Two issues:
1. Coordinates are fragile and depend on the simulator window position. If you move the sim window, the script taps the wrong place.
2. It moves the real mouse cursor, so it interferes with whatever else the user is doing on their laptop.

**Prefer `idb ui tap`** — see section above. Use `sim_tap.sh` only when idb is broken and you need a one-off tap.

**Common errors:** if `cliclick` isn't installed, the script exits with `cliclick: command not found`.

### Toggle dark / light mode

```bash
xcrun simctl ui <UUID> appearance dark    # or 'light'
```

**No params besides the simulator UUID.** Changes take effect immediately; the next `sim_screenshot.sh` will show dark mode.

**Prereqs:** booted simulator (appearance setting is simulator-wide, not per-app).

### Terminate / launch the app

```bash
xcrun simctl terminate <UUID> <bundle-id>     # kill the app
xcrun simctl launch <UUID> <bundle-id>       # start the app
```

**Use case:** relaunch after toggling dark mode (otherwise the running app keeps light colors until you restart it).

---

## Android build (release artifacts)

### Build signed release AAB (Play Store upload format)

```bash
./scripts/build_appbundle.sh
```

**No required env vars** (defaults to `PROVIDER_PROFILE=release_safe`, `APP_DEV_MODE=false`).

**Prereqs:**
- `android/app/niduna-upload.jks` exists (gitignored, see "Keystore" section below)
- `android/key.properties` exists (gitignored)
- `build.gradle.kts` has the release signingConfig wired (it does, after commit `200c888`)

**What you get:** `build/app/outputs/bundle/release/app-release.aab` (52.8MB as of writing)

**Output validation:** grep the AAB for `META-INF/<ALIAS>_UPPER.SF` and `META-INF/<ALIAS>_UPPER.RSA` to confirm v1 signature present.

### Build signed release APK (sideload / direct install)

```bash
./scripts/build_apk.sh
```

**Same prereqs as the AAB script.**

**What you get:** `build/app/outputs/flutter-apk/app-release.apk` (60.7MB as of writing)

### Verify APK signature

```bash
/Users/luis/Library/Android/sdk/build-tools/35.0.0/apksigner verify --verbose --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

**Output (after keystore wiring commit `200c888`):**
```
Verifies
Verified using v1 scheme (JAR signing): false
Verified using v2 scheme (APK Signature Scheme v2): true
Verified using v3 scheme (APK Signature Scheme v3): false
Signer #1 certificate DN: CN=Niduna Currency Converter, OU=Mobile, O=Niduna, L=Zurich, ST=ZH, C=CH
Signer #1 certificate SHA-256 digest: 808cfb19b29836b79e8299e3ac03c620b6c9df79df20b06c9f5ff913925cf761
Signer #1 key algorithm: RSA
Signer #1 key size (bits): 2048
```

v2 is sufficient for Google Play. v1 only would fail on devices with no v2 support (Android <7.0).

**Note:** `apksigner verify` works on APK only, not AAB. For AAB, extract the cert from `META-INF/<ALIAS>.RSA` via `unzip -p <aab> META-INF/<ALIAS>.RSA | openssl pkcs7 -inform DER -print_certs`.

---

## Keystore management

### Generate a new release keystore

```bash
keytool -genkey -v \
  -keystore android/app/niduna-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias niduna_currency_converter_upload \
  -storepass <password> -keypass <password> \
  -dname "CN=Niduna Currency Converter, OU=Mobile, O=Niduna, L=Zurich, ST=ZH, C=CH"
```

| Param | Required | Value (this repo) |
|---|---|---|
| `-keystore` | yes | `android/app/niduna-upload.jks` (path is gitignored via `**/*.jks`) |
| `-alias` | yes | `niduna_currency_converter_upload` |
| `-keyalg / -keysize` | yes | `RSA` / `2048` (Play Store minimum) |
| `-validity` | yes (days) | `10000` (~27 years; exceeds Play's 25-year minimum) |
| `-storepass / -keypass` | yes | **TEMP until rotated.** Both are stored in `android/key.properties` (gitignored). |
| `-dname` | yes (X.500 DN) | `CN=<app name>, OU=<team>, O=<company>, L=<city>, ST=<state>, C=<country>` |

**Prereqs:** JDK (`brew install --cask temurin` or use Android Studio's bundled JDK).

**Common gotchas:**
- Forgetting `-keypass` when it's different from `-storepass` → keystore created but key unreadable
- Password too weak (under 6 chars) → `keytool` warns
- Wrong dname format → AAPT manifest merge may complain

### Rotate the keystore password

```bash
keytool -storepasswd -new <NEW> \
  -keystore android/app/niduna-upload.jks
# enter the OLD password when prompted

keytool -keypasswd -new <NEW> \
  -keystore android/app/niduna-upload.jks \
  -alias niduna_currency_converter_upload
# enter the OLD storepass when prompted, then the OLD keypass
```

**Then update `android/key.properties`** to match the new `storePassword` and `keyPassword`.

**Then BACK UP the `.jks` file somewhere outside your Mac** (1Password attachment, encrypted USB, etc.). If you lose the file, you can't push updates to anyone who installed the app.

### Where the keystore lives

| File | Path | Git? |
|---|---|---|
| Keystore | `android/app/niduna-upload.jks` | ❌ gitignored via `**/*.jks` |
| Properties (passwords) | `android/key.properties` | ❌ gitignored |
| Build config (signingConfig) | `android/app/build.gradle.kts` | ✅ committed (no secrets) |

---

## Flutter test

### Run the full test suite

```bash
flutter test
```

**Output:** `+N -M: <test description>` lines as tests run. Final line is `Some tests failed.` if any failed. Compact reporter suppresses intermediate noise; use `expanded` for full failure detail.

### Run a single test file

```bash
flutter test test/path/to/file_test.dart
```

### Run a single test by name

```bash
flutter test --plain-name "<exact test description>"
```

| Param | Required | Purpose |
|---|---|---|
| `--plain-name` | yes (can repeat) | Substring match on the test's `test(...)` description. Quote if it has spaces. |
| `-N` / `--name` | no | Regex match instead of plain substring (use `^` for exact start) |

**Example:**
```bash
flutter test test/widget_test.dart --plain-name "Convert amount input uses sheet keypad"
```

**Note:** only one `--plain-name` works at a time in the CLI; if you need multiple, run them sequentially or filter by file.

### Compact / expanded reporter

```bash
flutter test --reporter=compact    # default, less noise
flutter test --reporter=expanded   # full per-test detail
```

### Common test failure patterns

| Error message | Likely cause | Fix |
|---|---|---|
| `Binding has not yet been initialized` | Missing `TestWidgetsFlutterBinding.ensureInitialized()` in `setUp()` | Add `setUp(() { TestWidgetsFlutterBinding.ensureInitialized(); });` to the file's `main()` |
| `Offset outside the bounds of the root of the render tree, Size(W, H)` | Test view too small for the widget tree (e.g. new widgets added but view stayed 800x600) | `tester.view.physicalSize = const Size(800, 1200)` + `addTearDown(tester.view.resetPhysicalSize)` |
| `PlatformException(-7, AppGroupId not set)` (in integration test) | Test runner doesn't have iOS App Group configured | Set `AppGroupId` in the test target, or skip integration tests for those features |
| `expected ... but widget tree has ...` (text not found) | Test view scrolled past the widget, OR widget text changed | `tester.ensureVisible(find.text(...))` first, or update the expectation to match current code |

---

## Git / branch

### Create the release branch

```bash
git checkout -b release-prep
```

**Why:** all release work happens on this branch, keeping `main` clean for the current `0.1.0+1` pre-MVP work.

### Commit the doc reorder before branching

```bash
git add PLAN.md RELEASE_CHECKLIST.md docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md
git commit -m "docs(plan): reorder post-phase-ad plan to agreed code-only release path"
```

**Why:** the reorder is a docs change that documents the agreed execution order. Doing it on `main` first means the release branch starts from a clean baseline.

---

## Mavis CLI quick reference (commands used in this session)

| Command | Used for | Note |
|---|---|---|
| `mavis-trash <path>` | Recoverable file deletion | Moves to OS Trash. Safer than `rm`. **Do NOT pass `.`** as the path — it trashes the whole directory, not "the stray entry in this dir". |
| `mavis memory append mavis --content "..."` | Add a new entry to agent memory | Use single quotes around content; double quotes if there are no `'` inside. |
| `mavis skill list mavis` | List all skills visible to the mavis agent | Output is JSON; pipe to `python3 -m json.tool` to read. |
| `mavis skill install <git-url> [-a <agent>]` | Install a skill from a git URL | The agent default is `mavis`. |

---

## What's still missing (intentional, awaiting user input)

- **B5 (privacy policy link in Settings):** needs a hosted URL (GitHub Pages, etc.) — code is ready to add the row, blocked on the URL
- **B4 (replace AdMob test unit IDs):** swap `ca-app-pub-3940256099942544/...` for real AdMob unit IDs in `lib/src/core/ads/ad_helper.dart`, `android/app/build.gradle.kts`, and `ios/Runner/Info.plist`
- **C1-C11 (Play Store listing):** needs Play Console account ($25) + content creation (descriptions, screenshots, etc.) — Luis creates manually
- **E1-E5 (Play Console + AdMob accounts):** external sign-up, no code work
- **Apple Developer Program ($99/yr):** external sign-up
- **Android home widget re-enable:** Kotlin file is in the source tree (`android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt`) but the `<receiver>` block in `AndroidManifest.xml` is currently commented out. To re-enable, restore the receiver from commit `55d7839` (`feature/widget-restore`). Build is verified; data flow works.
- **iOS home widget re-enable:** Swift code is in the source tree, the `NidunaWidget` Xcode target is wired up, but the `Embed App Extensions` build phase is **disabled in main** because `xcrun simctl install` fails on iOS 26 / Xcode 26 with `Invalid placeholder attributes` (known simctl bug, not a code issue). To re-enable for real-device testing, run the `ios/scripts/add_widget_target.rb` script which is idempotent. See `docs/release-prep/README.md` for full re-enable steps.
- **Keystore password rotation:** the keystore shipped with a TEMP password stored in `android/key.properties` and `/tmp/niduna_temp_keystore_pwd.txt`. Must be rotated via `keytool -storepasswd` + `keytool -keypasswd` before publishing (and the temp file deleted). Full steps in § "Rotate the keystore password" above.
- **iOS appearance reset:** the smoke test script flips iOS sim to `dark`. After running, set it back to `light` with `xcrun simctl ui <UDID> appearance light` so the sim doesn't open dark for future work.

