# Currency Converter Roadmap

This file is the practical guide for sequencing product, design, data, and
Flutter implementation work.

Use it together with:

- `DEFINITIONS.md` for product decisions and phase boundaries
- `PLAN.md` for implementation structure and task tracking
- `AGENTS.md` for agent workflow and verification rules

## Current Reality

The repo currently has:

- a Flutter shell with four tabs: `Convert`, `Favorites`, `Charts`, `Settings`
- a Stitch-derived `Convert` visual direction implemented with demo data
- product docs covering privacy, monetization, APIs, and phase boundaries
- repo-local agent docs and skills
- scripts for analysis, tests, and builds

The app is not yet a real data product. The next work should make product,
navigation, API, cache, and screen contracts explicit before adding more
Flutter feature code.

## Product Contract First

Before implementation expands, keep `DEFINITIONS.md` as the source of truth for:

- Phase 1 included features
- Phase 1 excluded features
- Phase 1 data sources
- Phase 1 monetization
- privacy promises
- phase triggers for backend, subscriptions, crypto/metals, and exports
- open questions that block implementation

Do not implement a feature just because it appears in a UI idea or generated
design. If it is not allowed by `DEFINITIONS.md`, update the definition first or
defer the feature.

## Phase 1 Screen Contract

Phase 1 has four primary tabs.

## Phase 1 Screen Matrix

| Tab | Primary job | Required content | Required states | Explicitly excluded |
|-----|-------------|------------------|-----------------|---------------------|
| `Convert` | Convert one amount into the Phase 1 fiat set | amount input, base selector, 16 fiat result rows, favorite star per row, last updated, local-only/privacy signal, refresh action, banner reserve | fresh, loading refresh, cached, stale/offline, fetch error with cached fallback, empty/no-cache error | crypto, transfers, accounts, RUB |
| `Favorites` | Manage up to 3 local pairs | saved pair rows, last known value, delete/edit action, empty state, add/select pair flow | empty, 1-3 saved pairs, max reached, stale value, local storage error | cloud sync, login, unlimited favorites |
| `Charts` | Review fiat history | fiat pair selector, 1W/1M/3M/6M/1Y/2Y ranges, chart, high/low/change, last updated | loading, fresh, cached, stale/offline, no historical data, fetch error with cached fallback | crypto charts, metals, export, multi-pair comparison |
| `Settings` | Configure local behavior and trust surface | default base, decimal precision, theme, refresh-on-open, clear cache, cache status, Remove Ads, privacy/about/version, subscription restore/management entry | normal, cache cleared, restore purchase/loading, IAP unavailable, no network for purchase | accounts, cloud backup |

Use this matrix as the first checklist before generating or editing Stitch
screens. If a screen concept introduces excluded content, reject that part of
the design instead of carrying it into Flutter.

### Convert

Purpose: the main daily-use conversion surface.

Must include:

- Niduna branding
- privacy-first/local-only status
- amount input
- base currency selector
- multi-currency results list
- fiat currencies from the Phase 1 list
- favorite toggle per row
- last updated status
- offline or stale-data indication when relevant
- bottom banner ad area with safe distance from the input

Must not include:

- accounts
- transfers
- aggressive paywall patterns
- RUB
- Phase 2 alert or backend features

### Favorites

Purpose: quick access to saved pairs.

Must include:

- up to 3 favorite pairs in Phase 1
- local-only persistence
- delete/edit affordance
- tap pair to open `Convert` with the same base/quote context
- empty state that stays useful without marketing copy

Must not include:

- cloud sync
- account login
- unlimited favorites unless a later monetization decision allows it

### Charts

Purpose: fiat historical review.

Must include:

- fiat pair selector
- 1W, 1M, 3M, 6M, 1Y, 2Y ranges
- historical line chart
- high, low, and change summary
- loading, cached, stale, and error states

Must not include:

- crypto charts in Phase 1
- metals
- chart export
- multi-pair chart comparison

### Settings

Purpose: app configuration and trust surface.

Must include:

- default base currency
- decimal precision
- theme mode
- refresh-on-open preference
- clear cache
- last updated/cache status
- Remove Ads one-time purchase entry
- privacy policy/about/version

Must not include:

- account settings
- backend account sync
- backend-only subscription features

### Monetization contract (Phase 1)

- Active subscription unlocks all premium app features and hides ads.
- Without subscription, users can still buy one-time unlocks.
- If subscription expires, subscription-only access is removed.
- If subscription expires, one-time unlocks remain active.
- Charts defaults to `USD -> EUR` (with free swap to `EUR -> USD`).
- Charts intraday ranges (`1H`, `6H`, `1D`) are subscription-only.
- Charts "any pair" selection is unlocked by subscription or one-time Charts Pro.

Implementation detail and edge cases live in `.agent/monetization-access-rules.md`.

## Data And Cache Contract

Define data behavior before wiring UI states.

### Fiat Latest Rates

Source:

- Frankfurter v2

App behavior:

- fetch latest rates by base currency
- calculate conversions client-side
- cache last successful payload locally
- show cached data immediately on app open when available
- refresh on app open if user setting allows it
- show offline/stale status when network refresh fails

Phase 1 does not need a backend proxy for fiat rates.

### Fiat Historical Rates

Source:

- Frankfurter historical endpoints

App behavior:

- cache by base currency, quote currency, and range
- reuse cached chart data when offline
- clearly distinguish stale chart data from fresh data

### Crypto Data

Phase 1 does not include crypto data.

Reason:

- CoinGecko Demo API requires a key.
- A mobile app cannot keep that key secret.
- The MVP should avoid backend/API-key complexity.

Revisit BTC/ETH prices only when there is:

- a backend/proxy
- a paid API plan with acceptable key controls
- an explicit decision that a public mobile key is acceptable

### Local User Data

Source:

- device-local storage

Stores:

- favorites
- settings
- latest fiat cache
- historical chart cache
- IAP/ad-removal state when implemented

Phase 1 has no account, no backend, no cloud sync, and no tracking.

## Stitch Before Flutter

Use Stitch after the screen contract is clear.

Recommended order:

1. Generate or refine the canonical `Convert` screen.
2. Generate `Favorites` using the same design system.
3. Generate `Charts` using the same design system.
4. Generate `Settings` using the same design system.
5. Review the four screens as one app system.
6. Create a handoff pack for Flutter.

Stitch should solve visual direction, screen hierarchy, density, and component
language. It should not decide product scope.

Flutter implementation should translate the approved design into native widgets.
Do not try to copy Stitch HTML/CSS one-to-one.

## Flutter Delivery Strategy

Build by vertical slices. Avoid building a large data layer and a large UI layer
separately.

Each slice should include only the data, state, UI, and tests needed for one
user-visible behavior.

### Slice 0: Product And Architecture Baseline

Goal:

- align `DEFINITIONS.md`, `PLAN.md`, and this roadmap
- make Phase 1 screen/API/cache contracts explicit
- confirm dependencies
- keep the existing shell intact

Done when:

- docs agree on Phase 1 scope
- no screen has ambiguous Phase 2 features
- the next Flutter slice has clear acceptance criteria

### Slice 1: Convert With Demo Data

Goal:

- finalize the native Flutter Convert UI based on the approved Stitch direction
- keep demo data isolated
- verify layout on small screens

Done when:

- Convert contains all required Phase 1 visual elements
- widget files remain small
- tests and static analysis pass

### Slice 2: Fiat Latest Rates

Goal:

- add Frankfurter latest-rates client/repository/cache only for Convert
- replace fiat demo values with real data

Done when:

- Convert works online
- Convert works from cache after a successful fetch
- refresh failure leaves usable cached values when available
- tests cover conversion math and repository fallback behavior

## Next Slice Plan: Convert Real Rates

This is the next logical implementation step.

Scope:

- Replace Convert demo values with real Frankfurter latest-rate data.
- Keep the existing four-tab shell and Stitch-derived visual direction.
- Implement only the minimum data/state/cache needed by Convert.
- Do not implement Favorites, Charts, Settings behavior, ads, IAP, backend, or
  crypto in this slice.

### User-Visible Behavior

Convert should:

- show cached values immediately on open when cache exists
- fetch latest fiat rates for the selected base currency
- calculate `amount × rate` client-side
- show 16 Phase 1 fiat currencies, excluding the active base from result rows
- expose a manual refresh action
- show `fresh`, `loading refresh`, `cached`, `stale/offline`, and `no cache`
  states clearly
- keep the banner ad area as a placeholder only

### API Contract

Use Frankfurter v2 directly from the app:

```text
GET https://api.frankfurter.dev/v2/rates?base={BASE}&quotes={QUOTE_CODES}
```

Expected handling:

- `{BASE}` must be one of the Phase 1 fiat codes.
- Response rows are normalized into decimal rates by quote currency.
- If a requested Phase 1 currency is missing from the response, skip that row
  and surface a recoverable data warning in state, not a crash.
- Frankfurter has no `/convert` endpoint; conversion is always local math.

### Cache Contract

Persist only the last successful latest-rates payload per base currency.

Minimum cached fields:

- base currency
- fetched timestamp from the API response when available
- local saved timestamp
- rates map for supported Phase 1 fiat currencies

Failure behavior:

- Network success: update cache and show fresh data.
- Network failure with cache: show cached values and stale/offline status.
- Network failure without cache: show a no-data state with a retry action.
- Invalid/partial payload: do not overwrite the last good cache.

### Suggested File Shape

Keep files small and split early.

Expected additions:

- `lib/src/core/currency/supported_currencies.dart`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
- `lib/src/features/convert/data/latest_rates_cache.dart`
- `lib/src/features/convert/data/latest_rates_repository.dart`
- `lib/src/features/convert/domain/currency_rate.dart`
- `lib/src/features/convert/domain/convert_quote.dart`
- `lib/src/features/convert/domain/convert_state.dart`
- `lib/src/features/convert/presentation/convert_controller.dart`

Expected UI extraction if needed:

- `lib/src/features/convert/presentation/amount_card.dart`
- `lib/src/features/convert/presentation/rate_row.dart`
- `lib/src/features/convert/presentation/rates_status_bar.dart`

The exact names can change, but avoid one large data class or one large screen
file. `ConvertScreen` should orchestrate widgets, not own networking or cache
logic.

### Dependency Bias

Prefer minimal dependencies for this slice.

Acceptable:

- `http` for network calls
- `shared_preferences` for simple JSON cache

Defer unless clearly needed:

- database packages
- broad state-management frameworks
- dependency-injection frameworks
- chart libraries
- ad/IAP packages

### Test Plan

Add tests before calling this slice done:

- conversion math for amount and rates
- supported currency list contains the 16 Phase 1 fiat codes
- no RUB, BTC, ETH, XAU, or XAG in supported currencies
- repository returns fresh data on successful fetch
- repository falls back to cache on network failure
- repository does not overwrite good cache with invalid data
- Convert widget shows the key states: fresh, cached/offline, no-data retry

Verification:

```bash
./scripts/check.sh
```

For UI review, rebuild or hot restart the iOS simulator after checks pass.

### Done Criteria

This slice is done when:

- Convert no longer depends on hard-coded demo rates for normal operation.
- The app still works offline after one successful fetch.
- The user can distinguish fresh data from cached/offline data.
- The implementation follows `AGENTS.md` file-size and modularity rules.
- `./scripts/check.sh` passes.
- No Phase 2/3 concepts enter the code or UI.

### Slice 3: Favorites

Goal:

- persist up to 3 local favorite pairs
- make row stars in Convert meaningful
- implement Favorites tab around the same local store

Done when:

- adding/removing favorites works from Convert and Favorites
- max-3 rule is enforced
- navigation back to Convert with selected pair/context works

### Slice 4: Charts

Goal:

- implement fiat-only historical charts
- add range selection and historical cache

Done when:

- chart data loads for supported fiat pairs
- cached chart data is reused offline
- crypto charts remain unavailable in Phase 1

### Slice 5: Settings

Goal:

- implement user preferences that already affect existing slices
- add cache controls

Done when:

- default base, decimals, theme, and refresh-on-open work
- clearing cache has visible effect
- settings do not introduce account/backend concepts

### Slice 6: Ads And Remove Ads

Goal:

- add banner ad integration and one-time Remove Ads purchase

Done when:

- banner placement respects the Convert screen safe-distance rule
- removed-ads state hides ad surfaces
- store/release privacy implications are documented

### Slice 7: Optional Crypto/Backend Planning

Goal:

- decide whether BTC/ETH prices belong in Phase 2 or Phase 3
- choose backend/proxy/API-key strategy before implementation

Done when:

- no API key is embedded in the mobile app without an explicit documented decision
- crypto scope, monetization, and cache rules are recorded in `DEFINITIONS.md`

## Architecture Guardrails

The calorie app required heavy refactoring after too much lived in one class.
Do not repeat that here.

Rules:

- keep screens thin
- keep business logic out of widgets
- keep each widget focused and reusable
- introduce repositories before API clients leak into UI
- introduce providers/state objects only when a slice needs them
- do not create a giant shared controller for all tabs
- do not merge unrelated tab logic into `app.dart`

Recommended direction:

- feature folders own their screen-specific widgets
- shared widgets stay generic
- data contracts live outside UI files
- caches and repositories are tested without rendering UI

## Decision Gates

Use these gates to avoid surprises:

- Product gate: feature exists in `DEFINITIONS.md`
- Screen gate: feature is assigned to one tab in the screen contract
- Data gate: API/cache/error behavior is defined
- Design gate: Stitch or design notes show the accepted visual direction
- Implementation gate: slice has tests/checks passing
- Release gate: ads, IAP, privacy, and store language have been reviewed

If a change fails one of these gates, stop and update the relevant doc before
expanding code.

## Next Best Step

Complete Slice 3 (Favorites):

- implement local persistence for up to 3 favorite pairs
- integrate star toggle in Convert with favorites storage
- implement Favorites tab around the same local store
- enforce max-3 rule when adding pairs
- navigation back to Convert with selected pair context
