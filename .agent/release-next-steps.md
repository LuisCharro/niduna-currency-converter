# Honest Fern release — next execution plan

> Created 2026-09-10 after the AdMob console setup. This is a bounded
> execution plan, not approval to upload, publish, deploy, buy, or change the
> release version. `RELEASE_CHECKLIST.md` remains the master checklist.

## Current gates

- Play draft exists; diagnostic internal AAB is `0.1.0+2`.
- First public candidate remains `1.0.0+3`; do not bump yet.
- AdMob app and units exist:
  - App ID: `ca-app-pub-1525645598421616~2391849252`
  - Publisher ID: `pub-1525645598421616`
  - Banner: `ca-app-pub-1525645598421616/6412809148`
  - Rewarded: `ca-app-pub-1525645598421616/7452604243`
- AdMob message **Honest Fern Europe Consent** is published for the app,
  with the privacy URL and Consent, Manage options and Do not consent enabled.
- AdMob still shows Payment setup incomplete; wait for account verification for
  app review and live serving. Keep test ads during development.

## Execution order

### 1. B4+B8 app integration — implemented; device/account acceptance remains

- Add the production IDs through the repository's existing configuration path;
  keep test IDs as the safe development default until release configuration.
- Request UMP consent information on every launch.
- Load and show the consent form when required.
- Gate every ad request on `canRequestAds()`.
- Keep banner and opt-in rewarded only; do not add interstitials or app-open ads.
- Add a Settings entry point for UMP Privacy Options when required.
- Preserve offline, no-consent, no-fill, early-close and Remove Ads states.
- Add focused tests for consent gating and configuration selection.

**2026-09-10 result:** `AdConsentManager` now owns the UMP gate; AppShell
starts it without blocking first paint, banners/rewarded ads await the gate,
and Settings exposes Privacy options when required. Real Android IDs are
available through the existing environment-based release build path. Keep
`ADMOB_USE_TEST_ADS=true` until the account verification/payment warning is
resolved; the production build command must set it to `false` and provide the
three Android IDs.

### 2. B9 Billing hardening — Codex can implement

- Catch product-query, purchase and restore failures.
- Await and handle `completePurchase`.
- Surface pending, cancelled and failed states without leaving the UI stuck.
- Prevent duplicate concurrent requests for one product.
- Show Play `ProductDetails` localized prices instead of fixed CHF copy.
- Give restore a visible success/empty/failure result.
- Add meaningful mocked stream/error tests; do not replace the real service with
  the old production stub.

### 3. Site and policy preparation — Codex can prepare; Luis approves deploy

- Add `app-ads.txt` using the recorded publisher ID:
  `google.com, pub-1525645598421616, DIRECT, f08c47fec0942fa0`.
- Align the app privacy page with final UMP, AdMob and Billing behavior.
- Keep OXR/VPS, CoinGecko, accounts and first-party analytics out of this release.
- Do not deploy the site without Luis's explicit approval.

### 4. Verification — Codex can run locally

- Run `./scripts/check.sh` and record analyze/test results.
- Build a verification APK/AAB without changing the public version.
- Inspect manifest, permissions, signing configuration and R8 output.
- Run device/emulator checks for Convert, Favorites, Charts and Settings in
  light/dark, small-screen, enlarged-text, offline and stale states.
- Verify UMP, banner, rewarded, Remove Ads, restore and deep links.

**2026-09-10 result:** `./scripts/check.sh` passes (clean analyze, 247 tests).
`ADMOB_USE_TEST_ADS=true ./scripts/build_appbundle.sh` also produced and
verified a signed `build/app/outputs/bundle/release/app-release.aab` (54.1 MB,
still `0.1.0+2`; not uploaded). The remaining verification is on Android:
consent form/Privacy options, live test ads, and billing purchase/restore.

### 5. Luis-only console acceptance

- Wait for AdMob account verification and confirm the red payment banner clears
  or shows a clear remaining action.
- Add license testers/internal testers in Play Console.
- Install the internal build and test the three one-time products, restore,
  cancel, pending, relaunch and reinstall. Use test payment methods only.
- Confirm code `3` is unused before the final version bump.
- Review final Play listing, Data Safety, ads declaration, financial-features
  declaration, IARC, trader/contact fields and closed-test testers.

## Stop conditions

Stop before any version bump, signed RC upload, closed-test submission, site
deploy, keystore operation or production publication. These require a separate
explicit approval after the concrete artifact and verification results are
ready.
