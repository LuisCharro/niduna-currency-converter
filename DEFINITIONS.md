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

## Key Decisions (2026-05-07 / updated 2026-05-08)

- Phase 1 is fiat-only. Crypto (BTC, ETH prices and charts) is deferred out of MVP because shipping a CoinGecko API key inside the mobile app is not an acceptable launch trade-off.
- Metals (XAU gold, XAG silver) deferred to Phase 3 (no good free API)
- Phase 2 subscription minimum: **1 CHF/mes = 12 CHF/año**; break-even at ~10 subscribers
- Grandfathering confirmed: Google Play auto-preserves prices; Apple requires "Preserve prices for existing subscribers" in App Store Connect
- Phase 2 subscription tiers: Basic (12 CHF/año = rate alerts + hourly refresh) + possible crypto add-on if served through backend/proxy
- Phase 3 crypto pack as separate one-time purchase: 1–1.50 CHF
- Charts: unlimited free fiat charts (up to 2 years) in Phase 1; crypto charts deferred to Phase 2/3
- Phase 1 = MVP (free, ads, no backend); Phase 2 = Backend + Subscriptions; Phase 3 = Crypto + Metals + Extensions
- CoinGecko API key required — do not embed it in the Phase 1 mobile app. Revisit only with backend/proxy or a deliberate public-key decision.
- i18n: Phase 1 ships with **English only** — add DE, FR, IT, ES, PT in Phase 1.x updates
- Rate alerts are deferred out of Phase 1. Phase 2 owns push alerts; optional in-app-only alerts can be reconsidered after the MVP ships.
- Monetization access policy (approved): active subscription unlocks all premium features and hides ads; without subscription, users can still buy one-time unlocks.

---

## Phase 1 Implementation Contract

This section is the product contract for implementation. If a generated UI,
agent proposal, or future idea conflicts with this contract, update this file
first or defer the idea.

### Product rules

- Phase 1 has no backend.
- Phase 1 has no accounts, login, cloud sync, or user profile.
- Phase 1 has zero tracking, zero analytics, and zero data collection.
- Phase 1 monetization is banner ads, one-time Remove Ads (1.99 CHF), one-time Charts Pro (2.99 CHF), and optional subscription (Coming Soon — pricing TBD).
- Phase 1 has four tabs only: `Convert`, `Favorites`, `Charts`, `Settings`. (Favorites tab hidden in v1 UI; code retained for Phase 2 re-enablement)
- Phase 1 is English only.
- RUB is not supported.
- Dark mode is free and available in v1 (follows system default; toggle in Settings).
- Data freshness: Frankfurter/ECB rates update once daily (~16:00 CET). App must communicate this clearly via freshness indicator + Settings explanation.

### Monetization access policy

- Active subscription always removes ads and unlocks all premium app features.
- Without an active subscription, one-time unlocks can still grant specific features.
- If subscription is canceled or expires, subscription-only access is removed.
- If subscription is canceled or expires, one-time unlocks remain owned and active.
- Ads are shown only when both conditions are true:
  - no active subscription
  - no one-time Remove Ads ownership

### Charts monetization policy

- Free default chart pair is `USD -> EUR` (with free swap to `EUR -> USD`).
- Free charts include ranges `1W`, `1M`, `3M`, `6M`, `1Y`, `2Y`.
- Intraday ranges `1H`, `6H`, and `1D` are subscription-only.
- "Choose any chart pair" is premium:
  - unlocked by active subscription
  - or unlocked by one-time Charts Pro ownership
- Optional Phase 1.x monetization experiment: Rewarded Ad can grant temporary chart-pair unlock to pure-free users.
  - applies only to chart pair selection
  - does not unlock intraday ranges (`1H`, `6H`, `1D`)
  - temporary unlock should be bidirectional for the selected pair
  - Remove Ads owners must not see rewarded-ad offers

### Screen ownership

| Screen | Owns | Does not own |
|--------|------|--------------|
| `Convert` | amount input, base currency, multi-currency results, favorite toggles, freshness/offline status, banner ad area | charts, settings, accounts, transfers |
| `Favorites` | local favorite pairs, max-3 rule, edit/delete, jump back to Convert context | unlimited favorites, cloud sync |
| `Charts` | fiat historical charts up to 2 years, range selector, high/low/change | crypto charts, metals, export, multi-pair compare |
| `Settings` | local preferences (default base, decimal places, refresh-on-open), cache controls, Remove Ads entry, privacy/about/version | account settings, backend sync, subscriptions before Phase 2 |

### Data and cache rules

| Data | Phase 1 source | Cache rule | Failure behavior |
|------|----------------|------------|------------------|
| Fiat latest rates | Frankfurter v2 | Keep last successful payload locally | Show cached stale/offline state if refresh fails |
| Fiat historical rates | Frankfurter historical endpoints | Cache by pair and range | Show cached chart data if available |
| Favorites | Local storage | Persistent until user deletes | Never requires network |
| Settings preferences | Local storage (SharedPreferences) | Persistent until user changes | Never requires network |
| Temp pair unlocks | Local storage (SharedPreferences) | 24h TTL, auto-expire | Never requires network |

### Implementation guardrail

Build by vertical slices: one user-visible behavior at a time, including its
minimal data, state, UI, and tests. Do not build one large data layer and one
large UI layer separately. Keep `ROADMAP.md` as the practical sequencing guide.

### Ads and privacy constraint

- If real ad SDKs are integrated (banner or rewarded), update store privacy disclosures and consent flow configuration before release.
- Keep purchase promises consistent:
  - Remove Ads must remove ad surfaces and ad prompts
  - subscription ad-removal behavior must remain consistent with one-time ownership fallback

### IAP purchase products (Phase 1)

| Product | Type | Price (CHF) | Note |
|---------|------|-------------|------|
| Remove Ads — forever | One-time | **1.99** | Core unlock; below My Currency Pro ($3.99) |
| Charts Pro — all pairs forever | One-time | **2.99** | Unlocks any chart pair selection |
| Subscription | Recurring | **Coming Soon** — 1-week free trial planned; store-local yearly price TBD | Informational only in Phase 1; real pricing TBD |

> Remove Ads purchase hides ALL ad surfaces AND removes rewarded-ad offer prompts (per monetization-access-rules.md).

## What's In / What's Out — Phase 1 (MVP)

### ✅ Phase 1 IN

| Feature | Detail |
|---------|--------|
| **Currencies (fiat)** | 16 MVP currencies: USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, **TRY** (Turkish Lira ⚠️ replaced RUB), KRW, SGD, HKD, NZD, CHF |
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
| **Crypto prices and charts** | Deferred. Requires CoinGecko or another source; do not embed API keys in Phase 1 mobile app |
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
|--------|------|-------------|------|
| Remove Banner Ads — 30 days | Rental | 0.50 | Low friction; "try before you buy" |
| Remove Banner Ads — forever | One-time | **1.99** | Core unlock; below My Currency Pro ($3.99) |
| **Charts Pro — all pairs forever** | One-time | **2.99** | Unlocks any chart pair selection |
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

### Crypto API (Deferred)

- CoinGecko Demo API requires a key.
- Do not ship that key directly inside the Phase 1 mobile app.
- Revisit BTC/ETH prices when there is a backend/proxy, a paid API plan, or an explicit decision that a public mobile key is acceptable.
- Crypto charts remain out of MVP.

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
- **Data**: Frankfurter v2 (free), direct from the app
- **Backend**: None
- **Success metric**: 500+ DAU within 3 months, 3–5% Remove Ads conversion

### Phase 2 — Convenience Paid Tiers + Backend *(triggered by ~2,000 DAU or user demand for alerts)*

| Tier | Price | Includes |
|------|-------|---------|
| Basic | 12 CHF/año | Rate alerts (push) + hourly refresh |
| Crypto/Metals add-on | 5–8 CHF/año extra | BTC, ETH, XAU, XAG if backend/API strategy is approved |

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
7. No backend, no subscription, no crypto/metals at launch
8. Self-host Frankfurter only if/when DAU exceeds ~10,000

---

## Changelog

| Date | Change | Verified |
|------|--------|----------|
| 2026-05-07 | RUB removed from MVP — Frankfurter confirmed without RUB (ECB suspended EUR/RUB on 2022-03-01) | curl: `api.frankfurter.dev/currencies` → RUB=false |
| 2026-05-07 | RUB → TRY (Turkish Lira) in MVP currency list | Frankfurter confirmed TRY available |
| 2026-05-08 | Crypto moved out of Phase 1. Reason: CoinGecko requires an API key and embedding that key in the mobile app is not an acceptable launch trade-off. | Product decision |
| 2026-05-07 | Historical note: BTC/ETH prices were previously considered for Phase 1, while BTC/ETH charts were deferred. Superseded on 2026-05-08. | Superseded |
| 2026-05-07 | CoinGecko Demo API rate limit confirmed: 30 calls/min, 10,000/month, API key required | Web search + curl verification |
| 2026-05-07 | Frankfurter currency count confirmed: **200** (not 165) from official frankfurter.dev | Official docs |
| 2026-05-07 | Frankfurter **no `/convert` endpoint** confirmed from official docs | frankfurter.dev |
| 2026-05-07 | Currency app chart limit: App Store listing does **NOT** specify a chart limit | App Store listing fetch |
| 2026-05-07 | Currency app has both **subscription (Currency+)** AND **one-time (Currency Pro $19.99)** IAP options | App Store listing |

---

## Phase Decision Matrix (Quick Reference)

| Decision | Phase 1 | Phase 2 | Phase 3 |
|----------|---------|---------|----------|
| **Data source** | Frankfurter free | ExchangeRate-API Pro + Frankfurter + optional crypto provider via backend | + CoinGecko or approved crypto provider |
| **Backend** | None | ASP.NET Core + PostgreSQL on Hostinger | Same |
| **Currencies** | 16 fiat currencies | All 200 from Frankfurter | + Crypto charts + Metals (XAU/XAG) |
| **Charts** | 2-year daily, unlimited free | + Multi-pair comparison | + Metals overlays |
| **Rate alerts** | No | Push via backend (subscription) | + Crypto price alerts |
| **Monetization** | Ads + Remove Ads one-time | + Subscriptions (Basic: 12 CHF/año) | + Crypto/Metals add-on |
| **Ads** | Banner only | Banner for free tier | Banner for free tier |
| **Metals** | No | No | Gold/Silver (XAU/XAG) |

---

## Luis's Key Questions — Answered Directly

**Q: Which phases?**
3 phases: MVP (free + ads, fiat-only), Phase 2 (backend + subscriptions and optional crypto API strategy), Phase 3 (crypto charts + metals + extensions).

**Q: What's in MVP?**
16 fiat currencies + 2-year fiat charts + offline cache + banner ads + Remove Ads (one-time 1.99 CHF). No crypto, no metals, no alerts, no backend.

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
| Crypto/Metals add-on | **5–8 CHF/año extra** | BTC, ETH, XAU, XAG if backend/API strategy is approved |

**Break-even**: ~10 subscribers (Basic) covers ExchangeRate-API Pro ($10/month ≈ 12 CHF/month).

**Grandfathering**: Google Play auto-preserves prices for existing subscribers. Apple requires "Preserve prices for existing subscribers" in App Store Connect.
