# fawazahmed0 / exchange-api — Crypto Rate Provider

> **Status:** PRIMARY crypto provider in `release_safe` builds.
> **License:** CC0-1.0 (Creative Commons Zero — public domain).
> **Play Store safe:** YES

---

## What It Is

fawazahmed0/exchange-api is a free, open-source currency dataset published as static
JSON files on CDN. It provides daily snapshots for 200+ currencies including BTC and ETH.

- **GitHub:** https://github.com/fawazahmed0/exchange-api
- **CDN primary:** jsdelivr (`cdn.jsdelivr.net`)
- **CDN fallback:** Cloudflare Pages (`currency-api.pages.dev`)
- **Data format:** Static JSON files (not a dynamic REST API)

## License

| Aspect | Detail |
|--------|--------|
| **License type** | **CC0-1.0** (Creative Commons Zero — full public domain dedication) |
| **Commercial use?** | **Yes** — CC0 grants unrestricted commercial use, modification, distribution |
| **Attribution required?** | No |
| **API key required?** | No |
| **Monthly cost** | $0 |

CC0 is the most permissive license possible. The data is effectively in the public domain.

## Data Offered

| Data type | Coverage | Granularity | Max history |
|-----------|---------|-------------|-------------|
| Latest prices | 200+ currencies incl. BTC, ETH | Daily snapshot | Current only |
| Historical prices | 200+ currencies incl. BTC, ETH | **Daily** snapshots | Per-date JSON files (effectively unlimited) |

### How historical data works

Unlike a normal API with a range endpoint, fawazahmed0 serves **one JSON file per date**:

```
https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@{YYYY-MM-DD}/v1/currencies/usd.min.json
```

Each file contains all currency prices for that date. To build a chart time series,
the app fetches individual daily files and composes them into a `Map<DateTime, double>`.

## How This App Uses fawazahmed0

### Endpoints called

**Latest BTC/ETH prices** (Convert tab):
```
GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json
```
Fallback:
```
GET https://latest.currency-api.pages.dev/v1/currencies/usd.json
```

**Historical chart data** (Charts tab, per date):
```
GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@{DATE}/v1/currencies/usd.min.json
```
Fallback:
```
GET https://{DATE}.currency-api.pages.dev/v1/currencies/usd.min.json
```

### When calls happen

| Trigger | Endpoint | Concurrency |
|---------|----------|-------------|
| App opens (crypto latest) | Latest JSON | 1 call (with fallback) |
| User views BTC/ETH chart | One file per date in range | **Batched 10 concurrent** |
| CoinPaprika fails (dev builds) | Latest JSON | Fallback activation |

### Price normalization

The JSON returns prices as `usd.btc = 0.000042` (1 USD = X BTC). The app inverts to get USD price:

```dart
priceUsd = 1 / btcRate  // e.g., 1 / 0.000042 = ~23,809 USD/BTC
```

### Validation (sanity ranges)

Before accepting any price, the app validates:

| Asset | Min valid | Max valid | Ratio check |
|-------|-----------|-----------|-------------|
| BTC | $1,000 | $1,000,000 | BTC/ETH between 1–200 |
| ETH | $50 | $100,000 | (same) |

Implausible prices are rejected and the fallback URL is tried, then an error is raised.

## Refresh Cadence

- fawazahmed0 updates **once per day** (the `@latest` tag points to today's file).
- Matches the app's daily cache policy perfectly.
- Crypto charts are limited to **1 year maximum** in this app (Phase 1 scope).

## Rate Limits & Constraints

| Constraint | Value |
|------------|-------|
| Hard monthly quota | **None** (static CDN files) |
| Rate limit | **None** (CDN-served, not a dynamic API) |
| Auth required | None |
| Concurrent requests | Up to 10 (app-enforced batch size) |
| SSL/TLS | Yes (HTTPS via jsdelivr / Cloudflare) |

This is the key advantage over CoinPaprika or CoinGecko: **zero rate limit risk** because it's serving static files from a major CDN.

## Known Issues

| Issue | Mitigation |
|-------|-----------|
| Occasional bad/inverted values on specific dates | Sanity range validation rejects them; those dates show as gaps in charts |
| Weekend dates may be missing (no trading) | Chart gracefully skips missing dates |
| CDN outage (jsdelivr down) | Automatic failover to Cloudflare Pages mirror |
| Both CDNs down | Error state; cached chart data still displays |

## Failure Behavior

| Scenario | App behavior |
|----------|-------------|
| Primary CDN (jsdelivr) fails | Try Cloudflare Pages fallback automatically |
| Both CDNs fail | Raise `CryptoUsdPriceException`; show error state |
| Individual date file returns 404 | Skip that date (weekend/gap); chart renders with available data |
| Price fails sanity validation | Reject value; try fallback URL; raise if both fail |

## Code Location

- Latest prices client: `lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart`
- History client: `lib/src/core/rates/crypto/fawazahmed_crypto_usd_history_client.dart`
- Cache: `lib/src/core/rates/crypto/crypto_usd_price_cache.dart`, `crypto_usd_history_cache.dart`
- Factory routing: `lib/src/core/rates/provider_factory.dart` (`CryptoHistoryProvider.fawazahmed0` case)

## Build Profile Routing

| Profile | Role | Active? |
|---------|------|---------|
| `release_safe` | **Primary** crypto provider (latest + history) | **YES** |
| `dev_coinpaprika` | Fallback for CoinPaprika latest | YES (fallback only) |

Release builds (`scripts/build_apk.sh`, `scripts/build_appbundle.sh`) default to
`PROVIDER_PROFILE=release_safe`, which uses fawazahmed0 as the sole crypto provider.

## Privacy Impact

| Data sent | Value |
|-----------|-------|
| IP address | Yes (to jsdelivr / Cloudflare CDN — standard infrastructure logging) |
| API key | **None** |
| User identifier | **None** |
| App name/header | **None** |
| Request body | **None** (GET only) |

CDNs log IPs for caching and abuse prevention. No user profiling.
