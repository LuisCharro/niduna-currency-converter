# Release Checklist — Path to Google Play Store

> **Last updated:** 2026-08-28
> **App version:** 0.1.0+1 (pre-MVP)
> **Branch:** main
> **Status:** The product UI and local data path are complete, but the
> **store release path is not code-complete**. The last recorded baseline is
> 239 passing tests with clean analysis (re-verified 2026-08-28). The current
> Flutter toolchain is healthy and the release AAB smoke build was revalidated
> successfully on 2026-08-28. Open release work is B4
> (real AdMob IDs), B5 (privacy link), B8 (UMP consent + privacy-options
> entry point), and B9 (real Play Billing replacing `PurchaseServiceStub`).
> Screenshots and the feature graphic are ready. The site is GDPR-prepared,
> but `niduna.com` does not resolve yet and the hosting plan must be made
> compatible with commercial use before the monetized app launches.
>
> **Remaining before submission (short list, true dependency order — updated 2026-08-28):**
> 0. **Re-entry/toolchain preflight:** keep the current Flutter/dependency
> baseline unless a targeted update is justified. This is complete for the
> current machine; the final AAB still waits for B4/B5/B8/B9 and the key/version
> gates below.
> 1. **Site foundation:** follow the approved Hostinger KVM 2 static-migration
> plan: preserve Vercel rollback, pass the VPS security/staging gate, buy and
> register `niduna.com` separately through Hostinger, attach DNS, and create/test
> `support@niduna.com`. Site detail: `niduna-site/RELEASE_PLAN.md` § S1 and
> `niduna-site/docs/hostinger-static-migration.md`. This unlocks C1, C10, and
> B5.
> 2. **Accounts in parallel:** create the personal Play account, finish
> identity + real-device verification, create/verify the merchant payments
> profile, create the app draft, AdMob app/ad units/EEA message, and finalize
> the immutable IDs for the three one-time products. Create the products as
> soon as Console permits; some account/app states may first require a
> billing-enabled bundle. [E1-E5, E5b, E8]
> 3. **Release candidate before the closed test:** implement B4, B5, B8 and
> B9; rotate and back up the upload key; run checks; build a signed AAB with a
> new versionCode. **Do not upload the existing stub-purchase build to any
> reviewable track.** Internal testing may be used first if useful.
> 4. **Console setup:** finalize the English listing and all required App
> content forms, including ads, target audience, Data Safety, financial
> features and any trader-status task shown by Play Console. Localized store
> listings are optional and must not delay the closed test. [C2-C10]
> 5. **Closed test:** publish the release candidate to the closed track,
> recruit 15-16 people so at least 12 remain opted in continuously for 14
> days, and test real billing/restore plus UMP during the window. [E7]
> 6. **Production:** fix findings with incremented versionCodes, apply for
> production access after the gate, review the pre-launch report, submit, and
> wait until the Play listing is publicly reachable.
> 7. **Site launch batch:** only after the production listing is public,
> replace Coming soon with the real Play URL and deploy/verify S2.
>
> **~~Open decision~~ RESOLVED (2026-07-16): "Coming Soon" subscription teasers removed** — the Settings "Subscription · Coming Soon" tile, the Charts locked intraday chips (1H/6H/1D + premium snackbar), and the Convert info-sheet "faster updates / future Premium subscription" line are gone from the UI on all platforms (no platform gating). Entitlement plumbing kept for Phase 2. Verified on emulator light+dark, 239 tests pass.
> **2026-06-02 update:** iOS widget code merged but disabled (Xcode 26 simctl install bug). Code complete, verify on real iPhone when convenient. See "Blocker Summary" below.
> **2026-06-01 update:** Backend work deferred until post-publish. Code-only path: see "Code-Only Pre-Flight" below. Full detail in `docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`.
> **2026-06-02 review:** see `docs/REVIEW-2026-06-01.md` for the full audit.

---

## Phase 0 — Release re-entry and toolchain preflight

This phase was added after the project had been idle for more than a month.
It prevents a broad SDK/package upgrade from being mixed with the release
implementation and records the current environment before external work starts.

- [x] **Repository baseline** — before this documentation update, both
  release repos were clean on `main` and synchronized with `origin/main`
  (verified 2026-08-28). The current working-tree changes are the intentional
  plan updates from this review.
- [x] **Toolchain audit** — Flutter `3.41.7` / Dart `3.11.5`, Android SDK 35,
  Java 21, Xcode 26.6 and CocoaPods 1.17 are installed and `flutter doctor -v`
  reports no issues. Flutter `3.47.2` is available, but is not a release
  prerequisite.
- [x] **Dependency audit** — the locked baseline resolves; conservative and
  major upgrade dry-runs were inspected without changing `pubspec.yaml`.
  Do not run `flutter upgrade` or a global `pub upgrade --major-versions` as
  part of the release.
- [x] **Dart verification** — `flutter analyze` and `flutter test` pass with
  239 tests (verified 2026-08-28).
- [x] **Android release-build revalidation** — `./scripts/build_appbundle.sh
  --verbose` completed successfully on 2026-08-28 after Gradle repopulated its
  local dependency cache. The diagnostic AAB is signed and verifies, but is not
  publishable because it still uses test AdMob IDs and the purchase stub.

### Dependency policy for this release

- Keep Flutter `3.41.7` and the current lockfile as the working baseline unless
  a controlled compatibility test justifies an isolated SDK upgrade.
- Update packages selectively, in the task that needs them, with tests and a
  native build afterward. B8 may update `google_mobile_ads` if the UMP API or
  native SDK requires it; B9 adds the official `in_app_purchase` dependency.
- Minor or transitive updates are optional and must not be bundled into the
  release without a clear reason and fresh verification.
- Do not regenerate iOS Pods or release binaries merely because time passed.
  Regenerate native dependencies after relevant dependency changes, and build
  the final AAB only after B4/B5/B8/B9, key rotation and the versionCode bump.

---

## Historical Code-Only Pre-Flight (reference only)

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

**Historical note:** this table predates B8/B9 and must not be used as the
current release order. Open release work is listed at the top of this file.

**Branch:** All this work is on `main` (merged from `release-prep` in commit `19f68b3`). The `release-prep` branch is kept around as a reference.

---

## Single Source of Truth Index

| Document | Purpose | Status |
|----------|---------|--------|
| **This file** | **Consolidated release checklist — start here** | — |
| `../../niduna-site/RELEASE_PLAN.md` | Site-only subplan; must agree with this file | Active |
| `docs/release-prep/play-store-listing.md` | Reviewable English listing draft | Active |
| `docs/RELEASE_COMMANDS.md` | Commands only; not an ordering source | Active |
| `docs/providers/frankfurter.md` | Fiat provider: license, endpoints, refresh cadence | Done |
| `docs/providers/fawazahmed0.md` | Crypto provider: license, CDN, history approach | Done |
| `docs/providers/coinpaprika.md` | Dev-only provider: why it's blocked for production | Done |
| `.plan/PLAY_STORE_PUBLISH_CHECKLIST.md` | Detailed Play Console field-by-field reference | Done (may need minor updates below) |
| `.plan/APP_STORE_PUBLISH_CHECKLIST.md` | App Store checklist (deferred — Android first) | Deferred |

---

## Current external references — re-check on execution day

Store and SDK requirements change. These primary sources support the current
ordering and declarations in this checklist:

- [Production access for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
  — closed-test eligibility, tester count and duration.
- [Create and set up the store listing](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en-EN)
  — listing fields, limits and translations.
- [Data Safety guidance](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
  and [Google Mobile Ads SDK disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure)
  — declarations must include SDK behavior.
- [UMP for Flutter](https://developers.google.com/admob/flutter/privacy) —
  consent refresh, `canRequestAds` gating and privacy-options entry point.
- [Payments profile](https://support.google.com/googleplay/android-developer/answer/7161426?hl=en)
  and [one-time products](https://support.google.com/googleplay/android-developer/answer/1153481?hl=en)
  — catalog setup, immutable IDs, pricing and Billing permission.

If Play Console shows a stricter or account-specific task, follow the Console
and update this checklist before proceeding.

---

## Blocker Summary — Must Complete Before Submission

### External Steps (you do these outside the codebase)

| # | Task | URL / Notes | Status |
|---|------|-------------|--------|
| E1 | Register Google Play Developer account ($25 one-time) | https://play.google.com/console | ❌ |
| E2 | Verify developer identity (required since 2026) | In Play Console | ❌ |
| E3 | Set up the payments/merchant profile — **launch-critical since 2026-07-16** (required before E8 in-app products can be created; needs bank details for payouts) | Play Console > Setup > Payments profile | ❌ |
| E4 | Create app in Play Console (draft mode) | In Play Console > All apps > Create app | ❌ |
| E5 | Register AdMob account + create ad units | https://admob.google.com | ❌ |
| E5b | AdMob → Privacy & messaging → create the GDPR consent message (required for EEA/UK/CH ads; pairs with code step B8) | In AdMob console, after E5 | ❌ |
| E5c | Publish `app-ads.txt` on niduna.com with the AdMob publisher ID from E5 | Site-side step — `niduna-site/RELEASE_PLAN.md` § S1.5 | ❌ |
| E6 | Complete the trader-status / verified-public-contact task shown by Play Console for EU distribution. Use truthful personal details and review exactly what Play says will be public before submitting. | Play Console → App content, after E4 | ❌ |
| E7 | New personal accounts created after 2023-11-13 currently need a closed test with at least **12 opted-in testers for 14 continuous days** before applying for production access. Start only after app setup is complete **and a policy-safe release candidate exists**; target 15-16 recruits for dropout margin. | Play Console → Testing → Closed testing | ❌ |
| E8 | **Finalize IDs, create and activate three one-time products in Play Console** — Remove Ads 1.99 CHF, Charts Pro 2.99 CHF, Favorites Pro 0.99 CHF. IDs cannot be changed/reused, so decide them before B9; suggested: `remove_ads_lifetime`, `charts_pro_lifetime`, `favorites_pro_lifetime`. Requires E3/E4. If Console does not expose product creation yet, implement B9 with those final IDs and upload the billing-enabled bundle to internal testing first; then create/activate the products before purchase testing or the closed track. | Play Console → Monetize with Play → Products → One-time products | ❌ |

> **Publishing identity (decided 2026-07-11 — "Pegolandia model", see
> `Niduna/docs/strategy/Niduna_Company_Options_CH_vs_US.md` Option 0 and
> `Reprocess_deprecated/Pegolandia_Style_Brand_First_App_Portfolio_Plan.md`):**
> publish as an **individual**, no company registered. "Niduna" is the
> brand (app names, icons, website, © notice); the verified **legal
> name** is what Google shows in "About the developer" for personal
> accounts created after Nov 2023 — plus address/email/phone in the EU
> via E6. Expect the store listing to show the personal name, exactly
> like the reference developer's Apple listing does. Guardrails from the
> strategy doc: never claim GmbH/LLC/Inc., never fake an address, keep
> store/payment identity truthful; the *website* stays brand-first. The
> site's privacy page (Contact & controller section, 2026-07-11) states
> the individual-developer status and defers the publishing name to the
> store listing.

### Code / Build Steps (agent can do these)

| # | Task | File(s) | Effort | Status | Commit / Note |
|---|------|--------|--------|--------|---|
| B1 | Generate release keystore | N/A (external file) | ~10 min | ✅ **Done** | `200c888` — at `android/app/niduna-upload.jks` (RSA 2048, 10000-day, valid until 2053) |
| B2 | Create `android/key.properties` (gitignored) | `android/key.properties` | ~5 min | ✅ **Done** | `200c888` — ⚠️ **password is TEMP, must be rotated before publish** (see Keystore note below) |
| B3 | Update `build.gradle.kts` release signing config | `android/app/build.gradle.kts` line ~37 | ~10 min | ✅ **Done** | `200c888` — release AAB now signed, falls back to debug if `key.properties` is missing |
| B4 | Replace AdMob test unit IDs with real ones | `lib/src/core/ads/ad_helper.dart`, `android/app/build.gradle.kts`, `ios/Runner/Info.plist` | ~15 min | ❌ | All 5 unit IDs + app ID still `ca-app-pub-3940256099942544/...` (Google's test IDs) |
| B5 | Add privacy policy link in Settings screen | Settings widget (natural spot: the merged "Data & privacy" page) | ~30 min | ❌ | Blocked on C1 (domain not public yet — see `niduna-site/RELEASE_PLAN.md` § S1). Target URL: `https://niduna.com/privacy/` |
| B6 | Build release AAB with new keystore | `./scripts/build_appbundle.sh` | ~5 min | 🔁 **Must re-run before upload** | Smoke revalidated on 2026-08-28: Gradle cache populated and a 51 MB signed AAB was produced and verified. The diagnostic artifact is not publishable because it still uses test AdMob IDs and the purchase stub. The FINAL AAB must be rebuilt after B4 (real ad IDs) + B5 (privacy link) + B8 (consent flow) + B9 (real billing) + keystore rotation. **Do not pass `--no-pub` to the release build:** Flutter must regenerate the release-filtered plugin registrant; with a stale development registrant, `integration_test` can break the Java compilation. **versionCode rule (added 2026-07-16):** every Play upload needs a strictly HIGHER build number — bump the `+N` in `pubspec.yaml` `version: 0.1.0+N` for each upload, closed-track updates included (Play rejects a reused versionCode). |
| B7 | Upload AAB to Play Console | External step after B6 | — | ❌ | — |
| B8 | **UMP consent flow + privacy options** | Ads init path (`lib/src/core/ads/`), uses `ConsentInformation`/`ConsentForm` from `google_mobile_ads` | ~2-3 hr | ❌ | Ad requests are already non-personalised, but the app still initializes Mobile Ads without UMP. Request consent info on every launch, show the form when required, gate ad requests on `canRequestAds`, and expose a privacy-options entry point when UMP reports it is required. Pair with E5b and keep the site policy aligned. |
| B9 | **Real Play Billing** — replace `PurchaseServiceStub` with a real implementation | `pubspec.yaml` (add `in_app_purchase`), new service in `lib/src/core/monetization/`, injection at `lib/src/app_shell.dart:94`, `settings_controller.dart:99` (restore), `iap_purchase_player.dart` (stream-driven phases) | ~1-2 days | ❌ | The app currently ships a FAKE purchase flow: 3 priced "Buy" buttons → "Processing payment…" overlay → always succeeds after ~2 s, no billing library present. Submitting this risks rejection and gives entitlements away free. Implementation is not blocked by Console product creation once E8's immutable IDs are finalized. The products must be active before real purchase/restore testing and before the closed track. **Full clues: Implementation Notes § B9.** |

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
>
> **⚠️ Keystore BACKUP (added 2026-07-11 — do right after rotation):**
> `niduna-upload.jks` and `key.properties` are gitignored and exist on
> ONE machine only. After rotating: store a copy of the .jks + both
> passwords in a password manager, plus a second copy off-machine
> (encrypted USB / private cloud). Losing the upload key doesn't kill
> the app (Play App Signing can reset upload keys) but costs days of
> support friction; losing it before first upload costs nothing to
> prevent now.

### Content / Metadata Steps

| # | Task | Specs | Effort | Status |
|---|------|-------|--------|--------|
| C1 | Write & host privacy policy page | Page is built, deployed and GDPR-prepared. The Vercel preview is public; remaining: complete the approved Hostinger KVM 2 security/staging gate, buy/register `niduna.com` separately through Hostinger, attach DNS and verify the final URL. Update the policy's hosting paragraph only after the Hostinger host is live. See `niduna-site/RELEASE_PLAN.md` § S1. | Hostinger gate + domain | 🟡 Blocked |
| C2 | App title (max 30 chars) | Must be unique in Play Store | ~10 min | ❌ |
| C3 | Short description (max 80 chars) | Example: *"45 currencies & crypto. Private, offline, no account."* (the app supports exactly 45 — do NOT claim 170+) | ~15 min | ❌ |
| C4 | Full description (max 4000 chars) | Features, privacy notes, Niduna differentiator | ~45 min | ❌ |
| C5 | Screenshots (min 2, max 8) | 1080px wide JPEG/PNG: Convert / Chart / Favorites, light + dark | ~1 hr | ✅ **Done** (refreshed 2026-07-08) | 6 final screenshots at 1080×2400 in `docs/release-prep/screenshots/`, re-captured 2026-07-08 after the polish pass (flat Favorites cards, no nav clipping, visible dark chart fill). English, paid-user state (no ads), real currency icons. Captured on `Pixel7_EN` AVD; `SCREENSHOT_DARK=true ./.devtools/capture_android_screens.sh` for the dark set. Requires swiftshader GPU (`-gpu swiftshader_indirect`) for icon rendering. The older 8-tab set from 2026-06-01 is kept alongside as reference. |
| C6 | Feature graphic (1024x500) | Branded graphic for featured placements | ~30 min | ✅ **Done** | `docs/release-prep/feature-graphic.png` (1024×500, botanical gradient + app name + phone mockup + tagline) |
| C7 | Content rating questionnaire (IARC/CERT) | In Play Console > Policy > App content | ~15 min | ❌ |
| C7b | **Target audience declaration — declare 13+** (added 2026-07-11) | Separate from C7! In App content → Target audience. Declaring ANY under-13 age group triggers the Families Policy (certified ad SDKs only, ad limits, stricter review) — wrong fit for an AdMob-funded utility. Content rating "Everyone" (C7) and target audience "13+" are compatible and both correct here. | ~5 min | ❌ |
| C8 | Data Safety form | Match actual behavior: HTTPS calls, local storage, zero PII collected by us — **but the AdMob SDK must be declared** (device/advertising identifiers, ad interaction data; see the "Third-party SDKs" table below). Align answers with the consent setup from B8/E5b. | ~30 min | ❌ |
| C9 | Category selection | Likely: Finance > Finance tools or Productivity | ~2 min | ❌ |
| C10 | Contact email + website + privacy URL | Required fields in Console listing. `support@niduna.com` must actually receive mail first — email setup is `niduna-site/RELEASE_PLAN.md` § S1.4 | ~10 min | ❌ (blocked on domain + email) |
| C11 | Localized listings (DE, ES, IT, FR) | Optional post-launch optimization; Play can serve the default English listing/automatic translation | ~1 hr | ⏸ Optional |

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
- **Decision resolved:** both banner and rewarded code already use
  `AdRequest(nonPersonalizedAds: true)`. Keep that behavior. UMP is still
  required, and the app must expose a privacy-options entry point when
  `getPrivacyOptionsRequirementStatus()` says it is required.
- Test with UMP debug geography = EEA on the emulator
  (`ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea,
  testIdentifiers: [...])`) before trusting it.

### B9 — Real Play Billing (replaces the Phase-1 stub)

**Decision context:** payments must work at launch, so the "Phase 2"
migration documented in `.agent/iap-purchase-plan.md` § "Migration to
Real IAP" is pulled forward into this release. What ships today is
fake: `purchase_service_stub.dart` waits ~2 s and returns success,
`IapPurchasePlayer` shows "Processing payment…" with no payment system
behind it, and no billing package exists in `pubspec.yaml`.

Implementation clues (verified against the code 2026-07-16):

1. **Finalize IDs first (E8):** product IDs cannot be changed or reused and
   must match the code — suggested `remove_ads_lifetime` /
   `charts_pro_lifetime` / `favorites_pro_lifetime`, priced 1.99 / 2.99 /
   0.99 CHF as displayed in `upgrade_shelf.dart`. Create/activate the products
   immediately if Console permits; otherwise do it after step 2's
   billing-enabled bundle is uploaded internally. They must be active before
   product lookup and purchase tests.
2. Add `in_app_purchase` (official Flutter plugin) to `pubspec.yaml`, implement
   the service below, and make the first billing-enabled internal-test bundle.
3. New `PlayPurchaseService implements PurchaseService`
   (`lib/src/core/monetization/purchase_service.dart` is the interface;
   all 3 products are non-consumables → `buyNonConsumable` +
   `completePurchase`). Handle the `purchaseStream` states: pending,
   purchased, restored, canceled, error.
4. **Injection point:** `lib/src/app_shell.dart:94` constructs
   `MonetizationController(prefs, adService: adService)` WITHOUT a
   `purchaseService`, so the stub default at
   `monetization_controller.dart:19` is what ships. Pass the real
   service there; keep the stub as the test-only default.
5. **Restore purchases:** `settings_controller.dart:99` currently shows
   a "Restore purchases is coming soon" snackbar (contradicting its own
   tile subtitle). Call `InAppPurchase.instance.restorePurchases()` and
   re-derive entitlements from the restored purchase stream events.
6. **`IapPurchasePlayer`** (`iap_purchase_player.dart`) phases are
   timer-driven — rewire them to the purchase stream (pending →
   processing, purchased → completed, canceled/error → failed).
   `ProductType.subscription` stays unwired (not sold in v0.1).
7. Local entitlement persistence (`MonetizationEntitlements` on
   SharedPreferences) stays the UI source of truth; also listen to the
   stream at startup for restored/pending purchases completing.
8. **Tests:** extend/replace the stub tests listed in
   `.agent/iap-purchase-plan.md` § Tests; mocks live in the test files
   (repo rule), never in `lib/`.

**Testing reality:** end-to-end purchase testing REQUIRES the app on a
Play track (the E7 closed track is perfect) plus License testing (Play
Console → Settings → License testing — add your own + testers' Gmail
addresses; their test purchases are not charged). It cannot be tested
before E4 + E8 exist. Device/emulator needs Play Store services and a
logged-in Google account. Uploading the B9 build to the running closed
track does NOT reset the E7 14-day clock.

### E7 — Closed-testing playbook (the 12-tester / 14-day gate)

**The rule, precisely:** personal accounts created after Nov 2023 must
have ≥12 testers opted in to a closed test **concurrently and
continuously for the trailing 14 days** before they can apply for
production access. It is a rolling window: if the opted-in count drops
below the minimum, the window is broken and the clock effectively
restarts. It is NOT "12 people who each tested at some point."
(Minimum was 20 at policy launch, reduced to 12 in 2024 — confirm the
current number in the Console banner when the account exists.)

**Store visibility during all this:** creating the app (E4) and running
the closed test does NOT put it on the public Play Store. In closed
testing the app is not searchable and has no public listing — it is
reachable ONLY via the opt-in link, only by the testers you added. The
public listing appears solely when you promote to production after the
gate (Step 15b/16). So there is no "half-published" exposure risk in
starting E7 early with the June AAB.

**What testers need:** a Google account + an Android phone. What they
actually do is a one-time ~2-minute task: click the opt-in link, accept,
install the app from Play. After that their only job is passive — keep
the app installed and stay opted in for 2 weeks. No daily usage, no
feedback duty, no meetings. Occasional real use is a bonus (helps answer
the production-access questionnaire honestly).

**Recruiting plan (do this while creating the account):**
- List candidates: friends/family/colleagues with Android. Target
  **15-16 sign-ups** so 2-3 dropouts can't break the 14-day window.
- The ask, in one sentence: "Install my app from this link and just
  leave it on your phone for two weeks — nothing else to do."
- Explicitly tell them NOT to uninstall or opt out until you say so.
- If short of 12: partners' phones, work colleagues, a second device
  per person (each needs its own Google account to count).
- Still short — external fallbacks (researched 2026-07-11):
  - **Free:** mutual-testing communities — r/AndroidClosedTesting
    subreddit or closed-testing Discords (you opt into their tests in
    exchange).
  - **Paid, one-time ~$15-25:** tester services, e.g.
    testerscommunity.com (~$15/15 testers), primetestlab.com (~$15,
    same-day dropout replacement), or Upwork/Fiverr gigs ($20-25).
  - **Quality caveat:** the production-access questionnaire asks how
    testers were recruited and what feedback they gave — keep real
    friends as the core (genuine usage + feedback) and use services/
    communities only to top up past 12 concurrent. Never buy store
    reviews/ratings — that's a ban-level policy violation; paid
    *opt-in testing* is the tolerated gray zone.

**Console setup (after E4, using the policy-safe release candidate from
B4/B5/B8/B9 — do not upload the June stub-purchase artifact):**
1. Play Console → Testing → Closed testing → create track, upload AAB.
   (Blocked until the "Set up your app" dashboard tasks are complete —
   declarations + store listing; see the Step 2c GATE note in the
   Execution Order.)
2. Add testers by email list (or a Google Group — easier to manage).
3. Set the track's country availability to include EVERY tester's
   country — testers outside the selected countries cannot opt in.
4. Publish the track (closed-test releases go through a short review).
5. Send everyone the opt-in link; confirm the opted-in count in the
   Console reaches 12+ — the 14-day clock runs from when the count is
   satisfied, so chase stragglers in the first days.

**During the 14 days:** glance at the opted-in count every few days;
replace dropouts immediately. Note 2-3 pieces of real feedback — the
questionnaire asks what you learned and what you changed.

**After 14 days:** Console → apply for production access → answer the
questionnaire (who tested, how you recruited, feedback, changes) →
Google reviews the application (allow several days) → production
publishing unlocks (B7/Step 16 becomes possible).

**Timeline math:** opt-ins complete on day X → apply on day X+14 →
plus Google's review of the application → plus the normal app review
after submission. Budget ~3 weeks of calendar time from "testers
invited" to "can go live", which is why Step 2c remains a later release gate
after the re-entry preflight and the Play setup requirements.

### Keystore rotation — commands are in the callout above; afterwards
re-run `./scripts/build_appbundle.sh` (B6) and confirm the AAB signature
with `jarsigner -verify` or `apksigner`.

### C2-C4 — Default English listing copy
- Use `docs/release-prep/play-store-listing.md` as the reviewable master
  before pasting into Console. DE/ES/IT/FR listings are optional after launch;
  the app ARB files are the vocabulary reference if they are added.
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
| All 34 fiat currencies + 11 crypto | `supported_currencies.dart`, multi-provider repo |
| Client-side conversion (`amount × rate`) | Convert controller |
| Historical charts (fiat 2Y, crypto 1Y) | Charts controller + fawazahmed0 date-file client |
| Favorites (max 3, local storage) | FavoritesStore wired |
| Offline mode / cache persistence | Cache per base/range; stale fallback works |
| Dark mode (system-follow + toggle) | AppTheme + Settings |
| Real AdMob SDK (`google_mobile_ads`) | BannerAd + RewardedAd integrated; test-mode only until real IDs |
| IAP purchase UI + entitlement system (⚠️ payment itself is STUBBED — real billing is open step B9, added 2026-07-16) | PurchaseServiceStub, IapPurchasePlayer |
| i18n (EN, DE, ES, IT, FR) | ARB files + generated localizations |
| Branded app name ("Currency Converter") | Committed `bade57e` |
| iOS deployment target 15.0 | Committed `bade57e` |
| Release APK + App Bundle builds | `scripts/build_apk.sh`, `scripts/build_appbundle.sh`; AAB smoke revalidated 2026-08-28, final build remains gated on release-code changes |
| Firebase hosting deploy pipeline | `scripts/firebase_hosting_*.sh` |
| Latest direct verification | 239 tests, clean analysis, and a signed AAB smoke build on 2026-08-28; full `./scripts/check.sh` and final AAB still follow B4/B5/B8/B9 |

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

## Execution Order (cross-repo master order — 2026-08-28)

This is the order to follow. The site repo contains implementation detail for
its own steps, but it does not redefine this sequence.

### Phase 0 — Re-entry and toolchain preflight

0a. Complete the Phase 0 checklist above. Do not make a global Flutter or
dependency upgrade part of the release by default.

0b. Resolve and re-run the Android release-build smoke test. A successful
`flutter analyze`/`flutter test` run is not sufficient to mark B6 complete.

### Phase 1 — Foundations (site and accounts can run in parallel)

1. **Prepare the approved Hostinger static migration before the domain.** Keep
   Vercel as rollback, create the safety tag/branch, then pass the VPS
   security and isolated staging gates. See
   `../../niduna-site/docs/hostinger-static-migration.md` and
   `../../niduna-site/RELEASE_PLAN.md` S1.0.
2. Buy/register `niduna.com` separately through Hostinger, attach it to the
   verified Hostinger host, make apex canonical and redirect `www`, then verify
   Home, Privacy and Currency Converter in an anonymous browser. [site S1.1-S1.3]
3. Create `support@niduna.com`, publish MX/SPF/DKIM, and prove mail works in
   both directions. [site S1.4]
4. In parallel, create the **personal** Play account, complete identity,
   contact and real-Android-device verification, create/verify the merchant
   payments profile, and create the app draft. [E1-E4]
5. Create the AdMob app, Android banner/rewarded units and European regulations
   message. Finalize the three immutable one-time-product IDs and prices;
   create them now if Console permits. [E5, E5b, E8]

### Phase 2 — Build a policy-safe release candidate

6. Publish `app-ads.txt` with the exact AdMob snippet and keep `niduna.com` as
   the developer website in Play. [E5c / site S1.5]
7. Implement real Android AdMob IDs, UMP consent + required privacy-options
   entry point, in-app privacy URL, real Play Billing and Restore purchases
   using E8's finalized IDs. [B4, B5, B8, B9]
8. Rotate the temporary upload-key password, delete the temporary password
   file, and store encrypted on-machine/off-machine backups.
9. Run `./scripts/check.sh`; verify release-safe providers, no dev UI, real
   billing failure/cancel/restore paths and non-personalised ad requests. Build
   the signed AAB with a fresh `+N` versionCode. [B6]
10. Upload to **internal testing** for a small smoke pass before the reviewable
    closed track. If E8 was unavailable earlier, create/activate the products
    after this billing-enabled upload. Verify product lookup, successful and
    cancelled purchases, acknowledgement, relaunch persistence and Restore.
    Internal testing does not count toward the 12/14-day production gate.

### Phase 3 — Finish Play setup, then start the fixed clock

11. Finalize the default English listing from
    `docs/release-prep/play-store-listing.md`, upload the ready screenshots and
    feature graphic, and use Android application ID
    `com.niduna.currency_converter` everywhere. [C2-C6, C9-C10]
12. Complete all App content declarations shown in Console: ads, content
    rating, 13+ target audience, Data Safety based on the **final** AdMob/UMP
    build, financial-features declaration, and trader/public-contact task.
    [C7, C7b, C8, E6]
13. Create the closed track, select every tester's country, upload the release
    candidate only after all three products are active, and recruit 15-16
    people so at least 12 remain opted in for 14 continuous days. [E7]
14. During the window, monitor the count, gather real feedback, test purchases
    and restore with license testers, review crashes/pre-launch findings, and
    upload fixes to the same track with higher versionCodes.

### Phase 4 — Production and public-site switch

15. When the gate is satisfied, apply for production access and answer the
    testing questionnaire with real recruitment/feedback/change details.
16. After access is granted, upload/promote the final verified build, review
    the pre-launch report and submit for production review.
17. Wait until the production Play listing is publicly reachable. Then execute
    the site's S2 batch: correct Play URL, Available badge, release metadata,
    trust line, deploy and click-test.
18. Add DE/ES/IT/FR store listings later if wanted; they are not a launch gate.

The fixed critical path is therefore:

`Hostinger security/staging + domain/email + accounts → release candidate + Console
setup → closed test (12/14 days) → production-access review → app review →
public listing → site launch batch`.

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
| Device ID / advertising ID | **BY US: NO — but YES via the AdMob SDK once real ads are live (B4)** | No analytics SDK of our own; the Data Safety form counts SDK collection, so declare AdMob (see C8 note + § Third-party SDKs below). Corrected 2026-07-16 — do NOT answer "no" from this row. |
| Financial info | **NO** | Display-only; no transactions, no wallet |
| Health / fitness | **NO** | N/A |

### Data this app transmits

| Type | To whom | When |
|------|---------|------|
| IP address | Frankfurter, jsdelivr, Cloudflare CDNs | On each rate fetch (HTTPS, unavoidable) |
| Ad request signals (IP, advertising ID, device info) | Google (AdMob) | When ads load for free users (once B4 real IDs are live; per the B8 consent/NPA setup) — none after Remove Ads |
| (nothing else by us) | — | No API keys, no user IDs, no custom headers |

### Local storage

| Data | Where | Purpose |
|------|-------|---------|
| Favorite pairs | SharedPreferences | User's saved currency pairs (max 3) |
| App settings | SharedPreferences | Base currency, decimals, theme, refresh preference |
| Rate cache | SharedPreferences | Last known fiat + crypto rates (offline use) |
| Chart cache | SharedPreferences | Historical data for displayed pairs |
| IAP state | Platform purchase receipt store + local entitlement cache | Remove Ads / Charts Pro / Favorites Pro ownership after B9 |
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
| First-party analytics | None per AGENTS.md | AdMob SDK collection/sharing is disclosed separately |
| Promo video | Nice-to-have | Increases conversion |
| Tablet screenshots | Optional | Phone-first MVP |
| Long-press context menu on rows | Low priority | Swipe already covers Pin/Swap |
| App Store (iOS) submission | Deferred | $99/year fee; Android first |

---

## Change Log (this file)

- **2026-08-28 (release re-entry audit)** — Added Phase 0 for resuming the
  release after a pause. Flutter 3.41.7/Dart 3.11.5, the Android/iOS
  toolchain, dependency resolution, `flutter analyze`, and 239 tests were
  re-verified. No global SDK or dependency upgrade is required. The first
  `--no-pub` AAB attempt exposed a stale development plugin registrant; the
  normal release command regenerated the release-filtered registrant and
  produced a signed 51 MB diagnostic AAB. B6 is technically revalidated, but
  the final AAB remains gated on B4/B5/B8/B9, key rotation, and a new
  versionCode.
- **2026-07-16 (teaser removal implemented)** — The "Coming Soon"
  open decision is resolved and DONE: removed the Settings
  Subscription tile (+ its 3 l10n keys from all 5 ARBs), the locked
  1H/6H/1D chart range chips with their premium snackbar, and the
  Convert info-sheet "faster updates" subscription line. No platform
  gating — removed everywhere. Entitlement plumbing
  (`canUseIntradayRanges`, `ProductType.subscription`, dev panel)
  kept as the Phase 2 seam. Verified: 239 tests pass, emulator
  screenshots light+dark (Settings premium section, charts range
  row, info sheet) all clean.
- **2026-07-16 (third-pass consistency review)** — Swept both plans for
  statements contradicting the corrected closed-test gate and for stale
  premises. Fixed: (1) E7 blocker row still said the closed track "can
  run in parallel with the listing work" — listing/forms now correctly
  precede it; (2) Execution Order intro gained the corrected critical
  path; (3) "Rule of thumb" still cited the stale SSO-gate premise —
  the real blocker is that `niduna.com` isn't bought; (4) **Data Safety
  trap:** the "What To Disclose" tables still said advertising ID "NO /
  no tracking SDK", contradicting the C8 AdMob declaration — corrected
  so nobody answers the form wrong from this file; AdMob added to the
  transmits table. Site plan: master-order pointer made layout-neutral
  (old `apps/...` path), dependency summary gained the E7 forms-gate
  line.
- **2026-07-16 (second-pass review)** — Re-verified the full order
  against how Play Console actually gates a first-time publisher.
  Corrections: (1) **the closed test cannot start "early"** — the
  Console blocks publishing a closed track until the "Set up your app"
  dashboard tasks are complete (App content declarations AND the store
  listing); only internal testing skips the forms, but internal does
  not count toward the E7 12-tester/14-day gate. Header list
  renumbered (listing/content forms now item 3, before the closed
  test); Step 2c gained the GATE note; Phase 3 reframed as a final
  review pass. (2) **E3 corrected** — payments/merchant profile
  (Setup → Payments profile), launch-critical for E8/B9, not "later";
  the old "Setup > License" path was wrong. (3) **versionCode rule
  added to B6** — every Play upload needs a bumped `+N` build number
  in pubspec, closed-track updates included. (4) **E7 playbook** —
  the track's country availability must include every tester's
  country, or they cannot opt in.
- **2026-07-16 (payments review)** — Goal confirmed: launch on Google
  Play with **working payments + ads**. Review found the plan had NO
  step to replace the Phase-1 IAP stub: the app ships a fake purchase
  flow ("Processing payment…" always succeeds —
  `purchase_service_stub.dart`; no billing package in `pubspec.yaml`),
  a Play payments-policy rejection risk that also gives every
  entitlement away free. Added **E8** (create the 3 in-app products in
  Play Console) and **B9** (real Play Billing implementation, full
  clues in Implementation Notes § B9), inserted as Steps 3c / 8b; B6's
  final AAB now also waits on B9. Email provider decided: **Zoho Mail**
  (site plan S1.4 updated). New open decision recorded in the header:
  remove/hide the "Coming Soon" subscription teasers (Settings tile +
  Charts intraday snackbar) before the final AAB.
- **2026-07-11 (publishing-identity review)** — Adopted the
  "Pegolandia model": publish as an individual, no company; brand
  stays website/app-facing, legal identity lives in store
  verification (guardrails from the strategy docs recorded above the
  External Steps table). Two NEW external gates found missing: **E6**
  EU DSA trader declaration (monetized app ⇒ verified contact details
  publicly shown on EU listings, mandatory for EU distribution) and
  **E7** the 12-tester/14-day closed-testing requirement for personal
  accounts created after Nov 2023 — E7 is timeline-critical, so the
  historical execution order placed closed-track preparation early while
  still gating submission (Step 15b). The current order keeps the closed
  track after the new re-entry Phase 0 and all Play setup gates. Site-side
  GDPR work landed the
  same day (fonts self-hosted, privacy page website + controller
  sections — `niduna-site/RELEASE_PLAN.md` § S0).
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
