# Google Play Store Publishing Checklist

> Pre-submission checklist for Niduna Currency Converter.
> Updated: 2026-05-22
>
> **Current app version:** `0.1.0+1` (pre-MVP, must stay `0.x.x`)
> **Branch:** `turbo/ui-redesign`
> **Target:** Google Play Store (Apple App Store deferred)

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done / Ready |
| 🔶 | Partially done / Needs review |
| ❌ | Not started / Blocking |
| ⏸️ | Deferred to post-MVP |
| 🔄 | In progress |

---

## 1. Developer Account & Console Setup

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Google Play Developer account registered ($25 one-time) | ❌ | External step — [play.google.com/console](https://play.google.com/console) |
| 1.2 | Developer identity verified | ❌ | Required as of 2026 for all developers |
| 1.3 | Payment profile set up (for IAP revenue) | ❌ | Needed when Remove Ads IAP goes live |
| 1.4 | App created in Play Console (draft mode) | ❌ | Requires account first |

---

## 2. App Signing (BLOCKER)

> **Important:** Google Play **only accepts AAB (Android App Bundle)** format since August 2021. APK uploads are rejected for new apps. Use `flutter build appbundle --release` (via `scripts/build_appbundle.sh`), NOT `flutter build apk`.

| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Release keystore created | ❌ | `build.gradle.kts` still uses debug signing keys |
| 2.2 | `key.properties` file created (excluded from git via `.gitignore`) | ❌ | Template needed — see [Signing docs](https://docs.flutter.dev/deployment/android#signing-the-app) |
| 2.3 | `build.gradle.kts` release signing config updated | ❌ | Line 37: change from `signingConfigs.getByName("debug")` to release keystore |
| 2.4 | Decision: Google Play App Signing vs self-managed key | 🔄 | Recommended: let Google manage the upload key for safety |
| 2.5 | Keystore backup stored securely (not in repo) | ❌ | Lose this = can't update the app ever again |

**Quick fix reference:**

```bash
# Generate keystore (run once, store safely)
keytool -genkey -v -keystore ~/niduna-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias niduna

# Create android/key.properties (add to .gitignore!)
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=niduna
storeFile=/Users/luis/niduna-release-key.jks
```

---

## 3. Android Manifest & Technical Requirements

| # | Task | Status | Current State |
|---|------|--------|---------------|
| 3.1 | `android:label` branded (not generic "currency_converter") | ❌ | Currently `"currency_converter"` — should be `"Niduna Currency Converter"` or similar |
| 3.2 | Target API level meets current requirement | ✅ | **Verified: APK builds with `compileSdkVersion=36` (Android 16)** via Flutter 3.41.7. Exceeds Aug 2026 requirement of API 36. |
| 3.3 | Min SDK reasonable | ✅ | Flutter default (21) covers ~99% of devices |
| 3.4 | No unnecessary permissions declared | ✅ | Manifest has zero `<uses-permission>` entries — clean. Note: `INTERNET` is auto-added by Flutter's `http` package at build time (expected, needed for rate fetching) |
| 3.5 | `android:allowBackup` explicitly set | 🔶 | Defaults to true; fine for this app but should be explicit |
| 3.6 | Network security config (if using HTTPS APIs) | 🔶 | Not declared; HTTP client uses HTTPS by default but explicit config is best practice |
| 3.7 | `usesCleartextTraffic` set correctly | ✅ | Not declared = defaults to false (good — no plain HTTP) |
| 3.8 | All 64-bit architectures supported | ✅ | Flutter default includes arm64-v8a |

---

## 4. Rate Data Provider Licensing (BLOCKER)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | CoinPaprika replaced for production builds | ❌ | **Per `PROVIDER_LIMITS.md`: CoinPaprika ToS forbids commercial/Play Store distribution on free plan and user-facing display on paid plans** |
| 4.2 | Production provider selected and integrated | ❌ | Recommendation: fawazahmed0 (CC0 license) or similar free-for-commercial API |
| 4.3 | `release_safe` provider profile uses licensed source | ❌ | Current `release_safe` must not use CoinPaprika |
| 4.4 | Rate data attribution displayed if required by provider | ❌ | Check chosen provider's attribution requirements |
| 4.5 | Fallback behavior when rate API is unavailable | ✅ | Cached rates + offline capability exists |

---

## 5. Privacy Policy & Data Safety

| # | Task | Status | Notes |
|---|------|--------|-------|
| 5.1 | Privacy policy page published (public URL) | ❌ | Required by Play Store. Can be a simple GitHub Pages page |
| 5.2 | Privacy policy linked in-app (Settings screen) | ❌ | Add link/button in Settings |
| 5.3 | Play Data Safety questionnaire completed | ❌ | Must match actual app behavior exactly |
| 5.4 | Data collection inventory documented | 🔶 | Known data: network requests for rates, local storage (shared_preferences) for favorites/settings. No PII collected. |
| 5.5 | Third-party SDK disclosures filed | ⏸️ | Deferred until AdMob/IAP integration |
| 5.6 | GDPR / CCPA compliance language in policy | ❌ | Include even if minimal data — good practice |

**Expected Data Safety answers (to verify):**
- Is data encrypted in transit? → Yes (HTTPS API calls)
- Is data shared with third parties? → Phase 1: No (no analytics, no ads yet)
- Can users request data deletion? → Yes (uninstall clears local storage)
- Does app collect location? → No
- Does app collect financial info? → No (display only, no transactions)

**Key rules from Google's Data Safety docs (verified 2026-05-22):**
- Even apps that collect **zero** user data must complete the form and provide a privacy policy URL
- **On-device-only** data (shared_preferences, local files) does NOT need disclosure — only data transmitted off-device counts
- **Ephemeral** data (in-memory HTTP response, processed immediately, never persisted) can be declared as such
- Data collected by **SDKs/libraries** must be disclosed even if your own code doesn't directly handle it
- Apps on **internal test track only** are exempt from Data Safety section
- Discrepancy between declaration and actual behavior = enforcement action (block/removal)

---

## 6. Content Rating (IARC / CERT)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 6.1 | Content rating questionnaire completed | ❌ | In Play Console under Policy > App content |
| 6.2 | Expected rating: Everyone / Teen | 🔄 | Currency converter with no user-generated content, no violence, no ads (yet) = likely Everyone |

---

## 7. Store Listing Assets

| # | Task | Status | Specs |
|---|------|--------|-------|
| 7.1 | App icon (512x512 PNG) | ✅ | Already deployed to mipmap densities |
| 7.2 | Feature graphic (1024x500 PNG/JPG) | ❌ | Used for featured placements. Branded graphic with app name |
| 7.3 | High-res icon (512x512, no padding) | ❌ | Separate from adaptive icon — used in some Play surfaces |
| 7.4 | Screenshots (phone, min 2, max 8) | ❌ | **1080px wide max**, JPEG/PNG. Show: Convert tab, Charts tab, Settings |
| 7.5 | Screenshots (tablet, optional) | ❌ | If targeting tablets |
| 7.6 | Short description (80 char max) | ❌ | Example: "Convert 170+ currencies instantly. Offline-ready. Beautiful design." |
| 7.7 | Full description (4000 char max) | ❌ | Feature list, privacy notes, what makes Niduna different |
| 7.8 | Promo video (YouTube URL, optional) | ❌ | Nice-to-have, increases conversion |
| 7.9 | Application type / Category | ❌ | Likely: Finance > Finance tools or Productivity |

**Screenshot plan (minimum 2):**
1. Convert tab — amount entry, currency selection, result display
2. Charts tab — historical rate chart with range selector

**Optional additional screenshots:**
3. Settings screen — theme, about, version info
4. Small-screen proof — works well on compact phones

---

## 8. App Metadata

| # | Task | Status | Notes |
|---|------|--------|-------|
| 8.1 | App title (max 30 chars) | ❌ | Must be unique in Play Store. Ideas: "Niduna Currency", "Niduna Convert" |
| 8.2 | Short description (max 80 chars) | ❌ | See 7.6 above |
| 8.3 | Full description (max 4000 chars) | ❌ | See 7.7 above |
| 8.4 | Contact email / website / privacy policy URL | ❌ | Required fields in Console |
| 8.5 | Default language set + localized listings (EN, DE, ES, IT, FR) | ❌ | MVP scope: provide localized app/store text for these languages |

---

## 9. Monetization Integration (Deferred)

These are NOT blockers for an initial free release without ads/IAP.

| # | Task | Status | Priority |
|---|------|--------|----------|
| 9.1 | AdMob SDK integrated (`google_mobile_ads`) | ⏸️ | Post-MVP |
| 9.2 | Banner ad units configured in AdMob console | ⏸️ | Post-MVP |
| 9.3 | AdMob App ID added to AndroidManifest | ⏸️ | Post-MVP |
| 9.4 | Remove Ads IAP (`in_app_purchase` package) | ⏸️ | Post-MVP |
| 9.5 | Billing permission in manifest | ⏸️ | Post-MVP |
| 9.6 | Google Merchant Account linked | ⏸️ | Post-MVP |
| 9.7 | IAP products defined in Play Console | ⏸️ | Post-MVP |

**Note:** Per AGENTS.md and UI_REDESIGN.md, Phase 1 ships **without live ads**. AdMob placeholder is acceptable for initial submission if the app is fully functional without it.

---

## 10. Quality & Testing

| # | Task | Status | Notes |
|---|------|--------|-------|
| 10.1 | Release build compiles cleanly (`flutter build appbundle --release`) | 🔶 | Works but needs keystore (see #2) |
| 10.2 | `./scripts/check.sh` passes (analyzer + tests) | ✅ | 122 tests pass, 0 issues |
| 10.3 | Tested on small-screen Android device | ✅ | Small_Screen_API_36 verified |
| 10.4 | Tested on medium-phone Android device | ✅ | Medium_Phone verified |
| 10.5 | Tested on iOS simulator | ✅ | iPhone 16e verified |
| 10.6 | Text scaling tested (1.3x+) | ✅ | Widget tests cover this |
| 10.7 | Dark mode tested | 🔶 | Theme exists; manual visual pass recommended |
| 10.8 | Offline behavior tested | 🔶 | Cached rates work; test full offline flow end-to-end |
| 10.9 | No crash-on-start | ✅ | Splash screen working on both platforms |
| 10.10 | Play Console pre-launch report reviewed | ❌ | Upload AAB to Console to get automated report |
| 10.11 | Accessibility basics (screen reader, contrast) | 🔶 | Run Android Accessibility Scanner |

---

## 11. Version Management

| # | Task | Status | Notes |
|---|------|--------|-------|
| 11.1 | `pubspec.yaml` version follows semver | ✅ | `0.1.0+1` — pre-MVP format correct |
| 11.2 | `versionCode` increments on each release | ✅ | Auto-managed by Flutter from pubspec |
| 11.3 | Firebase deploy script version matches | ✅ | Both use same `0.x.x` line |
| 11.4 | Changelog / release notes drafted | ❌ | Needed for each Play Console release |

---

## 12. Security Checklist

| # | Task | Status | Notes |
|---|------|--------|-------|
| 12.1 | No hardcoded secrets in codebase | ✅ | `.env.local` gitignored, keys external |
| 12.2 | Debug flags disabled in release builds | ✅ | `APP_DEV_MODE=false` in release scripts |
| 12.3 | Dev-only provider not accessible in release | ✅ | `PROVIDER_PROFILE=release_safe` default |
| 12.4 | No log statements leaking sensitive data | 🔶 | Review `print()` / `debugPrint()` calls before final build |
| 12.5 | Proguard/R8 obfuscation enabled (release) | 🔶 | Verify Gradle release build config |

---

## 13. Post-Launch (Not needed for initial submission)

| # | Task | Status | Notes |
|---|------|--------|-------|
| 13.1 | Crash reporting (Crashlytics or similar) | ⏸️ | Post-MVP |
| 13.2 | Analytics (privacy-compliant or none) | ⏸️ | Per AGENTS.md: no tracking in Phase 1 |
| 13.3 | Update cadence established | ⏸️ | Plan for rate data updates, bug fixes |
| 13.4 | User reviews response process | ⏸️ | Monitor and respond to feedback |

---

## Blocker Summary (Must Fix Before Submission)

These items **must** be resolved before the app can be submitted to Google Play:

| # | Blocker | Effort |
|---|---------|--------|
| **2** | App signing keystore + release build config | ~30 min |
| **3.1** | Branded `android:label` in manifest | ~2 min |
| **4** | Replace CoinPaprika with licensed provider for `release_safe` | ~2-4 hours |
| **5.1-5.2** | Privacy policy (hosted URL + in-app link) | ~1 hour |
| **6** | Content rating questionnaire | ~15 min |
| **7** | Store listing assets (screenshots, graphics, descriptions) | ~2-3 hours |
| **8** | App metadata (title, descriptions, contact info) | ~30 min |
| **1.1** | Google Play Developer account ($25) | External |

**Estimated total effort for unblocked submission: ~1-2 days**

---

## Deferred Items (Can Ship Without)

Items marked ⏸️ can be shipped in a future update:
- AdMob / ads integration
- Remove Ads IAP
- Analytics / crash reporting
- Tablet-specific screenshots
- Promo video

MVP note: translations are NOT deferred. Release scope includes EN, DE, ES, IT, FR for meaningful user-facing app and listing text.

---

## Related Skills & Docs

| Resource | Path | Purpose |
|----------|------|---------|
| Store release check (repo-local) | `.agent/skills/store-release-check/SKILL.md` | Privacy-first compliance gates |
| Store release check (shared) | `.agent-local/skills/release/store-release-check.SKILL.md` | 8-question release gate |
| Mobile release QA | `.agent-local/skills/release/mobile-release-qa.SKILL.md` | Pre-ship sanity pass |
| Store metadata review | `.agent-local/skills/release/store-metadata-review.SKILL.md` | Listing quality check |
| Privacy surface check | `.agent-local/skills/release/privacy-surface-check.SKILL.md` | Privacy disclosure audit |
| Store UI readiness | `.agent-local/skills/mobile/references/store-ui-readiness-checklist.md` | Touch targets, text scale |
| Provider limits | `PROVIDER_LIMITS.md` | API licensing requirements |
| Build scripts | `scripts/build_apk.sh`, `scripts/build_appbundle.sh` | Release build commands |
| Firebase distribution | `scripts/firebase_app_distribution.sh` | Tester distribution workflow |
