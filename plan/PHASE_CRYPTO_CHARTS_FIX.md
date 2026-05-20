# Plan: Fix Crypto Charts — Replace Broken CoinCap with CoinGecko

**Date:** 2026-05-20
**Status:** READY — awaiting implementation
**Supersedes:** `PHASE_COINCAP_INTEGRATION.md` (DONE but broken)
**Repo:** `/workspace/repos/niduna-currency-converter`

---

## Problem

CoinCap's free API is dead. The current implementation uses `rest.coincap.io/v2` which returns 404. The new `rest.coincap.io/v3` requires a bearer token (paid plan). **The deployed `release_safe` build has broken crypto charts** — every BTC/ETH chart request fails with a `CryptoUsdHistoryException`.

### Timeline
1. We implemented CoinCap as the crypto history provider (commit `8ac33f7`) — worked fine at the time
2. CoinCap deprecated `api.coincap.io/v2` (connection refused) and `rest.coincap.io/v2` (404)
3. CoinCap v3 (`rest.coincap.io/v3`) now requires paid bearer auth
4. **Result: `release_safe` builds ship with broken crypto charts**

---

## Options Analysis

| Option | Pros | Cons | Verdict |
|--------|------|------|---------|
| **CoinGecko (public)** | Free, no API key, stable, proven. Public endpoint `api.coingecko.com/api/v3` confirmed working (tested 2026-05-20). Returns `[timestamp_ms, price]` pairs. | Rate limit 5-15 calls/min (variable). License: free for non-commercial. | **✅ Recommended** |
| CoinGecko (Demo API) | 100 calls/min, 10K/month — much better rate limits | Requires free API key signup. Adds key management complexity. | Good future upgrade path, but unnecessary now |
| Revert to `none` | Safe, no external dependency | Users lose crypto charts entirely in release builds | Last resort only |
| CoinPaprika for release | Already implemented, works | Was excluded from release due to unclear commercial license | Unchanged reasoning |
| Self-hosted price data | Full control | Massive engineering effort, not worth it for 2 assets | Overkill |
| Frankfurter | Only fiat | No crypto data at all | Not applicable |

### Why CoinGecko works for us
- **Already in the ecosystem**: CoinGecko is the de-facto free crypto data API used by thousands of apps
- **No API key needed** for the public tier — zero secret management
- **BTC + ETH IDs are `bitcoin` and `ethereum`** — same as CoinCap's `coinCapId` field already in `crypto_asset.dart`
- **Historical data confirmed working**: tested `/coins/{id}/market_chart/range` endpoint, returns clean `[ms, price]` pairs
- **Rate limits are fine**: mobile app makes 1 chart request per navigation → well under 5-15/min

---

## Recommended Solution

Replace the CoinCap client with a CoinGecko client. **Minimal change surface** — only the HTTP client implementation changes. Everything else (config, factory, cache, UI) stays the same.

### Key Insight: Reuse `coinCapId` as CoinGecko ID
CoinGecko uses `bitcoin` and `ethereum` as coin IDs — identical to CoinCap's `coinCapId` field. **We can reuse the existing `CryptoAsset.coinCapId` field without renaming it** (or rename to a more generic name in a follow-up). This means `crypto_asset.dart` needs zero changes for this fix.

---

## CoinGecko API Details

### Endpoints (both verified working on public API, no key required)

**Option A: Days-based (simpler)**
```
GET https://api.coingecko.com/api/v3/coins/{id}/market_chart?vs_currency=usd&days={N}
```

**Option B: Range-based (matches current code pattern)**
```
GET https://api.coingecko.com/api/v3/coins/{id}/market_chart/range?vs_currency=usd&from={unix_s}&to={unix_s}
```

**Recommendation: Use Option A (`days=N`)** — simpler, automatically returns daily granularity for >90 days. Our app always requests relative to "now" (up to 1 year), so days-based is a natural fit.

### Response Format
```json
{
  "prices": [
    [1747699777157, 105663.20],
    [1747703549720, 105954.59],
    ...
  ],
  "market_caps": [...],
  "total_volumes": [...]
}
```
- `prices` is an array of `[unix_ms_timestamp, price_usd]` pairs
- Each pair: timestamp is **milliseconds** (like CoinCap), price is a **num** (unlike CoinCap which returned String)
- Only `prices` array is needed — ignore `market_caps` and `total_volumes`

### Data Granularity (automatic, no `interval` param needed)
| Days range | Granularity |
|------------|-------------|
| ≤1 day | 5-minutely |
| 2-90 days | Hourly |
| >90 days | Daily (00:00 UTC) |

Our app uses ranges up to 1 year → **daily granularity automatically**. For shorter ranges (30/90 days), we get hourly data which is even better for chart quality.

### Rate Limits
| Tier | Rate Limit | Monthly Cap | Auth |
|------|-----------|-------------|------|
| Public (no key) | 5-15 calls/min (variable) | None documented | None |
| Demo (free key) | 100 calls/min | 10,000 calls/month | `x-cg-demo-api-key` header |
| Analyst ($29/mo) | 100 calls/min | 100,000 calls/month | API key |

**For our use case**: 1-2 calls per chart view, user navigates manually → well within 5-15/min. If rate limiting becomes an issue, upgrade to Demo tier (free signup, just add header).

### License Considerations
- CoinGecko public API is free for non-commercial use
- Their ToS requires attribution (link to CoinGecko) in apps using the free tier
- **Action**: Add "Data provided by CoinGecko" attribution to the Data Sources page
- For commercial use, paid plans start at $29/mo (Analyst tier)
- **Risk level**: Low — the app is a personal tool / side project. If it goes commercial, $29/mo is reasonable.

---

## Scope

### Files to Change

| File | Change | Lines (est.) |
|------|--------|-------------|
| `lib/src/core/rates/crypto/coingecko_crypto_usd_history_client.dart` | **New file** — CoinGecko history client, replaces CoinCap client | ~85 |
| `lib/src/core/rates/provider_config.dart` | Rename `coincap` enum to `coingecko` (or add `coingecko` and keep `coincap` as deprecated). Update `chartsProviderLabel` and `cryptoHistoryProvider` | ~10 |
| `lib/src/core/rates/provider_factory.dart` | Import CoinGecko client, switch `coincap` case to `coingecko` | ~5 |
| `lib/src/features/settings/widgets/data_sources_page.dart` | Add CoinGecko attribution text | ~3 |
| `lib/src/features/settings/widgets/dev_sandbox_section.dart` | Enhanced provider table (see below) | ~50-70 |
| `test/crypto_charts_test.dart` | Add CoinGecko client test (parse valid response, handle errors) | ~40 |

### Files that DO NOT Change
- `crypto_asset.dart` — `coinCapId` field values (`bitcoin`, `ethereum`) are identical to CoinGecko IDs. Reuse as-is.
- `crypto_usd_history_client.dart` — interface unchanged
- `crypto_usd_history_cache.dart` — cache logic unchanged
- `crypto_usd_history_snapshot.dart` — data model unchanged
- `historical_rate_composer.dart` — composition logic unchanged

### Optional Cleanup (separate PR)
- Rename `CryptoAsset.coinCapId` to `cryptoChartId` or `coinGeckoId` — cosmetic, can wait
- Delete `coincap_crypto_usd_history_client.dart` once CoinGecko is confirmed working
- Consider Demo API key for better rate limits if needed

---

## Dev Sandbox Enhancement

**Current display** (basic):
```
Profile: Release safe
Latest: fawazahmed0/exchange-api
Charts: CoinCap historical data
```

**Proposed display** — show full provider landscape:

```
Provider profile: Release safe

Latest prices:
  fawazahmed0/exchange-api ✓

History provider:
  CoinGecko ✓

All providers:
  ┌──────────────┬─────────────────┬──────────┐
  │ Provider     │ Type            │ Status   │
  ├──────────────┼─────────────────┼──────────┤
  │ Frankfurter  │ Fiat latest+hist│ ✓ active │
  │ fawazahmed0  │ Crypto latest   │ ✓ active │
  │ CoinPaprika  │ Crypto latest+hist│ dev only│
  │ CoinGecko    │ Crypto history  │ ✓ active │
  └──────────────┴─────────────────┴──────────┘
```

### Implementation approach
Add static helper methods to `ProviderConfig` for introspection:
```dart
static String get latestProviderSummary => ...
static String get historyProviderSummary => ...
static List<ProviderInfo> get allProviders => [
  ProviderInfo(name: 'Frankfurter', type: 'Fiat latest+hist', active: true),
  ProviderInfo(name: 'fawazahmed0', type: 'Crypto latest', active: isPlayStoreSafe),
  ProviderInfo(name: 'CoinPaprika', type: 'Crypto latest+hist', active: !isPlayStoreSafe),
  ProviderInfo(name: 'CoinGecko', type: 'Crypto history', active: cryptoChartsEnabled),
];
```

Keep the sandbox enhancement as a **separate commit** from the CoinGecko client fix.

---

## Implementation Steps

### Step 1: Create CoinGecko history client (~85 lines)
Create `lib/src/core/rates/crypto/coingecko_crypto_usd_history_client.dart`:
- Implements `CryptoUsdHistoryClient`
- Uses `GET /coins/{id}/market_chart?vs_currency=usd&days={N}` 
- Calculates `days` from `(to.difference(from).inDays + 1)`
- Parses `prices` array: `[[ms_timestamp, price_num], ...]`
- Normalizes to `Map<DateTime, double>` with date-only keys (same as CoinPaprika/CoinCap)
- Validates: non-empty, plausible price range (same min/max as existing clients)
- Returns `CryptoUsdHistorySnapshot`

### Step 2: Update provider config (~10 lines)
In `provider_config.dart`:
- Option A (clean): Rename `CryptoHistoryProvider.coincap` → `CryptoHistoryProvider.coingecko`
- Update `chartsProviderLabel` to return `'CoinGecko historical data'`
- Update `cryptoHistoryProvider` switch for `releaseSafe` → `CryptoHistoryProvider.coingecko`

### Step 3: Update provider factory (~5 lines)
In `provider_factory.dart`:
- Import `coingecko_crypto_usd_history_client.dart`
- Change `CryptoHistoryProvider.coincap` case to `CryptoHistoryProvider.coingecko` returning `CoinGeckoCryptoUsdHistoryClient()`
- Remove or keep CoinCap import (remove if renaming enum value)

### Step 4: Add attribution (~3 lines)
In `data_sources_page.dart`:
- Add footnote: "Crypto historical data provided by CoinGecko" to the crypto charts card

### Step 5: Add unit tests (~40 lines)
In `test/crypto_charts_test.dart`:
- Test: CoinGecko client parses valid JSON response (prices array with `[ms, price]` pairs)
- Test: CoinGecko client rejects non-200 status
- Use existing `_StaticHttpClient` pattern

### Step 6: Dev sandbox enhancement (~50-70 lines, separate commit)
In `dev_sandbox_section.dart`:
- Add provider summary table using a `Table` widget
- Show profile name, latest provider chain, history provider
- Show all providers with active/inactive status per current profile
- Add helper methods to `ProviderConfig` as needed

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| CoinGecko public rate limit hit | Low | Low | Cache aggressively (1-year cache already in place). Worst case: chart fails gracefully with error message |
| CoinGecko deprecates public API | Low | Medium | Same situation as CoinCap. Mitigated by: (1) architecture supports swapping providers, (2) Demo tier with key is backup plan |
| CoinGecko ToS requires paid plan for app store distribution | Low | Medium | Attributed free tier is fine for non-commercial. If app goes commercial, $29/mo Analyst plan is affordable |
| CoinGecko returns different granularity than expected | Very Low | Low | We normalize to daily timestamps regardless. Hourly data from shorter ranges is a bonus, not a problem |
| `coinCapId` field name is confusing after switch | Low | None | Cosmetic — rename in follow-up. Values are identical for BTC/ETH |
| Existing CoinCap cache entries become stale | None | None | Cache is keyed by code+date range — old entries just expire naturally via TTL |

---

## Total Size Estimate

| Component | Lines | Complexity |
|-----------|-------|------------|
| CoinGecko client (new) | ~85 | Low — mirrors CoinPaprika pattern |
| Provider config changes | ~10 | Trivial |
| Provider factory changes | ~5 | Trivial |
| Data sources attribution | ~3 | Trivial |
| Unit tests | ~40 | Low |
| Dev sandbox enhancement | ~50-70 | Medium — UI layout |
| **Total (core fix)** | **~143 lines** | **Small, focused** |
| **Total (with sandbox)** | **~200-220 lines** | **Still small** |

---

## Commit Strategy

1. **`fix(crypto): replace broken CoinCap with CoinGecko for crypto charts`** — core fix (steps 1-4 + tests). This is the critical fix.
2. **`feat(settings): enhanced dev sandbox provider display`** — sandbox table (step 6). Nice-to-have, separate concern.

---

## Verification

1. Run with `PROVIDER_PROFILE=release_safe` — confirm BTC and ETH charts render with data
2. Run with `PROVIDER_PROFILE=dev_coinpaprika` — confirm CoinPaprika still works (no regression)
3. Verify 1-year cache works: load chart once, go back, load again → should use cache
4. Check Data Sources page shows "CoinGecko" attribution
5. Check dev sandbox shows correct provider state

---

## Lessons Learned

1. **Free APIs can disappear overnight** — CoinCap worked perfectly when we integrated it, then died without warning. The architecture (swappable `CryptoUsdHistoryClient` interface) made this fix possible in ~143 lines.
2. **Verify APIs at deploy time, not just at integration time** — CoinCap was dead when the release was built but we didn't catch it.
3. **Prefer APIs with a clear free tier** — CoinGecko has an explicit free/public tier with documented limits. CoinCap's "free" was always unofficial.
