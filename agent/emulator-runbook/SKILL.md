---
name: emulator-runbook
description: Use when launching, seeding, rebuilding, or relaunching this Flutter app in Android or iOS emulators. Covers the repo commands for device discovery, rebuilds, and hot restart expectations.
---

# Emulator Runbook

Start with:

- `$HOME/SKILLS/_shared/repo-devtools-layout.SKILL.md` when adding or changing internal helper scripts
- `$HOME/SKILLS/mobile/flutter/flutter-verification.SKILL.md` when the run loop follows a Flutter code change
- `$HOME/SKILLS/mobile/flutter/flutter-android-emulator-startup-playbook.SKILL.md` when Android AVD launch or attach is failing

Use this local wrapper for repo-specific emulator and relaunch commands.

## Trigger

Use it when the task involves:

- starting an emulator
- running the app on Android or iOS
- rebuilding after UI changes
- refreshing the running emulator session

## Repo-specific prerequisites

Before trying to run the app on a new Mac, verify:

- Xcode exists
- Simulator exists
- Android Studio exists
- Flutter exists
- CocoaPods exists

Practical install commands:

```bash
brew install --cask flutter
brew install cocoapods
```

Then verify:

```bash
flutter doctor -v
```

If Android licenses are missing:

```bash
flutter doctor --android-licenses
```

## Android workflow

List devices:

```bash
flutter devices
```

List emulators:

```bash
flutter emulators
```

Launch an emulator:

```bash
flutter emulators --launch <emulator_id>
```

Run the app:

```bash
flutter run -d emulator-5554
```

## iOS workflow

Open Simulator:

```bash
open -a Simulator
```

Run on iOS:

```bash
flutter run -d ios
```

Prefer targeting one simulator explicitly:

```bash
xcrun simctl list devices available
flutter devices
flutter run -d <ios_simulator_id>
```

## Smoke test workflow

Run minimal smoke test on iOS:

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

Capture screenshots:

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios ./.devtools/capture_ios_screens.sh
```

## Repo-specific notes

- Prefer the small Android emulator for UI review.
- If the small Android emulator will not boot or attach to `adb`, do not assume the app is the cause.
- Prefer this recovery order for Android startup issues:
  - cold boot or disable Quick Boot for the AVD
  - retry launch with `-no-snapshot-load`
  - check whether the emulator process exits before attaching to `adb`
- Emulator keyboard issues are not automatically app bugs.
- After structural UI changes, prefer hot restart over hot reload.
- Keep only one booted iPhone simulator when practical.
- If iOS generated files still reference an older deleted Flutter SDK, recover with:

```bash
flutter clean
flutter pub get
```
