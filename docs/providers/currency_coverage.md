# Currency Coverage — What Each Provider Offers vs What This App Uses

> **Last updated:** 2026-05-31
> **Purpose:** Complete inventory of available currencies per provider,
> versus what this app actually pulls and displays.

---

## Quick Answer

| | Fiat currencies | Crypto currencies |
|---|---|---|
| **App uses (Convert tab)** | **40** | **11** (BTC, ETH, SOL, XRP, ADA, DOGE, AVAX, USDT, USDC, BNB, MATIC) |
| **App uses (Charts — fiat pairs)** | Any of the 40 as base or quote | N/A |
| **App uses (Charts — crypto pairs)** | N/A | **11** (same as Convert) |
| **Frankfurter offers** | **~200** (ECB + 55 central banks) | None |
| **fawazahmed0 offers** | **200+** | **200+** (incl. all 11 supported cryptos) |
| **CoinPaprika offers (dev only)** | None | **2,500+** |

---

## What This App Actually Displays

### Convert Tab — Rate Rows

The Convert tab shows one row per supported currency:

```
User types: 100 USD
↓ app fetches: GET /v2/rates?base=USD&quotes=EUR,GBP,JPY,...
↓ shows 40 fiat result rows + 11 optional crypto quote rows
```

**40 Fiat Currencies (always shown):**

| Code | Name | Symbol | From Frankfurter? |
|------|------|--------|-------------------|
| USD | US Dollar | $ | YES |
| EUR | Euro | € | YES |
| GBP | British Pound | £ | YES |
| JPY | Japanese Yen | ¥ | YES |
| CHF | Swiss Franc | Fr. | YES |
| SEK | Swedish Krona | kr | YES |
| NOK | Norwegian Krone | kr | YES |
| DKK | Danish Krone | kr | YES |
| PLN | Polish Złoty | zł | YES |
| CZK | Czech Koruna | Kč | YES |
| HUF | Hungarian Forint | Ft | YES |
| RON | Romanian Leu | lei | YES |
| CAD | Canadian Dollar | CA$ | YES |
| AUD | Australian Dollar | AU$ | YES |
| MXN | Mexican Peso | MX$ | YES |
| BRL | Brazilian Real | R$ | YES |
| ARS | Argentine Peso | AR$ | YES |
| CLP | Chilean Peso | CLP$ | YES |
| COP | Colombian Peso | COP$ | YES |
| INR | Indian Rupee | ₹ | YES |
| SGD | Singapore Dollar | S$ | YES |
| HKD | Hong Kong Dollar | HK$ | YES |
| KRW | South Korean Won | ₩ | YES |
| THB | Thai Baht | ฿ | YES |
| PHP | Philippine Peso | ₱ | YES |
| IDR | Indonesian Rupiah | Rp | YES |
| MYR | Malaysian Ringgit | RM | YES |
| TWD | Taiwan Dollar | NT$ | YES |
| NZD | New Zealand Dollar | NZ$ | YES |
| CNY | Chinese Yuan | ¥ | YES |
| TRY | Turkish Lira | ₺ | YES |
| AED | UAE Dirham | AED | YES |
| ILS | Israeli Shekel | ₪ | YES |
| ZAR | South African Rand | R | YES |

**11 Crypto Currencies (quote-only rows in Convert):**

| Code | Name | Source (release_safe) | Source (dev) |
|------|------|---------------------|---------------|
| BTC | Bitcoin | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| ETH | Ethereum | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| SOL | Solana | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| XRP | Ripple | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| ADA | Cardano | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| DOGE | Dogecoin | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| AVAX | Avalanche | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| USDT | Tether USD | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| USDC | USD Coin | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| BNB | BNB | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |
| MATIC | Polygon | fawazahmed0 | CoinPaprika → fawazahmed0 fallback |

Crypto rows show converted amount only (e.g., "₿ 0.00421" for 100 USD → BTC).
They are **not selectable as base currency** in Phase 1.

### Charts Tab — Pair Selector

| Pair type | Base options | Quote options | Max range |
|-----------|-------------|---------------|----------|
| **Fiat/Fiat** | Any of the 40 fiat | Any of the 40 fiat (excluding base) | **2 years** |
| **Crypto/Crypto** | Any of 11 crypto | Any of 11 crypto | **1 year** |
| **Fiat/Crypto** | Any of the 40 fiat | Any of 11 crypto | **1 year** |
| **Crypto/Fiat** | Any of 11 crypto | Any of the 40 fiat | **1 year** |

### Favorites Tab

- User can save up to **3 pairs** (free), **16** with IAP/ads.
- Any combination of the above 51 currencies (40 fiat + 11 crypto).

---

## Provider #1: Frankfurter (fiat — all builds)

### What It Is

Open-source API serving daily reference rates from the **European Central Bank**
plus 55 central banks worldwide.

- **URL:** `https://api.frankfurter.dev`
- **License:** Unlicense (public domain, commercial OK)

### Full Currency Inventory (~200 currencies)

Frankfurter exposes all currencies published by ECB and its partner central banks.
The app requests only 40, but **many more are available**. Notable ones we don't use yet:

#### Major currencies NOT in our MVP list (available from Frankfurter):

| Code | Name | Notes |
|------|------|-------|
| PLN | Polish Złoty | Popular in EU |
| SEK | Swedish Krona | Nordic |
| NOK | Norwegian Krone | Nordic |
| DKK | Danish Krone | Nordic |
| CZK | Czech Koruna | EU |
| HUF | Hungarian Forint | EU |
| RON | Romanian Leu | EU |
| BGN | Bulgarian Lev | EU |
| HRK | Croatian Kuna | EU |
| ISK | Icelandic Króna | Nordic |
| THB | Thai Baht | Asia |
| ZAR | South African Rand | Africa |
| NGN | Nigerian Naira | Africa |
| PHP | Philippine Peso | Asia |
| IDR | Indonesian Rupiah | Asia |
| MYR | Malaysian Ringgit | Asia |
| TWD | Taiwan Dollar | Asia |
| VND | Vietnamese Dong | Asia |
| CLP | Chilean Peso | Latin America |
| ARS | Argentine Peso | Latin America |
| COP | Colombian Peso | Latin America |
| PEN | Peruvian Sol | Latin America |
| UYU | Uruguayan Peso | Latin America |
| ILS | Israeli Shekel | Middle East |
| AED | UAE Dirham | Middle East |
| SAR | Saudi Riyal | Middle East |
| QAR | Qatari Riyal | Middle East |
| BHD | Bahraini Dinar | Middle East |
| KWD | Kuwaiti Dinar | Middle East |
| OMR | Omani Rial | Middle East |
| JOD | Jordanian Dinar | Middle East |
| LBP | Lebanese Pound | Middle East |
| EGP | Egyptian Pound | Middle East |
| MAD | Moroccan Dirham | Africa |
| TND | Tunisian Dinar | Africa |
| GHS | Ghanaian Cedi | Africa |
| KES | Kenyan Shilling | Africa |
| TZS | Tanzanian Shilling | Africa |
| UGX | Ugandan Shilling | Africa |
| XOF | West African CFA Franc | Africa (8 countries) |
| XAF | Central African CFA Franc | Africa (6 countries) |
| XPF | CFP Franc | Pacific (French territories) |
| FJD | Fiji Dollar | Pacific |
| PKR | Pakistani Rupee | South Asia |
| LKR | Sri Lankan Rupee | South Asia |
| NPR | Nepalese Rupee | South Asia |
| BDT | Bangladeshi Taka | South Asia |
| MMK | Myanmar Kyat | Southeast Asia |
| LAK | Lao Kip | Southeast Asia |
| KHR | Cambodian Riel | Southeast Asia |
| MOP | Macanese Pataca | China region |
| MVR | Maldivian Rufiyaa | Indian Ocean |
| SBD | Solomon Islands Dollar | Pacific |
| TOP | Tongan Pa'anga | Pacific |
| WST | Samoan Tala | Pacific |
| BYN | Belarusian Ruble | Eastern Europe |
| MDL | Moldovan Leu | Eastern Europe |
| RSD | Serbian Dinar | Eastern Europe |
| BAM | Bosnia Mark | Balkans |
| MKD | Macedonian Denar | Balkans |
| ALL | Albanian Lek | Balkans |
| GEL | Georgian Lari | Caucasus |
| AMD | Armenian Dram | Caucasus |
| AZN | Azerbaijani Manat | Caucasus |
| KZT | Kazakhstani Tenge | Central Asia |
| UZS | Uzbekistan Som | Central Asia |
| KGS | Kyrgyzstani Som | Central Asia |
| TJS | Tajikistani Somoni | Central Asia |
| MNT | Mongolian Tugrik | East Asia |
| MUR | Mauritian Rupee | Indian Ocean |
| SCR | Seychellois Rupee | Indian Ocean |
| BWP | Botswana Pula | Southern Africa |
| SZL | Swazi Lilangeni | Southern Africa |
| LSL | Lesotho Loti | Southern Africa |
| NAD | Namibian Dollar | Southern Africa |
| BSD | Bahamian Dollar | Caribbean |
| BZD | Belize Dollar | Caribbean |
| KYD | Cayman Islands Dollar | Caribbean |
| TT$ | Trinidad & Tobago Dollar | Caribbean |
| BBD | Barbadian Dollar | Caribbean |
| ANG | Netherlands Antillean Guilder | Caribbean |
| SRD | Surinamese Dollar | Caribbean |
| GYD | Guyanaese Dollar | Caribbean |
| CVE | Cape Verdean Escudo | Atlantic |
| SOS | Somali Shilling | Horn of Africa |
| ERN | Eritrean Nakfa | Horn of Africa |
| DJF | Djiboutian Franc | Horn of Africa |
| GMD | Gambian Dalasi | West Africa |
| ZMW | Zambian Kwacha | Southern Africa |
| MWK | Malawian Kwacha | Southern Africa |
| MGA | Malagasy Ariary | Indian Ocean |
| RWF | Rwandan Franc | East Africa |
| BIF | Burundian Franc | East Africa |
| CDF | Congolese Franc | Central Africa |
| AOA | Angolan Kwanza | Southern Africa |
| MZN | Mozambican Metical | Southern Africa |
| STN | São Tomé/Dobra | Atlantic |
| STD | São Tomé/Dobra | Atlantic |
| VUV | Vanuatu Vatu | Pacific |
| WIR | Special Drawing Rights (IMF basket) | Reserve asset |

**NOT supported by Frankfurter:**

| Code | Reason |
|------|--------|
| **RUB** | Russian Ruble — ECB suspended EUR/RUB on 2022-03-01 after sanctions |
| **BYR** | Belarusian Ruble — not in ECB dataset |
| **Any cryptocurrency** | Frankfurter is fiat-only; no BTC, ETH, etc. |

### How to add more fiat currencies

To add a new fiat currency (e.g., PLN):

1. Add to `supportedFiatCurrencies` list in `supported_currencies.dart`
2. It automatically appears in Convert rate rows, Charts pair picker, and currency picker
3. No provider change needed — Frankfurter already has it
4. One API call (`/v2/rates`) returns ALL 200 currencies regardless of how many you request

**Cost of adding a fiat currency: zero API calls, zero code changes beyond the list.**

---

## Provider #2: fawazahmed0/exchange-api (crypto — release_safe)

### What It Is

Static JSON files served via jsdelivr CDN + Cloudflare Pages fallback.
Published daily by @fawazahmed0 on GitHub.

- **GitHub:** https://github.com/fawazahmed0/exchange-api
- **License:** CC0-1.0 (public domain, commercial OK)
- **Format:** One JSON file per date containing all 200+ currencies vs USD

### Full Crypto Inventory

The `usd.json` snapshot includes **every cryptocurrency** that has a market price
in USD. This is not a curated list — it's essentially "everything with a price."

Notable cryptos available from fawazahmed0 that this app does **NOT** yet use:

| Category | Examples (subset) |
|---------|-------------------|
| Top market cap | SOL, XRP, ADA, DOGE, AVAX, DOT, MATIC, LINK, UNI, ATOM, FIL, NEAR, APT, ICP, HBAR, EGLD, OP, ARB, AAVE, SNX, RUNE, 1INCH, CRV, SUSHI, COMP, AAVE, MKR, YFI, BAL, LDO, GMX, GNS, FXS, QNT, REN, ENJ, LRC, KAVA, INJ, RAD, DIA, BAND, COTI, FLOW, CELO, CHR, RLY, ALCX, AUDIT, GALA, SPELL, LOOKS, IMX, SAND, STORJ, AXS, GMT, GLP, JUP, ORCA, WOO, PERP, KP3R, RDNT, SUSHI, ... |
| Stablecoins | USDT, USDC, DAI, BUSD, UST, TUSD, FRAX, FEI, GUSD, LUSD, MIM, USDN, USDP, USDS, ... |
| Memes/altcoins | SHIB, PEPE, DOGE, BABYDOGE, FLOKI, BONK, CUMRO, ... |
| Layer-2s | MATIC (Polygon), OP (Optimism), ARB (Arbitrum), METIS, ... |
| Exchange tokens | BNB, KCS, KUCOIN, HT, GT, LEO, FTT, ... |
| Privacy coins | XMR, ZEC, DASH, ... |
| DeFi bluechips | AAVE, UNI, COMP, MKR, YFI, LDO, CRV, CVX, FXS, ... |

**Total available: 200+ cryptocurrencies. This app uses 11 (BTC, ETH, SOL, XRP, ADA, DOGE, AVAX, USDT, USDC, BNB, MATIC).**

### How the app picks which cryptos to show

The `crypto_asset.dart` list controls which cryptos have chart/history support:

```dart
const List<CryptoAsset> supportedCryptoAssets = <CryptoAsset>[
  CryptoAsset(code: 'BTC', coinPaprikaId: 'btc-bitcoin', coinCapId: 'bitcoin'),
  CryptoAsset(code: 'ETH', coinPaprikaId: 'eth-ethereum', coinCapId: 'ethereum'),
  CryptoAsset(code: 'SOL', coinPaprikaId: 'sol-solana', coinCapId: 'solana'),
  CryptoAsset(code: 'XRP', coinPaprikaId: 'xrp-xrp', coinCapId: 'ripple'),
  CryptoAsset(code: 'ADA', coinPaprikaId: 'ada-cardano', coinCapId: 'cardano'),
  CryptoAsset(code: 'DOGE', coinPaprikaId: 'doge-dogecoin', coinCapId: 'dogecoin'),
  CryptoAsset(code: 'AVAX', coinPaprikaId: 'avax-avalanche', coinCapId: 'avalanche-2'),
  CryptoAsset(code: 'USDT', coinPaprikaId: 'usdt-tether', coinCapId: 'tether'),
  CryptoAsset(code: 'USDC', coinPaprikaId: 'usdc-usd-coin', coinCapId: 'usd-coin'),
  CryptoAsset(code: 'BNB', coinPaprikaId: 'bnb-binance-coin', coinCapId: 'binancecoin'),
  CryptoAsset(code: 'MATIC', coinPaprikaId: 'matic-polygon-networks', coinCapId: 'polygon-pos'),
];
```

Only these 11 are wired into:
- Convert tab quote rows
- Charts tab pair selector
- Historical chart fetching
- Price validation (sanity range checks)

**Cost of adding another crypto (e.g., DOT):**
1. Add entry to `supportedCryptoAssets` list in `crypto_asset.dart`
2. Add to `supportedCryptoCurrencies` list in `supported_currencies.dart`
3. It appears in Charts pair picker automatically
4. Latest price: already included in fawazahmed0's `usd.json` (no new endpoint needed!)
5. History: fawazahmed0 date-file client already works for any currency in the JSON
6. Zero new API calls or endpoints

---

## Provider #3: CoinPaprika (crypto — dev_only)

### What It Is

Commercial crypto market data API with 2,500+ coins.

- **URL:** https://coinpaprika.com
- **License:** Proprietary — commercial use forbidden on free plan
- **Status:** Dev/emulator builds ONLY

### Full Inventory

CoinPaprika covers **2,500+ cryptocurrencies** across categories:

| Category | Count (approx) | Examples |
|---------|---------------|---------|
| All coins | 2,500+ | Everything on CoinMarketCap top lists |
| Top 100 by market cap | 100 | BTC, ETH, BNB, SOL, XRP, ADA, DOGE, AVAX, DOT, ... |
| Stablecoins | 50+ | USDT, USDC, DAI, BUSD, UST, TUSD, FRAX, FEI, ... |
| DeFi tokens | 500+ | UNI, AAVE, COMP, MKR, SUSHI, CRV, 1INCH, ... |
| Gaming/metaverse | 100+ | AXS, ILV, GALA, IMX, SAND, RAD, ... |
| Layer-2s | 30+ | MATIC, OP, ARB, METIS, ... |
| Exchange tokens | 20+ | BNB, KCS, HT, GT, LEO, FTT, ... |
| Privacy coins | 10+ | XMR, ZEC, DASH, GRIN, ... |

### How dev builds use CoinPaprika

Dev builds (`PROVIDER_PROFILE=dev_coinpaprika`) route through CoinPaprika for:
- **Latest prices:** `/v1/tickers/{id}?quotes=USD` (per coin)
- **Historical charts:** `/v1/tickers/{id}/historical?start={}&end={}&interval=1d&quote=usd`

This app requests only **11 cryptos** even in dev mode. The other 2,489+ coins are available but unused.

### Why we can't ship it

See [`docs/providers/coinpaprika.md`](docs/providers/coinpaprika.md) for full ToS analysis.
Short version: free plan forbids commercial use; all paid plans are internal-tools-only;
user-facing apps need Enterprise contract ($500+/mo).

---

## Summary Matrix

| | Frankfurter | fawazahmed0 | CoinPaprika (dev) |
|---|------------|-------------|-------------------|
| **Build profile** | All builds | release_safe + dev (fallback) | dev_coinpaprika only |
| **Fiat currencies** | ~200 (we use 40) | ~200 (we use 0 directly) | 0 |
| **Crypto currencies** | 0 | ~200+ (we use 11) | ~2,500+ (we use 11) |
| **Historical data** | Daily, ~1999–present, fiat only | Daily snapshots, unlimited history | Daily/hourly/OHLC, up to 1Y+ |
| **Rate limit** | Soft ~10/min | **None** (static CDN) | 20K/mo free |
| **License** | Unlicense (public domain) | **CC0-1.0** (public domain) | Proprietary (commercial ❌) |
| **Auth required** | No | No | No (free plan) |
| **Monthly cost** | $0 | $0 | $0 (but license blocks shipping) |

---

## Expansion Paths (Future Phases)

### Easy additions (zero cost, config change only)

| Addition | Effort | Where |
|----------|-------|-------|
| Add more fiat (PLN already included, others available) | ~2 min | `supported_currencies.dart` |
| Add 12th crypto | ~15 min | `crypto_asset.dart` + UI |
| Show more crypto in Convert (top 20) | ~1 hr | Expand `supportedCryptoCurrencies` |

### Medium effort (new provider or backend)

| Addition | Effort | Where |
|----------|-------|-------|
| All 200 fiat currencies from Frankfurter | ~30 min | Expand list + UI density solution |
| More crypto (top 50) | ~2 hrs | List + validation + charts |
| Intraday/hourly crypto charts | Backend needed | New provider or proxy |
| Metals (XAU/XAG) | New provider | Phase 3 |

### Key constraint

Frankfurter returns **all 200 currencies in one call** regardless of how many you request.
Adding fiat currencies costs nothing in API calls or complexity.
Adding crypto from fawazahmed0 also costs nothing (already in the daily JSON file).
The only limits are **UI space** and **app scope decisions**, not provider availability.
