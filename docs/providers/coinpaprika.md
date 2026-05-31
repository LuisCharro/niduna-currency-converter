# CoinPaprika — Crypto Provider (DEV ONLY)

> **Status:** DEV-ONLY provider. NOT used in release/play-store builds.
> **License:** Proprietary — free plan forbids commercial use.
> **Play Store safe:** NO — must not ship in production builds.

---

## What It Is

CoinPaprika is a cryptocurrency market data API providing real-time and historical
data for 2,500+ cryptocurrencies.

- **Website:** https://coinpaprika.com
- **API docs:** https://coinpaprika.com/api/
- **ToS:** https://coinpaprika.com/api-terms-of-use/

## License — BLOCKING FOR COMMERCIAL USE

| Aspect | Detail |
|--------|--------|
| **License type** | Proprietary Terms of Service |
| **Free plan commercial use?** | **NO** — ToS Section 3.6: *"Commercial use only in Plans other than 'Free'."* |
| **Standard paid plans ($99–$1,499/mo)** | **Still blocks user-facing apps** — all standard plans are for *internal company tools only* |
| **User-facing app display** | Requires separate **Enterprise contract** (custom pricing, sales negotiation) |
| **Attribution required** | Yes — ToS Section 3.9: must display *"Powered by CoinPaprika"* (font size 10+, fully visible) |
| **Jurisdiction** | Polish law, courts in Poznań |
| **Monthly cost (free plan)** | $0 but **commercial use forbidden** |
| **Monthly cost (Enterprise)** | Custom (estimated $500+/mo) |

### Why This Is A Problem

Even if you pay $99/month for the Starter plan, you **cannot** use CoinPaprika data
in an app published on Google Play Store because:

1. Your app shows data to end users → qualifies as "commercial use"
2. All paid plans up to $1,499/mo Ultimate are restricted to "internal tools"
3. You would need a custom Enterprise contract to publish commercially

**This app does NOT use CoinPaprika in release builds.**

## Data Offered

| Data type | Coverage | Granularity | Free plan max |
|-----------|---------|-------------|--------------|
| Ticker/latest | 2,500+ coins | Real-time | 20,000 calls/month |
| Historical OHLCV | 2,500+ coins | Daily, hourly, per-ticker | 20,000 calls/month |
| Historical ticks | Per coin | Daily interval | Up to 1 year lookback |

## How This App Uses CoinPaprika (Dev Builds Only)

### Endpoints called

**Latest BTC + ETH prices** (2 calls):
```
GET https://api.coinpaprika.com/v1/tickers/btc-bitcoin?quotes=USD
GET https://api.coinpaprika.com/v1/tickers/eth-ethereum?quotes=USD
```

**BTC historical chart** (1 call):
```
GET https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start={DATE}&end={DATE}&interval=1d&quote=usd
```

**ETH historical chart** (1 call):
```
GET https://api.coinpaprika.com/v1/tickers/eth-ethereum/historical?start={DATE}&end={DATE}&interval=1d&quote=usd
```

### When calls happen

Only when `PROVIDER_PROFILE=dev_coinpaprika`, which is the default for:

- iOS simulator launches (`.devtools/run_ios_simulator_app.sh`)
- Android emulator launches (`.devtools/android_reinstall_build.sh`)
- Local development

**Release builds** (`scripts/build_apk.sh`, `scripts/build_appbundle.sh`) use
`PROVIDER_PROFILE=release_safe` which routes crypto to **fawazahmed0 only**.

### Fallback chain (dev profile)

```
CoinPaprika (primary)
  ↓ on failure
fawazahmed0 (fallback)
  ↓ on failure
Error shown to user
```

## Rate Limits (Free Plan)

| Constraint | Value |
|------------|-------|
| Monthly call quota | **20,000 calls** |
| Rate limit | ~4 calls/second |
| Auth required | No API key on free plan |

At 300 DAU with daily refresh, estimated usage is ~27,000 calls/month — which would
**exceed the quota**. This is another reason (beyond licensing) why CoinPaprika
cannot scale to production.

## Code Location

- Latest prices client: `lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart`
- History client: `lib/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart`
- Factory routing: `lib/src/core/rates/provider_factory.dart` (`CryptoHistoryProvider.coinPaprika` case — dev profile only)
- Config guard: `lib/src/core/rates/provider_config.dart` — `validateReleaseMode()` throws if release build attempts non-safe profile

## Release Guard

The app enforces this at build time:

```dart
// provider_config.dart
static void validateReleaseMode() {
  if (kReleaseMode && !isPlayStoreSafe) {
    throw StateError(
      'Release builds must use a Play Store safe provider profile.',
    );
  }
}
```

A release (`kReleaseMode=true`) build with `PROVIDER_PROFILE=dev_coinpaprika` will **crash on startup** with a clear error message. This prevents accidental submission of non-compliant builds.

## When Would CoinPaprika Be Safe?

| Condition | Requirement |
|-----------|-------------|
| Internal tool (not shipped to stores) | Free plan OK |
| Shipped to Play Store / App Store | Enterprise contract ($500+/mo est.) |
| Paid plan ($99–$1,499/mo) | Still NOT ok — internal tools only |

## Recommendation

**Keep CoinPaprika as a dev-only testing provider only.** Do not attempt to use it
in production. fawazahmed0 (CC0 license, no rate limit, already integrated) covers
all Phase 1 crypto needs legally and freely.
