# Frankfurter — Fiat Exchange Rate Provider

> **Status:** PRIMARY provider for all fiat data in all build profiles.
> **License:** Unlicense (public domain) — commercial use explicitly allowed.
> **Play Store safe:** YES

---

## What It Is

Frankfurter is an open-source API that serves exchange rates sourced from the
**European Central Bank (ECB)** and many other central banks. Its v2 endpoint
blends providers by default, so the latest rate date is not necessarily the ECB
publication date.

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
| Latest rates | ~200 currencies (all 34 app fiat currencies included) | Daily snapshot | N/A (current only) |
| Historical time series | ~200 currencies | **Daily** points | Source-dependent |

### Supported app currencies (all 34)

USD, EUR, GBP, JPY, CNY, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON, CAD,
AUD, MXN, BRL, ARS, CLP, COP, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR,
TWD, NZD, TRY, AED, ILS, ZAR

**Not supported:** RUB (ECB suspended EUR/RUB on 2022-03-01)

## How This App Uses Frankfurter

### Endpoints called

```
GET https://api.frankfurter.dev/v2/rates?base={BASE}&quotes={QUOTE_CODES}
```
Returns latest rates for the requested fiat currencies in **one call**. Without
a `providers` filter, Frankfurter v2 blends its available sources.

```
GET https://api.frankfurter.dev/v2/rates?from={FROM_DATE}&to={TO_DATE}&base={BASE}&quotes={QUOTE_CODES}
```
Returns v2 row-list historical daily rates for a date range (used by Charts
and previous-day trend badges).

### When calls happen

| Trigger | Endpoint | Frequency |
|---------|----------|-----------|
| App opens (if cache stale/expired) | `/v2/rates` | Once per day max |
| User pulls to refresh on Convert tab | `/v2/rates` | User-initiated |
| Convert calculates daily trend badges | `/v2/rates` with `from`/`to` | Once per refresh when needed |
| User views a chart pair+range | `/v2/rates` with `from`/`to` | Cached per pair+range |

### Cache behavior

- Latest rates: persisted locally via `SharedPreferencesRatesCache`.
  Shown immediately on app open; refreshed automatically on the first app open
  of a new local calendar day, or when the user requests a refresh.
- Historical chart data: cached persistently per `(base, quote, range)` tuple.
  Reused offline; only new date gaps trigger additional fetches.

### Conversion math

Frankfurter has **no `/convert` endpoint**. The app calculates conversions client-side:

```
converted_amount = user_input × rate_from_frankfurter
```

This means all conversion math happens on-device — no extra API calls.

## Refresh Cadence

- Frankfurter v2 blends public central-bank sources by default. Individual
  sources publish at different times, and their latest dates may differ.
- The app's `RateRefreshPolicy` considers rates fresh if fetched on the same
  local calendar day. A manual refresh can check again during that day.
- The provider rate date shown in the UI identifies the data snapshot. It may
  stay unchanged on weekends, holidays, or while sources have not published.
  When the Convert snapshot also contains crypto data, the UI uses the older
  of the fiat and crypto dates as the combined snapshot date.
- The `DailyRatesInfoSheet` (tap `(i)` icon on Convert) explains this to users:
  *"The app checks the latest rates from public sources once daily."*

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
