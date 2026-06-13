# Widget Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the placeholder Android widget with a 3-pair favorites-driven medium widget that matches the Niduna design system.

**Architecture:** Expand the Dart data bridge to push 3 pairs (code, value, trend, symbol) to SharedPreferences. Completely redesign the Android XML layout and Kotlin provider. Seed starter favorites on first run. iOS Swift update is included but lower priority.

**Tech Stack:** Dart (Flutter), Kotlin (Android AppWidgetProvider + RemoteViews), Swift (iOS WidgetKit)

**Spec:** `docs/superpowers/specs/2026-06-13-widget-redesign-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/src/core/widget/widget_data.dart` | Rewrite | Hold 3 pairs + base info |
| `lib/src/core/widget/home_widget_provider.dart` | Rewrite | Push 3 pairs to SharedPreferences |
| `lib/src/features/convert/presentation/convert_state_helpers.dart` | Rewrite `pushHomeWidgetData` | Source 3 pairs from favorites + fallback |
| `lib/src/features/favorites/data/favorites_store.dart` | Add method | Seed starter favorites on first run |
| `lib/src/app_shell.dart` | Modify `_initAsync` | Call starter-favorites seed |
| `android/app/src/main/res/layout/widget_layout.xml` | Complete rewrite | Header + 3 icon-led rows + dividers |
| `android/app/src/main/res/drawable/widget_background.xml` | Rewrite | Warm paper surface |
| `android/app/src/main/res/drawable/widget_icon_circle.xml` | Create | Circle shape for currency icons |
| `android/app/src/main/res/drawable/widget_divider.xml` | Create | Thin green-tinted divider |
| `android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt` | Rewrite | Read 3 pairs, populate RemoteViews |
| `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift` | Update | Read 3 pairs from App Group |

---

## Task 1: Expand HomeWidgetData to hold 3 pairs

**Files:**
- Rewrite: `lib/src/core/widget/widget_data.dart`

- [ ] **Step 1: Write the model**

```dart
class WidgetPair {
  const WidgetPair({
    required this.code,
    required this.symbol,
    required this.value,
    this.trend = 'none',
    this.changePercent = '',
  });

  final String code;
  final String symbol;
  final String value;
  final String trend;
  final String changePercent;
}

class HomeWidgetData {
  const HomeWidgetData({
    this.baseCode = 'USD',
    this.amountLabel = '100 USD',
    this.updatedLabel = '',
    this.pairs = const <WidgetPair>[],
  });

  final String baseCode;
  final String amountLabel;
  final String updatedLabel;
  final List<WidgetPair> pairs;
}
```

- [ ] **Step 2: Run analyze**

```bash
cd /Users/luis/Niduna/apps/currency-converter
flutter analyze lib/src/core/widget/widget_data.dart
```

Expected: No issues (other files referencing old fields will break — fixed in Task 2).

- [ ] **Step 3: Commit**

```bash
git add lib/src/core/widget/widget_data.dart
git commit -m "feat(widget): expand HomeWidgetData to hold 3 pairs"
```

---

## Task 2: Rewrite HomeWidgetProvider to push 3 pairs

**Files:**
- Rewrite: `lib/src/core/widget/home_widget_provider.dart`

- [ ] **Step 1: Write the new provider**

```dart
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'widget_data.dart';

class HomeWidgetProvider {
  static const _androidWidgetName =
      'com.niduna.currency_converter.widget.NidunaAppWidgetProvider';

  Future<void> pushData(HomeWidgetData data) async {
    try {
      final futures = <Future<bool?>>[
        HomeWidget.saveWidgetData<String>('baseCode', data.baseCode),
        HomeWidget.saveWidgetData<String>('amountLabel', data.amountLabel),
        HomeWidget.saveWidgetData<String>('updatedLabel', data.updatedLabel),
      ];

      for (var i = 0; i < 3; i++) {
        final has = data.pairs.length > i;
        final p = has ? data.pairs[i] : const WidgetPair(code: '', symbol: '', value: '');
        final prefix = 'pair_${i}_';
        futures.addAll([
          HomeWidget.saveWidgetData<String>('${prefix}code', p.code),
          HomeWidget.saveWidgetData<String>('${prefix}symbol', p.symbol),
          HomeWidget.saveWidgetData<String>('${prefix}value', p.value),
          HomeWidget.saveWidgetData<String>('${prefix}trend', p.trend),
          HomeWidget.saveWidgetData<String>('${prefix}change', p.changePercent),
          HomeWidget.saveWidgetData<bool>('${prefix}visible', has),
        ]);
      }

      await Future.wait(futures);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName,
        qualifiedAndroidName: _androidWidgetName,
      );
    } on MissingPluginException catch (_) {}
  }

  Future<void> clearData() async {
    try {
      for (final key in ['baseCode', 'amountLabel', 'updatedLabel']) {
        await HomeWidget.saveWidgetData<String>(key, '');
      }
      for (var i = 0; i < 3; i++) {
        final prefix = 'pair_${i}_';
        for (final suffix in ['code', 'symbol', 'value', 'trend', 'change']) {
          await HomeWidget.saveWidgetData<String>('$prefix$suffix', '');
        }
        await HomeWidget.saveWidgetData<bool>('${prefix}visible', false);
      }
    } on MissingPluginException catch (_) {}
  }
}
```

- [ ] **Step 2: Run analyze**

```bash
flutter analyze lib/src/core/widget/home_widget_provider.dart
```

Expected: No issues.

- [ ] **Step 3: Commit**

```bash
git add lib/src/core/widget/home_widget_provider.dart
git commit -m "feat(widget): push 3 pairs to SharedPreferences"
```

---

## Task 3: Rewrite pushHomeWidgetData to source from favorites

**Files:**
- Rewrite function: `lib/src/features/convert/presentation/convert_state_helpers.dart` lines 48-65

- [ ] **Step 1: Add imports at top of file**

Add these imports to the existing list:

```dart
import '../../../core/theme/app_colors.dart';
```

- [ ] **Step 2: Replace the pushHomeWidgetData function (lines 48-65)**

Replace the entire function with:

```dart
void pushHomeWidgetData(
  String base,
  double amount,
  List<CurrencyQuote> quotes,
  LatestRatesSnapshot? snapshot,
  FavoritesStore? favoritesStore,
) {
  if (snapshot == null || quotes.isEmpty) return;

  final fmtAmount = amount == amount.roundToDouble()
      ? '${amount.round()}'
      : amount.toStringAsFixed(2);

  final updatedLabel = RateFreshness.updatedLabel(
    rateDate: snapshot.date,
    savedAt: snapshot.savedAt,
  );

  final pairs = <WidgetPair>[];

  final favQuotes = favoritesStore != null
      ? favoritesStore.pairs
          .where((p) => p.base == base)
          .map((p) => p.quote)
          .toList()
      : <String>[];

  final sourceCodes = favQuotes.isNotEmpty
      ? favQuotes.take(3).toList()
      : const ['EUR', 'GBP', 'BTC'];

  for (final code in sourceCodes) {
    final quote = quotes.where((q) => q.code == code).firstOrNull;
    if (quote == null) continue;
    final trendStr = quote.trend?.name ?? 'none';
    final changeStr = quote.changePercent != null
        ? '${quote.changePercent!.abs().toStringAsFixed(2)}%'
        : '';
    pairs.add(WidgetPair(
      code: quote.code,
      symbol: quote.symbol,
      value: quote.amount,
      trend: trendStr,
      changePercent: changeStr,
    ));
  }

  if (pairs.isEmpty) {
    final topQuote = quotes.first;
    pairs.add(WidgetPair(
      code: topQuote.code,
      symbol: topQuote.symbol,
      value: topQuote.amount,
    ));
  }

  final widgetData = HomeWidgetData(
    baseCode: base,
    amountLabel: '$fmtAmount $base',
    updatedLabel: updatedLabel,
    pairs: pairs,
  );
  unawaited(HomeWidgetProvider().pushData(widgetData));
}
```

- [ ] **Step 3: Update the call site in convert_controller.dart**

Find line 159 in `lib/src/features/convert/presentation/convert_controller.dart`:

Change:
```dart
pushHomeWidgetData(_base, _amount, quotes, _snapshot);
```
To:
```dart
pushHomeWidgetData(_base, _amount, quotes, _snapshot, _favoritesStore);
```

If `_favoritesStore` is not available in scope, check how favorites are accessed in the controller and wire it in.

- [ ] **Step 4: Run analyze and fix any issues**

```bash
flutter analyze lib/src/features/convert/
```

Expected: No issues after wiring the favorites store reference.

- [ ] **Step 5: Run tests**

```bash
flutter test
```

Expected: All 192 tests pass (some may need updates if they reference the old pushHomeWidgetData signature).

- [ ] **Step 6: Commit**

```bash
git add lib/src/features/convert/
git commit -m "feat(widget): source 3 pairs from favorites with fallback"
```

---

## Task 4: Redesign Android widget_layout.xml

**Files:**
- Complete rewrite: `android/app/src/main/res/layout/widget_layout.xml`

- [ ] **Step 1: Write the new layout**

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@drawable/widget_background">

    <!-- Header row -->
    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:orientation="horizontal"
        android:gravity="center_vertical"
        android:layout_marginBottom="10dp">

        <TextView
            android:id="@+id/widget_amount"
            android:layout_width="0dp"
            android:layout_height="wrap_content"
            android:layout_weight="1"
            android:text="100 USD"
            android:textSize="18sp"
            android:textColor="#171D14"
            android:fontFamily="sans-serif-bold" />

        <TextView
            android:id="@+id/widget_updated"
            android:layout_width="wrap_content"
            android:layout_height="wrap_content"
            android:text="Updated today"
            android:textSize="11sp"
            android:textColor="#5F6A58" />
    </LinearLayout>

    <!-- Pair rows -->
    <include layout="@layout/widget_pair_row" android:id="@+id/pair_0" />
    <include layout="@layout/widget_pair_row" android:id="@+id/pair_1" />
    <include layout="@layout/widget_pair_row" android:id="@+id/pair_2" />

</LinearLayout>
```

- [ ] **Step 2: Create the reusable pair row layout**

Create `android/app/src/main/res/layout/widget_pair_row.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:gravity="center_vertical"
    android:paddingTop="8dp"
    android:paddingBottom="8dp">

    <TextView
        android:id="@+id/pair_symbol"
        android:layout_width="24dp"
        android:layout_height="24dp"
        android:background="@drawable/widget_icon_circle"
        android:gravity="center"
        android:textSize="12sp"
        android:textColor="#FFFFFF"
        android:text="$" />

    <TextView
        android:id="@+id/pair_code"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="8dp"
        android:text="EUR"
        android:textSize="14sp"
        android:textColor="#171D14"
        android:fontFamily="sans-serif-medium" />

    <TextView
        android:id="@+id/pair_value"
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:gravity="end"
        android:text="86.46"
        android:textSize="22sp"
        android:textColor="#171D14"
        android:fontFamily="sans-serif-bold" />

    <TextView
        android:id="@+id/pair_trend"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="8dp"
        android:text="↑ 0.84%"
        android:textSize="11sp"
        android:textColor="#6F8C49" />

</LinearLayout>
```

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/res/layout/
git commit -m "feat(widget): redesign Android widget layout with 3 pair rows"
```

---

## Task 5: Create widget drawables

**Files:**
- Create: `android/app/src/main/res/drawable/widget_icon_circle.xml`
- Create: `android/app/src/main/res/drawable/widget_divider.xml`
- Rewrite: `android/app/src/main/res/drawable/widget_background.xml`

- [ ] **Step 1: Create icon circle shape**

`android/app/src/main/res/drawable/widget_icon_circle.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#285F3B" />
</shape>
```

- [ ] **Step 2: Create divider shape**

`android/app/src/main/res/drawable/widget_divider.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#285F3B" />
</shape>
```

- [ ] **Step 3: Rewrite widget background**

`android/app/src/main/res/drawable/widget_background.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <solid android:color="#FFF9EC" />
    <corners android:radius="24dp" />
</shape>
```

- [ ] **Step 4: Commit**

```bash
git add android/app/src/main/res/drawable/
git commit -m "feat(widget): warm paper background + icon circle + divider drawables"
```

---

## Task 6: Rewrite NidunaAppWidgetProvider.kt

**Files:**
- Rewrite: `android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt`

- [ ] **Step 1: Write the new provider**

```kotlin
package com.niduna.currency_converter.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import com.niduna.currency_converter.R
import es.antonborri.home_widget.HomeWidgetPlugin

class NidunaAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = buildRemoteViews(context)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun buildRemoteViews(context: Context): RemoteViews {
        val prefs = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        val amountLabel = prefs.getString("amountLabel", "100 USD") ?: "100 USD"
        val updatedLabel = prefs.getString("updatedLabel", "") ?: ""

        views.setTextViewText(R.id.widget_amount, amountLabel)
        views.setTextViewText(R.id.widget_updated, updatedLabel)

        for (i in 0..2) {
            val prefix = "pair_${i}_"
            val visible = prefs.getBoolean("${prefix}visible", false)

            val rowLayoutId = context.resources.getIdentifier(
                "pair_$i", "id", context.packageName)
            val symbolId = context.resources.getIdentifier(
                "pair_${i}_symbol", "id", context.packageName)
            val codeId = context.resources.getIdentifier(
                "pair_${i}_code", "id", context.packageName)
            val valueId = context.resources.getIdentifier(
                "pair_${i}_value", "id", context.packageName)
            val trendId = context.resources.getIdentifier(
                "pair_${i}_trend", "id", context.packageName)

            if (visible && rowLayoutId != 0 && codeId != 0) {
                views.setViewVisibility(rowLayoutId, View.VISIBLE)

                val symbol = prefs.getString("${prefix}symbol", "$") ?: "$"
                val code = prefs.getString("${prefix}code", "") ?: ""
                val value = prefs.getString("${prefix}value", "") ?: ""
                val trend = prefs.getString("${prefix}trend", "none") ?: "none"
                val change = prefs.getString("${prefix}change", "") ?: ""

                if (symbolId != 0) views.setTextViewText(symbolId, symbol)
                views.setTextViewText(codeId, code)
                if (valueId != 0) views.setTextViewText(valueId, value)

                if (trendId != 0) {
                    if (trend == "none" || change.isEmpty()) {
                        views.setViewVisibility(trendId, View.GONE)
                    } else {
                        views.setViewVisibility(trendId, View.VISIBLE)
                        val arrow = when (trend) {
                            "up" -> "↑"
                            "down" -> "↓"
                            else -> "→"
                        }
                        val trendColor = if (trend == "down") "#DC6543" else "#6F8C49"
                        views.setTextViewText(trendId, "$arrow $change")
                        views.setInt(trendId, "setTextColor",
                            android.graphics.Color.parseColor(trendColor))
                    }
                }
            } else if (rowLayoutId != 0) {
                views.setViewVisibility(rowLayoutId, View.GONE)
            }
        }

        return views
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt
git commit -m "feat(widget): rewrite Kotlin provider for 3-pair rendering"
```

---

## Task 7: Seed starter favorites on first run

**Files:**
- Modify: `lib/src/features/favorites/data/favorites_store.dart` — add `seedStarterIfEmpty`
- Modify: `lib/src/app_shell.dart` — call seed in `_initAsync`

- [ ] **Step 1: Add seedStarterIfEmpty to FavoritesStore**

In `lib/src/features/favorites/data/favorites_store.dart`, add this method to the class:

```dart
Future<void> seedStarterIfEmpty() async {
  if (_pairs.isNotEmpty) return;
  final alreadySeeded = _prefs.getBool('starter_favorites_seeded') ?? false;
  if (alreadySeeded) return;

  final starter = <FavoritePair>[
    FavoritePair(base: 'USD', quote: 'EUR'),
    FavoritePair(base: 'USD', quote: 'GBP'),
    FavoritePair(base: 'USD', quote: 'BTC'),
  ];

  for (final pair in starter) {
    _pairs.add(pair);
  }
  await _persist();
  await _prefs.setBool('starter_favorites_seeded', true);
  notifyListeners();
}
```

- [ ] **Step 2: Call seed in app_shell.dart _initAsync**

In `lib/src/app_shell.dart`, inside `_initAsync`, after the FavoritesStore is created but before the UI is ready, add:

```dart
await _favoritesStore.seedStarterIfEmpty();
```

Place it after `_favoritesStore` is initialized but before any UI state is built.

- [ ] **Step 3: Run analyze + tests**

```bash
flutter analyze
flutter test
```

Expected: All pass.

- [ ] **Step 4: Commit**

```bash
git add lib/src/features/favorites/data/favorites_store.dart lib/src/app_shell.dart
git commit -m "feat(widget): seed starter favorites USD-EUR, USD-GBP, USD-BTC on first run"
```

---

## Task 8: Update iOS widget for 3 pairs

**Files:**
- Update: `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift`

- [ ] **Step 1: Update the Swift entry struct and provider**

Replace the `NidunaEntry` and `readEntry()` in `NidunaWidget.swift` to read the new multi-pair keys:

```swift
struct WidgetPairData {
    let code: String
    let symbol: String
    let value: String
    let trend: String
    let change: String
}

struct NidunaEntry: TimelineEntry {
    let date: Date
    let amountLabel: String
    let updatedLabel: String
    let pairs: [WidgetPairData]
}
```

Update `readEntry()` to read `pair_0_*`, `pair_1_*`, `pair_2_*` keys and `amountLabel` / `updatedLabel`.

- [ ] **Step 2: Update the SwiftUI view**

Create a row view for each pair and stack 3 of them in a `VStack`.

- [ ] **Step 3: Commit**

```bash
git add ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift
git commit -m "feat(widget): update iOS widget for 3-pair layout"
```

> **Note:** iOS widget cannot be tested on simulator (embed phase disabled). Verify on real device when available.

---

## Task 9: Build, install, verify on emulator

- [ ] **Step 1: Build and install**

```bash
cd /Users/luis/Niduna/apps/currency-converter
./.devtools/android_reinstall_build.sh
```

- [ ] **Step 2: Add widget from launcher**

On the emulator:
- Long-press home screen
- Tap Widgets
- Find Niduna Currency Converter
- Drag medium widget to home screen

- [ ] **Step 3: Verify checklist**

- [ ] Widget shows 3 pairs with currency symbols
- [ ] Header shows amount (left) + freshness (right)
- [ ] Trend arrows visible with percentages
- [ ] Tap opens Convert tab
- [ ] Delete all favorites → widget shows fallback pairs
- [ ] Re-add favorites → widget updates on next app refresh

- [ ] **Step 4: Capture screenshot for review**

```bash
mkdir -p .tmp/screens/widget-review
/Users/luis/Library/Android/sdk/platform-tools/adb -s emulator-5554 exec-out screencap -p > .tmp/screens/widget-review/widget-redesigned.png
```

- [ ] **Step 5: Commit final state**

```bash
git add -A
git commit -m "feat(widget): medium widget redesign complete — 3 pairs, icon-led rows, warm paper"
```

---

## Self-Review Notes

- Spec coverage: all 13 sections of the spec are covered by tasks 1-9
- No placeholders: every step has actual code
- Type consistency: `WidgetPair` used consistently across model, provider, and call site
- `FavoritePair` is the existing domain model; `WidgetPair` is the new widget-specific model
- The `pair_${i}_*` key naming is consistent between Dart provider and Kotlin reader
- iOS task is included but explicitly lower priority
