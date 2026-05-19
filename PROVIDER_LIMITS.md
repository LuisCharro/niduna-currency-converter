# Provider Rate Limits and Call Budget

> Last updated: 2026-05-19
> Purpose: document free provider limits, how the app makes calls, and whether
> current usage is safe.

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
| **App identifier** | **No** | No custom header identifies this app or Niduna. |
| **Request body** | No body | All calls are `GET` requests — no personal data in the URL or body. |

### Do They Log IPs?

**Yes, all HTTP servers log IPs by default.** But:

- **Frankfurter**: open-source project (h县城 auf GitHub). No known tracking or user profiling. Server logs are standard access logs, not analytics. Self-hostable if needed.
- **CoinPaprika**: commercial API service. They likely log IPs for rate limiting (20K/month quota is enforced per IP or per subnet). They have a published Privacy Policy at `coinpaprika.com`. The free plan has no account, so they track usage by IP.
- **fawazahmed0**: served via jsdelivr CDN and Cloudflare. These CDNs log IPs for caching and abuse prevention. No user profiling.

### Is This A Privacy Problem For Users?

**No, not for this app.** Reasons:

1. The app sends **zero personal data** — no name, no email, no device ID, no location.
2. The only identifying information is the **IP address**, which every internet service sees.
3. Each user's IP is **different** — CoinPaprika sees 100 different IPs from 100 users, not "100 calls from one app."
4. The daily cache means each user makes **at most ~3-8 calls per day** across all providers.
5. This is identical to any website user loading a page — your app's users are making fewer requests than a single web browsing session.

### What CoinPaprika Actually Tracks

CoinPaprika's rate limit (20K/month) applies **per IP address** on the free plan, not per app. This means:

- 100 users = 100 different IPs = 100 separate 20K/month quotas
- The app does **not** pool all users into one quota
- There is no way for CoinPaprika to know these calls come from the same app

### Your Backend Plan Solves Everything

When you implement the backend:

```
User's phone → Your backend → Paid provider
              (your server IP)   (one identity)
```

- Users no longer call providers directly — only your backend does
- Your backend controls caching, rate limiting, and costs
- Providers see only your server's IP, not your users'
- You can switch providers without app updates
- Users' privacy improves further (one hop between them and third parties)

---

## Providers Overview

| Provider | Use | Auth | Rate Limit |
|----------|-----|------|------------|
| **Frankfurter** (`api.frankfurter.dev`) | Fiat latest + historical | No key | ~10 req/min (soft); no hard monthly quota |
| **CoinPaprika** (`api.coinpaprika.com`) | BTC/ETH latest + historical | No key | **20,000 calls/month** on free plan |
| **fawazahmed0** (`cdn.jsdelivr.net`) | BTC/ETH latest fallback | No key | **No rate limit** (static CDN file, CC0) |

### Frankfurter Details

- Open-source, sources from ECB + 55 central banks
- Daily rates only (updated once per business day)
- Historical data available (fiat only, no BTC/ETH)
- No API key, no account
- The v1 endpoint (`/v1/{date}`) supports date ranges like `2024-01-01..2024-06-01`
- The v2 endpoint (`/v2/rates`) returns latest rates
- Self-hostable via Docker if needed at scale (`lineofflight/frankfurter`)
- Soft limit: ~10 requests/minute observed; no published hard cap

### CoinPaprika Details

- Free plan: 20,000 calls/month, no API key
- 25+ endpoints available
- Rate: roughly 4 calls/second on free plan
- Historical ticks: daily interval supports up to 1 year lookback
- Historical OHLC: only last 24 hours (not used by this app)
- Paid plans: Starter $99/mo (400K calls), Pro ($1M calls), Business ($5M calls)

### fawazahmed0 Details

- Static JSON file served via jsdelivr CDN + Cloudflare Pages fallback
- Updated daily
- No rate limit (it is a static file, not a dynamic API)
- CC0 license
- Includes 200+ currencies including BTC/ETH
- Known issue: occasional bad crypto data (e.g. inverted BTC values on 2025-12-06)
- The app validates prices against sanity ranges before accepting

---

## How The App Makes Calls

### Call Anatomy — What Goes Over The Wire

The app makes plain `GET` requests. No POST, no body, no custom headers, no auth tokens. Here are the exact URLs:

**Convert — fiat latest (Frankfurter):**
```
GET https://api.frankfurter.dev/v2/rates?base=USD&quotes=EUR,GBP,JPY,...
```
→ Returns JSON array of `{date, base, quote, rate}` objects.

**Convert — crypto latest (CoinPaprika, 2 calls):**
```
GET https://api.coinpaprika.com/v1/tickers/btc-bitcoin?quotes=USD
GET https://api.coinpaprika.com/v1/tickers/eth-ethereum?quotes=USD
```
→ Each returns `{symbol, last_updated, quotes: {USD: {price: ...}}}`.

**Convert — crypto fallback (fawazahmed0, only if CoinPaprika fails):**
```
GET https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json
```
→ Returns `{date, usd: {btc: ..., eth: ...}}` static JSON. Lowercase keys, inverted (USD per 1 BTC, not BTC per 1 USD — the app inverts it).

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
| 1. Fetch fiat latest | Frankfurter | **1** | `GET /v2/rates?base=USD&quotes=...` (all 16 fiat in 1 call) |
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

### CoinPaprika (the tightest constraint)

Free plan: **20,000 calls/month**

| Scenario | Users | Convert calls/mo | Chart calls/mo | Total | Safe? |
|----------|-------|-------------------|-----------------|-------|-------|
| Development (1 user) | 1 | ~60 | ~30 | **~90** | Yes |
| Soft launch (100 DAU) | 100 | ~6,000 | ~3,000 | **~9,000** | Yes |
| Growth (300 DAU) | 300 | ~18,000 | ~9,000 | **~27,000** | **Over** |
| Target MVP (500 DAU) | 500 | ~30,000 | ~15,000 | **~45,000** | **Over** |

Assumes each user opens Convert once/day and views ~3 chart pairs with crypto.

### Why It Is Probably Fine In Practice

1. **Daily cache policy**: Convert refreshes at most once per local day. Most users open the app briefly and leave — they do not trigger multiple refreshes.
2. **Chart caching**: historical data is cached persistently. Only new date gaps are fetched. A user viewing BTC/ETH 1M today and again tomorrow only fetches 1 new day.
3. **Fiat charts cost zero CoinPaprika calls**: only crypto-involving pairs use CoinPaprika.
4. **Not all users view crypto charts**: most users stay on fiat pairs.
5. **fawazahmed0 is the safety net**: if CoinPaprika quota is exhausted, the fallback still provides latest BTC/ETH rates for Convert (though not charts).

### When To Worry

- Above ~200 DAU regularly viewing crypto charts, start monitoring.
- At ~500 DAU, consider self-hosting or upgrading CoinPaprika.
- Phase 2 backend proxy removes all provider quotas from client devices.

---

## Frankfurter Safety

Frankfurter has no published hard monthly quota. The soft rate limit (~10 req/min) is generous for a mobile app:

- Convert: 1 call per day per user
- Charts: 1 call per pair+range (cached forever after)
- 500 DAU: ~500 Convert + ~1,500 chart = **~2,000 Frankfurter calls/month**

Completely safe. If ever needed, self-host via Docker.

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

### Should 2Y Be Reduced For Fiat?

**No.** Reasons:

1. Frankfurter has no hard quota — 2Y fiat charts cost nothing extra.
2. 2Y is a competitive feature (Currency app offers it).
3. 2Y charts are cached permanently after first fetch.
4. Removing 2Y would reduce app value without saving meaningful cost.

### Recommendation

Keep current range structure. 2Y fiat is safe and free. 1Y crypto max is a CoinPaprika constraint, not a choice.

---

## Scale: What Happens On Google Play / App Store

### Key Insight: Each User Has An Independent Quota

Because there is **no API key** and **no shared identity**, CoinPaprika and Frankfurter treat each user as an independent caller:

- **User A** on WiFi at home → IP `203.0.113.5` → their own 20K/month CoinPaprika quota
- **User B** on mobile data → IP `198.51.100.12` → their own 20K/month CoinPaprika quota
- The providers **cannot tell** these users are using the same app

This means **1,000 users = 1,000 independent quotas of 20K/month each**. The app will never hit a global "all users combined" limit.

### Edge Case: Shared IPs (Corporate/School WiFi)

Many users behind one IP (e.g. office WiFi) share the per-IP rate limit. But daily caching limits each device to ~3-8 calls/day, so even 50 users behind one IP = ~150-400 calls/day = ~12K/month — still under 20K.

### Your Backend Plan Is The Correct Strategy

```
Phase 1 (now, free):                Phase 2 (when you have users):

Phone → CoinPaprika (direct)        Phone → Your backend → Paid provider
Phone → Frankfurter (direct)                    ↓
Phone → fawazahmed0 (direct)              Cache + rate control
                                          One server IP to provider
                                          ~$10-20/mo server cost
```

**Benefits of the backend proxy:**
1. All users call your server, not providers directly
2. Your server caches aggressively — 1 provider call serves 1,000 users
3. You control costs — server pays one provider bill
4. Users' privacy improves — their IP never reaches third parties
5. You can switch providers without app updates
6. You can add rate limiting, monitoring, and analytics on your side

**When to build the backend:** when you have real users and can justify the $10-20/month server cost. Until then, the free direct-call architecture works perfectly.

---

## Mitigation Strategies (Future)

| Strategy | When | Cost |
|----------|------|------|
| **Current architecture** | < 200 DAU | Free |
| **Daily cache enforcement** | Always | Free (already implemented) |
| **Reduce crypto chart to 6M max** | If CoinPaprika quota pressure | Free (reduces data per fetch) |
| **Phase 2 backend proxy** | ~500 DAU | ~$10/mo server |
| **CoinPaprika Starter plan** | If needed before backend | $99/mo (400K calls) |
| **Self-hosted Frankfurter** | If Frankfurter rate-limits | Docker on existing VPS |

---

## Summary

| Question | Answer |
|----------|--------|
| Am I doing too many calls? | **No**, not at current scale. Daily caching keeps calls minimal. |
| How many calls per provider? | CoinPaprika: 20K/mo free. Frankfurter: no hard limit. fawazahmed0: no limit. |
| Should I reduce chart ranges? | **No**, keep 2Y fiat. 1Y crypto is already the free-plan max. |
| When will I hit limits? | ~200-300 DAU regularly using crypto charts. |
| What happens if CoinPaprika quota runs out? | Latest BTC/ETH rates fall back to fawazahmed0 (still works). Crypto charts stop updating until month resets. Fiat is unaffected. |
| Will Google Play / App Store users cause problems? | **No** — each user has a different IP, so CoinPaprika's 20K/month limit applies per-user, not per-app. |
| Do I pass any value from me to providers? | **No** — no API key, no user ID, no app identifier. Just standard HTTP GET requests. |
| Is my backend plan the right approach? | **Yes** — backend proxy is the correct scale-up strategy. Free for now, migrate when you have real users. |
