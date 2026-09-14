# Google Play publishing runbook

> App-specific operational guide for Honest Fern Currency Converter. Keep
> secrets and machine-specific paths in `AGENTS.local.md`, never in this file.

For the reusable portfolio-wide model, read
[`google-play-developer-api.md`](../../../../docs/platforms/google-play-developer-api.md)
when this repository is checked out inside the Honest Fern monorepo. This
document owns only Currency Converter facts and commands.

**Last verified:** 2026-09-14

**Package:** `com.honestfern.currency_converter`

**Play app ID:** `4973875544480645622`

**Developer account ID:** `6219086036817053258`
**Default listing locale:** `en-GB`

## Current release state

- Internal testing contains `1.0.0`, Android `versionCode 6`, uploaded from
  commit `aad8249`.
- The published release notes are in English (`en-GB`): “Refined default
  currency selection and crypto pickers.”
- Uploaded AAB SHA-256:
  `9f6c0464046b636fe0a3f66b74afa58217696e269477366a0f35addf51f5ed96`.
- The stable internal opt-in link is
  `https://play.google.com/apps/internaltest/4701596695392061996`.
- That link identifies the testing track, not a particular version. Testers
  should join once and then update from Google Play when a newer release is
  published.
- The next intended operation is promotion of the same tested artifact to
  Closed testing. Do not rebuild merely to change its version name.

## Closed-testing promotion — next approved decision point

Do not create a Closed release just because a single email address is on the
tester list. Luis will request this operation after recruiting a practical
cohort (target 14–16 people) and confirming that the app is ready.

At that point, perform this bounded sequence:

1. Check in Play Console that Closed tester selection and countries/regions
   are configured. Keep the tester emails private; do not put them in Git or
   in release scripts.
2. Confirm the source AAB is the accepted Internal artifact `1.0.0` /
   `versionCode 6` (or a separately approved, higher-code fix), its release
   notes, and its country targeting.
3. With Luis's explicit release instruction, use the Publisher API to assign
   that code to `closed` in one edit and commit it. Do not alter Production.
4. Create a fresh read-only edit to verify the committed Closed track, then
   delete that verification edit.
5. Copy the live **Closed** opt-in URL from the Console's Testers tab and give
   it to Luis. It is different from the Internal opt-in URL above.
6. Each person must opt in through that Closed link. Email-list membership and
   installing the Internal build do not count. Monitor the Console until at
   least 12 people are actually opted in continuously for the 14-day
   requirement.

Stop before committing if the selected countries, version code, artifact or
release notes are ambiguous, or if the Console has an unfinished setup/review
gate. Resolve and record that fact first.

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
version: 1.0.0+6
```

For a real follow-up fix, keep `versionName` `1.0.0` and increment only the
build number (`1.0.0+6`, then `+7`, etc.). Play orders Android releases by
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
