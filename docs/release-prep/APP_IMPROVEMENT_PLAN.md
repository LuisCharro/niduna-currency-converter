# Currency Converter — App improvement plan

**Status:** pre-release review
**Last reviewed:** 2026-08-30
**Product:** Honest Fern Currency Converter
**Canonical release order:** [`../../RELEASE_CHECKLIST.md`](../../RELEASE_CHECKLIST.md)

This document tracks improvements to the app itself. It complements the
cross-repository release checklist; it does not replace the Play Console,
AdMob, website, email, or closed-testing steps documented there.

## Current baseline

- Flutter 3.41.7 / Dart 3.11.5.
- `flutter analyze` passes.
- 241 Flutter tests pass.
- A sequential release AAB build completes and is signed with the current
  Honest Fern Android application ID.
- The current AAB is still diagnostic and must not be uploaded: it uses test
  AdMob configuration and the fake purchase implementation.
- The 2026-08-30 correction and quality batches are committed on `main`.

## P0 — Must fix before any reviewable Play track

### P0.1 Replace fake purchases with real Play Billing

Replace `PurchaseServiceStub` with a real `in_app_purchase` implementation.
The service must handle product lookup, pending/success/error/cancelled
states, acknowledgement/completion, relaunch persistence, and Restore.

Products planned for the first release:

- `remove_ads_lifetime`
- `charts_pro_lifetime`
- `favorites_pro_lifetime`

Products and prices must be finalized in Play Console before purchase testing.
Do not grant entitlements merely because a purchase button was pressed.

**Acceptance:** license-test purchases, cancellations, failures, relaunch,
and Restore behave correctly in internal testing; no stub is reachable from a
release build.

### P0.2 Remove the release Dev Sandbox path

The hidden developer-mode interaction can currently expose entitlement toggles
in the app. Keep developer tools available for local development, but compile
or gate the sandbox so it cannot be activated in a reviewable release build.

**Acceptance:** a release build has no Dev Sandbox UI and cannot grant
products locally.

**2026-08-30 status:** implemented and committed in `af12283` by making
developer tools available only in debug mode; the release AAB was rebuilt
successfully.

### P0.3 Finish AdMob consent and production configuration

Implement UMP consent handling before Mobile Ads requests:

- request consent information on launch;
- show the form when required;
- gate ad requests on `canRequestAds`;
- expose privacy options when Google requires them;
- keep normal surfaces banner-only and rewarded ads explicitly opt-in.

Create the AdMob app and Android banner/rewarded units first. Real IDs can be
prepared while Play identity review is pending, but they belong in the final
release only after the account, app setup, consent message, and app-ads.txt
plan are ready. Keep test IDs for development and automated tests.

**Acceptance:** EEA/UK/CH consent behavior is testable, non-personalised ad
requests remain documented, and the final release contains no Google test IDs.

### P0.4 Complete the privacy surface

Add the public app privacy-policy URL inside Settings and reconcile the
in-app wording with the website, especially:

- outbound rate-provider requests;
- Google Mobile Ads processing;
- what “Clear all data” actually removes;
- local-only preferences versus cached data and temporary unlocks.

**Acceptance:** the app link opens the live app-specific policy, and the
privacy policy, in-app copy, AdMob consent flow, and Play Data Safety answers
describe the same behavior.

**2026-08-30 status:** the Settings link and `url_launcher` dependency are
implemented and committed in `7aed7b1`. Full wording/Data Safety alignment
remains coupled to the future AdMob/UMP pass.

### P0.5 Make release signing fail closed

The release configuration must not fall back to debug signing when
`android/key.properties` is absent. Preserve convenient local debug workflows,
but make the release build fail if the release keystore is missing or invalid.

Before the first upload, rotate the temporary keystore password and keep the
key material outside Git with restricted local permissions.

**Acceptance:** a release build cannot silently produce a debug-signed AAB;
the final AAB signature is verified and its version code is new.

**2026-08-30 status:** release signing now fails closed when the required
keystore configuration or file is missing; the current configured keystore
produced a verified diagnostic AAB.

## P1 — Fix before production submission when practical

### P1.1 Make cached chart freshness truthful

Historical cache results should preserve their saved timestamp/status rather
than being labelled as updated at the moment they are displayed. Show a clear
cached/stale/offline state when appropriate.

**2026-08-30 status:** controller now uses the cached snapshot's `savedAt`
timestamp instead of `DateTime.now()`.

### P1.2 Resolve crypto base-currency behavior

The latest-rates repository currently rejects crypto bases, so base selection
must not expose crypto currencies until a full crypto-base path exists.

**2026-08-30 status:** base selection now exposes fiat currencies only; crypto
remains available as a quote/visible currency.

### P1.3 Complete localization consistency

Move remaining user-facing hardcoded English messages into localization keys
and translate the newer Favorites Pro copy. Review number formatting so Convert
and Favorites follow the same locale policy.

**2026-08-30 status:** chart errors, chart empty state, currency-picker empty
state, share failures, and owned-product labels now use localized copy. The
remaining hardcoded strings are either developer-only/internal or belong to
the deferred monetization/ad surfaces; this item remains partial until the
final billing/AdMob copy pass.

### P1.4 Repair accessibility actions and large-text layouts

Ensure the semantics action advertised for each currency row performs the
same action a screen-reader user expects. Add activation tests, not only
semantics-presence tests. Recheck 320/375/414 dp widths and large text scales,
especially the quote value and rate line.

**2026-08-30 status:** currency rows in the production list now expose a real
screen-reader action that opens the conversion lens; section headers expose
their expand/collapse action; quote values and rate lines are constrained for
narrow layouts. Focused accessibility and narrow-layout tests pass. Physical
Android-device TalkBack and large-text review remain pending.

### P1.5 Improve error boundaries

Charts and provider failures should become intentional user-facing states,
not uncaught repository exceptions. Add tests for direct repository failures,
partial provider failure, and retry behavior.

**2026-08-30 status:** chart-controller repository exceptions are now caught
and converted into a generic localized error state, with a regression test for
an unexpected repository failure. Provider-level partial-failure behavior is
covered by the existing crypto tests; final device retry/offline QA remains.

## P2 — Hardening and polish

- Pin or otherwise control the mutable crypto CDN `@latest` dependency, with a
  documented update process and payload validation. **2026-08-30:** payload
  dates are validated and future-dated responses are rejected; the endpoint
  is still intentionally `@latest` and needs a later pin/update decision.
- Review whether the home-screen widget should appear on the lock screen and
  whether entered amounts should be exposed there. **2026-08-30:** the widget
  is no longer declared for the Android keyguard/lock screen.
- Add a final merged-manifest/Data Safety audit to the release procedure,
  including the AdMob-added `AD_ID` permission.
- Review local permissions for `.env.local`, `android/key.properties`, and the
  upload keystore; use owner-only permissions where appropriate. **2026-08-30:**
  all three files are owner-only (`0600`) in the local checkout.
- Add a real Android-device manual QA pass for ads, consent, purchases,
  Restore, rate refresh, offline cache, widgets, and privacy links.

## AdMob and Play Console dependency notes

AdMob setup is a separate track from Play developer identity verification.
While Play Console reviews Luis's identity documents, AdMob can be prepared
using an unpublished app. The AdMob account still needs correct payment and
identity information, and Google may review it before serving ads.

Choose the AdMob account type and country carefully. Use `Individual` unless
Honest Fern is a legally registered organization whose payment/tax documents
match the organization details. The account type is not an informal brand
choice.

Useful official references:

- [AdMob getting started](https://support.google.com/admob/answer/15948559)
- [AdMob account sign-up](https://support.google.com/admob/answer/7356219)
- [App IDs and ad-unit IDs](https://support.google.com/admob/answer/7356431)
- [AdMob app-ads.txt setup](https://support.google.com/admob/answer/9363762)

## Recommended execution order

1. Finalize the three Play one-time product IDs and prices.
2. Implement real Billing and Restore.
3. Review the local privacy link and wording; keep the app-specific policy
   aligned with the website.
4. Rotate the upload-key password and keep the key material outside Git.
5. Resume the postponed AdMob track: create/configure the app and units,
   implement UMP, use real IDs, and publish `app-ads.txt`.
6. Complete the remaining P1 correctness/accessibility/localization fixes.
7. Run `./scripts/check.sh`, build a fresh signed AAB with a higher version
   code, and inspect the merged release artifact.
8. Upload to internal testing, test real billing with license testers, then
   begin the 12-testers/14-continuous-days closed-test gate.

## Review evidence

The 2026-08-30 review used three independent read-only reviews plus local
verification. The first concurrent AAB attempt exposed a stale generated
plugin registrant; after dependency resolution completed, the same release
build ran sequentially and produced a signed 53.4 MB AAB. The correction
batch then passed `./scripts/check.sh` and another sequential AAB build. This
is why the release procedure must run dependency resolution and the final build
sequentially and must re-check the generated registrant.

The follow-up quality batch also passed `./scripts/check.sh` with 241 tests and
produced a fresh 53.4 MB signed diagnostic AAB. No source changes are implied
by this document alone. Each implementation
batch must update this plan, the canonical release checklist, focused tests,
and the final release evidence together.
