# Flutter App Template — Guide

Use this template as the starting point for new Flutter apps in the Niduna portfolio.

---

## When to Use

When starting a new Flutter app:
1. Copy this folder to `{{PARENT_PATH}}/{{NEW_APP_FOLDER}}/`
2. Run `find . -type f -exec sed -i '' 's/{{APP_NAME}}/{{NEW_APP_NAME}}/g' {} \;` to replace placeholders
3. Or use the scripted setup below

---

## Placeholders

All placeholders use the `{{VAR_NAME}}` format and must be replaced:

| Placeholder | Description | Example |
|------------|-------------|---------|
| `{{APP_NAME}}` | Display name of the app | "Currency Converter" |
| `{{APP_FOLDER}}` | Folder/kebab-case name | "currency-converter" |
| `{{BUNDLE_ID}}` | iOS bundle identifier | "com.niduna.currencyConverter" |
| `{{FIREBASE_PROJECT}}` | Firebase project name | "currency-converter-by-niduna" |
| `{{PHASE_1_SCOPE}}` | Phase 1 feature summary | "fiat currency conversion + charts" |
| `{{ONE_LINE_DESCRIPTION}}` | One-line app description | "A privacy-first currency converter" |
| `{{PARENT_PATH}}` | Parent folder path | "/Users/luis/Niduna/apps" |
| `{{SHARED_SKILLS_REPO}}` | Path to shared skills repo | "/Users/luis/Repos/skills" |
| `{{STORAGE_KEY_PREFIX}}` | SharedPreferences key prefix for seed data | "dailyCalories" |
| `{{ANDROID_PACKAGE_NAME}}` | Android package name | "com.niduna.daily_calorie_needs_calculator" |
| `{{TAB_LIST}}` | App shell tab order | "Tab 1: Home, Tab 2: ..." |

---

## What's Included

### Scripts (`scripts/`)

All Flutter build/test/analysis scripts:
- `check.sh` — analyze + test (default verification)
- `analyze.sh` — static analysis only
- `test.sh` — unit tests only
- `pub_get.sh` — get dependencies
- `build_apk.sh` — Android APK build
- `build_appbundle.sh` — Android App Bundle
- `build_web.sh` — Web build
- `bump_version.sh` — version bump + app_info.dart
- `clean-temp-files.sh` — temp files clean (build, .dart_tool, logs)
- `clean-deep-files.sh` — full clean (build, Pods, .gradle, node_modules)
- Firebase: `firebase_hosting_preview.sh`, `firebase_hosting_live.sh`, `firebase_app_distribution.sh`, `install_firebase_cli.sh`
- Web E2E: `install_web_e2e.sh`, `test_web_preview_e2e.sh`
- `common.sh` — shared helpers (run_flutter, run_firebase, resolve_firebase_bin, require_firebase_hosting_config)

### Devtools (`.devtools/`)

26 scripts across 4 categories:

**Simulator Interaction (9):**

| Script | Purpose |
|--------|---------|
| `run_ios_simulator_app.sh` | Launch app in background (preferred for agent workflows) |
| `run_ios_minimal_smoke.sh` | Smoke test via integration test |
| `capture_ios_screens.sh` | Screenshot capture via integration test driver |
| `sim_screenshot.sh` | Manual screenshot at any time |
| `sim_tap.sh` | Tap simulator at (x, y) coordinates |
| `sim_wait_ready.sh` | Poll until app renders on simulator |
| `sim_uninstall.sh` | Uninstall app from simulator |
| `sim_fresh_install.sh` | Uninstall + fresh run (one command) |
| `capture_tabs.sh` | Auto-capture all tabs |

**Seeded Testing (6):**

| Script | Purpose |
|--------|---------|
| `run_seeded_ios_app.sh` | Build + seed + launch iOS with realistic sample data |
| `seed_ios_simulator_sample_data.sh` | Seed iOS simulator SharedPreferences plist |
| `seed_emulator_sample_data.sh` | Seed Android emulator shared prefs XML |
| `generate_sample_prefs.dart` | Generate prefs from seed data definition |
| `sample_seed_data.dart` | **App-specific:** seed data structure (customize per app) |
| `generate_web_seed_data.dart` | Generate web JSON seed payload |

**Reference Capture (8):**

| Script | Purpose |
|--------|---------|
| `capture_ios_onboarding_reference_screens.sh` | Onboarding flow screenshots |
| `capture_ios_seeded_reference_screens.sh` | Main screens with seeded data |
| `capture_ios_add_entry_reference_screens.sh` | Add-entry / editing flow |
| `capture_ios_settings_reference_screens.sh` | Settings deep dive |
| `capture_ios_post_onboarding_reference_screens.sh` | Post-onboarding empty states |
| `capture_ios_ui_review_bundle.sh` | ALL captures in one run + MANIFEST.md |
| `capture_android_screens.sh` | Android emulator screenshot capture |
| `capture_screenshots.sh` | Generic screenshot wrapper |

**Other (3):**

| Script | Purpose |
|--------|---------|
| `generate_seed_json.js` | Node.js seed generator (web fallback) |
| `README.md` | Full devtools documentation |

**All scripts support `IOS_SIMULATOR_ID` env var (UUID or "booted").**
**Scripts that target a specific app use `BUNDLE_ID` / `IOS_BUNDLE_ID` / `ANDROID_PACKAGE_NAME` env var.**
**See `.devtools/README.md` for full documentation and usage examples.**

### Config (root)

- `.gitignore` — comprehensive, includes `.env*`, `.tmp/`, `.firebase/`, `.stitch/added`
- `analysis_options.yaml` — Flutter recommended lints
- `l10n.yaml` — localization configuration
- `pubspec.yaml` — minimal deps (flutter, cupertino_icons, intl, flutter_lints)

### Lib Skeleton (`lib/`)

Minimal app skeleton to build upon:
- `main.dart` — entry point (~7 lines)
- `src/app.dart` — MaterialApp + AppShell + floating pill nav with 4 placeholder screens
- `src/core/theme/app_theme.dart` — theme tokens with dark mode skeleton (commented out)

### Tests (`test/`, `integration_test/`, `test_driver/`)

- `test/widget_test.dart` — basic widget smoke test
- `integration_test/minimal_smoke_test.dart` — integration smoke test
- `test_driver/screenshots_driver.dart` — screenshot capture driver

### Docs

- `README.md` — app README template
- `AGENTS.md` — agent-facing instructions (design workflow, commands, rules)
- `DESIGN.md` — design system skeleton (YAML frontmatter + section structure)
- `ARCHITECTURE.md` — architecture skeleton (MVVM pattern, core modules)
- `CODE_PATTERNS.md` — extracted patterns (MVVM, settings, state class, split triggers)
- `TEMPLATE_SYNC_PROCESS.md` — standalone process doc for future template sync cycles

---

## Setup After Copying

```bash
cd {{NEW_APP_FOLDER}}

# Replace placeholders (macOS sed syntax)
find . -type f \( -name "*.dart" -o -name "*.md" -o -name "*.yaml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i '' 's/{{APP_NAME}}/{{NEW_APP_NAME}}/g' {} \;
find . -type f \( -name "*.dart" -o -name "*.md" -o -name "*.yaml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i '' 's/{{APP_FOLDER}}/{{NEW_APP_FOLDER}}/g' {} \;
find . -type f \( -name "*.dart" -o -name "*.md" -o -name "*.yaml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i '' 's/{{BUNDLE_ID}}/{{NEW_BUNDLE_ID}}/g' {} \;
find . -type f \( -name "*.dart" -o -name "*.md" -o -name "*.yaml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i '' 's/{{FIREBASE_PROJECT}}/{{NEW_FIREBASE_PROJECT}}/g' {} \;
# ... repeat for all placeholders ...

# Initialize git (if needed)
git init

# Create initial commit
git add .
git commit -m "Initial commit from template"

# Verify (requires platform folders — run flutter pub get first)
./scripts/check.sh
```

---

## Firebase Setup

Firebase scripts are included but not configured. To activate:

1. Create Firebase project in Firebase Console
2. Run `firebase init hosting` to create `firebase.json` and `.firebaserc`
3. Update target names in `firebase.json` and `.firebaserc`
4. Use `require_firebase_hosting_config()` in custom Firebase scripts

---

## Sync Shared Skills

After copying, restore shared skills:

```bash
agent/sync-shared-skills.sh /path/to/shared/skills
```

---

## Agent Folders

There are three agent-related folders in Niduna apps:

### `agent/` (no dot) — Sync Scaffold

Created by `sync-shared-skills.sh`. Contains:
- `sync-shared-skills.sh` — script to sync shared skills
- `skills-manifest.txt` — which shared skill bundles to sync
- `README.md` — repo-local product truth

**Template includes:** all three files. Run `sync-shared-skills.sh` after copying to populate `.agent-local/`.

### `.agent/` (with dot) — Repo-Specific Skills + Docs

Repo-specific skills (e.g. `emulator-runbook`, `flutter-verification`) and documentation (design guidelines, UI specs, etc.). Git-tracked. Created organically as the app matures.

**Template includes:** skeleton with `README.md` + `skills/` placeholder directory. Add files here as the app matures and needs app-specific agent guidance.

### `.agent-local/` (gitignored) — Shared Skills Cache

Copied shared skills from the shared skills repo. Updated by `sync-shared-skills.sh`. Gitignored — treated like `node_modules`.

**Template includes:** none. Populated after running `sync-shared-skills.sh`.

---

## Design Workflow

For UI work, follow this loop:

```
1. Read DESIGN.md for tokens and component specs
2. Implement changes in Flutter code
3. Run ./scripts/check.sh (analyze + test)
4. Hot restart running emulator app
5. Capture screenshots with devtools scripts
6. Compare rendered result against design intent
7. Repeat until verified
```

---

## File Size Budgets

| File type | Max lines | Notes |
|-----------|-----------|-------|
| Screen | 80 | One screen = one focused responsibility |
| Shared widget | 60 | One widget = one reusable piece |
| Theme / constants | 50 | Pure data, no logic |
| App shell | 80 | Navigation only, no business logic |
| State management | 100 | Controller/ChangeNotifier |

**Split triggers:**
- File > 200 lines
- Widget > 3 nested levels
- build() > 30 lines
- Must scroll to understand what the file does
- File does more than one thing

---

## Template Source

This template was created by analyzing and merging:

- `daily-calorie-needs-calculator/` — Firebase scripts, build tooling, **seeded testing ecosystem (17 scripts)**, reference capture system, devtools README
- `currency-converter/` — non-blocking launch, devtools scripts, DESIGN.md, ARCHITECTURE.md, CODE_PATTERNS.md, MVVM-within-feature pattern, floating pill nav, settings controller extraction

**Sync history:**
- v1.0 (2026-05-11): Initial template from CC — 9 devtools, doc skeletons
- v1.1 (2026-05-11): DNC harvest — seeded testing, reference capture, AGENTS.md enhancements, .agent skeleton, 26 devtools total