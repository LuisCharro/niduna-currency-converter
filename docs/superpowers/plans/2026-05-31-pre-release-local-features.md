# Pre-Release Local Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 4 high-value local-only features before first store release: rate trend arrows, auto-sort favorites by usage, built-in calculator, and home screen widget.

**Architecture:** All features are fully offline/local. No backend, no cloud data, no user accounts. Trend uses cached yesterday rates from Frankfurter historical endpoint. Calculator extends existing custom keypad. Favorites adds usage counters to existing SharedPreferences store. Widget reads cached rates via `home_widget` package.

**Tech Stack:** Flutter/Dart, SharedPreferences, home_widget package, Frankfurter API (already integrated)

---

## Task 1: Rate Trend Arrows on Convert Rows

**Files:**
- Modify: `lib/src/features/convert/models/currency_quote.dart`
- Create: `lib/src/features/convert/models/trend_direction.dart`
- Modify: `lib/src/features/convert/domain/latest_rates_snapshot.dart`
- Modify: `lib/src/features/convert/domain/convert_quote_builder.dart`
- Modify: `lib/src/features/convert/widgets/quote_value.dart`

### What it does
Each rate row shows a small colored arrow (green up / red down / neutral flat) indicating whether this currency's rate went up or down vs the last known rate. Uses existing `trendUp` / `trendDown` colors already in `AppColors`. No new color tokens needed.

Data source: Frankfurter historical endpoint (`/v1/{yesterday}..{yesterday}?base=USD`) which is **already wired** for chart history. We just cache one extra day's rates alongside current rates.

- [ ] **Step 1: Create `TrendDirection` enum**

New file `lib/src/features/convert/models/trend_direction.dart`:
```dart
enum TrendDirection { up, down, flat }
```

- [ ] **Step 2: Add `previousRate` + computed trend to `CurrencyQuote`**

Edit `lib/src/features/convert/models/currency_quote.dart` — add field and getters:

```dart
class CurrencyQuote {
  const CurrencyQuote(
    this.symbol,
    this.code,
    this.name,
    this.amount,
    this.rateLine, {
    required this.rate,
    this.favorite = false,
    this.previousRate,
  });

  final String symbol;
  final String code;
  final String name;
  final String amount;
  final String rateLine;
  final double rate;
  final bool favorite;
  final double? previousRate;

  TrendDirection? get trend {
    if (previousRate == null || previousRate! <= 0) return null;
    if (rate > previousRate!) return TrendDirection.up;
    if (rate < previousRate!) return TrendDirection.down;
    return TrendDirection.flat;
  }

  double? get changePercent {
    if (previousRate == null || previousRate! <= 0) return null;
    return ((rate - previousRate!) / previousRate!) * 100;
  }
}
```

- [ ] **Step 3: Add `previousRates` map to `LatestRatesSnapshot`**

Edit `lib/src/features/convert/domain/latest_rates_snapshot.dart`:

```dart
class LatestRatesSnapshot {
  const LatestRatesSnapshot({
    required this.base,
    required this.date,
    required this.savedAt,
    required this.rates,
    this.previousRates,
  });
  // ... existing fields unchanged ...
  final Map<String, double>? previousRates;  // NEW: code -> yesterday's rate
}
```

- [ ] **Step 4: Compute trend in `buildQuotes()`**

Edit `lib/src/features/convert/domain/convert_quote_builder.dart` — around line 38-59, after computing `rate`, look up previousRate and pass to CurrencyQuote constructor:

```dart
final rate = snapshot.rates[currency.code]!;
final previousRate = snapshot.previousRates?[currency.code];  // NEW
// ... return CurrencyQuote(..., previousRate: previousRate)
```

- [ ] **Step 5: Render trend indicator in `QuoteValue`**

Edit `lib/src/features/convert/widgets/quote_value.dart` — add `_TrendBadge` widget after rateLine row. Shows arrow icon + optional percentage. Uses `colors.trendUp` / `colors.trendDown`.

- [ ] **Step 6: Fetch yesterday's rates in fetch pipeline**

Insert into Frankfurter latest-rates client or repository layer: after fetching today's rates, also fetch yesterday's single-day snapshot via same historical endpoint already used by charts. Attach as `previousRates` on `LatestRatesSnapshot`.

- [ ] **Step 7: Verify + commit**

```bash
./scripts/check.sh
git commit -m "feat(convert): add rate trend arrows on each currency row"
```

---

## Task 2: Auto-Sort Favorites by Usage Frequency

**Files:**
- Modify: `lib/src/features/favorites/domain/favorite_pair.dart`
- Modify: `lib/src/features/favorites/data/favorites_store.dart`
- Wire `recordUsage()` at favorite-row tap point

### What it does
Each time a user opens a favorite pair, increment its usage count. Favorites list sorts by usage count descending so frequently-used pairs rise to top. Data in SharedPreferences under new key `'favorite_usage'`.

- [ ] **Step 1: Add `useCount` + `lastUsedAt` to `FavoritePair`**

Edit `lib/src/features/favorites/domain/favorite_pair.dart` — add fields, add `copyWith()`, update equality unchanged.

- [ ] **Step 2: Add tracking methods to `FavoritesStore`**

Edit `lib/src/features/favorites/data/favorites_store.dart`:

- Add `static const _usageKey = 'favorite_usage'`
- Add `Future<void> recordUsage(String base, String quote)` — appends key marker to string list
- Add `int usageCount(String base, String quote)` — counts occurrences
- Add `List<FavoritePair> get sortedPairs` — returns pairs sorted by useCount desc, then lastUsedAt desc
- Update `_save()` / `_load()` for timestamp persistence under `'favorite_timestamps'`

- [ ] **Step 3: Call `recordUsage()` when user taps favorite row**

Find navigation handler in favorite pair row widget. After navigating to Convert, call `favoritesStore.recordUsage(pair.base, pair.quote)`.

- [ ] **Step 4: Swap `pairs` → `sortedPairs` in Favorites UI**

In `FavoritesList.build()`, use `favoritesStore.sortedPairs` instead of `favoritesStore.pairs`. Same type, drop-in replacement.

- [ ] **Step 5: Verify + commit**

```bash
./scripts/check.sh
git commit -m "feat(favorites): auto-sort by usage frequency"
```

---

## Task 3: Built-in Calculator (+−*/÷)

**Files:**
- Create: `lib/src/core/calculator/simple_expression_eval.dart`
- Modify: `lib/src/features/convert/widgets/amount_keypad.dart`
- Modify: `lib/src/features/convert/widgets/amount_input_sheet.dart`

### What it does
Extends custom numeric keypad with operator row (`+`, `-`, `×`, `÷`, `=`). Users type expressions like `100+50*2` and get result on "Done". Simple left-to-right eval (no precedence). Pure local.

- [ ] **Step 1: Create expression evaluator**

New file `lib/src/core/calculator/simple_expression_eval.dart`:

```dart
double? evaluateExpression(String expression) {
  final trimmed = expression.replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/');
  if (trimmed.isEmpty) return null;
  final tokens = <String>[];
  final buffer = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final ch = trimmed[i];
    if ('+-*/'.contains(ch)) {
      if (buffer.isNotEmpty) tokens.add(buffer.toString());
      buffer.clear();
      tokens.add(ch);
    } else { buffer.write(ch); }
  }
  if (buffer.isNotEmpty) tokens.add(buffer.toString());
  if (tokens.isEmpty) return null;
  var result = double.tryParse(tokens[0]);
  if (result == null) return null;
  var i = 1;
  while (i < tokens.length) {
    final op = tokens[i]; i++;
    if (i >= tokens.length) break;
    final nextVal = double.tryParse(tokens[i]);
    if (nextVal == null) break;
    switch (op) {
      case '+': result = result! + nextVal;
      case '-': result = result! - nextVal;
      case '*': result = result! * nextVal;
      case '/': if (nextVal == 0) return null; result = result! / nextVal;
      default: return null;
    }
    i++;
  }
  return result;
}
```

- [ ] **Step 2: Extend `AmountKeypad` with operator row**

Edit `lib/src/features/convert/widgets/amount_keypad.dart`:

- Add callbacks: `void Function(String)? onOperator`, `VoidCallback? onEquals`
- Wrap existing GridView in Column, add operator Row above it
- New `_OpKey` widget class (smaller than `_Key`, uses primary color for operators, `=` is a drag_handle icon with distinct bg)
- Operator row: `[+] [−] [×] [÷] spacer [=]`

- [ ] **Step 3: Add expression state to `AmountInputSheet`**

Edit `lib/src/features/convert/widgets/amount_input_sheet.dart`:

- Import `evaluateExpression`
- Add state: `List<String> _expressionParts = []`, `bool _isExpression = false`
- Add `_handleOperator(String op)` — appends current amount + op to expression parts, clears display
- Add `_handleEquals()` — joins expression parts, calls `evaluateExpression()`, sets result as `_amount`
- Pass `onOperator: _handleOperator, onEquals: _handleEquals` to AmountKeypad

- [ ] **Step 4: Verify + manual test**

Test expressions: `100+50` → 150, `100+50*2` → 300, `10.5+2.5` → 13, `100/3` → 33.33, backspace after operator.

```bash
./scripts/check.sh
git commit -m "feat(convert): built-in calculator (+-*/÷) on amount keypad"
```

---

## Task 4: Home Screen Widget (Android + iOS)

**Files:**
- Modify: `pubspec.yaml` (add `home_widget: ^0.7.0`)
- Create: `lib/src/core/widget/widget_data.dart`
- Create: `lib/src/core/widget/home_widget_provider.dart`
- Create: Android widget XML/Kotlin files
- Create: iOS WidgetKit extension files
- Wire push into ConvertController

### What it shows
Compact home widget displaying: base→quote conversion rate, freshness timestamp, tap launches app to Convert tab. Works on lock screen.

- [ ] **Step 1: Add `home_widget` package, run `flutter pub get`**

- [ ] **Step 2: Create `widget_data.dart` model** (baseCode, quoteCode, rate, amount, convertedAmount, updatedAt — toJson/fromJson)

- [ ] **Step 3: Create `home_widget_provider.dart`** (pushData/clearData wrappers around `HomeWidget.saveWidgetData()`)

- [ ] **Step 4: Wire into ConvertController._stateFromSnapshot()** — push data fire-and-forget via `unawaited()` after building quotes

- [ ] **Step 5: Configure Android** — `widget_info.xml`, layout XML, GlanceAppWidget Kotlin provider (or use home_widget package's Android boilerplate)

- [ ] **Step 6: Configure iOS** — WidgetKit extension target, TimelineProvider Swift implementation, AppGroup UserDefaults bridge

- [ ] **Step 7: Verify on physical device** (widgets don't work well on simulator)

```bash
./scripts/check.sh
git commit -m "feat(widget): home screen widget for quick rate glance"
```

---

## Execution Order

| Order | Task | Effort | Dependencies |
|-------|------|--------|-------------|
| 1 | Rate trend arrows | ~2-3 hrs | None |
| 2 | Auto-sort favorites | ~2 hrs | None |
| 3 | Built-in calculator | ~3-4 hrs | None |
| 4 | Home screen widget | ~1 day | None (but most complex) |

Tasks 1-3 are fully independent and can run in parallel via subagents. Task 4 last due to native platform complexity.

## Risk Notes
- **Trend:** Extra API call for yesterday's rates. Graceful degradation: null previousRate = no arrow shown.
- **Favorites migration:** Existing pairs start at count 0, sort alphabetically until first use.
- **Calculator:** Deliberately simple left-to-right eval. Division-by-zero guard returns null.
- **Widget:** Most complex. Requires native platform config. Consider deferring to post-release if time-constrained.
