# fawazahmed0 / exchange-api — Crypto Rate Provider

> **Status:** PRIMARY crypto provider in `release_safe` builds.
> **License:** CC0-1.0 (Creative Commons Zero — public domain).
> **Release routing:** enabled. Upstream source investigated 2026-10-20; owner decision:
> keep it. Legal exposure low; the material risk is **data availability**.

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

The repository publishes CC0, which permits commercial reuse under the
rights waived. CC0 does not remove other parties' rights.

### Upstream source and risk decision (2026-10-20)

- The maintainer stated in
  [issue #36](https://github.com/fawazahmed0/exchange-api/issues/36) (2022):
  *"I ended up using a stable paid API (I cannot tell the name). I have kept
  the url hidden, because the url has my api keys in it."* Earlier data was
  scraped from Google/Bing. Requests to name the source in 2026
  ([#147](https://github.com/fawazahmed0/exchange-api/issues/147), #36) were
  answered only with a pointer back to that comment.
- `currscript.js` reads `cryptoLink` from env/`links.ini` and parses
  `data[].quote.USD.price` with a CoinMarketCap reference comment. That is
  CoinMarketCap's API shape, so the paid API is very likely CoinMarketCap
  (not confirmed). CMC's current terms allow commercial use integrated in the
  key holder's own product but not redistribution "as a standalone service".
- **Who carries that risk:** the API terms are a contract between the data
  vendor and the key holder (the maintainer). Honest Fern never accepted them.
  Individual prices are facts, not copyrightable works, and the app shows them
  as part of a converter. No illegal use by Honest Fern was identified; any
  vendor dispute would be with the maintainer. This is a practical assessment,
  not formal legal advice.
- **The material risk is availability:** if the vendor revokes the key or the
  maintainer stops publishing, crypto latest/history stops updating (the
  predecessor `currency-api` was already discontinued once in 2024; issue
  #93 "this project keeps breaking"). Fiat via Frankfurter is unaffected.
- **Decision (Luis, 2026-10-20): option A** — keep this provider for launch,
  do not contact the maintainer (low chance of an answer). Do not describe the
  data as licensed or verified. Long-term fix: a paid data subscription served
  through Honest Fern's own VPS API once the app has revenue (see README
  "Future backend direction").

See the [dated review](../release-prep/data-licensing-and-disclosure-review-2026-10-19.md)
and [CC0 terms](https://creativecommons.org/publicdomain/zero/1.0/).

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

This is the key advantage over CoinPaprika or CoinGecko: no published per-client API quota; CDN abuse controls, outages or policy changes can still affect availability.

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

jsDelivr's [privacy policy](https://www.jsdelivr.com/terms/privacy-policy)
describes possible network/usage metadata processing for delivery, security
and statistics. Check its current retention/transfer terms rather than claiming
zero processing or assuming all CDN operators have identical logging policies.
