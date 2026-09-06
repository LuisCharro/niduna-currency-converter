# Provider Rate Limits, Licensing, and Call Budget

> Last updated: 2026-09-06
> Purpose: document free provider limits, licensing status for commercial
> publication, how the app makes calls, and replacement strategies.
>
> **Current release boundary (2026-09-06):** the shipped `release_safe` profile
> uses Frankfurter + fawazahmed0 only. CoinGecko is a future backend candidate,
> not a current mobile-app dependency. The backend plan and its licensing gate
> live in `../../docs/strategy/`.

> **Selected future fiat architecture:** use OXR Developer ($12/month or
> $120/year) on the VPS. A server-side worker pulls OXR hourly, validates and
> stores the snapshot, and a public Honest Fern API serves the normalized data
> to the Currency Converter and future apps. The OXR App ID must never be
> embedded in a mobile build. Keep Frankfurter and fawazahmed0 as fallbacks.

---

## Licensing Summary (Can I Publish on Play Store?)

### TL;DR

| Provider | Use in App | License | Commercial Use | Play Store Safe? | Action Needed |
|----------|-----------|---------|----------------|-----------------|---------------|
| **Frankfurter** | Fiat latest + historical | Unlicense (open source) | **Yes — explicitly** stated on their site: *"Is the API free for commercial use? Yes, absolutely."* | **YES** | None |
| **fawazahmed0** | BTC/ETH latest + historical (release_safe) | **CC0-1.0** (public domain) | **Yes** — CC0 allows commercial use, modification, distribution with no restrictions | **YES** | None |
| **CoinPaprika** | BTC/ETH latest + charts (dev only) | Proprietary ToS | **NO** — free plan forbids commercial use; paid plans ($99–$1,499/mo) are **internal tools only**; user-facing apps require custom Enterprise contract | **NO** | Dev-only; not shipped in release builds |
| **CoinGecko** | Future backend candidate; not called by current `release_safe` app | Demo: no standard Commercial licence; Basic+: standard Commercial licence | **Demo: dev/soak only. Basic+: $35/mo monthly or $348/year ($29/mo effective), attribution required** | **Current app: N/A. Future own-VPS endpoint: AMBER until written confirmation** | Do not add to release-safe builds; confirm the VPS endpoint pattern before production |

### Detailed License Analysis

#### Frankfurter — GREEN

- **Source**: https://frankfurter.dev — FAQ section
- **Quote**: *"Is the API free for commercial use? Yes, absolutely."*
- **License**: Unlicense (public domain equivalent). Open-source project on GitHub.
- **Attribution**: Not required
- **Data source**: ECB + 55 central banks (public reference rates)
- **Risk**: None. Publish anywhere, monetize however you want.

#### fawazahmed0/exchange-api — GREEN

- **Source**: https://github.com/fawazahmed0/exchange-api
- **License**: CC0-1.0 (Creative Commons Zero — full public domain dedication)
- **CC0 grants**: commercial use, modification, distribution, no attribution required
- **Served via**: jsdelivr CDN + Cloudflare Pages fallback — both are standard CDN infrastructure
- **Includes**: 200+ currencies including BTC/ETH
- **Risk**: None. Fully open data.

#### CoinPaprika — RED (BLOCKING)

- **Source**: https://coinpaprika.com/api-terms-of-use/
- **ToS Section 2.5 (definition)**: *"Commercial use means any use of API directly or indirectly in connection with any business or other undertaking intended directly or indirectly for any profit."*
- **ToS Section 3.6 (restriction)**: *"You are eligible to use API for Commercial use only in Plans other than 'Free'."*
- **ToS Section 3.9 (attribution)**: Must display *"Powered by CoinPaprika"* in font size 10+, fully visible to users.
- **Even paid plans don't help**: Independent research (CoinGecko comparison, 2026) confirms that **all standard paid plans** ($99/mo Starter through $1,499/mo Ultimate) are restricted to **internal company tools only**. Any application displaying data to end users requires a separate **Enterprise contract** (custom pricing).
- **Jurisdiction**: ToS governed by Polish law, courts in Poznań.
- **Risk**: **HIGH**. Publishing this app on Google Play with CoinPaprika = commercial use = ToS violation, even if you pay $99/mo.

### Google Play Store: Does a Currency Converter Need Special Approval?

#### Financial Features Declaration — Required but Simple

Google requires **every app** to complete a Financial Features Declaration in Play Console
(Policy and programs > App content). The categories are:

| Feature | This app? |
|---------|-----------|
| Cryptocurrency wallet | No |
| Cryptocurrency exchange | No |
| Tokenized digital asset (NFT) | No |
| Stock trading / portfolio management | No |
| Mobile payments / digital wallets | No |
| Banking / loans | No |
| Insurance | No |

**Correct declaration**: *"My app doesn't provide any financial features."*

A currency converter that **displays exchange rates** is not a financial service. It does
not hold funds, execute trades, facilitate transactions, or manage wallets.

#### Cryptocurrency Exchanges & Wallets Policy (2025 Update) — NOT in Scope

Google's 2025 policy targets **actual crypto exchanges and custodial wallets** — apps where
users buy, sell, trade, or store cryptocurrency. Displaying BTC/ETH prices in a converter
is no different from any existing "Crypto & Currency Converter" app already on Play Store.

- Non-custodial wallets: explicitly exempt
- Price display apps: not mentioned in scope
- License requirements: only apply to exchanges/wallets holding or trading user funds

---

## CoinPaprika Replacement Options

Since CoinPaprika **cannot** be used for Play Store publication, the crypto data
needs a different provider. Options ranked by feasibility:

### Option A: Expand fawazahmed0 Usage (Recommended — Free, Immediate)

fawazahmed0 already provides BTC/ETH latest rates as a fallback. It could become
the primary crypto provider.

- **Latest rates**: already works — just promote from fallback to primary
- **Historical charts**: fawazahmed0 supports date-specific URLs
  (`@2025-01-01/v1/currencies/btc.json`) — would need to fetch multiple dates
  and compose a time series. Less elegant but functional for short ranges.
- **Cost**: Free (CC0)
- **Limitation**: daily granularity only, data quality is good but not
  exchange-grade (occasional bad values — app already validates with sanity ranges)
- **Risk**: None (CC0 license)

### Option B: CoinGecko Basic (Future Backend Candidate, Not Current App)

- **Demo**: 10,000 calls/month and 100 calls/minute; intended for testing and
  prototyping. Treat it as development/soak only, not production commercial
  traffic.
- **Basic**: $35/month monthly or $348/year ($29/month effective when billed
  annually); 100,000 call credits/month and 300 calls/minute. Basic includes
  the standard Commercial licence.
- **Attribution**: required on every plan by the API Terms. Use “Data provided
  by CoinGecko” with a direct link to the API page; the Terms also specify
  prominent “Powered by CoinGecko” attribution in a legible font of at least
  size 10.
- **Important boundary**: CoinGecko allows integrating data into a proprietary
  product, but prohibits selling, sublicensing, redistributing or syndicating
  API access. The published sources do not explicitly classify Honest Fern's
  proposed public VPS endpoint serving normalized/derived rates to its own
  app. This remains AMBER until CoinGecko confirms the exact pattern in
  writing; a Custom/Enterprise licence may be required.
- **API key**: required for the server-side plan; never embed it in the mobile
  app.

### Option C: DIA (diadata.org) (Free, No Key)

- **Free crypto price API**: no registration, no API key, no credit card
- **Coverage**: 3,000+ tokens
- **License**: appears permissive but verify terms before publishing
- **Historical data**: check availability and granularity

### Option D: CoinPaprika Enterprise Contract

- **Cost**: Custom pricing (likely $500+/month)
- **Effort**: sales negotiation required
- **When**: only if you need CoinPaprika-specific data and have revenue

### Option E: Drop Crypto Charts for Phase 1 Launch

- Keep BTC/ETH **latest rates** (use fawazahmed0 as primary — CC0, no issues)
- Remove crypto **chart** functionality temporarily
- Add crypto charts back when a compliant provider is integrated
- Simplest path to Play Store release

### Recommended Path

```
Phase 1 (current Play Store release):
  Latest rates:  Frankfurter (fiat) + fawazahmed0 (crypto, promoted to primary)
  Charts:        Frankfurter (fiat) + fawazahmed0 (crypto, daily snapshots)
  Cost:          $0
  License:       Unlicense + CC0; no CoinGecko dependency

Phase 2 (post-release backend, only when freshness justifies it):
  Latest rates:  Honest Fern VPS service with daily fallbacks
  Crypto:        CoinGecko Basic is the candidate for intraday data
  Cost:          $35/mo monthly or $348/year ($29/mo effective), plus taxes
  License:       Standard Commercial + attribution, but own-VPS endpoint
                 requires written confirmation before production
```

---

## Privacy And IP Logging

### What Information Do The Providers See?

When the app calls a provider, the HTTP request contains:

| Data point | Sent? | Details |
|------------|-------|---------|
| **IP address** | **Yes** | Every HTTP request reveals the client IP to the server. This is fundamental to how the internet works. |
| **User-Agent** | Dart's `http` package default | Something like `dart-io/3.x` — identifies the HTTP library, not the user. |
| **API key** | **No** | The app does not send any API key or auth token to any provider. |
| **User ID** | **No** | The app has no accounts, no tracking, no device ID. |
| **App identifier** | **No** | No custom header identifies this app or Honest Fern. |
| **Request body** | No body | All calls are `GET` requests — no personal data in the URL or body. |

### Do They Log IPs?

**Yes, all HTTP servers log IPs by default.** But:

- **Frankfurter**: open-source project. No known tracking or user profiling. Server logs are standard access logs, not analytics. Self-hostable if needed.
- **CoinPaprika**: commercial API service. They likely log IPs for rate limiting (20K/month quota is enforced per IP or per subnet). They have a published Privacy Policy at `coinpaprika.com`. The free plan has no account, so they track usage by IP.
- **fawazahmed0**: served via jsdelivr CDN and Cloudflare. These CDNs log IPs for caching and abuse prevention. No user profiling.

### Is This A Privacy Problem For Users?

**No, not for this app.** Reasons:

1. The app sends **zero personal data** — no name, no email, no device ID, no location.
2. The only identifying information is the **IP address**, which every internet service sees.
3. Each user's IP is **different** — providers see 100 different IPs from 100 users, not "100 calls from one app."
4. The daily cache means each user makes **at most ~3-8 calls per day** across all providers.
5. This is identical to any website user loading a page — your app's users are making fewer requests than a single web browsing session.

### Your Backend Plan Solves Everything

When you implement the backend:

```
User's phone → Your backend → Provider
              (your server IP)   (one identity)
```

- Users no longer call providers directly — only your backend does
- Your backend controls caching, rate limiting, and costs
- Providers see only your server's IP, not your users'
- You can switch providers without app updates
- Users' privacy improves further (one hop between them and third parties)

---

## Providers Overview

| Provider | Use | Auth | Rate Limit | License |
|----------|-----|------|------------|---------|
| **Frankfurter** (`api.frankfurter.dev`) | Fiat latest + historical | No key | ~10 req/min (soft); no hard monthly quota | Unlicense (commercial OK) |
| **CoinPaprika** (`api.coinpaprika.com`) | BTC/ETH latest + historical | No key | **20,000 calls/month** on free plan | Proprietary (commercial **NOT** allowed on free or standard paid plans) |
| **CoinGecko** (`api.coingecko.com`) | Future backend intraday crypto candidate | Server-side key only | Demo 10k/mo, 100/min; Basic 100k/mo, 300/min | Demo: dev/soak only; Basic+: Commercial + attribution; own-VPS endpoint AMBER pending written confirmation |
| **fawazahmed0** (`cdn.jsdelivr.net`) | BTC/ETH latest (fallback → primary candidate) | No key | **No rate limit** (static CDN file) | **CC0** (commercial OK) |

### Frankfurter Details

- Open-source, sources from ECB + 55 central banks
- Daily rates only (updated once per business day)
- Historical data available (fiat only, no BTC/ETH)
- No API key, no account
- The v1 endpoint (`/v1/{date}`) supports date ranges like `2024-01-01..2024-06-01`
- The v2 endpoint (`/v2/rates`) returns latest rates
- Self-hostable via Docker if needed at scale
- Soft limit: ~10 requests/minute observed; no published hard cap
- **License**: Unlicense — explicitly free for commercial use

### CoinPaprika Details

- Free plan: 20,000 calls/month, no API key
- 25+ endpoints available
- Rate: roughly 4 calls/second on free plan
- Historical ticks: daily interval supports up to 1 year lookback
- Historical OHLC: only last 24 hours (not used by this app)
- Paid plans: Starter $99/mo (400K calls), Pro, Business, Ultimate $1,499/mo
- **CRITICAL**: ALL plans (free through $1,499/mo Ultimate) are **internal tools only**
- User-facing apps require a separate Enterprise contract (custom pricing)
- **Must display "Powered by CoinPaprika" attribution** (ToS Section 3.9)
- **BLOCKER FOR PLAY STORE**: commercial use forbidden on free plan,
  user-facing display forbidden on all standard paid plans

### fawazahmed0 Details

- Static JSON file served via jsdelivr CDN + Cloudflare Pages fallback
- Updated daily
- No rate limit (it is a static file, not a dynamic API)
- **CC0-1.0 license** — full public domain, commercial use explicitly allowed
- Includes 200+ currencies including BTC/ETH
- Known issue: occasional bad crypto data (e.g. inverted BTC values on 2025-12-06)
- The app validates prices against sanity ranges before accepting
- **Best candidate for primary crypto provider** (replacing CoinPaprika)

---

## How The App Makes Calls

### Call Anatomy — What Goes Over The Wire

The app makes plain `GET` requests. No POST, no body, no custom headers, no auth tokens. Here are the exact URLs:

**Convert — fiat latest (Frankfurter):**
```
GET https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR,GBP,JPY,...
```

**Convert — crypto latest (CoinPaprika, 2 calls):**
```
GET https://api.coinpaprika.com/v1/tickers/btc-bitcoin?quotes=USD
GET https://api.coinpaprika.com/v1/tickers/eth-ethereum?quotes=USD
```

**Convert — crypto fallback (fawazahmed0, only if CoinPaprika fails):**
```
GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json
```

**Charts — fiat historical (Frankfurter):**
```
GET https://api.frankfurter.dev/v1/2025-01-01..2026-01-01?base=USD&symbols=EUR
```

**Charts — crypto historical (CoinPaprika, 1 per crypto asset):**
```
GET https://api.coinpaprika.com/v1/tickers/btc-bitcoin/historical?start=2025-01-01&end=2026-01-01&interval=1d&quote=usd
```

**Nothing else is sent.** No headers with app name, no API key, no user identifier, no device fingerprint.

### Convert Tab (Latest Rates)

Triggered when: app opens, user pulls to refresh, or daily cache expires.

| Step | Provider | Calls | When |
|------|----------|-------|------|
| 1. Fetch fiat latest | Frankfurter | **1** | `GET /v2/rates?base=USD&quotes=...` (all 40 fiat in 1 call) |
| 2. Fetch crypto USD prices | CoinPaprika | **2** | `GET /v1/tickers/btc-bitcoin?quotes=USD` + `GET /v1/tickers/eth-ethereum?quotes=USD` |
| 3. Fallback (if CoinPaprika fails) | fawazahmed0 | **1** | Single static JSON download (contains all currencies) |
| **Total per refresh** | | **1-3** | At most 3 calls per Convert refresh |

Daily cap (1 refresh/day, 1 user): **3 CoinPaprika + 1 Frankfurter calls per day**

With 500 DAU each refreshing once: **~1,000 CoinPaprika calls/day ≈ 30,000/month** — this exceeds the 20K limit.

With 500 DAU but refresh-on-open = daily cached: most users hit cache, only first open of the day fetches. Realistic: **~500 unique user-days ≈ 1,500 CoinPaprika calls/month** — well under 20K.

### Charts Tab (Historical Rates)

Triggered when: user selects a pair + range, or cached data is stale.

**Fiat/Fiat pair (e.g. USD/EUR):**

| Step | Provider | Calls |
|------|----------|-------|
| Historical range | Frankfurter | **1** (`GET /v1/{from}..{to}?base=USD&symbols=EUR`) |

**Crypto/Crypto pair (e.g. BTC/ETH):**

| Step | Provider | Calls |
|------|----------|-------|
| BTC USD history | CoinPaprika | **1** |
| ETH USD history | CoinPaprika | **1** |
| **Total** | | **2** |

**Fiat/Crypto pair (e.g. EUR/BTC):**

| Step | Provider | Calls |
|------|----------|-------|
| Fiat to USD history | Frankfurter | **1** |
| Crypto USD history | CoinPaprika | **1** |
| **Total** | | **2** |

**Crypto/Fiat pair (e.g. BTC/USD):**

| Step | Provider | Calls |
|------|----------|-------|
| Crypto USD history | CoinPaprika | **1** |
| USD to fiat (or identity if USD) | Frankfurter or **0** | **0-1** |
| **Total** | | **1-2** |

Cache behavior: once a range is fetched, it is cached persistently. Only new date gaps trigger additional calls.

### Per-User Daily Call Budget (Worst Case)

| Action | Frankfurter | CoinPaprika | fawazahmed0 |
|--------|-------------|-------------|-------------|
| Convert open (1x/day) | 1 | 2 | 0 |
| View 3 different chart pairs | 1-3 | 2-6 | 0 |
| Switch ranges (same pair cached) | 0 | 0 | 0 |
| **Daily worst case** | **4** | **8** | **0** |

---

## Monthly Call Budget Analysis

### CoinPaprika (the tightest constraint — and a licensing blocker)

Free plan: **20,000 calls/month** — but **cannot be used commercially** anyway.

| Scenario | Users | Convert calls/mo | Chart calls/mo | Total | Under quota? | License OK? |
|----------|-------|-------------------|-----------------|-------|-------------|-------------|
| Development (1 user) | 1 | ~60 | ~30 | **~90** | Yes | **No** |
| Soft launch (100 DAU) | 100 | ~6,000 | ~3,000 | **~9,000** | Yes | **No** |
| Growth (300 DAU) | 300 | ~18,000 | ~9,000 | **~27,000** | Over | **No** |

The quota discussion is **moot** — the license forbids commercial use regardless of call volume.

### Why fawazahmed0 As Primary Crypto Provider Works

1. **CC0 license**: no commercial use restrictions, no attribution required
2. **No rate limit**: static CDN file, not a dynamic API
3. **Already in the codebase**: currently a fallback, just needs promotion to primary
4. **Includes BTC/ETH**: same data already used
5. **Daily update**: matches the app's daily cache policy
6. **Limitation**: no native historical time series endpoint (each date is a separate file) — charts would need a different approach or a secondary provider

---

## Chart Range Recommendations

### Current Ranges

| Range | Fiat | Crypto | Why |
|-------|------|--------|-----|
| 1W | Yes | Yes | Short range, low data |
| 1M | Yes | Yes | Standard |
| 3M | Yes | Yes | Standard |
| 6M | Yes | Yes | Standard |
| 1Y | Yes | Yes | CoinPaprika free plan max |
| 2Y | Yes | **No** | CoinPaprika free plan does not support > 1Y |

### After CoinPaprika Replacement

Crypto chart ranges will depend on the replacement provider's capabilities:

| Replacement | Historical Available | Max Range | Commercial OK? |
|-------------|---------------------|-----------|----------------|
| fawazahmed0 (date files) | Daily snapshots | Unlimited (1 date per call) | Yes (CC0) |
| CoinGecko Demo | 1 year daily | 1Y | Dev/soak only; not cleared for production |
| CoinGecko Basic ($35/mo or $348/year) | Plan-dependent | Plan-dependent | Standard Commercial + attribution; own-VPS endpoint requires confirmation |
| DIA | TBD | TBD | Verify |

### Recommendation

Keep current range structure for fiat. Crypto ranges adjust based on replacement provider.
2Y fiat is safe and free (Frankfurter, no quota).

---

## Scale: What Happens On Google Play / App Store

### Key Insight: Each User Has An Independent Quota

Because there is **no API key** and **no shared identity**, providers treat each user
as an independent caller:

- **User A** on WiFi at home → IP `203.0.113.5` → their own quota
- **User B** on mobile data → IP `198.51.100.12` → their own quota
- The providers **cannot tell** these users are using the same app

This means **1,000 users = 1,000 independent quotas**. The app will never hit a
global "all users combined" limit.

### Edge Case: Shared IPs (Corporate/School WiFi)

Many users behind one IP (e.g. office WiFi) share the per-IP rate limit. But daily
caching limits each device to ~3-8 calls/day, so even 50 users behind one IP =
~150-400 calls/day = ~12K/month — still under most quotas.

### Your Backend Plan Is The Correct Long-Term Strategy

```
Phase 1 (now, free):                  Phase 2 (when justified):

Phone → Frankfurter (fiat)            Phone → Honest Fern public API
Phone → fawazahmed0 (crypto)                      ↓
                                      VPS worker → OXR Developer ($12/mo
                                      or $120/year) → validate + store
                                      Cache + rate control
                                      OXR App ID stays on the VPS
                                      Optional CoinGecko only after its
                                      own endpoint/licence gate is cleared
```

**Benefits of the backend proxy:**
1. All users call your server, not providers directly
2. Your server caches aggressively — 1 provider call serves 1,000 users
3. You control costs — server pays one provider bill
4. Users' privacy improves — their IP never reaches third parties
5. You can switch providers without app updates
6. You can add rate limiting, monitoring, and analytics on your side

**When to build the backend:** when you have real users and can justify the
VPS cost plus OXR Developer ($12/month or $120/year). Until then, free
providers (Frankfurter + fawazahmed0) cover the current app legally.

---

## Mitigation Strategies

| Strategy | When | Cost | License OK? |
|----------|------|------|-------------|
| **Frankfurter + fawazahmed0 only** (drop CoinPaprika) | Phase 1 launch | Free | Yes (Unlicense + CC0) |
| **Add CoinGecko Demo** for crypto charts | Not for current release; dev/soak only | Free | No production commercial clearance |
| **CoinGecko Basic** | Future backend when revenue/freshness justify it | $35/mo monthly or $348/year | Standard Commercial + attribution; own endpoint needs written confirmation |
| **Phase 2 backend proxy** | ~500+ DAU or a clear product need | VPS cost + provider plan | Only after provider-specific terms are cleared |
| **Self-hosted Frankfurter** | If Frankfurter rate-limits | Docker on existing VPS | Yes |
| **CoinPaprika Enterprise** | Only if specifically needed | Custom ($500+/mo estimate) | Yes (with contract) |

---

## Summary

| Question | Answer |
|----------|--------|
| Can I publish on Play Store with current providers? | **NO** — CoinPaprika ToS forbids commercial use on free plan and user-facing display on all standard paid plans. **Must replace CoinPaprika.** |
| What should I replace CoinPaprika with? | **fawazahmed0** (CC0, already in codebase) for latest rates. For charts, either compose from fawazahmed0 date files, or add CoinGecko. |
| Are Frankfurter and fawazahmed0 safe? | **Yes** — both explicitly allow commercial use (Unlicense + CC0). |
| Does Google Play require special approval? | **No** — declare "no financial features." A rate display app is not a crypto exchange or wallet. |
| Am I doing too many calls? | **No**, not at current scale. Daily caching keeps calls minimal. |
| Should I reduce chart ranges? | **No** for fiat. Crypto ranges depend on replacement provider. |
| What happens if a provider fails? | fawazahmed0 fallback provides latest BTC/ETH. Fiat is independent. Charts cache persists. |
| Is my backend plan the right approach? | **Yes** — backend proxy is the correct scale-up strategy. Free for now (Frankfurter + fawazahmed0); when justified, OXR Developer is the selected hourly-fiat upstream. CoinGecko remains optional for intraday crypto and needs its own licence confirmation. |
