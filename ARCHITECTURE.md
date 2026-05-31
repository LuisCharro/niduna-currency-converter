# Currency Converter — Architecture

> This file documents the system's architecture, patterns, and data flow.
> Read this before touching data, cache, or network code.

---

## Overview

Architecture principle: **business logic lives outside the UI layer**.

```
lib/src/
├── app.dart
├── app_shell.dart              # AppShell navigation + async init
├── core/
│   ├── rates/                    ← Pure logic (no Flutter widgets)
│   │   ├── models/
│   │   ├── clients/
│   │   ├── cache/
│   │   ├── rates_service.dart
│   │   └── rates_service_helpers.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_text_styles.dart
│   │   └── app_decorations.dart
│   ├── localization/
│   │   └── ui_copy*.dart       # Part files (general/convert/charts/settings/locked)
│   ├── monetization/
│   │   ├── monetization_controller.dart
│   │   └── monetization_entitlements.dart
│   └── widget/
│       └── home_widget_provider.dart
├── features/
│   ├── convert/
│   │   ├── presentation/         ← Controller (ChangeNotifier)
│   │   ├── domain/              ← Convert-specific domain objects
│   │   ├── data/                ← (Legacy) Convert's own data layer
│   │   └── widgets/             ← View (Stateless/StatefulWidget)
│   ├── favorites/
│   ├── charts/
│   │   └── domain/
│   │       └── chart_repository.dart  # Abstract interface
│   └── settings/
└── shared/widgets/
    ├── sectioned_currency_picker.dart
    ├── animated_progress_bar.dart
    └── currency_section_header.dart
```

**Rule:** Widgets never call repositories or clients directly. Controllers connect
services to UI state. Services contain pure business logic with zero Flutter widget imports.

---

## Pattern: MVVM (Flutter's version of MVP)

| Layer | Files | Responsibility |
|-------|-------|----------------|
| **View** | `widgets/` | Render UI. Receive callbacks from controller. Zero business logic. |
| **ViewModel** | `presentation/` (Controller) | Connect service to UI. Transform data for view. Hold UI state. No cache/network logic. |
| **Model** | `core/rates/`, `domain/` | Pure business logic. Data fetching, caching, calculations. |

---

## Current Data Flow (Convert — what works today)

```
App open
  └─ ConvertScreen initState
       └─ ConvertController.load()
            ├─ repository.readCached(base)     → LatestRatesCache (SharedPreferences)
            │                                     ↓ null on first open
            └─ repository.fetchLatest(base)      → FrankfurterLatestRatesClient
                                                   ↓ 1 call, returns all 15 rates
                                                   ↓ saved to cache
            └─ _stateFromSnapshot(snapshot)
                 ├─ state = ConvertState(quotes, status, lastUpdated, ...)
                 ├─ notifyListeners()
                 ├─ _pushHomeWidgetData()     ← also fires on cached load
                 └─ unawaited(_enrichWithYesterdayRates())  ← NEW: background yesterday fetch
                      └─ on success: snapshot.previousRates populated → trend badges show
                          └─ ListenableBuilder → UI rebuilds
```

**API calls by screen:**

| Screen | Calls on open | Calls on user action | Cache behavior |
|--------|---------------|----------------------|----------------|
| Convert | 1 (if no cache) or 0 (if cache fresh) | 1 per refresh | Show cache immediately; refresh stale cache in background |
| Favorites | 0 (reads from Convert's cached rates) | 1 when navigating back to Convert | Reuses Convert's latest snapshot |
| Charts | 1 per pair+range | 1 per new range | Persistent by pair+range |

---

## Problem: Data Layer Lives Inside Feature

Today:

```
lib/src/features/convert/data/
├── frankfurter_latest_rates_client.dart   ← tied to Convert (+fetchYesterdayRates)
├── latest_rates_cache.dart                ← tied to Convert
├── latest_rates_repository.dart           ← tied to Convert (+fetchYesterdayRates)
└── multi_provider_latest_rates_repository.dart
```

If Charts or Favorites need rates, they must either:
1. Duplicate the data layer (code duplication)
2. Import from `features/convert/` (cross-feature coupling)

Neither is acceptable as scope grows.

---

## Solution: `core/rates/` — Shared Rates Module

A module in `lib/src/core/rates/` that is:
- **Inaccessible to UI** (no Flutter widget imports)
- **Shareable across features** (Convert, Charts, Favorites all use it)
- **Swappable** (Frankfurter → Backend VPS without changing consumers)

```
lib/src/core/rates/
├── rates_client.dart           ← abstract interface
├── rates_cache.dart           ← abstract interface
├── rates_service.dart         ← orchestrates cache + network + TTL
├── models/
│   ├── rates_snapshot.dart    ← pure data model
│   └── rates_result.dart      ← service status/result models
└── clients/
    └── frankfurter_client.dart ← concrete implementation
```

### Interfaces

**RatesClient** — how to fetch data from a source:
```dart
abstract class RatesClient {
  Future<RatesSnapshot> fetchLatest(String base);
  Future<HistoricalSnapshot> fetchHistorical({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  });
}
```

**RatesCache** — how to store/retrieve cached data:
```dart
abstract class RatesCache {
  Future<RatesSnapshot?> readLatest(String base);
  Future<void> writeLatest(RatesSnapshot snapshot);
  Future<void> invalidateLatest(String base);
  Future<HistoricalSnapshot?> readHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  });
  Future<void> writeHistorical(HistoricalSnapshot snapshot);
  Future<void> invalidateHistorical({
    required String base,
    required String quote,
    required String rangeKey,
  });
  Future<void> clear();
}
```

**RatesService** — orchestrates cache vs network, handles stale logic:
```dart
class RatesService {
  RatesService({required RatesClient client, required RatesCache cache});

  Future<RatesResult> getLatestRates(String base, {bool forceRefresh = false});
}

enum RatesStatus { fresh, cached, stale, noCache, error }

class RatesResult {
  final RatesSnapshot? snapshot;
  final RatesStatus status;
  final String? message;
}
```

### getLatestRates internal logic:

```
1. forceRefresh == true → skip cache, go to client.fetchLatest
2. Read cache
3. Cache exists AND not stale (age < TTL) → return cached (status: cached)
4. Cache exists AND stale → return stale (status: stale) + background refresh
5. No cache → fetch from client
6. Fetch success → save to cache, return fresh (status: fresh)
7. Fetch fails AND has cache → return stale (status: error) with message
8. Fetch fails AND no cache → return noCache (status: noCache) with message
```

The service deduplicates concurrent latest-rate requests per base currency, so
three simultaneous `USD` misses still produce one network request.

Historical rates are cache-first by `base+quote+rangeKey`. They do not use a TTL
in Phase 1 because historical daily rates are stable enough for MVP usage.

---

## Cache Strategy

| Data | Storage | TTL | Notes |
|------|---------|-----|-------|
| Latest rates | SharedPreferences per base | Configurable (default: 1 hour) | Stale detection via `RatesSnapshot.isStale()` |
| Historical rates | SharedPreferences per base+quote+range | No TTL (historical data doesn't change) | Charts reuses by key |

### Stale Detection

```dart
class RatesSnapshot {
  bool isStale({Duration maxAge = const Duration(hours: 1)}) {
    return DateTime.now().difference(savedAt) > maxAge;
  }
}
```

`isStale()` is pure Dart — no Flutter imports. Can be unit tested without widgets.

---

## Phase 2: Backend VPS Integration

When Phase 2 activates (backend proxy for paid API):

```
RatesService
  └─ client: BackendRatesClient (instead of FrankfurterRatesClient)
       └─ calls: https://your-vps.com/api/rates?base=USD
            └─ VPS calls ExchangeRate-API Pro or self-hosted Frankfurter
```

**No UI changes.** The consumer (`RatesService`) is unaware of which `RatesClient` is injected.

---

## Architectural Rules

1. **Widgets = render only.** No repository calls, no business logic.
2. **Controllers = UI state + service connection.** No cache/network logic.
3. **Services = pure business logic.** Zero Flutter widget imports.
4. **Interfaces always abstract.** Concrete implementations injected at runtime.
5. **No cross-feature imports.** Features communicate via shared services in `core/`.

---

## Existing Patterns in Use

| Pattern | Where | Implementation |
|---------|-------|----------------|
| **Repository** | `ConvertRatesRepository` | Abstract + concrete (Frankfurter) |
| **Observer** | `ConvertController extends ChangeNotifier` | Flutter built-in |
| **Strategy** | `RatesClient` (planned) | Multiple implementations, one interface |
| **Facade** | `RatesService` (planned) | Single entry point for cache + network |
| **State** | `ConvertStatus` enum | Clear, exhaustive state machine |
| **Adapter** | `RatesServiceChartRepository` | Adapts RatesService to ChartRepository interface |

---

## Planned Refactor (Phase A-D — Partially Done)

The `features/convert/data/` layer will eventually be replaced by `core/rates/`:

- ✅ `FrankfurterLatestRatesClient.fetchYesterdayRates()` added
- ✅ `ChartRepository` abstract interface created (`features/charts/domain/chart_repository.dart`)
- ✅ `RatesServiceChartRepository` adapter created (`features/charts/data/rates_service_chart_repository.dart`)
- ✅ `ChartsController` accepts repository instead of raw service
- ⬜ Full migration of `ConvertController._repository` → injected `RatesService` (still pending)
