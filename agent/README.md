# Currency Converter Repo Agent Guide

Use this file for repo-specific truth that should stay inside this app repo.

Keep here:
- product identity
- exact commands and preferred wrappers
- repo-specific UI and architecture constraints
- local testing and emulator notes
- **modularity rules** — see below

Important:
- use this repo's command docs as source of truth
- do not copy simulator or Flutter command assumptions from other repos
- keep files SMALL — every screen under 80 lines, every widget under 60 lines

Keep reusable heuristics in copied shared skills under `./.agent-local/skills/`.

## Product and stack

This repo is a Flutter currency converter for the Niduna portfolio.

Primary app shell order (Phase 1):
- `Convert` — multi-currency conversion view
- `Favorites` — saved currency pairs
- `Charts` — historical exchange rate charts
- `Settings` — app config, Remove Ads IAP

Non-goals for normal feature work:
- no backend (Phase 1)
- no accounts
- no tracking / analytics
- no cloud sync

## Read this repo in this order

- `DEFINITIONS.md`
- `PLAN.md`
- `agent/README.md`

## Common commands

- default verification: `./scripts/check.sh`
- if Flutter is not on `PATH`: `FLUTTER_BIN=${FLUTTER_BIN} ./scripts/check.sh`
- smoke test (iOS): `.devtools/run_ios_minimal_smoke.sh`
- screenshot capture: `.devtools/capture_ios_screens.sh`

## Common iOS simulator blockers

**Multiple booted simulators** is the most common blocker:

```bash
xcrun simctl shutdown all
xcrun simctl boot ${IOS_SIMULATOR_ID}
```

Always pass `IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID}` explicitly to
smoke and screenshot scripts.

## Shared-skills router

If `./.agent-local/skills/` is present, start shared-skill routing with:

- `./.agent-local/skills/_shared/repo-bootstrap-check.SKILL.md`
- `./.agent-local/skills/mobile/README.md`
- `./.agent-local/skills/frontend/README.md`
- `./.agent-local/skills/release/README.md`
- `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md` for Stitch design exploration

Then load only the copied shared skill that matches the task.

Repo-local `agent/skills/` still matter here for:
- small-screen review
- Flutter verification
- emulator runbook
- product-scope checks
- store release checks

## Modularity rules — ENFORCED

### File size limits

| File type | Max lines |
|-----------|----------|
| Screen (ConvertScreen, etc.) | **80 lines** |
| Shared widget | **60 lines** |
| Theme / constants | **50 lines** |
| App shell (AppShell) | **80 lines** |

### Split immediately when:

- File exceeds **200 lines**
- Widget has > **3 nested levels** of Column/Row/Expanded
- build() method has > **30 lines**
- You find yourself scrolling to understand a widget
- A file does **more than one thing**

### Import structure

```
lib/
├── main.dart                    # Entry point (~5 lines)
├── src/
│   ├── app.dart                 # App shell + navigation (~80 lines)
│   ├── core/theme/app_theme.dart   # Theme tokens (~40 lines)
│   └── features/
│       ├── convert/convert_screen.dart
│       ├── favorites/favorites_screen.dart
│       ├── charts/charts_screen.dart
│       └── settings/settings_screen.dart
```

### Anti-patterns

- ❌ One giant file with all widgets as private classes
- ❌ Copy-pasting widget code instead of extracting shared widgets
- ❌ Business logic inside UI widget files
- ❌ Screens importing things they don't need

### When adding a new feature

1. New file under `src/features/<feature_name>/`
2. Keep screen under 80 lines — if it grows, extract sub-widgets
3. Add import to `app.dart` only for the new screen
4. Run `flutter analyze` — if it passes, structure is good

## Docs to keep updated

- `agent/README.md`
- `DEFINITIONS.md`
- `PLAN.md`
- `AGENTS.md`
