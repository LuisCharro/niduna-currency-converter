# Template Sync Process

> How to extract patterns from a mature app and propagate them to the template,
> then apply template updates to existing apps. This process repeats as apps mature.

---

## When to Run

| Trigger | Action |
|---------|--------|
| An app reaches shipping-grade (all features done, stable) | Extract patterns to template |
| Template gets a meaningful update | Propagate to all apps |
| Starting a new app from template | Use template as-is, then update |
| A shared pattern is discovered in one app | Add to template + propagate |

---

## Part A: App → Template Extraction

### Step 1: Identify Template Material

Ask for each file/script/pattern: **Is this generic across all Niduna apps?**

**✅ IS template material:**
- Devtools scripts (simulator interaction, no business logic)
- AGENTS.md structure and commands
- Design doc skeleton (YAML frontmatter + sections, not tokens)
- Architecture doc skeleton (MVVM pattern, blanked feature names)
- app_theme.dart (light + dark mode skeleton)
- common.sh env var conventions
- Code patterns doc (MVVM, settings, state class)
- Script variable conventions (IOS_SIMULATOR_ID, BUNDLE_ID, etc.)
- Modular file size rules and split triggers
- Firebase hosting script conventions

**❌ IS NOT template material:**
- Business logic (API clients, caches, services)
- Specific feature widgets (Convert, Charts, Settings)
- Monetization / IAP logic
- App-specific assets (icons, images)
- DEFINITIONS.md / ROADMAP.md / PLAN.md content
- Product-specific color tokens or copy
- Packages not used by all apps (fl_chart, http, shared_preferences)

### Step 2: Audit Source App

```
Research the source app:
1. List ALL devtools scripts (count + line count)
2. List ALL scripts/ (count + line count)
3. Read AGENTS.md — what structure exists?
4. Read DESIGN.md if it exists
5. Read ARCHITECTURE.md if it exists
6. Read app_theme.dart — does dark mode exist?
7. Check pubspec.yaml — what packages are "standard"?
8. Read .gitignore — what workspace files?
```

### Step 3: Copy or Reference

For each template material item:

| Type | Action |
|------|--------|
| Devtools scripts | Copy file verbatim; clean hardcoded bundle IDs |
| AGENTS.md enrichment | Read source; add new sections to template; keep placeholders |
| DESIGN.md skeleton | Copy structure; blank all tokens; clear component specs |
| ARCHITECTURE.md skeleton | Copy structure; blank feature names; keep pattern examples |
| app_theme.dart | Copy light theme; add commented dark mode skeleton |
| Code patterns | Copy pattern docs; redact app-specific examples |
| common.sh | Copy function structure; remove hardcoded project names |
| .gitignore | Merge additions |

### Step 4: Clean Script Variables

All scripts MUST support these env vars:

```
IOS_SIMULATOR_ID  — Target simulator (UUID or "booted")
BUNDLE_ID         — App bundle identifier
FLUTTER_BIN       — Path to flutter binary (if not on PATH)
FIREBASE_PROJECT   — Firebase project ID
SCREEN_OUTPUT_DIR — Screenshot output directory
```

**Never hardcode a specific bundle ID or project name in template scripts.**

### Step 5: Document the Extraction

Add an entry to `TEMPLATE_SYNC_PROCESS.md` Execution Log:

```
### [Date]: [App] → Template
- [Item copied/updated]
- [What was extracted and why]
- [Any adaptations made]
```

---

## Part B: Template → Apps Propagation

### Step 1: Identify Changed Items

For each change to the template:
- Is it a new file? (template only had placeholder)
- Is it a modified file? (compare with existing app version)
- Is it a deleted file? (unlikely — template only adds)

### Step 2: Propagate Per-App

For each app that exists before the template update:

**New files added to template:**
→ Copy to each app if the app doesn't have one

**Existing files modified in template:**
→ Review each app's version; merge changes if safe; flag conflicts

**Script improvements:**
→ Copy new/updated scripts; do NOT overwrite app-specific configuration

### Step 3: Verify Each App

After propagation, run in each app:

```bash
./scripts/check.sh       # analyze + test
./.devtools/run_ios_simulator_app.sh  # launch, verify no crash
./scripts/analyze.sh    # clean
```

If any app fails, do NOT force-push changes. Fix conflicts manually.

---

## Part C: New App from Template

### Step 1: Copy Template

```bash
cp -r _flutter-app-template/ {{NEW_APP_FOLDER}}/
cd {{NEW_APP_FOLDER}}
```

### Step 2: Fill Placeholders

```bash
find . -type f \( -name "*.dart" -o -name "*.md" -o -name "*.yaml" -o -name "*.sh" -o -name "*.json" \) \
  -exec sed -i '' 's/{{APP_NAME}}/{{NEW_APP_NAME}}/g' {} \;
# ... repeat for each placeholder ...
```

### Step 3: Restore Shared Skills

```bash
./agent/sync-shared-skills.sh /path/to/shared/skills
```

### Step 4: Create App-Specific Docs

```bash
touch DEFINITIONS.md ROADMAP.md PLAN.md
```

### Step 5: Initialize Platform Folders

```bash
flutter pub get   # creates ios/, android/, web/ folders
```

### Step 6: Verify

```bash
./scripts/check.sh
```

### Step 7: Create Initial Commit

```bash
git init
git add .
git commit -m "Initial commit from template"
```

---

## Risk Matrix

| Change Type | Risk | Mitigation |
|-------------|------|------------|
| New devtools script | Low — additive only | Copy; test on one app first |
| AGENTS.md enrichment | Low — additive structure | Merge carefully; preserve {{placeholders}} |
| DESIGN.md skeleton update | Low — doc only | Review section structure fits all apps |
| ARCHITECTURE.md skeleton update | Low — doc only | Keep pattern examples; blank app specifics |
| app_theme.dart dark mode | Medium — affects all UI | Test on simulator after adding |
| Script variable cleanup | Medium — existing scripts may break | Ensure backward compat with env var defaults |
| .gitignore additions | Low — workspace only | Add to all apps' .gitignore |
| TEMPLATE-GUIDE.md update | Low — doc only | Update; no code impact |

---

## Versioning Convention

When the template changes significantly, tag the change:

```
template/v1.0.0 — Initial version
template/v1.1.0 — Added DESIGN.md skeleton + 6 new devtools scripts
template/v1.2.0 — Added dark mode skeleton + CODE_PATTERNS.md
```

Use lightweight tags on the template repo.

---

## Execution Log

### 2026-05-11: currency-converter → _flutter-app-template

**Source:** currency-converter (86 Dart files, 9 devtools scripts, DESIGN.md, ARCHITECTURE.md, full MVVM pattern)

**Extracted:**
- T1: 6 new devtools scripts (sim_screenshot, sim_tap, sim_wait_ready, sim_uninstall, sim_fresh_install, capture_tabs)
- T2: common.sh — replaced hardcoded `require_openclaw_target()` with generic `require_firebase_hosting_config()`
- T3: capture_ios_screens.sh — removed hardcoded `com.niduna.currencyConverter` bundle ID
- T4: AGENTS.md — added Design Workflow section, 9-script devtools inventory table, expanded Common Commands
- T5: DESIGN.md skeleton — copied structure from CC, blanked all tokens and component specs
- T6: ARCHITECTURE.md skeleton — copied structure from CC, blanked feature names, kept pattern examples
- T7: app_theme.dart — added commented dark mode skeleton
- T8: CODE_PATTERNS.md — new file documenting MVVM-within-feature, settings controller, state class, split triggers
- T9: .gitignore — added `.firebase/`, `.stitch/added`, `.integration_test/*.png`, `.test_driver/*.png`
- T10: TEMPLATE-GUIDE.md — expanded script inventory, design workflow section, file size budgets, design workflow loop
- T11: TEMPLATE_SYNC_PROCESS.md — this file

**Notes:**
- CC test/widget_test.dart had 2 missing `onNavigateToSettings` args — fixed as part of CC baseline verification before template work
- capture_ios_screens.sh uses `IOS_BUNDLE_ID` env var (not `BUNDLE_ID`) for bundle ID — this is the existing convention in template; left as-is
- setsid not available on macOS — run_ios_simulator_app.sh uses nohup; not changed in template