# Honest Fern release — next execution plan

> Revised 2026-09-30 after Closed Alpha became available and Licence testing was checked.
> This is a bounded execution plan; `RELEASE_CHECKLIST.md` remains the master
> checklist.

## Current gates

`RELEASE_CHECKLIST.md` and the publishing runbook hold the dated evidence,
artifact identity, links and private-list counts. As of 2026-09-30, Internal
and Closed Alpha serve code 7. Closed is Active / Available to selected testers,
with Spain/Switzerland and `Testers for Closed Test` (20) selected; the 2-email
list is unselected there. Review/setup changes have published. Do not restart
preparation or treat historical entries below as current blockers.

Only `Billing test - work account` (1) is selected in Licence testing; lists
20/2 are unselected. Device checkout still showed real Visa after saving:
no successful no-charge Billing test on that account has been verified.

## Execution order

### 0. Current next steps through the public launch

1. **Pending device verification:** confirm the licence-test account in the
   purchase dialog and test notice/test card before confirming. Troubleshoot
   account, cache and propagation per the runbook. Test all three IAPs,
   relaunch/Restore and record evidence; do not pay accidentally.
2. **Luis plans 2026-10-01:** email the Closed web opt-in link from the runbook
   to the authorized cohort. Existing Internal participants leave Internal
   first. New testers go straight to Closed, accept and install/update.
3. Verify actual Dashboard opt-in count/date; list membership or a working
   work-phone install is not evidence of the full cohort's eligibility.
4. Keep at least 12 genuine testers continuously opted in for 14 days, collect
   usage/feedback and review crashes/pre-launch results. Late joiners can join;
   their own continuous eligibility starts at opt-in. Use the same Closed track
   and higher unused version codes for separately approved tested fixes.
5. Once eligible, apply for production access with accurate answers. Approval
   is not automatic; additional testing may be requested.
6. After access approval, complete final production ads/UMP/Billing and artifact
   acceptance, then submit Production with explicit release approval. Reuse a
   tested artifact only if its production configuration passes; a binary change
   requires a higher unused code.
7. After approved Production is publicly reachable, execute the site's S2 batch
   with deployment approval; Closed visibility does not trigger Coming Soon removal.

Historical B4/B8/B9 sections below are quality references, not evidence that
all current-account/production gates have passed or authorization to publish.

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

### 5. Historical Console acceptance — 2026-09-10

The list selections, code 3 reminder and pending setup tasks below belong to
that old checkpoint. Use section 0 and the current runbook for today’s action.

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

Stop before any new version bump, signed RC upload, further track submission, site
deploy, keystore operation or production publication. These require a separate
explicit approval after the concrete artifact and verification results are
ready. Provider/catalog implementation is locally authorized only when Luis
explicitly starts that implementation task; this document itself is not upload
authorization.
