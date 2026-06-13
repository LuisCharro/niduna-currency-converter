# Local Feature Status Harmonization

> **Created:** 2026-06-13
> **Branch:** `main`
> **Purpose:** Align repo docs around the current truth for Favorites nav, home-screen widgets, trend arrows, and multi-pair chart comparison.

---

## Current Truth

| Area | Status | Notes |
|------|--------|-------|
| Favorites tab in nav | **Live on main** | `lib/src/shared/widgets/floating_pill_nav.dart` includes the Favorites tab. Any doc saying it is hidden is outdated. |
| Android home-screen widget | **Redesigned and verified on main** | Completely redesigned from single-pair placeholder to 3-pair icon-led widget. Warm paper background, currency symbols in circles, thin dividers, trend arrows. Favorites-driven with fallback pairs. Starter favorites seeded on first run. Shows "Niduna · Open to load" placeholder when no data. Runtime-verified on Pixel 7 emulator. See `docs/superpowers/specs/2026-06-13-widget-redesign-design.md`. |
| iOS home-screen widget | **Code complete, disabled by default on main** | WidgetKit target exists and Swift code is wired, but the Embed App Extensions phase was removed to keep iOS 26 simulator installs working. Real-device verification still requires re-adding the embed phase. |
| Rate trend arrows on Convert rows | **Implemented on main** | Yesterday rates are fetched in `ConvertController`, passed into `LatestRatesSnapshot.previousRates`, converted into `CurrencyQuote.previousRate`, and rendered through `TrendBadge` when present. Remaining work is UX verification, not feature implementation. |
| Multi-pair chart comparison | **Deferred** | Still out of Phase 1.x. It requires a new chart information architecture and a dedicated UI redesign pass before coding. |

---

## Recommended Execution Order

1. **Verify Android widget runtime from the launcher**
   - Add the widget to the home screen
   - Confirm it renders the top pair and updates after refresh

2. **Verify Convert trend arrows visually**
   - Confirm badges appear consistently after the yesterday-rates enrichment pass
   - Decide if the current visual treatment needs polish only

3. **Decide whether iOS widget testing is worth doing now**
   - If yes: restore the embed phase and test on a real iPhone
   - If no: keep the current simulator-safe setup and defer until real-device testing time

4. **Treat multi-pair chart comparison as a future design project**
   - Do not start implementation until a dedicated redesign/spec pass defines layout, pair selection, color logic, and readability rules

---

## File References

- Favorites nav: `lib/src/shared/widgets/floating_pill_nav.dart`
- Android widget bridge: `lib/src/core/widget/home_widget_provider.dart`
- Android widget receiver: `android/app/src/main/java/com/niduna/currency_converter/widget/NidunaAppWidgetProvider.kt`
- Android widget manifest entry: `android/app/src/main/AndroidManifest.xml`
- iOS widget code: `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift`
- Trend computation: `lib/src/features/convert/models/currency_quote.dart`
- Trend enrichment: `lib/src/features/convert/presentation/convert_controller_loading.dart`
- Trend rendering: `lib/src/features/convert/widgets/quote_value.dart`
