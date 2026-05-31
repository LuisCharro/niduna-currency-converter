# Frankfurter (ECB) — Fiat Exchange Rate Provider

> **Status:** PRIMARY provider for all fiat data in all build profiles.
> **License:** Unlicense (public domain) — commercial use explicitly allowed.
> **Play Store safe:** YES

---

## What It Is

Frankfurter is an open-source API that serves exchange rates sourced from the
**European Central Bank (ECB)** plus 55 central banks worldwide. It is the
canonical free source for daily fiat currency reference rates.

- **Website:** https://frankfurter.dev
- **GitHub:** https://github.com/hakenes/frankfurter
- **Data origin:** ECB daily reference rates + 55 central banks

## License

| Aspect | Detail |
|--------|--------|
| **License type** | Unlicense (public domain equivalent) |
| **Commercial use?** | **Yes — explicitly.** FAQ states: *"Is the API free for commercial use? Yes, absolutely."* |
| **Attribution required?** | No |
| **API key required?** | No |
| **Monthly cost** | $0 |

## Data Offered

| Data type | Coverage | Granularity | Max history |
|-----------|---------|-------------|-------------|
| Latest rates | 200 currencies (all 40 fiat currencies included) | Daily snapshot | N/A (current only) |
| Historical time series | 200 currencies | **Daily** points | Back to 1999 (ECB data start) |

### Supported MVP Currencies (all 16)

USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, TRY, KRW, SGD, HKD, NZD, CHF

**Not supported:** RUB (ECB suspended EUR/RUB on 2022-03-01)

## How This App Uses Frankfurter

### Endpoints called

```
GET https://api.frankfurter.dev/v2/rates?base={BASE}&quotes={QUOTE_CODES}
```
Returns latest rates for all 40 fiat currencies in **one call**.

```
GET https://api.frankfurter.dev/v1/{FROM_DATE}..{TO_DATE}?base={BASE}&symbols={QUOTE}
```
Returns historical daily rates for a date range (used by Charts tab).

### When calls happen

| Trigger | Endpoint | Frequency |
|---------|----------|-----------|
| App opens (if cache stale/expired) | `/v2/rates` | Once per day max |
| User pulls to refresh on Convert tab | `/v2/rates` | User-initiated |
| User views a chart pair+range | `/v1/{range}` | Cached per pair+range |

### Cache behavior

- Latest rates: persisted locally via `SharedPreferencesRatesCache`.
  Shown immediately on app open; refreshed only when stale (>24h or user action).
- Historical chart data: cached persistently per `(base, quote, range)` tuple.
  Reused offline; only new date gaps trigger additional fetches.

### Conversion math

Frankfurter has **no `/convert` endpoint**. The app calculates conversions client-side:

```
converted_amount = user_input × rate_from_frankfurter
```

This means all conversion math happens on-device — no extra API calls.

## Refresh Cadence

- **ECB publishes rates once per business day**, typically around **16:00 CET**
  (Central European Time), Monday–Friday.
- Weekends and ECB holidays: no new rates. Last Friday's rate stays current.
- The app's `RateRefreshPolicy` considers rates "fresh" if fetched on the same calendar day.
- The `DailyRatesInfoSheet` (tap `(i)` icon on Convert) explains this to users:
  *"The free version updates exchange rates once per day."*

## Rate Limits & Constraints

| Constraint | Value |
|------------|-------|
| Hard monthly quota | **None published** |
| Observed soft limit | ~10 requests/minute |
| Auth required | None |
| SSL/TLS | Yes (HTTPS only) |

At current expected scale (<500 DAU), rate limits are not a concern.
Self-hosting via Docker (`lineofflight/frankfurter`) is available if needed at 10K+ DAU.

## Failure Behavior

| Scenario | App behavior |
|----------|-------------|
| Network error + cached data exists | Show cached values with "stale/offline" status indicator |
| Network error + no cache | Show no-data state with retry action |
| Invalid/partial payload | Do NOT overwrite last good cache |
| Server error (5xx) | Same as network error — fall back to cache |

## Code Location

- Client: `lib/src/core/rates/clients/frankfurter_client.dart`
- Cache: `lib/src/core/rates/cache/shared_preferences_rates_cache.dart`
- Freshness policy: `lib/src/core/rates/rate_refresh_policy.dart`
- Factory routing: `lib/src/core/rates/provider_factory.dart` (always selected for fiat)

## Privacy Impact

| Data sent | Value |
|-----------|-------|
| IP address | Yes (every HTTP request — unavoidable) |
| API key | **None** |
| User identifier | **None** |
| App name/header | **None** |
| Request body | **None** (GET only) |

Frankfurter is open-source with no known tracking or user profiling.
Server logs are standard access logs only.
