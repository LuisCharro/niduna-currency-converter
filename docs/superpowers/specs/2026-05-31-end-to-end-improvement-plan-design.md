# End-to-End Improvement Plan

**Date:** 2026-05-31
**Scope:** All 4 tiers — Critical fixes, test gaps, UX polish, file hygiene
**Total tasks:** 23 across 4 phases
**Blocks:** Pre-release quality gate

## Context

Full codebase review of Niduna Currency Converter (v0.1.0+1, pre-MVP).
130 Dart files, ~16,200 lines. 40 fiat + 11 crypto = 51 currencies.
State management: ChangeNotifier + ListenableBuilder (vanilla Flutter).
Test suite: 12 files, 122 passing / 23 failing (all pre-existing Binding issues).

## Tier 1 — Critical Fixes (6 tasks)

### T1.1 Replace hand-rolled JSON parser

**File:** `lib/src/core/monetization/monetization_controller.dart:136-175`

**Problem:**
32-line character-by-character JSON parser (`_parseJsonMap`) silently returns `{}` on any parse error. Fragile on edge cases: nested values, escaped quotes, numeric booleans, whitespace variations.

**Fix:**
Replace `_parseJsonMap` body with `jsonDecode(source) as Map<String, dynamic>? ?? {}`. Remove `_decodeJsonMap` wrapper (inline try/catch). Import `dart:convert`.

**Verification:**
- Existing monetization tests must pass
- Manual test: purchase flow still persists/reads entitlements correctly

---

### T1.2 Complete trend arrows data pipeline

**Files:**
- `lib/src/features/convert/presentation/convert_controller_loading.dart`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
- `lib/src/features/convert/domain/latest_rates_snapshot.dart`

**Problem:**
`LatestRatesSnapshot.previousRates` field exists but is never populated. Frankfurter historical endpoint is never called for yesterday's rates. All trend badges render null → hidden.

**Fix:**
1. Add `fetchYesterdayRates(String base)` to `FrankfurterLatestRatesClient`:
   - Call `GET {base}/..?to={yesterday_YYYY-MM-DD}` on Frankfurter v2
   - Return `Map<String, double>` or null on failure
2. In `ConvertController._stateFromSnapshot()` (loading part):
   - After today's fetch succeeds, fire yesterday fetch as fire-and-forget
   - On yesterday result: rebuild snapshot with `previousRates` set
   - Call `notifyListeners()` to update UI with trend data
3. Graceful: if yesterday fetch fails, trends stay null (current behavior). No error shown.

**Verification:**
- Trend badges appear on currency rows after first refresh
- Badge shows correct direction (up/down/flat) based on rate change
- Badge shows percentage change
- App works offline when yesterday data unavailable

---

### T1.3 Fix SettingsController lifecycle

**Files:**
- `lib/src/app.dart` (AppShell)
- `lib/src/features/settings/settings_screen.dart`
- `lib/src/features/settings/settings_controller.dart`

**Problem:**
`SettingsScreen.build()` creates `new SettingsController(...)` every frame. Works now because controller holds only references, but breaks if it ever gains mutable state. Inconsistent with Convert/Favorites/Charts pattern.

**Fix:**
1. Create `SettingsController` in `AppShell._initAsync()` alongside other controllers
2. Pass to `SettingsScreen` via constructor parameter
3. Remove controller creation from `SettingsScreen.build()`

**Verification:**
- Settings screen renders identically
- Toggle switches still work
- Dev section still conditionally visible

---

### T1.4 Wire home widget to real data

**Files:**
- `lib/src/features/convert/presentation/convert_controller.dart` (already has `_pushHomeWidgetData`)
- `lib/src/core/widget/home_widget_provider.dart`

**Problem:**
`_pushHomeWidgetData()` fires only on full snapshot refresh (`_stateFromSnapshot`). Does not fire on cached load. Widget shows stale/empty data until first network refresh.

**Fix:**
In `convert_controller_loading.dart`, also call `_pushHomeWidgetData()` when emitting cached state (not just after refresh). Ensure widget receives data on app open even without network.

**Verification:**
- Home widget updates on app launch (cached data)
- Home widget updates after refresh (fresh data)
- No crash when home_widget plugin unavailable (existing guard)

---

### T1.5 Fix ConvertContent competing Expanded

**Files:**
- `lib/src/features/convert/widgets/convert_content.dart`
- `lib/src/features/convert/widgets/amount_panel.dart`
- `lib/src/features/convert/widgets/amount_value_row.dart`

**Problem:**
Test "ConvertContent survives text scale 1.3 without overflow" fails with `Competing ParentDataWidgets: Expanded(flex: 1)`. Root cause: `AmountValueRow` uses `Expanded` internally for inline layout, while parent `ConvertContent > Column` also has `Expanded(VisibleRatesList)`. At text scale 1.3, both compete.

**Fix:**
Wrap `AmountPanel` in `Expanded` within `ConvertContent`'s Column, so inner `Expanded` in `AmountValueRow` nests correctly rather than competing with sibling `Expanded(VisibleRatesList)`.

**Verification:**
- Test "ConvertContent survives text scale 1.3" passes
- Convert layout unchanged at normal text scale
- Amount field and rate list still size correctly

---

### T1.6 Add Charts repository interface

**Files (new):**
- `lib/src/features/charts/domain/chart_repository.dart` (interface)
- `lib/src/features/charts/data/rates_service_chart_repository.dart` (impl)

**Files (modified):**
- `lib/src/features/charts/presentation/charts_controller.dart`
- `lib/src/app.dart` (AppShell construction)

**Problem:**
Convert has clean `LatestRatesRepository` interface → `MultiProviderLatestRatesRepository`. Charts passes `RatesService` directly into `ChartsController`. This makes Charts harder to test (requires full RatesService mock vs simple repository mock) and creates tighter coupling.

**Fix:**
1. Create `ChartRepository` abstract class with single method:
   ```dart
   Future<HistoricalSnapshot> getHistoricalRates({
     required String base,
     required String quote,
     required DateTime from,
     required DateTime to,
   });
   ```
2. Create `RatesServiceChartRepository` implementing it via existing `RatesService`
3. Swap `ChartsController` to accept `ChartRepository` instead of `RatesService`
4. Create in `AppShell._initAsync()`, pass to `ChartsScreen`

**Verification:**
- All chart tests pass with repository mock
- Chart loading behavior unchanged
- Historical data displays correctly for all pair types

---

## Tier 2 — Test Gaps (5 tasks)

### T2.1 Calculator expression evaluator tests

**New file:** `test/calculator_test.dart`

**Cover `lib/src/core/calculator/simple_expression_eval.dart`:**

| Case | Input | Expected |
|------|-------|----------|
| Basic add | `100+50` | 150.0 |
| Basic subtract | `100-30` | 70.0 |
| Basic multiply | `12*5` | 60.0 |
| Basic divide | `100/4` | 25.0 |
| Div by zero | `10/0` | null |
| Chain left-to-right | `10+5*2-3` | 17.0 (not 17, left-to-right) |
| Decimal | `10.5+2.3` | 12.8 |
| Empty string | `` | 0.0 |
| Single number | `42` | 42.0 |
| Negative intermediate | `5-10` | -5.0 |

---

### T2.2 Home widget provider tests

**New file:** `test/home_widget_test.dart`

**Cover:**
- `WidgetData` serialization round-trip (toJson → fromJson → equals)
- All fields non-null by default (base, amount, quote, updated)
- `HomeWidgetProvider.pushData()` with missing plugin returns without error
- `HomeWidgetProvider.clearData()` resets to empty map

---

### T2.3 Currency groups tests

**New file:** `test/currency_groups_test.dart`

**Cover `lib/src/core/currency/currency_groups.dart`:**

| Case | Expected |
|------|----------|
| All 34 fiat currencies assigned to exactly one region | No overlaps, no orphans |
| Europe section has exactly 10 codes | EUR, GBP, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON |
| Americas section has 8 codes | USD, CAD, AUD, MXN, BRL, ARS, CLP, COP |
| AsiaPacific section has 12 codes | JPY, CNY, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR, TWD, NZD |
| MiddleEastAfrica section has 4 codes | TRY, AED, ILS, ZAR |
| Crypto section has 11 codes | BTC, ETH, SOL, XRP, ADA, DOGE, AVAX, USDT, USDC, BNB, MATIC |
| Empty input returns empty groups list | Length 0 |
| Crypto-only input returns only Crypto group | 1 group |
| Default expanded = Crypto only | Other sections collapsed |

---

### T2.4 Rate freshness tests

**New file:** `test/rate_freshness_test.dart`

**Cover `lib/src/features/convert/domain/rate_freshness.dart`:**

| Case | Expected Behavior |
|------|-------------------|
| Weekend rate (Saturday/Sunday) | Label skips to Friday's date |
| Next update on weekday | Falls within expected window |
| Next update on weekend | Skips to Monday |
| Locale: es/de/it/fr/en | Correct translation for each |
| Null rateDate | Shows savedAt timestamp |
| Timezone handling | Uses local device timezone |

---

### T2.5 Favorite usage tracker tests

**New file:** `test/favorite_usage_tracker_test.dart`

**Cover `lib/src/features/favorites/data/favorite_usage_tracker.dart`:**

| Case | Expected |
|------|----------|
| Initial usage count = 0 | 0 |
| After 1 recordUsage | 1 |
| After 3 recordUsage on same pair | 3 |
| Different pairs have independent counts | PairA=2, PairB=1 |
| lastUsedAt updates on each call | Most recent timestamp |
| Sorted order: higher count first | Usage-sorted list correct |
| Tiebreaker: more recent first | Timestamp ordering within same count |
| Persistence: survives recreation | Counts preserved |

---

## Tier 3 — UX Polish (4 tasks)

### T3.1 Split conversion_lens_sheet.dart

**Current:** 471 lines, monolithic. Contains positioning math, quick-value grid, reverse-target panel, close animation.

**Target files:**

| File | Responsibility | Lines |
|------|---------------|-------|
| `conversion_lens_positioner.dart` | Anchor-aware position calculator, show() static method | ~60 |
| `conversion_lens_quick_values.dart` | Preset amount grid (1/2/5/10/100) | ~80 |
| `conversion_lens_reverse_target.dart` | Swap-direction panel with amount field | ~80 |
| `conversion_lens_sheet.dart` | Orchestrator shell, composes above + header/close | ~100 |

**Approach:**
- Extract each concern into its own file
- Keep `ConversionLens.show()` static method on sheet class (it's the public API)
- Internal widgets become private or library-private
- No behavioral changes

---

### T3.2 Deduplicate chart vs convert currency picker

**Current:**
- `chart_currency_picker_sheet.dart`: 447 lines
- `currency_picker_sheet.dart`: 200 lines
- ~70% duplicated: section headers, search field, tile rendering, lock/unlock logic

**Target:** Extract shared base widget:

| File | Responsibility |
|------|---------------|
| `sectioned_currency_picker.dart` | Base StatefulWidget with search, sections, tile builder callback |
| `currency_picker_sheet.dart` | Composes base for convert use-case (no temp badges) |
| `chart_currency_picker_sheet.dart` | Composes base for charts use-case (temp badges, locked actions) |

**Interface:**
```dart
typedef CurrencyTileBuilder = Widget Function({
  required String code,
  required bool isSelected,
  required bool isLocked,
  required bool isUnlocked,
  required VoidCallback onTap,
});
```

**Net reduction:** ~200 lines removed.

---

### T3.3 Reduce amount_input_header.dart

**Current:** 157 lines mixing header layout, base display, cancel/done buttons, expression preview.

**Target files:**

| File | Lines |
|------|-------|
| `sheet_handle_bar.dart` | ~25 (drag handle + title row) |
| `expression_preview.dart` | ~35 (shows current expression while typing) |
| `amount_input_header.dart` | ~80 (orchestrator) |

---

### T3.4 Add pull-to-refresh to Favorites and Charts

**Files:**
- `lib/src/features/favorites/favorites_screen.dart`
- `lib/src/features/charts/charts_screen.dart`

**Fix:**
Wrap each screen body in `RefreshIndicator` with `onRefresh` calling respective controller's `refresh()` method. Convert already has manual refresh; this adds standard gesture support to the other two tabs.

**Behavior:**
- Pull down on Favorites → refreshes favorite pair rates
- Pull down on Charts → reloads historical data for current pair/range
- Uses existing `NidunaRefreshIndicator` (custom branded indicator already in shared widgets)

---

## Tier 4 — File Hygiene (8 tasks)

### 4.1 Split ui_copy.dart (508 → ≤200)

Split into per-locale segments:
- `ui_copy_shared.dart` — keys used by all locales (~80 lines)
- `ui_copy_en.dart` — English defaults (~60 lines)
- `ui_copy_es.dart` — Spanish overrides (~60 lines)
- `ui_copy_de.dart` — German overrides (~60 lines)
- `ui_copy_fr.dart` — French overrides (~60 lines)
- `ui_copy_it.dart` — Italian overrides (~60 lines)
- `ui_copy.dart` — re-exports all, backward-compatible facade (~40 lines)

### 4.2 Split app_theme.dart (384 → ≤200)

Extract:
- `app_text_styles.dart` — heroAmount, heroAmountCompact, screenTitleFraunces, settingsGroupTitle, etc. (~100 lines)
- `app_theme.dart` — spacing tokens, radii, curves, ThemeData factory (~180 lines)

### 4.3 Split rates_service.dart (348 → ≤200)

Extract:
- `cache_policy.dart` — staleness check, dedup key generation, cache-hit/miss/stale classification (~80 lines)
- `rates_service.dart` — orchestration, compose + fallback (~200 lines)

### 4.4 Split monetization_controller.dart (285 → ≤200)

Extract:
- `purchase_flow_handler.dart` — IAP purchase execution, receipt validation stub, entitlement persistence (~100 lines)
- `monetization_controller.dart` — state queries, ad availability, unlock checks (~200 lines)

### 4.5 Split app.dart / AppShell (238 → ≤200)

Extract:
- `tab_router.dart` — tab index management, tab change animation, controller disposal (~60 lines)
- `app.dart` — initialization, provider tree, error boundary (~180 lines)

### 4.6 Simplify charts_controller.dart (242 → ≤200)

After T1.6 (repository pattern), controller simplifies:
- Remove direct `RatesService` dependency
- Repository handles caching/composition
- Target: ≤180 lines

### 4.7 Trim convert_controller.dart (216 → ≤200)

Extract:
- `widget_sync_mixin.dart` — home widget push, notification throttling (~30 lines)
- Controller drops to ~190 lines

### 4.8 Reduce settings_screen.dart (89 → ≤80)

T1.3 (extract controller) naturally reduces this by removing 5 lines of controller construction. Remaining 9 lines over budget addressed by extracting the about section setup into a helper method.

---

## Execution Phases

```
Phase A (Tier 1 — Critical):
  T1.1 JSON parser fix        → 15 min, no deps
  T1.3 SettingsController      → 20 min, no deps
  T1.5 Expanded fix            → 20 min, no deps
  T1.6 Chart repository       → 45 min, do before T1.2/T3.2
  T1.2 Trend arrows pipeline  → 60 min, needs T1.6
  T1.4 Home widget wiring     → 15 min, needs T1.2

Phase B (Tier 2 — Tests):
  T2.1 Calculator tests       → 20 min
  T2.2 Home widget tests       → 15 min
  T2.3 Currency groups tests   → 25 min
  T2.4 Rate freshness tests    → 30 min
  T2.5 Usage tracker tests     → 20 min

Phase C (Tier 3 — UX):
  T3.1 Lens sheet split        → 45 min
  T3.2 Picker dedup           → 90 min, needs T1.6
  T3.3 Input header split      → 30 min
  T3.4 Pull-to-refresh        → 20 min

Phase D (Tier 4 — Hygiene):
  4.1 ui_copy split            → 60 min
  4.2 app_theme split          → 40 min
  4.3 rates_service split      → 45 min
  4.4 monetization split       → 40 min
  4.5 app.dart split            → 35 min
  4.6 charts_controller trim   → 20 min (after T1.6)
  4.7 convert_controller trim  → 20 min
  4.8 settings_screen trim     → 15 min (after T1.3)
```

## Verification Gate

After each phase:

```bash
./scripts/check.sh              # analyzer + test
flutter test --reporter=expanded # full test count
```

**Pass criteria:**
- 0 new analyzer errors/warnings (pre-existing OK)
- Test count ≥ 122 (current baseline), ideally +25 new tests = 147+
- No regressions in existing functionality
- All new/modified files under category limits

## Success Metrics

| Metric | Before | After (target) |
|--------|--------|-----------------|
| Files >200 lines | 15 | **0** |
| Files >widget limit (60) | ~30 | **≤10** |
| Files >screen limit (80) | 2 | **0** |
| Test count | 122 | **147+** (+25 new) |
| Test failures (fixable) | 0 | **0** (T1.5 fixes 1) |
| Hand-rolled parsers | 1 | **0** |
| Half-done features | 1 (trends) | **0** |
| Controllers per-build creation | 1 | **0** |
| Repository pattern coverage | 1/4 screens | **4/4 screens** |
