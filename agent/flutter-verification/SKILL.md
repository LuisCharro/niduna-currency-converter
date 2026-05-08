---
name: flutter-verification
description: Use when changing Flutter UI, models, local persistence, tests, or app structure in this repo. Runs the repo verification flow, checks for failures before claiming completion, and refreshes the running app when UI behavior changed.
---

# Flutter Verification

Start with:

- `$HOME/SKILLS/mobile/flutter/flutter-verification.SKILL.md`

Use this local wrapper for the repo-specific verification commands and expectations.

## Trigger

Use it when touching:

- `lib/**`
- `test/**`
- `pubspec.*`
- local persistence or model code
- any refactor that could affect app behavior

## Repo-specific workflow

1. Run the repo checks:

```bash
./scripts/check.sh
```

If Flutter is not on `PATH`:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

2. If `check.sh` is too broad for the task, at minimum run:

```bash
./scripts/analyze.sh
./scripts/test.sh
```

3. Do not report success until verification passes.

4. If the change affects UI or interaction flow, refresh the running emulator app.
Prefer hot restart for structural widget changes.

## Repo-specific output expectations

When closing the task, report:

- what was verified
- whether the emulator app was refreshed
- any remaining gap if something could not be run
