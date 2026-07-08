# Feature Ideas — Post-Launch Backlog (v0.2+)

> **Created:** 2026-07-08, from competitive research of top currency converter
> apps (XE, Wise, Currency by Grossman, Elk, Valuta+, Currency Converter Plus,
> Easy Currency Converter, CurrencyXT).
> **How to use this doc:** when a feature here feels right, open a dedicated
> brainstorm + plan for it (per AGENTS.md workflow). Nothing in this file is
> committed work — it's a ranked menu.
> **Constraint check for every idea:** must fit the Phase 1 identity — no
> backend, no accounts, no tracking (see `DEFINITIONS.md`). Ideas that
> violate this are listed only with an explicit note.

---

## Ranked feature ideas

### 1. Local rate alerts ⭐ top pick

| | |
|---|---|
| **What** | User sets a target rate for a pair (e.g. "EUR/USD above 1.10"). On each rates refresh, the app checks thresholds locally and fires a local notification. |
| **Why** | The single most-requested "advanced" feature across the category. XE, Wise, CurrencyXT, and Currency Exchange Rate Alert all offer it — **but all the big players require an account**. A local, no-login alert is a genuine "privacy-first and still useful" differentiator. |
| **Seen in** | XE (account required), Wise (account required), CurrencyXT (no sign-in — closest model) |
| **Privacy fit** | ✅ Perfect — threshold check on refresh needs no server. Note: with once-daily rates, alerts fire at most daily; set that expectation in UI copy. |
| **Effort** | M — local notifications plugin, threshold store, settings UI, check-on-refresh hook. |

### 2. Inline trend sparkline on Convert/Favorites rows

| | |
|---|---|
| **What** | A compact 7-day sparkline next to the trend badge on each rate row, surfacing trend context at the point of conversion instead of requiring a tab switch. |
| **Why** | Wise shows rate change inline on the converter itself; reviewers like trend-at-a-glance. The app already has historical data, chart rendering (fl_chart), and trend badges — most of the plumbing exists. |
| **Seen in** | Wise |
| **Privacy fit** | ✅ Uses already-cached historical data. Watch API-call volume: reuse chart cache, don't add per-row fetches. |
| **Effort** | M — data reuse is the tricky part; rendering is small. |

### 3. Incremental conversion table ("cheat sheet")

| | |
|---|---|
| **What** | For a selected pair, show a pre-computed table of common amounts (1 / 5 / 10 / 20 / 50 / 100 / 500 / 1000) converted at once. Answer-before-you-type for shopping/travel. |
| **Why** | This is Elk's entire product (Apple Design Award winner) — solves "many amounts" the way our multi-convert view solves "many currencies". Complements rather than duplicates the existing Convert tab; could live in the conversion lens or a long-press action. |
| **Seen in** | Elk |
| **Privacy fit** | ✅ Pure client-side math on existing rates. |
| **Effort** | S–M — one widget + an entry point decision. |

### 4. Widget theme picker

| | |
|---|---|
| **What** | Let users pick the home-screen widget appearance (system / light / dark / brand) independently of the app theme. |
| **Why** | Small, well-liked touch in the category's #1 iOS app; we're already widget-strong (redesigned 3-pair widget on both platforms). |
| **Seen in** | Currency by Jeffrey Grossman (system/light/green/dark widget options) |
| **Privacy fit** | ✅ A preference + widget re-render. |
| **Effort** | S–M per platform (Android RemoteViews theming, iOS WidgetKit). |

### 5. Watch / Wear OS companion

| | |
|---|---|
| **What** | Watch app + complication with the favorite pair(s); Digital Crown / rotary scrolling through amounts. |
| **Why** | Both flagship iOS competitors ship one and reviewers highlight it. A no-account watch converter is rare. |
| **Seen in** | Currency by Grossman (Watch keypad + calculator), Elk (Crown-scrolled conversions) |
| **Privacy fit** | ✅, but **big build** — new targets on both platforms, and iOS needs the Apple Developer team set up first (same blocker as the iOS widget on device). |
| **Effort** | L — defer until after launch traction. |

### Nice-to-haves (deferred, with reasons)

- **Camera banknote scan / AR conversion** (GMoney, Cash Reader): "magic" for travelers, but needs on-device OCR/ML — a big build for a secondary use case.
- **Keyboard extension** for inline conversion in other apps: category feature nobody's flagship markets heavily; low ROI.
- **Travel/tip mode** (Elk's positioning): overlaps heavily with idea #3; revisit only if #3 lands well.
- **Auto-detect local currency by location** (Valuta+): reduces first-run friction, but even a one-time location permission dents the "zero permissions" privacy story. Locale-based guess (no permission) is already possible — consider that variant only.

---

## Store-listing trust angles (free marketing ammunition)

Documented competitor failures this app structurally avoids — use in Play Store
copy and review responses:

| Competitor failure (documented in their reviews) | Our answer |
|---|---|
| Ads persist even after paying for ad removal (XE, Currency Converter Plus) | One-time Remove Ads that works instantly, forever |
| "Lifetime" purchase features later moved into a new subscription (Currency Converter Plus) | **One purchase, forever. No subscription.** |
| Forced bank-account linking for core features (XE) | No account, no login, no bank linking, ever |
| Trial "bait and switch" — free tier gutted after 2 weeks (Elk) | Free tier is permanent; no time-limited trial |
| Aggressive full-screen interstitials on app resume (Currency Converter Plus) | **Banner ads only — never full-screen** |
| Stale rates with no timestamp (category-wide complaint) | Explicit freshness label + offline-cache transparency (already shipped) |

Suggested listing line: *"One purchase, forever. No subscription. No account.
No tracking. Banner ads only — never full-screen."*

## UI patterns worth borrowing (smaller than features)

- **XE:** explicit "as of [timestamp]" rate freshness label — we already do this; keep it prominent, it defuses the #1 category complaint.
- **Wise:** rate-change context inline on the converter (→ idea #2).
- **Elk:** incremental value table (→ idea #3); swipe to rescale amounts.
- **Currency by Grossman:** widget appearance picker (→ idea #4).
