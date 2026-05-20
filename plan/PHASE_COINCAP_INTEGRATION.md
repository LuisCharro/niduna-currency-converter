# Plan: CoinCap Integration for Crypto Charts in Release Safe

**Date:** 2026-05-20
**Status:** REVIEWED — ready for implementation with caveats
**Repo:** `/workspace/repos/niduna-currency-converter`

---

## Reviewer Analysis

**Verdict: Small focused change — proceed.** The architecture supports this cleanly. A few gaps in the plan need fixing, but nothing that changes the size estimate.

### Risk Reassessment

| Risk | Original | Revised | Why |
|------|----------|---------|-----|
| Code complexity | None | **Low** | Missing file from plan (crypto_asset.dart), CoinCap response quirks |
| CoinCap goes down | Low/High | **Low/Medium** | No automatic fallback to Unsupported — error just propagates to UI as CryptoUsdHistoryException. This is the same behavior as CoinPaprika today, so no regression. But the plan's wording ("Fallback to UnsupportedCryptoUsdHistoryClient") is misleading — there is no runtime fallback mechanism. |
| CoinCap rate limits | Low/Medium | **Low/Medium** | OK as stated. Existing 1-year cache in `CryptoUsdHistoryCache` handles this well. |
| CoinCap adds commercial restrictions | Low/Medium | Unchanged | Acceptable — monitor ToS annually |

### Code Quality Notes

1. **Architecture is solid.** `CryptoUsdHistoryClient` interface is clean, `ProviderFactory` switch is straightforward, `ProviderConfig` enum-driven config is the right pattern. No refactoring needed.

2. **Missing file in plan: `crypto_asset.dart`** — This is the most important gap. `CryptoAsset` currently has only `coinPaprikaId`. CoinCap uses different IDs (`bitcoin`, `ethereum` — not `btc-bitcoin`). You must either:
   - **(Recommended)** Add a `coinCapId` field to `CryptoAsset` and update the constructor:
     ```dart
     class CryptoAsset {
       const CryptoAsset({required this.code, required this.coinPaprikaId, required this.coinCapId});
       final String code;
       final String coinPaprikaId;
       final String coinCapId;
     }
     ```
     Then: `CryptoAsset(code: 'BTC', coinPaprikaId: 'btc-bitcoin', coinCapId: 'bitcoin')`
   - **(Alternative)** Hardcode the mapping inside the CoinCap client itself (simpler but less extensible if you add more cryptos later)

3. **CoinCap response has 3 important differences from CoinPaprika** the plan doesn't call out clearly:
   - `priceUsd` is a **String** (not num) → needs `double.parse()` with error handling, not a simple cast
   - Response is wrapped in `{"data": [...]}` → need to unwrap the `data` array (CoinPaprika returns a bare array)
   - `start`/`end` params are **millisecond epoch timestamps** → `from.millisecondsSinceEpoch`, not ISO date strings
   - Field is `date` (ISO string) not `timestamp` — minor but affects parsing

4. **`chartsProviderLabel` switch needs a new case** — Currently only handles `coinPaprika` and `none`. Adding `coincap` requires a third case returning something like `'CoinCap historical data'`.

5. **`ProviderFactory` import** — Will need to import the new `coincap_crypto_usd_history_client.dart`.

6. **No breaking changes.** The enum addition is non-breaking (Dart enums are exhaustive only in switch expressions — the factory already uses a switch, so you add a case, done). No existing call sites change.

### Missing Test Coverage

The plan's testing section is entirely manual. This is a gap. Recommended unit tests:

| Test | Priority | Notes |
|------|----------|-------|
| CoinCap client parses valid JSON response | **Must** | Mirror the existing `coinpaprika history client parses daily BTC USD history` test in `test/crypto_charts_test.dart`. Use `_StaticHttpClient` pattern. |
| CoinCap client rejects non-200 status | **Must** | Verify `CryptoUsdHistoryException` on 4xx/5xx |
| CoinCap client rejects empty data array | **Should** | Same validation as CoinPaprika |
| CoinCap client handles string `priceUsd` correctly | **Must** | Edge case: what if `priceUsd` is `null`, empty, or non-numeric? |
| CoinCap implausible price validation | **Should** | Same min/max check as CoinPaprika |
| ProviderFactory returns correct client per profile | **Should** | Prevents wiring bugs |

The test infrastructure already exists — `_StaticHttpClient`, `_FakeCryptoUsdHistoryClient`, etc. are all in `test/crypto_charts_test.dart`. Adding 2-3 tests there is ~30 lines of code.

### Scope Changes Recommended

1. **Add `crypto_asset.dart` to Files to Change table** — Missing from the plan. This is a required change.

2. **Consider splitting the dev sandbox UI into a separate commit or PR** — The sandbox enhancement (table layout, "all providers" enumeration) is a separate concern from the CoinCap integration. It's also the riskiest part for scope creep. If the table design gets bikeshedded, it shouldn't block the CoinCap client. The plan already has a 2-commit strategy — lean into that.

3. **Dev sandbox table may need new `ProviderConfig` methods** — To enumerate "all possible providers" vs "active ones", you'd need something like `static List<CryptoHistoryProvider> get allHistoryProviders => CryptoHistoryProvider.values` and an `isActiveInCurrentProfile` predicate. This is simple but needs design. Consider a minimal version first:
   ```
   Profile: Release safe
   Latest: fawazahmed0/exchange-api
   Charts: CoinCap historical data
   ```
   Then enhance to the table format later.

4. **`data_sources_page.dart` and `data_details_page.dart` should update their text** — Currently `data_sources_page.dart` shows `chartsProviderLabel` as the provider for crypto charts, and `data_details_page.dart` conditionally shows crypto chart text. After CoinCap integration, the `release_safe` build will show "CoinCap historical data" instead of "Disabled in this build" — the detail text should reflect this. The plan doesn't mention these files but they'll need minor text updates.

### Final Size Estimate

| Component | Lines (est.) | Complexity |
|-----------|-------------|------------|
| `coincap_crypto_usd_history_client.dart` (new) | ~90-100 | Low — mirrors CoinPaprika |
| `crypto_asset.dart` (add coinCapId) | ~5 changes | Trivial |
| `provider_config.dart` (enum + switch cases) | ~15 | Trivial |
| `provider_factory.dart` (import + case) | ~5 | Trivial |
| `dev_sandbox_section.dart` (enhanced display) | ~30-50 | Medium — UI layout decisions |
| `data_sources_page.dart` + `data_details_page.dart` | ~10 | Trivial — text only |
| Unit tests | ~50-60 | Low |
| **Total** | **~205-245 lines** | **Small focused change** |

**Bottom line:** This is what it looks like — a small, well-scoped integration. The architecture was designed for exactly this pattern. The main risk is the dev sandbox UI scope, not the CoinCap client itself. Ship the client first, sandbox polish second.

---

## Problem

- `fawazahmed0/exchange-api` license restricts commercial use
- In `release_safe` profile, crypto charts are disabled
- Users in production builds cannot see BTC/ETH historical charts
- Dev sandbox shows minimal info about provider state

---

## Goal

Enable crypto charts in `release_safe` using **CoinCap.io** as the data source, and improve the dev sandbox info panel to show all available providers vs. active ones.

---

## CoinCap.io Facts

- **Base URL:** `https://api.coincap.io/v2`
- **Historical endpoint:** `GET /assets/{id}/history?interval=d1&start={ms}&end={ms}`
- **Auth:** No API key required (free tier)
- **License:** No explicit commercial restriction (unlike fawazahmed0)
- **Supported:** BTC, ETH (primary targets) — others available
- **Rate limits:** Reasonable for mobile app usage patterns
- **Response format:** JSON with `priceUsd` array per day

---

## Scope

### Must
- [ ] Add `coincap` to `CryptoHistoryProvider` enum
- [ ] Create `CoincapCryptoUsdHistoryClient` implementing `CryptoUsdHistoryClient`
- [ ] Wire `coincap` in `ProviderFactory.createCryptoHistoryClient()`
- [ ] Set `release_safe` → `CryptoHistoryProvider.coincap`
- [ ] Update dev sandbox to show: profile, latest provider chain, history provider, all possible providers

### Nice to have (out of scope for this PR)
- [ ] Replace fawazahmed0 for latest prices too (would need license review)
- [ ] Add more crypto assets beyond BTC/ETH
- [ ] Intraday chart granularity

---

## Files to Change

| File | Change |
|------|--------|
| `lib/src/core/rates/provider_config.dart` | Add `coincap` to `CryptoHistoryProvider`, set `release_safe` to use it |
| `lib/src/core/rates/crypto/coincap_crypto_usd_history_client.dart` | **New** — CoinCap history client (~80 lines) |
| `lib/src/core/rates/provider_factory.dart` | Add `CryptoHistoryProvider.coincap` case |
| `lib/src/features/settings/widgets/dev_sandbox_section.dart` | Expand info to show all providers vs. active |

---

## Dev Sandbox UI Enhancement

**Current display:**
```
Profile: Release safe
Latest: fawazahmed0/exchange-api
Charts: Disabled in this build
```

**Proposed display:**
```
Profile: Release safe
Latest (chain): fawazahmed0
History: CoinCap ✓
All history providers: none ✗, coinpaprika (dev), coincap (active)
```

Or even cleaner — a table:
| Provider | Type | Active in Release Safe |
|----------|------|------------------------|
| Frankfurter | Fiat | ✓ (only) |
| fawazahmed0 | Crypto Latest | ✓ (only) |
| CoinPaprika | Crypto Latest + History | dev only |
| CoinCap | Crypto History | ✓ (active) |

---

## Architecture Notes

The provider factory already uses a fallback chain for latest prices and a switch on `CryptoHistoryProvider` for history. Adding CoinCap follows the exact same pattern as the existing `CoinPaprikaCryptoUsdHistoryClient`.

CoinCap response shape:
```json
{
  "data": [
    { "priceUsd": "92341.23", "date": "2025-01-01T00:00:00.000Z" },
    ...
  ]
}
```

Needs normalization to `CryptoUsdHistorySnapshot` format (same as CoinPaprika).

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| CoinCap rate limits | Low | Medium | Cache aggressively, 1-year cache TTL already in place |
| CoinCap goes down | Low | High | Fallback to `UnsupportedCryptoUsdHistoryClient` with clear message |
| CoinCap adds commercial restrictions | Low | Medium | Monitor ToS; app can function without charts if needed |
| Code complexity increase | None | None | CoinCap client mirrors CoinPaprika pattern exactly |

---

## Testing Plan

1. Run with `PROVIDER_PROFILE=release_safe` — confirm charts work for BTC, ETH
2. Run with `PROVIDER_PROFILE=dev_coinpaprika` — confirm charts still work
3. Verify cache invalidation works (date range requests)
4. Manual: check dev sandbox shows correct provider state

---

## Dependencies

None — uses existing `http` package already in pubspec.yaml.

---

## Commit Strategy

1. `feat(crypto): add coincap history provider for release_safe` — core implementation
2. `feat(settings): show all providers in dev sandbox` — UI enhancement

---

## Reviewer Notes

- CoinCap is a ShapeShift product with reasonable usage terms as of 2026-05
- No API key needed — reduces secret management surface
- The `release_safe` profile name will become slightly misleading (we now call an external crypto history API), but the spirit remains: no paid/sponsored data sources