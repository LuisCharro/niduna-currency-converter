# Release Checklist — Path to Google Play Store

> **Last updated:** 2026-05-31
> **App version:** 0.1.0+1 (pre-MVP)
> **Branch:** main
> **Status:** Ready for final prep work (~1-2 days focused)

---

## Single Source of Truth Index

| Document | Purpose | Status |
|----------|---------|--------|
| **This file** | **Consolidated release checklist — start here** | — |
| `docs/providers/frankfurter.md` | Fiat provider: license, endpoints, refresh cadence | Done |
| `docs/providers/fawazahmed0.md` | Crypto provider: license, CDN, history approach | Done |
| `docs/providers/coinpaprika.md` | Dev-only provider: why it's blocked for production | Done |
| `.plan/PLAY_STORE_PUBLISH_CHECKLIST.md` | Detailed Play Console field-by-field reference | Done (may need minor updates below) |
| `.plan/APP_STORE_PUBLISH_CHECKLIST.md` | App Store checklist (deferred — Android first) | Deferred |

---

## Blocker Summary — Must Complete Before Submission

### External Steps (you do these outside the codebase)

| # | Task | URL / Notes | Status |
|---|------|-------------|--------|
| E1 | Register Google Play Developer account ($25 one-time) | https://play.google.com/console | ❌ |
| E2 | Verify developer identity (required since 2026) | In Play Console | ❌ |
| E3 | Set up payment profile (for IAP revenue later) | In Play Console > Setup > License | ❌ |
| E4 | Create app in Play Console (draft mode) | In Play Console > All apps > Create app | ❌ |
| E5 | Register AdMob account + create ad units | https://admob.google.com | ❌ |

### Code / Build Steps (agent can do these)

| # | Task | File(s) | Effort | Status |
|---|------|--------|--------|--------|
| B1 | Generate release keystore | N/A (external file) | ~10 min | ❌ |
| B2 | Create `android/key.properties` (gitignored) | `android/key.properties` | ~5 min | ❌ |
| B3 | Update `build.gradle.kts` release signing config | `android/app/build.gradle.kts` line ~37 | ~10 min | ❌ |
| B4 | Replace AdMob test unit IDs with real ones | `lib/src/shared/widgets/ad_helper.dart`, Android manifest | ~15 min | ❌ |
| B5 | Add privacy policy link in Settings screen | Settings widget | ~30 min | ❌ |
| B6 | Build release AAB with new keystore | `./scripts/build_appbundle.sh` | ~5 min | ❌ |
| B7 | Upload AAB to Play Console | External step after B6 | — | ❌ |

### Content / Metadata Steps

| # | Task | Specs | Effort | Status |
|---|------|-------|--------|--------|
| C1 | Write & host privacy policy page | GitHub Pages or similar; public URL required | ~1 hr | ❌ |
| C2 | App title (max 30 chars) | Must be unique in Play Store | ~10 min | ❌ |
| C3 | Short description (max 80 chars) | Example: *"Convert 170+ currencies instantly. Privacy-first. Beautiful."* | ~15 min | ❌ |
| C4 | Full description (max 4000 chars) | Features, privacy notes, Niduna differentiator | ~45 min | ❌ |
| C5 | Screenshots (min 2, max 8) | 1080px wide JPEG/PNG: Convert, Charts, Settings tabs | ~1 hr | ❌ |
| C6 | Feature graphic (1024x500) | Branded graphic for featured placements | ~30 min | ❌ |
| C7 | Content rating questionnaire (IARC/CERT) | In Play Console > Policy > App content | ~15 min | ❌ |
| C8 | Data Safety form | Match actual behavior: HTTPS calls, local storage, zero PII | ~30 min | ❌ |
| C9 | Category selection | Likely: Finance > Finance tools or Productivity | ~2 min | ❌ |
| C10 | Contact email + website + privacy URL | Required fields in Console listing | ~10 min | ❌ |
| C11 | Localized listings (EN, DE, ES, IT, FR) | At minimum: translated short description | ~1 hr | ❌ |

---

## Already Done ✅ (no action needed)

### Provider Licensing — Clean for Publication

| Provider | Role in release builds | License | Commercial OK? |
|----------|----------------------|---------|---------------|
| **Frankfurter** | Fiat latest + fiat historical charts | Unlicense (public domain) | **YES** |
| **fawazahmed0** | Crypto latest + crypto historical charts | **CC0-1.0** (public domain) | **YES** |
| CoinPaprika | Dev/emulator builds only | Proprietary (commercial forbidden) | **NO — not shipped** |

Release build profile (`release_safe`) uses only Frankfurter + fawazahmed0.
Build-time guard crashes if release build attempts non-safe profile.
See `docs/providers/*.md` for full per-provider details.

### Code Complete

| Item | Evidence |
|------|----------|
| All 40 fiat currencies + 11 crypto | `supported_currencies.dart`, multi-provider repo |
| Client-side conversion (`amount × rate`) | Convert controller |
| Historical charts (fiat 2Y, crypto 1Y) | Charts controller + fawazahmed0 date-file client |
| Favorites (max 3, local storage) | FavoritesStore wired |
| Offline mode / cache persistence | Cache per base/range; stale fallback works |
| Dark mode (system-follow + toggle) | AppTheme + Settings |
| Real AdMob SDK (`google_mobile_ads`) | BannerAd + RewardedAd integrated; test-mode only until real IDs |
| Remove Ads IAP stub + Charts Pro IAP stub | PurchaseServiceStub, IapPurchasePlayer |
| i18n (EN, DE, ES, IT, FR) | ARB files + generated localizations |
| Branded app name ("Currency Converter") | Committed `bade57e` |
| iOS deployment target 15.0 | Committed `bade57e` |
| Release APK + App Bundle builds verified | `scripts/build_apk.sh`, `scripts/build_appbundle.sh` |
| Firebase hosting deploy pipeline | `scripts/firebase_hosting_*.sh` |
| `./scripts/check.sh` passes (122 tests, 0 errors) | CI green |

### Provider Profile System — Correctly Segregated

| Profile | Used by | Crypto Latest | Crypto History | Shipped in stores? |
|---------|----------|--------------|---------------|------------------|
| `release_safe` | Release APK/AAB, Firebase hosting | **fawazahmed0 only** | **fawazahmed0 only** | **YES** |
| `dev_coinpaprika` | Emulator, debug builds | CoinPaprika → fawazahmed0 fallback | **CoinPaprika** | NO (dev only) |

Controlled via `PROVIDER_PROFILE` dart-define. Default is `release_safe`.
Dev scripts (`.devtools/*.sh`) override to `dev_coinpaprika`.

---

## Execution Order (Recommended)

```
Step 1:  External — Register Play account ($25)                    [E1-E4]
Step 2:  External — Register AdMob, get real ad unit IDs             [E5]
Step 3:  Code — Generate keystore + update signing config              [B1-B3]
Step 4:  Code — Swap AdMob test IDs for real ones                   [B4]
Step 5:  Code — Privacy policy page + in-app link                     [B5]
Step 6:  Code — Build release AAB with real keystore                 [B6]
Step 7:  External — Upload AAB to Play Console                      [B7]
Step 8:  Content — Privacy policy hosted publicly                  [C1]
Step 9:  Content — Screenshots + feature graphic                  [C5-C6]
Step 10: Content — App metadata (title, descriptions, category)      [C2-C4, C9-C11]
Step 11: Content — Content rating + Data Safety forms               [C7-C8]
Step 12: Review — Pre-launch report from Play Console               [auto after upload]
Step 13: Submit for review                                             [Play Console]
```

Steps 1-2 are external and can happen in parallel.
Steps 3-6 are code changes (agent can do autonomously).
Steps 7-13 alternate between external console work and content creation.

---

## Data Refresh Cadence (for privacy policy + data safety form)

| Data type | Source | Frequency | How users see it |
|-----------|--------|-----------|-----------------|
| Fiat rates | Frankfurter / ECB | **Once per business day** (~16:00 CET) | "Updated May 29" label + `(i)` tooltip |
| Crypto prices | fawazahmed0 CDN | **Once per day** (static JSON update) | Same freshness indicator |
| Chart history | Frankfurter (fiat) / fawazahmed0 (crypto) | Cached persistently; refetched on gap or staleness | Date range shown on chart header |

**Key phrase for policy:** *"Exchange rates update once daily from public central bank and open-data sources. No real-time or intraday data."*

---

## Privacy Policy — What To Disclose

### Data this app collects

| Type | Collected? | Detail |
|------|-----------|--------|
| Personal name, email, phone | **NO** | No accounts, no login |
| Location | **NO** | Not requested |
| Device ID / advertising ID | **NO** | No analytics, no tracking SDK |
| Financial info | **NO** | Display-only; no transactions, no wallet |
| Health / fitness | **NO** | N/A |

### Data this app transmits

| Type | To whom | When |
|------|---------|------|
| IP address | Frankfurter, jsdelivr, Cloudflare CDNs | On each rate fetch (HTTPS, unavoidable) |
| (nothing else) | — | No API keys, no user IDs, no custom headers |

### Local storage

| Data | Where | Purpose |
|------|-------|---------|
| Favorite pairs | SharedPreferences | User's saved currency pairs (max 3) |
| App settings | SharedPreferences | Base currency, decimals, theme, refresh preference |
| Rate cache | SharedPreferences | Last known fiat + crypto rates (offline use) |
| Chart cache | SharedPreferences | Historical data for displayed pairs |
| IAP state | Platform purchase receipt store | Remove Ads / Charts Pro ownership |
| Temp unlocks | SharedPreferences | 24h chart-pair unlock TTLs |

All local storage is cleared on app uninstall. Users can clear cache via Settings.

### Third-party SDKs (Phase 1)

| SDK | Purpose | Data it may collect | Our mitigation |
|-----|---------|-------------------|---------------|
| Google Mobile Ads | Banner ads, rewarded ads | Device signals for ad targeting | Will disclose in Data Safety form when live |
| (none others) | — | — | — |

---

## Financial Features Declaration (Play Console)

Google requires every app to declare financial features. Correct answers:

| Feature | This app? |
|---------|----------|
| Cryptocurrency wallet | **NO** |
| Cryptocurrency exchange | **NO** |
| Tokenized digital asset (NFT) | **NO** |
| Stock trading / portfolio management | **NO** |
| Mobile payments / digital wallets | **NO** |
| Banking / loans | **NO** |
| Insurance | **NO** |

**Declaration:** *"My app doesn't provide any financial features."*

A currency converter that displays exchange rates is NOT a financial service. It does not hold funds, execute trades, facilitate transactions, or manage wallets.

---

## Post-Submission (Not Blocking)

These can ship in v0.2.0+ updates:

| Item | Priority | Notes |
|------|----------|-------|
| Crash reporting (Crashlytics) | Low | Post-MVP |
| Analytics (privacy-compliant or none) | None per AGENTS.md | Phase 1 = zero tracking |
| Promo video | Nice-to-have | Increases conversion |
| Tablet screenshots | Optional | Phone-first MVP |
| Long-press context menu on rows | Low priority | Swipe already covers Pin/Swap |
| App Store (iOS) submission | Deferred | $99/year fee; Android first |
