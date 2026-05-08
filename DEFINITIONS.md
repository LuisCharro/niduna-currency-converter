# Currency Converter App — Definitions

> **Status:** DEFINITIONS finalized after Phase roadmap pass
> **Created:** 2026-05-06
> **Last updated:** 2026-05-07 (post-review verification pass)

---

## ⚠️ Critical Notes

- **RUB removed from MVP list** — Frankfurter does NOT carry Russian Ruble (RUB). ECB suspended EUR/RUB publication on 2022-03-01. Verified via curl: `api.frankfurter.dev/currencies` → RUB=false. Replaced with **TRY (Turkish Lira)**.
- **Dual Remove Ads model at launch** — recommending both rental (0.50 CHF/30 days) AND forever (1.99 CHF) adds complexity. Consider launching with **one option only** (forever at 1.99 CHF) and adding rental in Phase 2 if data shows demand.
- **Currency app chart limit unverified** — Luis observed 1-chart free on his device, but the App Store listing does NOT specify this. Action: verify directly in the app before publishing.

---

## Key Decisions (2026-05-07)

- Phase 1 INCLUDES crypto (BTC, ETH **prices**) via CoinGecko Demo API — crypto **charts** NOT in Phase 1
- Metals (XAU gold, XAG silver) deferred to Phase 3 (no good free API)
- Phase 2 subscription minimum: **1 CHF/mes = 12 CHF/año**; break-even at ~10 subscribers
- Grandfathering confirmed: Google Play auto-preserves prices; Apple requires "Preserve prices for existing subscribers" in App Store Connect
- Phase 2 subscription tiers: Basic (12 CHF/año = rate alerts + hourly refresh) + Crypto/Metals add-on (5–8 CHF/año extra, Phase 3)
- Phase 3 crypto pack as separate one-time purchase: 1–1.50 CHF
- Charts: unlimited free fiat charts (up to 2 years) in Phase 1; crypto charts deferred to Phase 2/3
- Phase 1 = MVP (free, ads, no backend); Phase 2 = Backend + Subscriptions; Phase 3 = Crypto + Metals + Extensions
- CoinGecko API key required — free sign-up at coingecko.com; Demo plan: ~30 calls/min, ~10,000 calls/month
- i18n: Phase 1 ships with **English only** — add DE, FR, IT, ES, PT in Phase 1.x updates
- In-app rate alerts: free in Phase 1 (checked only while app is open, no backend) — push alerts require Phase 2 backend

---

## What's In / What's Out — Phase 1 (MVP)

### ✅ Phase 1 IN

| Feature | Detail |
|---------|--------|
| **Currencies (fiat)** | 16 MVP currencies: USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, **TRY** (Turkish Lira ⚠️ replaced RUB), KRW, SGD, HKD, NZD, CHF |
| **Crypto prices (BTC, ETH)** | **INCLUDED** — via CoinGecko Demo API, 24h local cache. Charts NOT included (deferred to Phase 2/3) |
| **Conversion** | Client-side `amount × rate`; Frankfurter has **no `/convert` endpoint** |
| **Historical charts** | Daily rates, up to 2 years, unlimited free in Phase 1 |
| **Favorite pairs** | Save up to 3 locally (no account) |
| **Offline mode** | Cache last known rates; show "last updated: [date]" |
| **Dark mode** | Free in 2026 — do NOT charge for this |
| **Ads** | Banner only (AdMob or similar) |
| **Data source** | Frankfurter v2 (`api.frankfurter.dev`), no API key, no monthly quota, anti-abuse rate limiting |

### ❌ Phase 1 OUT

| Feature | Why |
|---------|-----|
| **Crypto charts** | Prices are IN Phase 1; charts require backend caching → Phase 2/3 |
| **Metals (XAU, XAG)** | Deferred to Phase 3 — no good free API |
| **Charts beyond 2 years** | Phase 1 scope |
| **Rate alerts (push)** | Requires backend for push notifications; one-time payment can't sustain hosting costs |
| **Backend** | None at MVP; direct Frankfurter calls |
| **Intraday/hourly refresh** | Frankfurter provides daily rates only |
| **More than 3 favorite pairs** | Consider as Phase 2 paid unlock |
| **Chart export** | Phase 2 |
| **Multi-pair chart comparison** | Phase 2 |
| **Apple Watch** | Phase 2 or 3 |

---

## Concept

A free currency converter app for Android (eventually also iOS), published under the Niduna brand.
Android first at launch, Apple later (no $100/year Apple fee initially).

**Store-agnostic rule:** pricing, features, and data policies are identical on both platforms.

Core promise: convert between currencies, see historical charts, no login required.
Same philosophy as Currency (currencyapp.com): **zero tracking, zero accounts, zero data collection**.

---

## Competitive Study

### The privacy differentiator — PRIMARY

**Currency app collects Location + Identifiers for tracking** (App Store privacy label, May 2026). XE collects data for transfers. My Currency Converter Pro is better ("no data collected").

**Niduna's positioning**: strictly **zero tracking, zero accounts, zero data collection**. Point to the App Store privacy label as proof.

### Detailed competitor analysis

#### Currency (currencyapp.com) — the 800-pound gorilla

- **Price**: free with in-app purchases; **Currency+ = $19.99/year** (auto-renewing subscription)
- **Ratings**: **4.8★, 78K ratings** on iOS; ~100K+ downloads
- **Features**: 160+ currencies, ads, standard daily rates
- **What $19.99/year gets you**: removes ads + "unlocks all features" (exact features not publicly enumerated)
- **Privacy**: collects **Location** and **Identifiers** for tracking — **primary differentiator**
- **Note**: App Store listing shows both a subscription (Currency+) and a one-time "Currency Pro $19.99" IAP option

#### My Currency Converter Pro (JRustonApps) — the honest $3.99 one-time

- **Price**: **$3.99 one-time** (no subscription)
- **Ratings**: free app **4.86★, 122,559 ratings**; Pro app **4.87★, 2,637 ratings**
- **Features**: 150+ currencies, Bitcoin/LiteCoin/Dogecoin, offline mode, graphs/history, automatic updates
- **Pro unlocks**: ad-free + Apple Watch support
- **Privacy**: "the developer does not collect any data from this app"
- **Model**: separate Pro app (not IAP in same app)

#### CoinCalc — the dark horse

- **Ratings**: **4.2★, 3.33K reviews, 100K+ downloads**
- **Positioning**: broad currency + crypto coverage, widgets, offline, history
- **Note**: IAP pricing not publicly available. Lower rating suggests ad annoyance or UX issues.

#### XE Currency — the transfer company using "free" as a funnel

- **Price**: **completely free** for consumer features
- **Ratings**: **4.8★, 119K ratings, 105M+ downloads**
- **Features**: live rates, rate alerts, 10-year charts, transfers to 200+ countries
- **Monetization**: **money transfer fees** — they give away the utility for free and make money on international transfers
- **Implication**: XE sets the expectation that "currency apps are free", making paid utility apps harder to sell

### Competitor comparison summary

| Feature | Currency (free) | Currency+ ($19.99/yr) | My Currency Free | My Currency Pro ($3.99) | XE (free) |
|---------|-----------------|----------------------|------------------|------------------------|-----------|
| Core conversion | ✅ | ✅ | ✅ | ✅ | ✅ |
| 160+ currencies | ✅ | ✅ | ✅ (150+) | ✅ | ✅ |
| Historical charts | ✅ | ✅ | ✅ | ✅ | ✅ (10 yr) |
| Rate alerts | ? | ✅ | ? | ? | ✅ |
| Crypto | ? | ? | ✅ | ✅ | ? |
| Offline mode | ? | ? | ✅ | ✅ | ? |
| Ads | ✅ | ❌ | ✅ | ❌ | ? |
| Privacy | Tracks Location+IDs | — | No data | No data | Transfers |

### What Niduna can offer that competitors don't

1. **Privacy-first (no tracking, no accounts)** — verifiable differentiator vs Currency and XE
2. **Direct one-time pricing vs subscription** — Niduna at ~2 CHF one-time vs Currency at $19.99/year
3. **Unlimited free charts** — ⚠️ unverified; confirm directly in Currency app before claiming this
4. **Cleaner, simpler UI** — no transfer upsells or subscription prompts
5. **CHF-native positioning** — natural choice for CHF users

---

## Profitability Analysis

### The one-time unlock problem

**Scenario**: User buys "Remove Ads" for ~2 CHF in 2026. Two years later, API costs go up or a paid backend is added. Those 10,000 users generate **zero new revenue** — they already paid once, but costs grew.

**Mitigation strategies:**
1. Price one-time purchases high enough to account for future cost increases
2. Add subscription later for new features (alerts, hourly data) — existing buyers keep their unlock
3. Never depend on one-time purchases to fund ongoing operational costs

### Recommended price points

| Unlock | Type | Price (CHF) | Note |
|--------|------|------------|------|
| Remove Banner Ads — 30 days | Rental | 0.50 | Low friction; "try before you buy" |
| Remove Banner Ads — forever | One-time | **1.99** | Core unlock; below My Currency Pro ($3.99) |
| Save more than 3 favorite pairs | One-time | 0.50–0.99 | Power users |
| Export chart as PNG/JPG | One-time | 0.99 | Clear use case |
| Compare 2+ pairs on one chart | One-time | 0.99–1.50 | Power feature |
| Rate alerts (push, future) | Subscription | 12 CHF/año | Requires backend |
| Crypto pack (future) | One-time | 1–1.50 | Phase 3 |

### One-time vs subscription decision rules

| If the feature... | Then charge as... | Reason |
|-------------------|-------------------|--------|
| Costs nothing after development | One-time | Pure margin |
| Requires ongoing backend/server costs | Subscription | Can't sustain one-time on recurring costs |
| Provides ongoing data (alerts, hourly) | Subscription | Value is recurring |
| Unlocks permanent state (no ads forever) | One-time | One-time is expected |
| Adds new data source with API cost | Subscription | API costs are ongoing |

### Revenue model that scales

| Revenue stream | Amount | Recurring? | Phase |
|---------------|--------|------------|-------|
| Banner ads | $1–3 eCPM × impressions | Yes | MVP onward |
| Remove Ads — 30 days | 0.50 CHF | As rented | MVP onward |
| Remove Ads — forever | 1.99 CHF | New users keep buying | MVP onward |
| Rate alerts subscription | 12 CHF/año | Yes | Phase 2 |
| Chart export | 0.99 CHF | One-time | Phase 2 |
| Crypto pack | 1–1.50 CHF | One-time | Phase 3 |

---

## API Strategy

### Frankfurter v2

- **URL**: `https://api.frankfurter.dev`
- **No API key required** — no monthly or daily quota
- **Anti-abuse rate limiting** only — no exact RPM published
- **200 currencies** from 55 central banks, back to 1948
- **NO `/convert` endpoint** — app calculates `amount × rate` client-side using `/v2/rate/{base}/{quote}`
- Self-hosting: Docker image available (`lineofflight/frankfurter`) — consider at 10,000+ DAU

### How many calls can Niduna make safely?

| DAU | Est. daily calls | Recommendation |
|-----|-----------------|-----------------|
| < 500 | < 2,000 | Stay on Frankfurter free, no caching needed |
| 500–2,000 | 2,000–10,000 | Stay on Frankfurter, add local caching (5–15 min TTL) |
| 2,000–10,000 | 10,000–50,000 | Consider ExchangeRate-API Pro ($10/month) |
| 10,000–50,000 | 50,000–250,000 | Backend proxy + paid API |
| 50,000+ | 250,000+ | Self-host Frankfurter or enterprise paid API |

### CoinGecko Demo API

- **Requires free API key** (sign-up at coingecko.com)
- Without key: **429 rate limit** after 1–2 rapid requests (curl-verified)
- Demo plan: ~**30 calls/min**, ~**10,000 calls/month**
- Use: BTC and ETH **prices only** in Phase 1; **24h local cache** to minimize calls

### When to switch to paid API

**ExchangeRate-API Pro** ($10/month → ~12 CHF/month):
- 30,000 requests/month, hourly updates
- With 30-min local cache: supports ~2,000–5,000 DAU
- Break-even: ~10 subscribers (at 12 CHF/año) covers the cost

---

## Open Questions

| Question | Status | Action |
|----------|--------|--------|
| MVP currency list (TRY vs PLN?) | ⚠️ | RUB replaced with TRY (Turkish Lira); confirm if PLN (Polish Zloty) is better for target audience |
| Single or dual Remove Ads option at launch? | ⚠️ | Recommend launching with **one option only** (1.99 CHF forever); add rental in Phase 2 if data shows demand |
| Currency app chart limit | ⚠️ | **Unverified from public sources** — Luis observed 1-chart free, but App Store listing does NOT specify this. Must verify directly in the app before publishing |
| RUB compliance | ⚠️ | Swiss law / export regulations on showing RUB rates via an alternative source — consult a lawyer if RUB is important |
| i18n languages | ✅ Decided | Phase 1: English only. Phase 1.x: add DE, FR, IT, ES, PT |

---

## Phase Roadmap

### Phase 1 — MVP (Free + Ads + One-time Unlock)

- **Goal**: Ship fast, validate conversion funnel
- **Revenue**: Banner ads + Remove Ads (1.99 CHF forever / optional 0.50 CHF 30-day rental)
- **Data**: Frankfurter v2 (free) + CoinGecko Demo API for BTC/ETH prices
- **Backend**: None
- **Success metric**: 500+ DAU within 3 months, 3–5% Remove Ads conversion

### Phase 2 — Convenience Paid Tiers + Backend *(triggered by ~2,000 DAU or user demand for alerts)*

| Tier | Price | Includes |
|------|-------|---------|
| Basic | 12 CHF/año | Rate alerts (push) + hourly refresh |
| Crypto/Metals add-on | 5–8 CHF/año extra | BTC, ETH, XAU, XAG (Phase 3) |

- **Backend stack**: ASP.NET Core Minimal API + PostgreSQL + Nginx on Hostinger VPS + Firebase Cloud Messaging (free tier)
- **Additional cost**: ~$10/month (ExchangeRate-API Pro)

### Phase 3 — Crypto + Metals + Extensions

| Feature | Price |
|---------|-------|
| Crypto charts (BTC, ETH) | 1–1.50 CHF one-time pack |
| Metals (XAU, XAG) | Included in crypto pack or separate |
| Apple Watch support | 0.99 CHF or included in Remove Ads |
| 10-year charts | Free for all |

---

## Final Recommendation

Build the first release as a **simple, privacy-first, no-login, ad-supported converter**:

1. Flutter app
2. Frankfurter v2 primary data source
3. 16 MVP currencies including CHF (RUB → TRY)
4. Daily rates + 2-year charts + offline cache
5. Banner ads only
6. One-time **Remove Ads** at **1.99 CHF** (+ optional 30-day rental at 0.50 CHF — consider omitting at launch)
7. No backend, no subscription, no crypto charts/metals at launch
8. BTC/ETH **prices** via CoinGecko Demo API (24h cache)
9. Self-host Frankfurter only if/when DAU exceeds ~10,000

---

## Changelog

| Date | Change | Verified |
|------|--------|----------|
| 2026-05-07 | RUB removed from MVP — Frankfurter confirmed without RUB (ECB suspended EUR/RUB on 2022-03-01) | curl: `api.frankfurter.dev/currencies` → RUB=false |
| 2026-05-07 | RUB → TRY (Turkish Lira) in MVP currency list | Frankfurter confirmed TRY available |
| 2026-05-07 | Crypto note clarified: BTC/ETH **prices** IN Phase 1, BTC/ETH **charts** OUT (Phase 2/3) | CoinGecko Demo API supports price endpoint |
| 2026-05-07 | CoinGecko Demo API rate limit confirmed: 30 calls/min, 10,000/month, API key required | Web search + curl verification |
| 2026-05-07 | Frankfurter currency count confirmed: **200** (not 165) from official frankfurter.dev | Official docs |
| 2026-05-07 | Frankfurter **no `/convert` endpoint** confirmed from official docs | frankfurter.dev |
| 2026-05-07 | Currency app chart limit: App Store listing does **NOT** specify a chart limit | App Store listing fetch |
| 2026-05-07 | Currency app has both **subscription (Currency+)** AND **one-time (Currency Pro $19.99)** IAP options | App Store listing |

---

## Phase Decision Matrix (Quick Reference)

| Decision | Phase 1 | Phase 2 | Phase 3 |
|----------|---------|---------|----------|
| **Data source** | Frankfurter free | ExchangeRate-API Pro + Frankfurter | + CoinGecko (crypto) |
| **Backend** | None | ASP.NET Core + PostgreSQL on Hostinger | Same |
| **Currencies** | 16 + BTC + ETH prices | All 200 from Frankfurter | + Crypto charts + Metals (XAU/XAG) |
| **Charts** | 2-year daily, unlimited free | + Multi-pair comparison | + Metals overlays |
| **Rate alerts** | In-app only (free, app open) | Push via backend (subscription) | + Crypto price alerts |
| **Monetization** | Ads + Remove Ads one-time | + Subscriptions (Basic: 12 CHF/año) | + Crypto/Metals add-on |
| **Ads** | Banner only | Banner for free tier | Banner for free tier |
| **Metals** | No | No | Gold/Silver (XAU/XAG) |

---

## Luis's Key Questions — Answered Directly

**Q: Which phases?**
3 phases: MVP (free + ads + BTC/ETH prices), Phase 2 (backend + subscriptions), Phase 3 (crypto charts + metals + extensions).

**Q: What's in MVP?**
16 fiat currencies + BTC/ETH prices (no charts) + 2-year charts + offline cache + banner ads + Remove Ads (one-time 1.99 CHF). No metals, no push alerts, no backend.

**Q: How to monetize not just cover costs?**
Phase 1: ads + one-time Remove Ads accumulates cash reserve. Phase 2: subscriptions for alerts/hourly create recurring revenue. Don't use one-time purchases to fund ongoing backend — that's the fundamental mistake.

**Q: What does Phase 2 need in terms of backend?**
ASP.NET Core Minimal API + PostgreSQL on existing Hostinger VPS + Firebase Cloud Messaging (free tier: 2M notifications/month). Total Phase 2 backend cost: ~$10/month (ExchangeRate-API Pro).

---

## When Does Phase 2 Need a Backend? (Specific Triggers)

| Trigger | What backend does | DAU estimate |
|---------|------------------|---------------|
| Rate alert demand (user requests) | Sends push via FCM | Any DAU |
| ExchangeRate-API Pro needed | Protects API key; server-side cache | ~2,000+ DAU |
| Self-hosting Frankfurter | Full control over rate limits | ~10,000+ DAU |
| Intraday/hourly data needed | Serves cached intraday data | ~5,000+ DAU |

**Minimum viable backend**: ASP.NET Core Minimal API + PostgreSQL on existing Hostinger VPS + Firebase Cloud Messaging (free tier: 2M notifications/month). Total Phase 2 backend cost: ~$10/month.

---

## One-time vs Subscription: Decision Rules


| If the feature... | Then charge as... | Reason |
|-------------------|-------------------|--------|
| Costs nothing after development | One-time | Pure margin |
| Requires ongoing backend/server costs | Subscription | Can't sustain one-time on recurring costs |
| Provides ongoing data (alerts, hourly) | Subscription | Value is recurring |
| Unlocks permanent state (no ads forever) | One-time | One-time is expected |
| Adds new data source with API cost | Subscription | API costs are ongoing |

---

## What to Never Do

- **Don't add subscription to remove ads.** Users hate being forced to pay forever just to use an app they already paid for. Keep Remove Ads as a one-time purchase.
- **Don't use one-time purchases to fund ongoing backend costs.** A one-time 0.99 CHF payment cannot sustain a 12 CHF/month server. Charge subscriptions for recurring features.
- **Don't launch with RUB in the currency list.** Frankfurter doesn't carry it (ECB suspended 2022-03-01). Silent failure for users.
- **Don't promise unlimited charts if you haven't verified the competitor's limit.** Claims collapse on first review if wrong.

---

## Frankfurter Self-Hosting

At 10,000+ DAU, self-hosting Frankfurter eliminates rate-limit concerns entirely.

- **Docker image**: `lineofflight/frankfurter` (confirmed working)
- **Cost**: VPS cost only (no API fees)
- **Benefit**: full control over rate limits, no dependency on third-party uptime
- **Trade-off**: you own the data freshness (weekend/holiday lag same as current)

---

## Phase 2 Subscription Tiers (Confirmed CHF)

| Tier | Price | Includes |
|------|-------|----------|
| Basic | **12 CHF/año** | Rate alerts (push via backend) + hourly refresh |
| Crypto/Metals add-on | **5–8 CHF/año extra** | BTC, ETH, XAU, XAG (Phase 3) |

**Break-even**: ~10 subscribers (Basic) covers ExchangeRate-API Pro ($10/month ≈ 12 CHF/month).

**Grandfathering**: Google Play auto-preserves prices for existing subscribers. Apple requires "Preserve prices for existing subscribers" in App Store Connect.
