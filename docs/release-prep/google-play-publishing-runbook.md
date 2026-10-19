# Google Play publishing runbook

> App-specific operational guide for Honest Fern Currency Converter. Keep
> secrets and machine-specific paths in `AGENTS.local.md`, never in this file.

For the reusable portfolio-wide model, read
[`google-play-developer-api.md`](../../../../docs/platforms/google-play-developer-api.md)
when this repository is checked out inside the Honest Fern monorepo. This
document owns only Currency Converter facts and commands.

**Last verified:** 2026-10-19

**Package:** `com.honestfern.currency_converter`

**Play app ID:** `4973875544480645622`

**Developer account ID:** `6219086036817053258`
**Default listing locale:** `en-GB`

## Real-device acceptance — 2026-10-19, Closed build 10

- Console was subsequently checked: Closed Alpha `1.0.0 (10)` is **Available
  to selected testers**, released 19 Oct at 14:42. The earlier in-review
  snapshots below are historical. No Production promotion has occurred.
- Luis initially used the Internal link and saw old fixed CHF labels. After
  reinstalling from the Closed link he confirmed **2/3/1 CHF** in Settings and
  the same correct Google Play checkout price. His licence-test account showed
  the free test payment instrument. Do not count the Internal install as code-10 QA.
- Luis reports completing all requested real-phone checks successfully: three
  test purchases and their feature unlocks, relaunch persistence, reinstall and
  Restore, normal conversions/favorites/Charts including landscape, offline use
  after loading rates, and privacy links/controls. This is owner-reported manual
  acceptance, not an automated test run or an independently captured device log.
- Specifically, after uninstall/reinstall ads returned initially. Pressing
  **Restore purchases** recovered all three purchases and removed the ads again.
  Manual restoration passed; do not claim purchases auto-restored on reinstall.
- Keep the exact signed code-10 AAB/hash below. These results require no binary
  changes or rebuild. Final Console declarations/configuration and the open
  source/privacy adequacy findings still need review before the separately
  authorized Production promotion. Website S2 activation follows public availability.

## Original Closed submission — 2026-10-19, build 10

- Luis authorized submitting **1.0.0 (10)** to Closed Alpha (`alpha`) as the
  next public-release candidate. Upload, matching Google/local hash and fresh
  track verification succeeded. Console shows **Changes in review**, with
  quick checks running for code 10 / Start full rollout. No unrelated changes
  were pending before upload. Production is empty; Internal remains code 7.
- Source commit: `b28e9e67f6d50d0fa4d60c331a8c6aede3b280bf`. Signed AAB:
  `.tmp/play-candidate/20261019-build10/artifacts/app-release.aab` (54,683,454 bytes).
  SHA-256: `5ffcc01c221571ba55b20015fe0f3cbcfa5c27297b4db46bca3b34d66db98988`.
  Built on clean main with release_safe, developer mode false, real approved
  Android AdMob IDs and test ads false. Package/name/code, non-debuggable
  manifest, AdMob app ID and expected upload certificate verified.
- Includes the layered privacy/source help below and localized Play product
  prices. Settings queries the three existing products on entry/resume,
  hides stale prices while refreshing and shows descriptions alone if prices
  cannot be fetched. Purchase, entitlement and Restore flows are unchanged.
- Flutter analysis and signed AAB build passed. No automated tests ran for
  this preparation. The emulator still has the earlier test-ad preview;
  it is not evidence for this exact Play artifact or the localized price UI.
- Luis should update through the existing Closed link after approval:
  https://play.google.com/apps/testing/com.honestfern.currency_converter
  Until approval/propagation it can still serve code 9. Accept build 10 on the
  real Play device, including Settings prices, privacy links, Charts and normal
  use. Use the approved licence-test account for any Billing verification.
- If accepted, promote **this exact AAB** to Production with separate approval;
  no rebuild/version bump is needed. The agreed regional price policy has now been applied and verified; see
  Store price operations below. Any binary correction instead needs a new unused version code.
- Website policies/images are already public from site revision `12d3cb8`.
  Keep Coming Soon until Production is public, then execute the site's S2
  download-link/availability change. Data-source/controller adequacy questions
  in the disclosure review remain open; this upload is not legal clearance.
- Receipts, provenance, manifest/signature and logs are in the ignored candidate
  directory above; `play-review.png` records the Console review state. Upload
  succeeded on the first attempt; no manual retry or review restart was needed.

### Store price operations

The current live catalog, proposed launch tiers and read/plan commands are
owned by [`stores/google-play/pricing/README.md`](../../stores/google-play/pricing/README.md).
The 2026-10-19 policy was approved and applied: 69 prices in 23 regions,
with all 522 rows and preserved fields verified by independent API readback.
See `last-application.json` in that directory. It does not alter code 10.


Settings uses `ProductDetails.price` from the existing Play Billing products,
with no fixed CHF fallback. Changing country prices in Console does not require
a new binary solely to update displayed amounts; reopen/resume Settings after
store propagation and check the final Play checkout price. A lookup failure
leaves the benefit description visible. Source: [Google Billing integration](https://developer.android.com/google/play/billing/integrate).

The successful code-10 transfer used the existing resumable uploader with
8 MiB chunks and guarded edit commit. Status/preflight/upload remain serialized.
The exact tested AAB can later be promoted between tracks: [Google release
tracks](https://developers.google.com/android-publisher/tracks).

## Historical local preview after code 9 — 2026-10-19

`pubspec.yaml` is `1.0.0+10` for Luis's approved layered help changes. It has
not been uploaded; there is no approved code-10 Play AAB. The test-ad preview
APK and the isolated rendering harness in `.tmp/privacy-layered-preview-20261019/`
are not upload candidates. Code 9 remains the current Closed build; Luis
reports installing the latest version, and Console/Chrome confirmed the new
listing gallery live. Keep Production separate. Before any new upload, build
an exact signed real-ad AAB, run live unused-code preflight and review the whole
pending Console change batch. The historical code-9 artifact below is unchanged.

## Previous submission — 2026-10-19, code 9

`1.0.0 (9)` was uploaded and committed to Closed Alpha (`alpha`) with Luis's
explicit authorization. A fresh API edit verified the release, and Console
shows **in review**. Internal remains code 7; Production is empty. Code 8 had
already become Available to selected testers before this upload. Do not report
code 9 installable until Console confirms availability and the phone receives it.

Candidate source: `ca24985`; AAB:
`.tmp/play-candidate/20261019-build9/artifacts/app-release.aab` (54,676,836 bytes).
Local and Google SHA-256:
`d9c1d88199bffd892214e1cdb0ec2e9534c945179b54017717d98ad9488b39a2`.
Real approved Android AdMob IDs, test ads false, developer mode false and
release_safe profile. Manifest and upload signature checked; Flutter analysis
clean and AAB build successful. No automated tests were run for this submission;
Play-distributed acceptance remains pending on Luis's phone. The local preview
APK from earlier copy work is not this signed Play AAB.

Release notes (en-GB): “Refined rate guidance and privacy information in five
languages. Improved Settings clarity and release polish.”

Freshly checked tester URL:
https://play.google.com/apps/testing/com.honestfern.currency_converter
Selected Closed list: 22 entries; no selection changes. API upload verification
logs and provenance are in the ignored candidate directory. See the master
checklist for the exact next acceptance gate. Older code-8 review states below
are historical.

Publishing overview confirms **Changes in review**, with quick checks running
for `1.0.0 (9)` / Start full rollout and the saved en-GB phone screenshot
replacement in the same submission. No separate screenshot submission or
review restart was performed. Evidence: candidate directory `play-review.png`.

## Earlier release state — 2026-10-19, code 8

Closed Alpha has uploaded `1.0.0 (8)` with API status `completed`; Console
Publishing overview shows **in review**, last published 2026-09-30 (code 7).
Do not announce tester availability until Console confirms publication. Internal remains
`1.0.0 (7)`. A fresh Publisher API read confirmed Production is empty. The
Closed Alpha AAB was built from source commit `e5df688` and uploaded on
2026-10-19. SHA-256:
`ed492e6efcf32b7c0c7fb2ec983434a9bb8911a4a29a1d80315a66c0b1c11a87`.
The app version name remains `1.0.0`; its Android version code is `8`. This
Closed testing upload is not a Production release.

The machine-readable app map resolves Closed Alpha to the Publisher API track
`alpha` (Console track ID `4700576461420899940`). The new
`.devtools/google_play.sh` wrapper provides a repeatable local environment and
`plan-closed` preflight. `upload-closed` creates one edit, checks all listed
bundles and releases, uploads the supplied signed AAB, compares the API's
SHA-256 with the local file, validates the edit, updates only Closed Alpha and
commits. It uses `ERROR_IF_IN_REVIEW` so a pending review cannot be cancelled
implicitly. The upload command automatically verifies the track in a fresh edit; do not retry
an ambiguous upload until the live track has been checked. The commit can
still place changes into Play's review/publishing process; check Console before
telling testers an update is available.

### Updated listing gallery — 2026-10-19

Six fresh screenshots from current main were captured in light/dark modes:
Convert, portrait Charts (including the landscape/expand button), Favorites.
Both gallery integration runs passed. Canonical selected images are
`screenshots/{convert,chart,favorites}-{light,dark}.png`; exact upload filenames,
SHA-256 hashes and order are in `screenshots/play-gallery-manifest.json`.
Review `screenshots/play-gallery-preview.jpg`. Exported 1350×2400 copies preserve
all 1080×2400 source pixels with 135-pixel side margins; no landscape shot.

The six replacements are **saved**, in the existing en-GB default listing.
Publishing overview shows one unsent change: **Change Phone screenshots**.
Console explicitly warned that submitting it now would cancel and restart the
code 8 review. That operation was cancelled: leave the saved screenshots ready
until the current review completes, or obtain Luis's explicit restart decision.
Icon, feature graphic, text, and the existing AI asset declaration were preserved.
Do not claim the refreshed images are already public.

For Chrome extension uploads, direct `filechooser.setFiles` may fail when
file-URL access is disabled. Use the native macOS file picker instead: Upload,
Cmd+Shift+G, enter the export folder, select only the six PNGs (exclude manifest
and preview), Open. No extension permission expansion is needed. Remove the old
six phone selections, select new files in manifest order, Add, Save as draft,
Next, Save. Verify Publishing overview and stop before any review restart.

### Emulator Wait/Close investigation — 2026-10-19

The observed ANR belonged to `com.google.android.apps.nexuslauncher`
(**Pixel Launcher**), timestamp 08:58:36, waiting 5120ms for a focus event.
The incident trace showed substantial CPU, memory and I/O pressure; contention
is a plausible contributing factor, not a proven app defect. No Currency
Converter ANR was found. The old last-ANR entry persists after recovery and
must not be interpreted as a fresh crash.

Recovered the disposable Medium_Phone Android 36 emulator by restarting the
launcher, restored the exact normal release APK, and removed screenshot-test
seeded app state on that QA emulator. Subsequent launch succeeded on attempt 1;
Currency Converter held focus and no new ANR appeared in the event log. The
normal first-run UMP consent dialog is expected and is distinct from an ANR.

Capture no longer toggles global Android night mode: app preferences already
select light/dark. Launcher checks now reject ANR/error windows, return nonzero
on unconfirmed launch, and collect `android_diagnose.sh` evidence. Do not hide
failures by automatically tapping Wait. Run only necessary emulators and avoid
concurrent build/capture runs under memory pressure.

Local evidence (ignored): `.tmp/play-review-20261019/{anr,final-emulator}`,
`capture.log`, `check.log`, and `console-screenshots-saved.png`. For future
incidents, collect fresh diagnostics and compare process names and timestamps.

Historical 2026-09-30 release details follow.

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

## Tester invitations and monitoring

The following Console cohort and invitation details were last checked on
2026-09-30. Recheck the dashboard, tester lists, countries and invite status
before relying on them; the local closed-track API does not expose those facts.

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
- On 2026-09-30, emailing the cohort on 2026-10-01 was planned; sending was
  not recorded then. Recheck actual invitation status rather than relying on
  that old plan. Play does not email invitations when a list is populated.

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
`AGENTS.local.md` records the account email and local key path. Keep that
machine-specific path out of versioned documentation.

Required properties:

- file mode `600`;
- never commit, copy into the repo, print, or paste the JSON into a prompt;
- use `GOOGLE_APPLICATION_CREDENTIALS` only in the invoking shell; the
  `.devtools/google_play.sh` wrapper checks that it is set but never reads or
  prints the key contents;
- do not create a second key for a routine release.

The service account is intentionally scoped to this app. Do not grant account-
wide access just to make a listing or release call work. If a future app is
added, grant that package the minimum app-level permissions separately.

## Safe API workflow

Use the Android Publisher Publishing API with the `androidpublisher` scope.
The release operation is an edit transaction. The local workflow first runs
`plan-closed`, which checks the candidate and current track state using a
temporary read edit. After explicit authorization, `upload-closed` repeats the
checks inside the write edit:

1. Create an edit for the package.
2. Upload the signed AAB to that edit.
3. Update exactly one track with the new `versionCode`.
4. Validate the edit and commit with `changesInReviewBehavior=ERROR_IF_IN_REVIEW`
   so an existing review is not silently cancelled.
5. Create a fresh empty edit to verify the committed track, then delete the
   verification edit.

The current version source of truth is `pubspec.yaml`:

```text
version: 1.0.0+10
```

For a real follow-up fix, keep `versionName` `1.0.0` and increment only the
build number (`1.0.0+8`, then `+9`, etc.). Play orders Android releases by
`versionCode`; reusing a code is rejected. Promote the exact tested AAB between
tracks instead of rebuilding it.

Historical checkpoint (2026-10-14): code 8 was a local development candidate,
tested as a release APK on the emulator, while both test tracks remained at
code 7. This was superseded by the Closed Alpha upload recorded above.
Committing or pushing a branch does not upload or publish a Play release; a
signed AAB and explicit release authorization are still required.

This is an internal diagnostic build command only:

```bash
ADMOB_USE_TEST_ADS=true \
PROVIDER_PROFILE=release_safe \
APP_DEV_MODE=false \
./scripts/build_appbundle.sh
```

Do not upload that test-ad build to Closed testing or Production. For any
tester or Production candidate, use `.devtools/prepare_play_candidate.sh` with
`release_safe`, `APP_DEV_MODE=false`, approved real AdMob IDs and
`ADMOB_USE_TEST_ADS=false`. Production publication still requires its separate
owner approval and consent/privacy gates.

An authorized upload includes committing the Closed track edit, which may
enter Play's review/publishing process. Store presence, tester lists,
declarations, separate review-management actions and Production promotion
remain separate owner operations and need their own explicit authorization.

## API failure history and recovery

### Resumable upload raises `RedirectMissingLocation`

On 2026-10-19 the code-9 upload stopped before committing a track change.
The custom raw `httplib2.Http` interpreted Google's HTTP 308 Resume Incomplete
as a redirect requiring a Location header. The CLI now uses
`googleapiclient.http.build_http()` with the existing 180-second timeout;
Google's transport excludes 308 from redirects so the upload handler can
continue sending chunks. TLS verification and other redirects are unchanged.
See [Google's transport implementation](https://googleapis.github.io/google-api-python-client/docs/epy/googleapiclient.http-pysrc.html#build_http).

After any failed transfer, inspect fresh track state and run `plan-closed`
before retrying. A 503 is a separate service error: do not assume the artifact
or track committed, and never retry an already-used version code blindly.

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
