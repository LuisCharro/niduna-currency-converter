# iOS Home-Screen Widget — 3-Pair Update Plan

> **Status:** Plan only — NOT yet implemented.
> **Created:** 2026-06-15
> **Plan item:** #4 from `docs/superpowers/plans/2026-06-13-session-summary-and-next.md`
> **Hard caveat:** This work **cannot be runtime-verified in the current environment** — it needs a real iPhone (the WidgetKit extension is disabled by default so the iOS-26 simulator install works, and widgets don't render in unit tests). Execute this when a physical device is available. Treat the Swift here as "blind-written, device-verified later."

---

## Goal

Bring the iOS home-screen widget to parity with the redesigned Android widget: show **up to 3 currency pairs** (symbol + code + value, with a day-over-day trend), driven by the same shared data the Flutter app already pushes, with a "Niduna · Open to load" placeholder when there's no data yet.

## Why it's needed

The Flutter side and the Android widget were redesigned to a 3-pair model. The Flutter bridge (`lib/src/core/widget/home_widget_provider.dart`) now writes **3-pair keys**, but `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift` still reads the **old single-pair keys** and renders one conversion. So on iOS the widget reads keys that are never written → shows placeholder/garbage.

### Data contract (what Flutter writes — do not change without updating both sides)

Written to App Group `group.com.niduna.currencyConverter` via `HomeWidget.saveWidgetData`:

| Key | Type | Example |
|-----|------|---------|
| `baseCode` | String | `"USD"` |
| `amountLabel` | String | `"100 USD"` |
| `updatedLabel` | String | `"Updated Jun 15"` |
| `pair_{i}_code`   (i=0,1,2) | String | `"EUR"` |
| `pair_{i}_symbol` | String | `"€"` |
| `pair_{i}_value`  | String | `"86.34"` |
| `pair_{i}_trend`  | String | `"up"` / `"down"` / `"flat"` / `"none"` |
| `pair_{i}_change` | String | `"0.12%"` (already abs + `%`, may be empty) |
| `pair_{i}_visible`| bool   | `true` / `false` |

**Old keys to stop using:** `quoteCode`, `amount`, `rate`, `convertedAmount`, `updatedAt`.

### Current state of the iOS target

- App Group is configured: `main.dart:22` calls `HomeWidget.setAppGroupId('group.com.niduna.currencyConverter')`; the group is in `ios/Runner/Runner.entitlements` and `ios/Runner/Widgets/NidunaWidget/NidunaWidget.entitlements`.
- The WidgetKit target's **Embed App Extensions** build phase was removed so iOS-26 simulator installs work. Re-add it with the idempotent script:
  ```bash
  GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby ios/scripts/add_widget_target.rb
  ```
- `HomeWidgetProvider.pushData` calls `HomeWidget.updateWidget(androidName:, qualifiedAndroidName:)` with **no `iOSName`**, so WidgetKit never gets reloaded on a data push.

---

## Tasks

### Task 1: Add the iOS reload poke on the Flutter side

**File:** `lib/src/core/widget/home_widget_provider.dart`

In `pushData`, change the `updateWidget` call to also pass the iOS widget kind so WidgetKit reloads when fresh data is saved:

```dart
await HomeWidget.updateWidget(
  androidName: _androidWidgetName,
  qualifiedAndroidName: _androidWidgetName,
  iOSName: 'NidunaCurrencyWidget', // must equal the Swift Widget `kind`
);
```

This is safe on Android (the `iOSName` is ignored there) and is the only Dart change. Verify it doesn't break existing widget tests:

```bash
flutter analyze lib/src/core/widget
flutter test test/home_widget_test.dart
```

Expected: clean + all pass. (These tests assert the saved keys / no-throw behavior, which is unchanged.)

Commit: `feat(ios-widget): reload iOS widget timelines on data push`.

### Task 2: Rewrite `NidunaWidget.swift` for the 3-pair model

**File:** `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift` (full replacement)

Mirror the Android 3-pair design: warm paper background, a small header (`amountLabel` + `updatedLabel`), then up to 3 rows of `symbol · code … value (trend%)`. Trend colors match `DESIGN.md` (`trendUp #6F8C49`, `trendDown #DC6543`). Placeholder when no visible pairs.

```swift
import WidgetKit
import SwiftUI

// Shared store written by the Flutter app via HomeWidget.saveWidgetData.
private enum AppGroup {
  static let id = "group.com.niduna.currencyConverter"
  static let store = UserDefaults(suiteName: id)
}

// Niduna palette (see DESIGN.md).
private enum Palette {
  static let paper = Color(red: 0.96, green: 0.97, blue: 0.94)   // #F6F8EF
  static let ink   = Color(red: 0.09, green: 0.11, blue: 0.08)   // #171D14
  static let muted = Color(red: 0.37, green: 0.42, blue: 0.35)   // #5F6A58
  static let up    = Color(red: 0.44, green: 0.55, blue: 0.29)   // #6F8C49
  static let down  = Color(red: 0.86, green: 0.40, blue: 0.26)   // #DC6543
  static let circle = Color(red: 1.0, green: 0.98, blue: 0.92)   // container
}

struct NidunaPair {
  let code: String
  let symbol: String
  let value: String
  let trend: String   // up | down | flat | none
  let change: String  // e.g. "0.12%" (may be empty)
}

struct NidunaEntry: TimelineEntry {
  let date: Date
  let amountLabel: String
  let updatedLabel: String
  let pairs: [NidunaPair]
}

struct NidunaProvider: TimelineProvider {
  func placeholder(in context: Context) -> NidunaEntry {
    NidunaEntry(
      date: Date(),
      amountLabel: "100 USD",
      updatedLabel: "Updated today",
      pairs: [
        NidunaPair(code: "EUR", symbol: "€", value: "86.34", trend: "down", change: "0.12%"),
        NidunaPair(code: "GBP", symbol: "£", value: "74.57", trend: "up", change: "0.06%"),
        NidunaPair(code: "BTC", symbol: "₿", value: "0.00155", trend: "none", change: ""),
      ]
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (NidunaEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<NidunaEntry>) -> Void) {
    // The app pokes WidgetCenter on every data push; also self-refresh in 4h.
    let next = Date().addingTimeInterval(4 * 60 * 60)
    completion(Timeline(entries: [readEntry()], policy: .after(next)))
  }

  private func readEntry() -> NidunaEntry {
    let store = AppGroup.store
    var pairs: [NidunaPair] = []
    for i in 0..<3 {
      let prefix = "pair_\(i)_"
      let visible = store?.bool(forKey: "\(prefix)visible") ?? false
      let value = store?.string(forKey: "\(prefix)value") ?? ""
      guard visible, !value.isEmpty else { continue }
      pairs.append(
        NidunaPair(
          code: store?.string(forKey: "\(prefix)code") ?? "",
          symbol: store?.string(forKey: "\(prefix)symbol") ?? "",
          value: value,
          trend: store?.string(forKey: "\(prefix)trend") ?? "none",
          change: store?.string(forKey: "\(prefix)change") ?? ""
        )
      )
    }
    return NidunaEntry(
      date: Date(),
      amountLabel: store?.string(forKey: "amountLabel") ?? "",
      updatedLabel: store?.string(forKey: "updatedLabel") ?? "",
      pairs: pairs
    )
  }
}

private struct PairRow: View {
  let pair: NidunaPair

  private var trendColor: Color {
    switch pair.trend {
    case "up": return Palette.up
    case "down": return Palette.down
    default: return Palette.muted
    }
  }

  private var trendArrow: String {
    switch pair.trend {
    case "up": return "arrow.up"
    case "down": return "arrow.down"
    default: return ""
    }
  }

  var body: some View {
    HStack(spacing: 10) {
      ZStack {
        Circle().fill(Palette.circle)
        Text(pair.symbol).font(.system(size: 13, weight: .bold)).foregroundColor(Palette.ink)
      }
      .frame(width: 28, height: 28)

      Text(pair.code).font(.system(size: 13, weight: .semibold)).foregroundColor(Palette.muted)
      Spacer()
      if !trendArrow.isEmpty, !pair.change.isEmpty {
        HStack(spacing: 1) {
          Image(systemName: trendArrow).font(.system(size: 10, weight: .bold))
          Text(pair.change).font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(trendColor)
      }
      Text(pair.value).font(.system(size: 15, weight: .heavy)).foregroundColor(Palette.ink)
    }
  }
}

struct NidunaWidgetEntryView: View {
  var entry: NidunaEntry

  var body: some View {
    if entry.pairs.isEmpty {
      VStack(alignment: .leading, spacing: 4) {
        Text("Niduna").font(.system(size: 16, weight: .heavy)).foregroundColor(Palette.ink)
        Text("Open to load").font(.system(size: 12)).foregroundColor(Palette.muted)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding(16)
      .background(Palette.paper)
    } else {
      VStack(alignment: .leading, spacing: 8) {
        if !entry.amountLabel.isEmpty {
          Text(entry.amountLabel).font(.system(size: 13, weight: .bold)).foregroundColor(Palette.ink)
        }
        ForEach(Array(entry.pairs.enumerated()), id: \.offset) { index, pair in
          PairRow(pair: pair)
          if index < entry.pairs.count - 1 {
            Divider().background(Palette.muted.opacity(0.2))
          }
        }
        Spacer(minLength: 0)
        if !entry.updatedLabel.isEmpty {
          Text(entry.updatedLabel).font(.system(size: 10)).foregroundColor(Palette.muted)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      .padding(14)
      .background(Palette.paper)
    }
  }
}

struct NidunaWidget: Widget {
  let kind = "NidunaCurrencyWidget" // MUST match iOSName in home_widget_provider.dart

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: NidunaProvider()) { entry in
      if #available(iOS 17.0, *) {
        NidunaWidgetEntryView(entry: entry).containerBackground(Palette.paper, for: .widget)
      } else {
        NidunaWidgetEntryView(entry: entry)
      }
    }
    .configurationDisplayName("Niduna Currency")
    .description("Your top currency pairs at a glance")
    .supportedFamilies([.systemMedium])
  }
}

@main
struct NidunaWidgetBundle: WidgetBundle {
  var body: some Widget { NidunaWidget() }
}
```

Notes for the implementer:
- `kind` (`"NidunaCurrencyWidget"`) MUST equal the `iOSName` passed in Task 1.
- iOS 17 requires `.containerBackground(...)` for the widget to draw its background; the `if #available` keeps it building on older SDKs.
- `systemSmall` was dropped (3 rows don't fit a small widget cleanly) — only `.systemMedium`. Add `.systemSmall` later with a 1-pair layout if wanted.
- The symbol-in-circle uses the currency `symbol` glyph (matches Android's symbol circles), not a flag asset — keeps the extension asset-free.

### Task 3: Re-enable the widget target for a device build

The Embed App Extensions phase was removed for simulator installs. Re-add it (idempotent):

```bash
GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby ios/scripts/add_widget_target.rb
cd ios && pod install && cd ..
```

Then a device build:
```bash
flutter build ios --release   # or run from Xcode onto the connected iPhone
```

Do NOT commit a re-enabled Embed phase to `main` if it breaks simulator installs — keep the re-enable as a device-testing step, and decide separately whether to ship it enabled (see Risks).

### Task 4: Device verification (real iPhone)

1. Build/run onto the device.
2. Open the app once (so it pushes widget data), then background it.
3. Add the Niduna medium widget to the home screen.
4. Confirm: up to 3 pairs render with symbol circles, codes, values, and trend arrows/percentages on the pairs that moved; header shows the base amount; footer shows the updated label.
5. Force-refresh in the app (pull to refresh) and confirm the widget updates within a few seconds (the `iOSName` reload poke).
6. Fresh install (no data yet) → confirm the "Niduna / Open to load" placeholder.
7. Capture screenshots for the store listing.

---

## Risks & open decisions

- **Shipping enabled vs disabled:** the target is disabled by default to keep iOS-26 simulator installs working. Before release, decide whether to ship it enabled (requires the Embed phase) and confirm App Store builds + simulator dev both work. This is a release-time decision, not part of the code change.
- **No automated test coverage:** WidgetKit extensions aren't unit-testable in this project. Task 1 (Dart) is the only part with test coverage; Tasks 2–4 rely on device verification.
- **`bool(forKey:)` default:** `UserDefaults.bool(forKey:)` returns `false` for missing keys, which is the desired "not visible" behavior — but it also means a key written as the string `"false"` would read as `false` only if stored as a real Bool. The Dart side writes `pair_i_visible` via `saveWidgetData<bool>`, so it is a real Bool — correct. Don't change the Dart type to String.
- **Symbol glyph coverage:** exotic currency symbols (e.g. `₿`, `₴`) must render in the system font; if any show as tofu on-device, fall back to the `code` text in the circle.

## Out of scope

- `systemSmall` / `systemLarge` families (medium only for v1).
- A configurable widget (pair selection) — that's the separate "Widget configuration UI" item.
- Flag images in the symbol circle (kept asset-free).
