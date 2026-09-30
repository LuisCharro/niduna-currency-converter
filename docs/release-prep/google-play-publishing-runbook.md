# Google Play publishing runbook

> App-specific operational guide for Honest Fern Currency Converter. Keep
> secrets and machine-specific paths in `AGENTS.local.md`, never in this file.

For the reusable portfolio-wide model, read
[`google-play-developer-api.md`](../../../../docs/platforms/google-play-developer-api.md)
when this repository is checked out inside the Honest Fern monorepo. This
document owns only Currency Converter facts and commands.

**Last verified:** 2026-09-30

**Package:** `com.honestfern.currency_converter`

**Play app ID:** `4973875544480645622`

**Developer account ID:** `6219086036817053258`
**Default listing locale:** `en-GB`

## Current release state — 2026-09-30

Closed Alpha and Internal serve `1.0.0 (7)`, built from `c21561d` with version
bump `71f1d1a`. AAB SHA-256:
`1d8de98cecad06b16d5a5109eef6c4d7c365e5129043b8c35edbb627f448b1bf`.
Notes: “Refreshed Favorites and refined the app interface.” (`en-GB`).
Closed reused the accepted Internal artifact from Play's library. All 13
changes were submitted with approval and published; Alpha shows Active and
“Available to selected testers”, released 30 September 19:31. Managed
publishing is off. There is no recorded Production release.

Six refreshed `1350x2400` screenshots were included in the published listing
changes. The Store presence API validation returned HTTP 403, so the owner
Console selected/saved the assets; do not broaden API access.

Actual Console track IDs: Internal `4701596695392061996`; Closed Alpha
`4700576461420899940`. Before using the API, list tracks and verify its returned
track identifier; do not blindly assign the literal `closed` (it previously
returned 404). Record API identity separately if it differs from the Console ID.

## Tester invitations and monitoring — current next step

- Console → Test and release → Testing → Closed testing → Alpha → Testers.
- Selected: `Testers for Closed Test` (20); unselected: `Internal test email list`
  (2). These are private email lists with user-defined names. Selection is
  independent in Internal, Closed and Licence testing; multiple selected lists
  form a union, not additional counts for duplicates.
- Countries: Spain and Switzerland. Eligibility depends on Play account country.
- **Send:** https://play.google.com/apps/testing/com.honestfern.currency_converter
  This app-specific web opt-in link also works from an Android browser.
- **Install page / Join on Android:**
  https://play.google.com/store/apps/details?id=com.honestfern.currency_converter
- **Internal acceptance/exit:**
  https://play.google.com/apps/internaltest/4701596695392061996
  It stays stable across Internal builds and is not the Closed invitation.
- Luis plans emailing the cohort on 2026-10-01; invitations are not yet recorded
  as sent. Play does not email invitations when a list is populated.

Each person opens the Closed web URL with their authorized Google account,
accepts testing, then follows the Play installation link. Internal is optional;
existing Internal participants leave Internal before accepting Closed.
Luis reports a working Closed install on the work phone. Do not infer the
cohort count or 14-day eligibility from one install or the 20-email list.
Read Dashboard actual opt-ins/date and record them before claiming eligibility.
Maintain at least 12 genuine testers continuously opted in for 14 days and
collect real use/feedback. New testers can join during the test; they need their
own continuous period and do not reset earlier testers' history.

## Licence testing is separate from Closed testing

Account Console → Settings → Monetisation → Licence testing. As verified
2026-09-30, only `Billing test - work account` (1 account) is selected and
saved; the 2- and 20-email lists are unselected. Response remains
`RESPOND_NORMALLY`; no need to change legacy licence responses for Billing QA.
Private tester email/account details live in ignored `AGENTS.local.md`.

Testing tracks alone do not prevent real charges, even Internal. Licence
testers receive test payment instruments for this developer account's apps;
apps from other developers retain normal purchases. It is reversible and does
not grant Console access. Test ads are independent of Billing test mode.

**Open device issue:** after saving Licence testing, Luis still saw the real
Visa checkout. A test-card purchase is not yet verified. Before confirming:

1. Expand the purchase dialog and verify the account that downloaded the app
   is the licence-test account (multiple-account devices can use another one).
2. Require the explicit test-purchase notice and a test payment instrument,
   such as “Test card, always approves”. A displayed price alone is not proof.
3. If still showing a real method without the test notice, cancel, close the
   app/Play Store, clear Play Store cache, allow propagation and retry. No
   guaranteed propagation time is established here; don't repeat real purchases.
4. If unresolved, inspect saved list membership/account and record the blocker;
   do not rebuild or leave Closed merely to fix Billing-account recognition.
5. Once test mode is visible, verify all three one-time products, purchase
   acknowledgement, relaunch and Restore; record exact build/account evidence.

Do not tell invited friends to buy for free: their 20-email list is not selected
for Licence testing. Enabling it later requires an explicit cohort decision.

Sources checked 2026-09-30:
[Billing tests](https://developer.android.com/google/play/billing/test),
[test-track setup](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en),
[production-access requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

## Local credentials boundary

The service account is app-scoped in Play Console. The ignored
`AGENTS.local.md` records the account email and the local key path. The key is
currently outside the repository at:

`/Users/luis/.config/honestfern/play-publisher.json`

Required properties:

- file mode `600`;
- never commit, copy into the repo, print, or paste the JSON into a prompt;
- use `GOOGLE_APPLICATION_CREDENTIALS` only in the invoking shell;
- do not create a second key for a routine release.

The service account is intentionally scoped to this app. Do not grant account-
wide access just to make a listing or release call work. If a future app is
added, grant that package the minimum app-level permissions separately.

## Safe API workflow

Use the Android Publisher Publishing API with the `androidpublisher` scope.
The release operation is an edit transaction:

1. Create an edit for the package.
2. Upload the signed AAB to that edit.
3. Update exactly one track with the new `versionCode`.
4. Commit the edit.
5. Create a fresh empty edit to verify the committed track, then delete the
   verification edit.

The current version source of truth is `pubspec.yaml`:

```text
version: 1.0.0+7
```

For a real follow-up fix, keep `versionName` `1.0.0` and increment only the
build number (`1.0.0+7`, then `+8`, etc.). Play orders Android releases by
`versionCode`; reusing a code is rejected. Promote the exact tested AAB between
tracks instead of rebuilding it.

An API upload should use the signed artifact produced by:

```bash
ADMOB_USE_TEST_ADS=true \
PROVIDER_PROFILE=release_safe \
APP_DEV_MODE=false \
./scripts/build_appbundle.sh
```

The `ADMOB_USE_TEST_ADS=true` setting above is appropriate for the current
internal diagnostic build. A production release must use the approved real
AdMob IDs through the existing environment-based configuration and must pass
the consent/privacy gates first.

Do not send a review, change store presence, alter tester lists, or promote to
Production without explicit release approval.

## API failure history and recovery

### `changesNotSentForReview` rejected on commit

On 2026-09-12, upload and track update succeeded, but the commit returned:

```text
Changes are sent for review automatically. The query parameter
changesNotSentForReview must not be set.
```

This is an API behavior change, not a bad AAB. Retry the commit of the same
edit without `changesNotSentForReview`. Do not upload a duplicate bundle.

If the process exits after an uncertain network failure:

1. Do not immediately create another upload.
2. Query the track with a fresh read-only edit.
3. Delete that verification edit.
4. Only upload again if the expected `versionCode` is absent.

### Store listing commit returns HTTP 403

Bundle and testing-track permissions are separate from Store presence. A 403
on icon or screenshot commit means the account lacks the app-level Store
presence/release permission or the edit targets the wrong locale. Check both
before retrying. For this app the default locale is `en-GB`, not `en-US`.

If the API still cannot commit store assets after the minimum app-level
permission is confirmed, use the already authenticated owner Console session
to select and save the assets. Do not broaden the service account to the whole
developer account.

### More than eight screenshots

Play allows at most eight selected phone screenshots for this listing. Remove
old selected screenshots before selecting replacements. Old files may remain
in the asset library; they are not active listing assets.

The captured images are `1080x2400`; the upload copies are padded to
`1350x2400` so they retain a valid 9:16 ratio. Do not distort the app UI.

## AdMob and consent verification

The internal build uses Google test ad unit IDs. Seeing an empty `AD` shelf or
“ad not available” is not proof of an AdMob account problem. Check the UMP
consent path first:

- `AdConsentManager` must wait for the real UMP result;
- banner widgets must reload after a late consent update;
- rewarded ads must only load after `canRequestAds` is true;
- no-consent, no-fill, offline, and Remove Ads states must remain fail-closed.

The 2026-09-12 failure was caused by 300–500 ms platform timeouts. A fresh
install could still be resolving the UMP web consent layer when the app
permanently decided that ads were unavailable for that run. The fix is covered
by `test/ad_consent_manager_test.dart` and was verified on the large Android
emulator: after UMP resolved, the SDK logged a test-device ad request.

## Manual Console fallback

Use the browser only for operations that the API cannot safely complete:

- app setup declarations and review submission;
- selecting/saving default-locale listing assets after an API 403;
- visual inspection of Publishing overview and track status;
- copying the current tester opt-in link from Internal or Closed testing.

Never assume an opt-in URL from memory. Copy it from the track’s **Testers**
tab. Internal and Closed testing have different links.

## Closeout checklist

- [ ] `pubspec.yaml` has a new unused `versionCode`.
- [ ] `./scripts/check.sh` passes and `git diff --check` is clean.
- [ ] Signed AAB identity and version were inspected before upload.
- [ ] API upload and track status show the expected code and `completed`.
- [ ] A fresh read-only API edit was deleted after verification.
- [ ] Play-distributed installation was updated on a real Android device.
- [ ] UMP consent, banner, rewarded unlock, no-fill, and Remove Ads behavior
      were checked.
- [ ] Store assets are selected in `en-GB`, with no more than eight screenshots.
- [ ] Closed-test opt-in link is shared only after the Closed release is live.
- [ ] No service-account key, token, or private tester data entered Git.
