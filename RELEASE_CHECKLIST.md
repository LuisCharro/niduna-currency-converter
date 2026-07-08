# Release Checklist — Path to Google Play Store

> **Last updated:** 2026-07-08
> **App version:** 0.1.0+1 (pre-MVP)
> **Branch:** main (in sync with origin/main)
> **Status:** Code path complete, AAB+APK built and signed, 0 lint issues. Screenshots (C5) and feature graphic (C6) done. Accessibility pass done 2026-06-16; polish pass + screenshot refresh done 2026-07-08 (239 tests). **Remaining code work: B4 (real AdMob IDs), B5 (privacy link), and B8 (UMP consent flow — found in the 2026-07-08 plan review); B4/B5 are blocked on external steps, B8 on the AdMob consent message (E5b).**
>
> **Remaining before submission (short list, in dependency order):**
> 1. **Domain + email (niduna-site repo)** — buy `niduna.com` + attach to Vercel so `https://niduna.com/privacy/` is publicly reachable (the privacy *page* is already built; the Vercel project is SSO-gated until a domain is attached), and set up email so `support@niduna.com` receives mail (free forwarding is enough — provider comparison + "ask the friend" note in the site plan). Site-side steps: `niduna-site/RELEASE_PLAN.md` § S1. **Blocks C1, C10 and B5.**
> 2. E1–E4 — Google Play Developer account ($25) + identity verification + payment profile + create app draft *(parallel with 1)*
> 3. E5 — AdMob account + real ad unit IDs + GDPR consent message (E5b) *(parallel with 1)* → then B4 (swap test IDs), B8 (UMP consent flow in code — **new 2026-07-08 review finding**), and `app-ads.txt` on the site (E5c)
> 4. Rotate the TEMP keystore password (see callout below) *(anytime before 5)*
> 5. B5 in-app privacy link (needs 1) → B6 rebuild signed AAB
> 6. C2–C4, C7–C11 — Play Console listing content (title, descriptions, rating, Data Safety, category, contact + privacy/marketing URLs from 1, localized listings)
> 7. B7 upload AAB → pre-launch report → submit. **After approval:** run the site launch-day batch (`niduna-site/RELEASE_PLAN.md` § S2 — Play link, badge, JSON-LD, trust line).
> **2026-06-02 update:** iOS widget code merged but disabled (Xcode 26 simctl install bug). Code complete, verify on real iPhone when convenient. See "Blocker Summary" below.
> **2026-06-01 update:** Backend work deferred until post-publish. Code-only path: see "Code-Only Pre-Flight" below. Full detail in `docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`.
> **2026-06-02 review:** see `docs/REVIEW-2026-06-01.md` for the full audit.

---

## Code-Only Pre-Flight (Agent — Branch `release-prep`)

This section is the agent's agreed order. The rest of this file is the human-paced release flow (external steps + content steps + final upload).

| # | Item | Sub-item | Status | Commit |
|---|---|---|---|---|
| 1 | Fix 10 pre-existing test failures | — | ✅ Done | `6ac7c8e` (setUp fixes), `4a45cc4` (widget) |
| 2 | Visual verify Phase A-D | — | ✅ Done | `5491ea7` (range selector polish) + `1328338` (8 screenshots) |
| 3 | Dark mode audit | — | ✅ Done | `5491ea7` (decimal places dark contrast) |
| 4 | Release keystore trio | B1: generate keystore | ✅ Done | `200c888` |
| 4 | Release keystore trio | B2: `android/key.properties` | ✅ Done | `200c888` |
| 4 | Release keystore trio | B3: `build.gradle.kts` release signing | ✅ Done | `200c888` |
| 5 | Phase 1.x chart tests | crypto/crypto + fiat/crypto formulas | ✅ Done | `8a76058` (4 new tests) + `f65ef5e` (real logic fix) |
| 6 | Privacy link in Settings | B5: new row in Settings widget | ❌ Blocked on C1 (domain not public — see `niduna-site/RELEASE_PLAN.md`) | — |
| 7 | Build signed AAB | B6: `./scripts/build_appbundle.sh` smoke | ✅ Done | AAB at `build/app/outputs/bundle/release/app-release.aab` (50 MB, signed v2) |
| 8 | UI Polish cycle (Phase 6) | open | ✅ Done (range selector + decimal places) | `5491ea7` |

**Total agent time:** ~5h focused. After this, release is blocked only on external work (E1–E5) and content (C1–C11).

**Branch:** All this work is on `main` (merged from `release-prep` in commit `19f68b3`). The `release-prep` branch is kept around as a reference.

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
| E5b | AdMob → Privacy & messaging → create the GDPR consent message (required for EEA/UK/CH ads; pairs with code step B8) | In AdMob console, after E5 | ❌ |
| E5c | Publish `app-ads.txt` on niduna.com with the AdMob publisher ID from E5 | Site-side step — `niduna-site/RELEASE_PLAN.md` § S1.5 | ❌ |

### Code / Build Steps (agent can do these)

| # | Task | File(s) | Effort | Status | Commit / Note |
|---|------|--------|--------|--------|---|
| B1 | Generate release keystore | N/A (external file) | ~10 min | ✅ **Done** | `200c888` — at `android/app/niduna-upload.jks` (RSA 2048, 10000-day, valid until 2053) |
| B2 | Create `android/key.properties` (gitignored) | `android/key.properties` | ~5 min | ✅ **Done** | `200c888` — ⚠️ **password is TEMP, must be rotated before publish** (see Keystore note below) |
| B3 | Update `build.gradle.kts` release signing config | `android/app/build.gradle.kts` line ~37 | ~10 min | ✅ **Done** | `200c888` — release AAB now signed, falls back to debug if `key.properties` is missing |
| B4 | Replace AdMob test unit IDs with real ones | `lib/src/core/ads/ad_helper.dart`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist` | ~15 min | ❌ | All 5 unit IDs + app ID still `ca-app-pub-3940256099942544/...` (Google's test IDs) |
| B5 | Add privacy policy link in Settings screen | Settings widget (natural spot: the merged "Data & privacy" page) | ~30 min | ❌ | Blocked on C1 (domain not public yet — see `niduna-site/RELEASE_PLAN.md` § S1). Target URL: `https://niduna.com/privacy/` |
| B6 | Build release AAB with new keystore | `./scripts/build_appbundle.sh` | ~5 min | 🔁 **Must re-run before upload** | Build verified working (June AAB, 50 MB, signed v2), but the FINAL AAB must be rebuilt after B4 (real ad IDs) + B5 (privacy link) + B8 (consent flow) + keystore rotation. Do not upload the existing artifact. |
| B7 | Upload AAB to Play Console | External step after B6 | — | ❌ | — |
| B8 | **UMP consent flow (GDPR/EEA)** — NEW 2026-07-08 review | Ads init path (`lib/src/core/ads/`), uses `ConsentInformation`/`ConsentForm` from `google_mobile_ads` | ~2-3 hr | ❌ | Google requires a certified CMP consent message for EEA/UK/CH ad traffic (mandatory since 2024). Nothing in the app requests consent today. Pair with the AdMob-console side (E5: Privacy & messaging → create GDPR message). **Also:** the site privacy page claims "non-personalised advertising" — either configure NPA in the ad requests or align the privacy copy when implementing this. |

> **⚠️ Keystore password rotation (NEW — 2026-06-02):**
> The keystore was generated with a temporary password for this dev cycle.
> **Before publishing**, rotate the password:
> ```bash
> keytool -storepasswd -keystore android/app/niduna-upload.jks
> keytool -keypasswd -keystore android/app/niduna-upload.jks -alias niduna_currency_converter_upload
> ```
> Then update `android/key.properties` with the new passwords, and delete
> `/tmp/niduna_temp_keystore_pwd.txt` (the temp password file).
> See `docs/RELEASE_COMMANDS.md` § "Keystore management" for full steps.

### Content / Metadata Steps

| # | Task | Specs | Effort | Status |
|---|------|-------|--------|--------|
| C1 | Write & host privacy policy page | Page is **built and deployed** at `niduna-site/privacy/` (brand-level + per-app sections, 2026-06-02). Remaining: make it publicly reachable — buy `niduna.com` + attach to Vercel (project is SSO-gated). See `niduna-site/RELEASE_PLAN.md` § S1. | domain purchase | 🟡 Blocked on domain |
| C2 | App title (max 30 chars) | Must be unique in Play Store | ~10 min | ❌ |
| C3 | Short description (max 80 chars) | Example: *"45 currencies & crypto. Private, offline, no account."* (the app supports exactly 45 — do NOT claim 170+) | ~15 min | ❌ |
| C4 | Full description (max 4000 chars) | Features, privacy notes, Niduna differentiator | ~45 min | ❌ |
| C5 | Screenshots (min 2, max 8) | 1080px wide JPEG/PNG: Convert / Chart / Favorites, light + dark | ~1 hr | ✅ **Done** (refreshed 2026-07-08) | 6 final screenshots at 1080×2400 in `docs/release-prep/screenshots/`, re-captured 2026-07-08 after the polish pass (flat Favorites cards, no nav clipping, visible dark chart fill). English, paid-user state (no ads), real currency icons. Captured on `Pixel7_EN` AVD; `SCREENSHOT_DARK=true ./.devtools/capture_android_screens.sh` for the dark set. Requires swiftshader GPU (`-gpu swiftshader_indirect`) for icon rendering. The older 8-tab set from 2026-06-01 is kept alongside as reference. |
| C6 | Feature graphic (1024x500) | Branded graphic for featured placements | ~30 min | ✅ **Done** | `docs/release-prep/feature-graphic.png` (1024×500, botanical gradient + app name + phone mockup + tagline) |
| C7 | Content rating questionnaire (IARC/CERT) | In Play Console > Policy > App content | ~15 min | ❌ |
| C8 | Data Safety form | Match actual behavior: HTTPS calls, local storage, zero PII collected by us — **but the AdMob SDK must be declared** (device/advertising identifiers, ad interaction data; see the "Third-party SDKs" table below). Align answers with the consent setup from B8/E5b. | ~30 min | ❌ |
| C9 | Category selection | Likely: Finance > Finance tools or Productivity | ~2 min | ❌ |
| C10 | Contact email + website + privacy URL | Required fields in Console listing. `support@niduna.com` must actually receive mail first — email setup is `niduna-site/RELEASE_PLAN.md` § S1.4 | ~10 min | ❌ (blocked on domain + email) |
| C11 | Localized listings (EN, DE, ES, IT, FR) | At minimum: translated short description | ~1 hr | ❌ |

---

## Implementation Notes — exact clues per open step (2026-07-08)

### B4 — Real AdMob IDs (mostly env vars, almost no code)
The IDs flow through the build, not the source:
- **Ad unit IDs** are read via `String.fromEnvironment` in
  `lib/src/core/ads/ad_helper.dart` and injected as `--dart-define`s by
  `flutter_app_define_args` in `scripts/common.sh:93`. Set env vars
  `ADMOB_ANDROID_BANNER_AD_UNIT_ID` + `ADMOB_ANDROID_REWARDED_AD_UNIT_ID`
  when running `./scripts/build_appbundle.sh`.
- **`ADMOB_USE_TEST_ADS` defaults to `true`** (`scripts/common.sh:96`,
  `ad_helper.dart:6-9`) — the release build command MUST set
  `ADMOB_USE_TEST_ADS=false` or real IDs are ignored.
- **Android app ID**: env var `ADMOB_ANDROID_APP_ID` →
  `android/app/build.gradle.kts:43-45` (manifest placeholder; falls back
  to Google's test app ID `~3347511713`).
- **iOS app ID**: hardcoded test ID at `ios/Runner/Info.plist:28`
  (`GADApplicationIdentifier`) — only matters for the deferred iOS release.
- Suggested: keep the real values in a gitignored `.env.release` sourced
  by the build scripts, and document the final command in
  `docs/RELEASE_COMMANDS.md`.

### B5 — In-app privacy link
- **The app has NO `url_launcher`** — add `url_launcher: ^6.3.0` to
  `pubspec.yaml` first; nothing in `lib/` can open a browser today.
- Natural spot: a "Privacy policy" `SettingsTile` at the bottom of the
  merged Data & privacy page
  (`lib/src/features/settings/widgets/data_details_page.dart`), opening
  `https://niduna.com/privacy/` with
  `launchUrl(..., mode: LaunchMode.externalApplication)`.
- New ARB key (e.g. `labelPrivacyPolicy`) in all 5 `lib/l10n/app_*.arb`
  + `flutter gen-l10n`; extend the page test in `test/widget_test.dart`
  ("Data & privacy page attributes sources in plain language").

### B8 — UMP consent flow (after E5b creates the console message)
- Entry point: `lib/main.dart:33` — today it fire-and-forgets
  `MobileAds.instance.initialize()`. Wrap with the UMP sequence from the
  same `google_mobile_ads` package: `ConsentInformation.instance
  .requestConsentInfoUpdate(...)` → `ConsentForm
  .loadAndShowConsentFormIfRequired(...)` → only initialize/show ads when
  `canRequestAds` is true. Keep it non-blocking for app startup (ads are
  already lazy).
- **Decision to make here:** always-non-personalized (add `npa: '1'`
  extras to `AdRequest` in `lib/src/core/ads/ad_banner_widget.dart` and
  `admob_rewarded_ad_service.dart`; matches the site privacy page as
  written) vs consent-based personalization (higher revenue; then update
  the site privacy page's "non-personalised advertising" claim —
  `niduna-site/privacy/index.html` line ~142).
- Test with UMP debug geography = EEA on the emulator
  (`ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea,
  testIdentifiers: [...])`) before trusting it.

### Keystore rotation — commands are in the callout above; afterwards
re-run `./scripts/build_appbundle.sh` (B6) and confirm the AAB signature
with `jarsigner -verify` or `apksigner`.

### C2-C4 + C11 — Listing copy
- Draft everything in a new `docs/release-prep/store-listing.md` (EN
  master + DE/ES/IT/FR short descriptions) so it's reviewable before
  pasting into the Console. The app's own ARB files are the vocabulary
  reference for translated feature names.
- Facts to respect: **45 currencies (34 fiat + 11 crypto)** — count is
  from `lib/src/core/currency/supported_currencies.dart`; rates update
  once daily; free = full converter + charts, one-time IAPs remove
  ads/unlock extras. Trust line from `docs/FEATURE_IDEAS.md`: "One
  purchase, forever. No subscription. No account."

### C7-C10 — Console forms (click-paths)
- **C7 rating**: Console → Policy → App content → Content rating
  questionnaire. Utility/finance answers: no violence, no UGC, no data
  sharing between users → expect Everyone/3+.
- **C8 Data Safety**: answers pre-written in this file § "Privacy
  Policy — What To Disclose" + § "Data Refresh Cadence". Plus AdMob:
  declare "Device or other IDs" (advertising ID), purpose Advertising,
  collected-not-shared-by-us, per the consent setup chosen in B8.
- **C9**: Category = Finance (no financial-features declaration needed —
  see § "Financial Features Declaration").
- **C10 values**: email `support@niduna.com` (must receive — site plan
  S1.4), website `https://niduna.com`, privacy
  `https://niduna.com/privacy/`, marketing URL
  `https://niduna.com/currency-converter/`.

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

## Home-screen Widgets — Current State

### Android widget — ✅ Redesigned and verified

The Android home-screen widget has been completely redesigned from a
single-pair placeholder to a 3-pair icon-led medium widget.

- **Layout:** header (amount + freshness) + 3 rows (currency symbol
  in circle + code + value + trend), thin dividers, warm paper surface
- **Implementation:** `AppWidgetProvider` + `RemoteViews` (not Glance)
- **Files:** `NidunaAppWidgetProvider.kt`, `widget_layout.xml`,
  `widget_background.xml`, `widget_icon_circle.xml`
- **Data bridge:** Dart `HomeWidgetProvider.pushData()` pushes 3 pairs
  (code, symbol, value, trend, changePercent per row) after rates load
- **Favorites-driven:** shows top 3 favorites; fallback to
  EUR/GBP/BTC when favorites are empty
- **Starter favorites:** seeds USD-EUR, USD-GBP, USD-BTC on first run
- **Placeholder state:** shows "Niduna · Open to load" when no data
  pushed yet (widget added before app first opened)
- **Design spec:** `docs/superpowers/specs/2026-06-13-widget-redesign-design.md`
- **Verification:** ✅ runtime-verified on Pixel 7 emulator — 3 pairs
  render correctly, tap opens Convert, placeholder shows when no data

### iOS widget — ⚠️ Code complete, sim install blocked

The iOS widget (WidgetKit) code is complete and the Xcode project
target is wired up, but the iOS widget is **disabled by default in
main** because `xcrun simctl install` fails on iOS 26 / Xcode 26
with `Invalid placeholder attributes` for any widget extension. This
is a known simctl bug, not a code issue.

- **Files:** `ios/Runner/Widgets/NidunaWidget/NidunaWidget.swift`,
  `Info.plist`, `NidunaWidget.entitlements`, `Assets.xcassets/`
- **Data bridge:** App Group `group.com.niduna.currencyConverter` —
  main app writes via `UserDefaults(suiteName: ...)` from Dart
  through the home_widget plugin; widget reads from the same suite
- **Verification:** ✅ build succeeds, `.appex` is correctly
  produced, embed phase in Xcode is correctly placed; ❌ iOS sim
  install fails before the app can launch
- **Re-enable for real device:** (a) `cd ios && GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby scripts/add_widget_target.rb`
  (idempotent), (b) build & run on a real iPhone via Xcode
- **Code quality:** follows iOS 17+ WidgetKit conventions
  (`@main WidgetBundle`, `TimelineProvider`, `UserDefaults(suiteName:)`)
- **Full report:** `docs/release-prep/README.md` (Android + iOS widget
  history), `docs/REVIEW-2026-06-01.md` § "P3-2 iOS widget extension"

For the short current-truth summary covering Favorites nav visibility,
widgets, trend arrows, and chart-comparison deferral, see
`docs/superpowers/plans/2026-06-13-local-feature-status-harmonization.md`.

---

## Execution Order (Recommended — cross-repo master order, 2026-07-08)

This order spans **two repos**: this app repo and `niduna-site`
(the privacy policy + marketing pages live there; site-side detail in
`niduna-site/RELEASE_PLAN.md`). Phases 0/1 can run in parallel;
everything after depends on them.

```
─ Phase 0 · Accounts (external, parallel with Phase 1) ────────────────
Step 1:  Register Play Console account ($25) + identity + payments  [E1-E3]
Step 2:  Create the app in Play Console (draft)                     [E4]
Step 3:  Register AdMob, create real ad unit IDs                    [E5]
Step 3b: AdMob console: create the GDPR consent message
         (Privacy & messaging)                                      [E5b]

─ Phase 1 · Make niduna.com public (SITE — blocks C1/C10/B5) ──────────
Step 4:  Buy niduna.com + attach to Vercel            [niduna-site S1.1]
Step 5:  Verify /privacy/ + /currency-converter/ are publicly
         reachable (incognito, no SSO)                [niduna-site S1.2-S1.3]
         → C1 becomes ✅; privacy + marketing URLs are now final
Step 5b: Email on the domain — support@niduna.com must RECEIVE
         mail (free forwarding is enough; ask the friend which
         provider he uses)                            [niduna-site S1.4]
         → needed by C10 (Console contact email) + site mailto CTAs

─ Phase 2 · Finalize the app build (CODE — agent can do B4/B5/B6) ─────
Step 6:  Rotate the TEMP keystore password (human, local)  [see callout]
Step 7:  Swap AdMob test IDs for real ones (needs Step 3)  [B4]
Step 7b: Implement UMP consent flow (needs Step 3b); align
         the site's "non-personalised ads" claim            [B8]
Step 7c: Publish app-ads.txt on niduna.com (needs Steps
         3 + 4)                             [E5c / niduna-site S1.5]
Step 8:  Add in-app privacy link → https://niduna.com/privacy/
         (needs Step 5)                                     [B5]
Step 9:  ./scripts/check.sh + build signed AAB              [B6]

─ Phase 3 · Play Console listing (needs Phases 0-2) ───────────────────
Step 10: Listing content: title, descriptions, category      [C2-C4, C9]
Step 11: Contact email (working support@ from Step 5b) +
         website + privacy URL (from Step 5)                 [C10]
Step 12: Upload screenshots + feature graphic (✅ ready,
         refreshed 2026-07-08)                               [C5-C6]
Step 13: Content rating questionnaire + Data Safety form     [C7-C8]
Step 14: Localized listings (EN, DE, ES, IT, FR)             [C11]

─ Phase 4 · Submit ────────────────────────────────────────────────────
Step 15: Upload AAB → pre-launch report → fix if needed      [B7]
Step 16: Submit for review

─ Phase 5 · After approval (SITE launch-day batch) ────────────────────
Step 17: Play Store link + "Available" badge + JSON-LD
         datePublished + trust line, deploy + verify  [niduna-site S2]
Step 18: Post-launch backlog: docs/FEATURE_IDEAS.md (app),
         niduna-site PENDING.md deferred items
```

Rule of thumb: **nothing in Phases 2-4 can finish while the site is
still SSO-gated** — the privacy URL is required by the in-app link (B5),
the Console listing (C10), and the Data Safety form (C8).

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

---

## Change Log (this file)

- **2026-07-08 (plan review)** — Full review of both release plans found
  4 gaps, now fixed: (1) **B8 NEW** — no UMP/GDPR consent flow exists in
  the app; required for EEA/UK/CH ad serving, pairs with new E5b (AdMob
  consent message) — and the site privacy page's "non-personalised ads"
  claim must be aligned when implementing it; (2) **E5c NEW** —
  `app-ads.txt` on niduna.com (site plan S1.5); (3) B6 status corrected
  from Done to "must re-run" — the final AAB needs real ad IDs, privacy
  link, consent flow, and the rotated keystore; (4) C3's example claimed
  "170+ currencies" — the app supports exactly 45. C8 now explicitly
  requires declaring the AdMob SDK.
- **2026-07-08 (later)** — Rewrote the Execution Order as a cross-repo
  master order (Phases 0-5) covering this repo + `niduna-site`
  (`niduna-site/RELEASE_PLAN.md` created the same day). Key correction:
  C1's privacy *page* already exists on the site; the real blocker is
  the domain purchase (Vercel SSO gate), which also blocks B5/C10.
  Screenshots C5 re-captured post-polish. Header short list reordered
  by dependency.
- **2026-07-08** — Refreshed header with a consolidated "Remaining before
  submission" short list (accounts → AdMob IDs → privacy policy → keystore
  rotation → listing content → upload). Noted the 2026-06-16 accessibility
  pass and that main is pushed/in sync with origin. No blocker statuses
  changed — E1–E5, B4, B5, B7, C1–C4, C7–C11 all still open.
- **2026-06-13** — Marked C5 (screenshots) and C6 (feature graphic) as ✅
  Done. 6 final store screenshots at 1080×2400 captured on the new
  `Pixel7_EN` AVD (Convert / Chart with data point tooltip / Favorites
  × light + dark), all in `docs/release-prep/screenshots/`. Feature
  graphic at `docs/release-prep/feature-graphic.png` (1024×500).
  Capture infra added: `integration_test/screenshot_gallery_test.dart`,
  `.devtools/sample_seed_data.dart` (rewritten for real SharedPreferences
  keys), `.devtools/generate_sample_prefs.dart` (`--free-user` /
  `--no-favorites` flags). Note: swiftshader GPU required for icon
  rendering on emulator. OG social image refreshed on Vercel site
  (1200×630).
- **2026-06-02** — Updated Blocker Summary statuses to reflect actual
  state: B1–B3, B6 are ✅ Done (not ❌ as previously marked). Added
  keystore password rotation callout. Added "Home-screen Widgets —
  Current State" section. Added link to `docs/REVIEW-2026-06-01.md`
  in header. Status header now reflects "code complete, external
  work remaining."
- **2026-06-01** — Added code-only pre-flight section; refreshed
  header to point at `docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`.
- **2026-05-31** — Initial version.
