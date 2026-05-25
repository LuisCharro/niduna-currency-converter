# Devtools

This folder contains local development helpers for loading realistic sample data
into Android emulators and iOS simulators without changing app code.

## Build profile defaults

These helpers now pass app build defines automatically.

- emulator, smoke, seeded-run, and screenshot scripts default to:
  - `PROVIDER_PROFILE=dev_coinpaprika`
  - `APP_DEV_MODE=true`
- release build scripts under `scripts/` default to:
  - `PROVIDER_PROFILE=release_safe`
  - `APP_DEV_MODE=false`

Override either variable explicitly if you need a different local run mode.

## iOS seed script

```bash
./.devtools/seed_ios_simulator_sample_data.sh
```

What it does:

- generates a sample profile and rolling app data for the requested range
- writes them into the app's iOS simulator preferences plist
- terminates and relaunches the app on the selected simulator

## Android seed script

```bash
./.devtools/seed_emulator_sample_data.sh
```

What it does:

- generates a sample profile and rolling app data for the requested range
- writes them into the app's Android `SharedPreferences` XML
- force-stops and relaunches the app on the selected emulator

## Seeded iOS app run

```bash
./.devtools/run_seeded_ios_app.sh
```

What it does:

- installs the current debug build onto the selected iOS simulator
- seeds the sample dataset
- launches the app without a follow-up `flutter run`
- defaults to the dev crypto provider profile and visible developer UI

Use this when you want to review seeded app state on iOS and avoid the common
workflow mistake where a later reinstall drops the sample data and sends the
app back to onboarding.

## Seed data customization

The seed data definition lives in `.devtools/sample_seed_data.dart`.

**This file is app-specific.** The template provides a skeleton showing the
expected structure. Each app must implement its own domain-specific data:

- Profile fields (age, settings, preferences, etc.)
- Log/day entries with realistic variation across phases
- Saved templates or favorites
- Weight or other tracked metrics

To customize for your app, copy the skeleton and fill in:
1. Storage key constants (match your SharedPreferences keys)
2. Profile JSON shape (match your user profile model)
3. Day log JSON structure (match your daily entry model)
4. Template/saved-item definitions (match your saved item model)

## iOS screenshot capture

```bash
./.devtools/capture_ios_screens.sh
```

What it does:

- optionally reseeds the simulator with sample data first
- runs an `integration_test` flow against the selected iOS simulator
- navigates key app views and captures screenshots into `.tmp/screens/ios/`
- doubles as a basic end-to-end smoke pass for those flows
- defaults to the dev crypto provider profile and visible developer UI

Useful environment variables:

- `IOS_SIMULATOR_ID`
- `FLUTTER_BIN`
- `SCREEN_OUTPUT_DIR`
- `SEED_BEFORE_CAPTURE`
- `CAPTURE_TARGET_PATH`

## Reference capture scripts

Focused screenshot capture flows for specific app surfaces:

```bash
./.devtools/capture_ios_onboarding_reference_screens.sh    # Onboarding flow
./.devtools/capture_ios_seeded_reference_screens.sh        # Main screens with data
./.devtools/capture_ios_add_entry_reference_screens.sh     # Add-entry / editing flow
./.devtools/capture_ios_settings_reference_screens.sh      # Settings deep dive
./.devtools/capture_ios_post_onboarding_reference_screens.sh  # Empty post-onboarding state
./.devtools/capture_ios_ui_review_bundle.sh                # ALL captures in one run + manifest
```

Each script writes to its own subdirectory under `.tmp/screens/ios/`.

## Android screenshot capture

```bash
./.devtools/capture_android_screens.sh
```

Seeds data in-process and captures screenshots on Android emulator.

It defaults to the dev crypto provider profile and visible developer UI.

## iOS minimal smoke test

```bash
./.devtools/run_ios_minimal_smoke.sh
```

Fast sanity check after code changes.

It defaults to the dev crypto provider profile and visible developer UI.

## iOS build + reinstall + launch

```bash
./.devtools/sim_reinstall_build.sh
```

What it does:

- builds the current iOS simulator app bundle
- terminates/uninstalls the old app from the target simulator
- installs the new bundle and launches it
- defaults to the dev crypto provider profile and visible developer UI

Useful environment variables:

- `IOS_SIMULATOR_ID`
- `IOS_BUNDLE_ID` or `BUNDLE_ID`
- `IOS_APP_PATH` (default: `build/ios/iphonesimulator/Runner.app`)
- `BUILD_FIRST` (`1` default, set `0` to skip build)

Important:

- run only one iOS `flutter drive` smoke or screenshot script at a time
- do not start multiple scripts in parallel on the same simulator
- if another session is active, stop it first
- after a broken `flutter drive` run, restore normal state with:

```bash
IOS_SIMULATOR_ID=<ios_simulator_id> BUNDLE_ID={{BUNDLE_ID}} \
  ./.devtools/sim_reinstall_build.sh
```

## Android build + reinstall + launch

```bash
./.devtools/android_reinstall_build.sh
```

What it does:

- builds the current Android debug APK
- force-stops the old app on the target emulator/device
- reinstalls the APK, falling back to uninstall + reinstall if needed
- if the full debug APK fails because the emulator is low on space, it automatically builds a split APK for the device ABI and retries with the smaller package
- launches the app after install
- defaults to the dev crypto provider profile and visible developer UI

Useful environment variables:

- `ANDROID_SERIAL` (default: `booted`, auto-detect first running emulator/device)
- `ANDROID_PACKAGE_NAME` (default: `{{ANDROID_PACKAGE_NAME}}`)
- `ANDROID_APK_PATH` (default: `build/app/outputs/flutter-apk/app-debug.apk`)
- `ADB_BIN` (auto-detected if unset)
- `BUILD_FIRST` (`1` default, set `0` to skip build)
- `GRANT_PERMISSIONS` (`1` default, set `0` to skip `adb install -g`)
- `UNINSTALL_FIRST` (`1` default, set `0` to skip the pre-install uninstall)
- `SPLIT_PER_ABI_ON_LOW_STORAGE` (`1` default, set `0` to disable automatic low-storage fallback)

If `ANDROID_SERIAL` is unset, the script prefers the first running emulator
reported by `adb devices`. If no emulator is running, it falls back to the
first connected Android device. If neither exists, it prints connected devices
plus available AVD names to help you pick a target.

## Android emulator / device listing

```bash
./.devtools/list_android_emulators.sh
```

What it does:

- lists all connected Android devices and emulators (with serial, model, screen size)
- lists all available AVDs from `emulator -list-avds` (including stopped ones)
- prints a tip showing how to start an AVD and install to it

Use this when you need to discover or pick a target before running `android_reinstall_build.sh`.

## Environment variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `IOS_SIMULATOR_ID` | Target iOS simulator UUID | `booted` |
| `IOS_BUNDLE_ID` | iOS bundle identifier | `{{BUNDLE_ID}}` |
| `BUNDLE_ID` | Alias for IOS_BUNDLE_ID | `{{BUNDLE_ID}}` |
| `ANDROID_SERIAL` | Target Android device/emulator | `booted` (auto-detect first running target) |
| `ANDROID_PACKAGE_NAME` | Android package name | `{{ANDROID_PACKAGE_NAME}}` |
| `ADB_BIN` | Explicit path to adb | auto-detected |
| `FLUTTER_BIN` | Explicit path to flutter | auto-detected |
| `PROVIDER_PROFILE` | App provider profile define | `dev_coinpaprika` in `.devtools/`, `release_safe` in release scripts |
| `APP_DEV_MODE` | Show hidden developer section by default | `true` in `.devtools/`, `false` in release scripts |
| `SEED_DAYS` | Days of seed data to generate | `90` |
| `SCREEN_OUTPUT_DIR` | Screenshot output directory | `.tmp/screens/ios/` |
| `SEED_BEFORE_CAPTURE` | Reseed before capture | `0` |
| `CAPTURE_TARGET_PATH` | Integration test target path | default gallery |

## Notes

- Dates are not hardcoded. Generators use the current local date and fill backward.
- Sample data should be deterministic enough to be visually useful for testing charts, history, search states, and realistic month-to-month progression.
- For seeded iOS review, prefer `run_seeded_ios_app.sh` over running `flutter run` after seeding.
- `.tmp/` is intended for temporary local artifacts like captured screenshots (gitignored).
- When you need more coverage, extend your integration_test screenshot gallery or add a new focused reference-gallery test.
- For nested menus and long sections, prefer a focused reference-gallery test over one generic capture.
