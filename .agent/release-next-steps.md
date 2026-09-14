# Honest Fern release — next execution plan

> Revised 2026-09-14 after the approved default-selection and picker refinements.
> This is a bounded execution plan; `RELEASE_CHECKLIST.md` remains the master
> checklist.

## Current gates

- Internal testing now has signed `1.0.0+6` (`versionCode 6`) from commit
  `aad8249`. It includes the earlier provider/POL and late-consent repairs,
  plus approved fresh-install currency defaults and consistent grouped pickers.
- Its AAB SHA-256 is
  `9f6c0464046b636fe0a3f66b74afa58217696e269477366a0f35addf51f5ed96`.
  Android Publisher committed and independently verified the Internal track on
  2026-09-14. It still requires acceptance from the exact Play-distributed
  installation. Do not promote `1.0.0+6` to Closed before that acceptance.
- The provider implementation and verification record remains
  `.agent/provider-coverage-remediation-plan-2026-09-12.md`; code 5 is
  superseded and is not the candidate to test or promote.
- The default Play listing locale is `en-GB`. The new icon and six phone
  screenshots are saved in the listing draft and are waiting in Publishing
  overview for the required review flow.
- AdMob app and units exist:
  - App ID: `ca-app-pub-1525645598421616~2391849252`
  - Publisher ID: `pub-1525645598421616`
  - Banner: `ca-app-pub-1525645598421616/6412809148`
  - Rewarded: `ca-app-pub-1525645598421616/7452604243`
- AdMob message **Honest Fern Europe Consent** is published for the app,
  with the privacy URL and Consent, Manage options and Do not consent enabled.
- AdMob now shows the payment profile as complete. The account is still being
  verified; AdMob says this usually takes 24 hours and can rarely take up to
  two weeks. Keep test ads during development until approval is visible.

## Execution order

### 0. Closed-test and first-public-release sequence — current plan

1. **Complete locally (2026-09-13):** implement and independently review the
   provider-coverage remediation without unrelated backend, billing or ad work.
2. **Complete locally:** verify all 34 fiat currencies and POL against the
   release-safe providers; run deterministic tests, representative small/large
   device QA, clean-install QA and a seeded `1.0.0+4` persistence migration.
   Exact Play-distributed upgrade acceptance remains pending.
3. **Complete (2026-09-14):** commit the reviewed refinements, build and upload
   `1.0.0+6` to Internal testing only. Install and accept that exact
   Play-distributed artifact next.
4. Complete the remaining Play Console setup and saved listing/declaration
   review flow required before Closed testing.
5. Promote the accepted fixed artifact to Closed testing, create/select the
   tester list, share the opt-in link and recruit 14–16 testers.
6. Keep at least 12 testers opted in continuously for 14 days. Internal
   testing does not count toward this requirement. If a real fix is needed,
   upload the next unused higher code while keeping the tested release on the
   same Closed track.
7. Apply for production access after the requirement is met and answer the
   testing/product-readiness questions. After approval, promote the latest
   tested `1.0.0` artifact to Production; do not rebuild it just to change its
   version name.

The B4/B8/B9 notes below remain quality and release-risk references. They are
not authorization to expand the current UI branch or to submit a public release.

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

**2026-09-10 result:** `AdConsentManager` owns the UMP gate; AppShell starts
it without blocking first paint, banners/rewarded ads await the gate, and
Settings exposes Privacy options when required. **2026-09-12 follow-up:** the
short platform timeouts could permanently leave the gate closed on a fresh
install; `1.0.0+4` waits for the real UMP result and reloads banners after a
late consent update. The local APK produced test-ad requests after UMP
resolved. Real Android IDs remain available through the environment-based
release build path; keep test ads for this internal diagnostic build.

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

**2026-09-10 result:** `./scripts/check.sh` passes with the production AdMob
IDs (clean analyze, 247 tests). `ADMOB_USE_TEST_ADS=false
./scripts/build_appbundle.sh` produced a signed
`build/app/outputs/bundle/release/app-release.aab` (54.1 MB, still `0.1.0+2`;
not uploaded). The AAB SHA-256 is
`ccd2ad0d11cf7422f251471855e8f83140ea18237b487b2bcc05cc41bf4846af`.
The remaining verification is on Android: live production ads and final
billing edge cases. UMP and the basic UI smoke pass on
`emulator-5554`; the Settings Privacy options row is partially covered by the
bottom navigation at 720×1280 and remains a non-blocking UI follow-up.

### 5. Luis-only console acceptance

- AdMob account verification is complete; the console reports the account
  approved and ad serving enabled. The app still needs to be linked to its
  public Play store entry once that listing is available.
- Confirm the email list is assigned to the Internal testing track and use its
  opt-in link. An email list alone does not opt an account into a track.
- Separately confirm your Google account is in Play Console's **License
  testing** list. Track testers control download access; license testers make
  Play Billing purchases test purchases without real charges.
- Install the internal build and test the three one-time products, restore,
  cancel, pending, relaunch and reinstall. Use test payment methods only.
- Confirm code `3` is unused before the final version bump.
- Review final Play listing, Data Safety, ads declaration, financial-features
  declaration, IARC, trader/contact fields and closed-test testers.

**2026-09-10 result:** The internal-test email list is assigned to the
`Internal testing` track (1 user). The account accepted the opt-in invitation
through the generated join link and now appears as a tester. The same email
list is also selected under Play Console `Settings → Licence testing`, and
Play Console confirmed “Your changes have been saved”. The account is therefore
configured for both internal-build access and Play Billing licence testing.
The remaining console/device step is to install the Play-distributed internal
build and exercise each one-time purchase plus Restore; the locally installed
APK is not sufficient evidence for Play Billing.

**2026-09-10 device result:** The Play-distributed internal build was
installed on the Android work phone. With the configured licence-test account,
all three one-time products were purchased successfully and their benefits
were verified in the app: Remove Ads removed the ad surfaces, Charts Pro
unlocked the additional charts, and Favorites Pro unlocked the favorites
capability. The app was relaunched and Restore purchases completed without an
error while the benefits remained available. Reinstall-after-restore remains
the final Billing persistence check.

**2026-09-10 Play Console result:** The app's Privacy policy task was saved in
Play Console with `https://honestfern.com/currency-converter/privacy/`. Play
Console reported that the change is stored in Publishing overview and is ready
for a later review submission; no release was submitted. The remaining app
content tasks are Ads, Content rating, Target audience, Data safety, Financial
features, category/contact details, and the Store Listing.

## Stop conditions

Stop before any version bump, signed RC upload, closed-test submission, site
deploy, keystore operation or production publication. These require a separate
explicit approval after the concrete artifact and verification results are
ready. Provider/catalog implementation is locally authorized only when Luis
explicitly starts that implementation task; this document itself is not upload
authorization.
