---
name: google-play-publishing
description: Prepare and inspect Google Play releases for Honest Fern apps. Use when checking Play tracks, validating publisher access, preparing an Android release, or working with the Play Console and Android Publisher API.
---

# Google Play publishing

## Source of truth

Read these in order before release work:

1. App `RELEASE_CHECKLIST.md` for release ordering and current gates.
2. `docs/release-prep/google-play-publishing-runbook.md` for this package,
   credentials boundary, known API behavior and recovery.
3. Workspace `docs/platforms/google-play-developer-api.md` for shared policy
   and transaction rules (when this repo is inside the Honest Fern workspace).
4. `stores/google-play/apps/currency-converter.json` and `stores/google-play/README.md`
   for the machine-readable app mapping and supported local commands.

Recheck the live Console/API when a release-day fact can drift. The email
granting Production access permits a Production release workflow; it does not
mean a release exists or is public. Confirm the track state and dashboard.

## Safe workflow

1. Review branch, diff, version code, signing setup, app checks and device QA.
2. Set up the local Python environment once with
   `./.devtools/google_play.sh setup`; use that wrapper for Play CLI commands.
   Read Play track state with `./.devtools/google_play.sh status`.
   Inspect the returned API `track` values; a Console track label or numeric
   Console track ID is not necessarily the API track key. In particular, do
   not assume the API key `closed`; resolve the Closed Alpha track from a fresh
   API list first.
3. Prepare the candidate on clean `main` with
   `EXPECTED_VERSION_CODE=<unused-code> ./.devtools/prepare_play_candidate.sh`.
   Review its local APK/AAB, screenshots and checksums before upload. This
   helper never changes Play Console state. It checks emulator free space
   before running the longer verification and build steps.
4. Run `./.devtools/google_play.sh plan-closed --aab <candidate.aab>
   --version-code <code>`. Review its live target, candidate path, size,
   checksum, version and unused-code result. This creates and deletes a
   temporary read edit; it does not upload or change a track.
5. Before any upload, obtain Luis's explicit instruction naming the artifact
   and target track. API credentials alone are not release approval. For an
   authorized Closed Alpha upload, use `upload-closed`; it cannot target
   Internal or Production.
6. After an authorized upload, verify the committed track in a fresh API read
   and compare package, version code, status and artifact checksum with the
   approved candidate. Check Console for any review/publishing state before
   telling testers that an update is available.
7. Production promotion/publication and website launch are separate owner gates.

## API and Console lessons from earlier releases

- The app-scoped service account has successfully read and uploaded Internal
  releases using the Android Publisher API. A previous successful verification
  returned `track: internal`, status `completed` and the expected version code.
- Release uploads are edit transactions: create edit, upload the exact signed
  AAB, update one resolved track, commit, then verify in a fresh edit and
  delete that verification edit. Preserve the artifact SHA-256 and source
  commit in the handoff.
- Do not make Console changes while an API edit is open. Google documents that
  Console changes made during an edit discard that edit and take effect; finish
  or delete the API edit before switching surfaces, then read the final state
  again.
- An upload/commit response can be ambiguous. Check the track with a fresh
  read before retrying; never re-upload just because a command timed out or
  returned no output. A previous first upload attempt failed and the later
  persistent transfer succeeded, so wait for completion and capture the API
  response.
- Store listing asset commits returned HTTP 403 even though release operations
  worked. The owner Console was used to select and save the reviewed assets;
  keep the service account app-scoped and do not expand permissions as a
  reflex.
- Use Chrome for Console-only decisions and visual review. An authenticated
  dashboard is evidence of the visible state, but the presence of a Play grant
  email does not prove a Production release exists. A fresh Dashboard/track
  read is required before describing a release as active or public.
- Track enrollment and Licence testing are separate. Tester email-list
  membership is not opt-in, and a Closed tester does not automatically receive
  no-charge Billing. Follow the app runbook for account, cohort and country
  checks.

`status`, `verify-access` and `plan-closed` create temporary API edits to read
app-scoped state and delete those edits afterwards. `upload-closed` makes one
authorized AAB upload and Closed Alpha track update transaction. It confirms
the configured API track in a live track list, checks all listed bundles and
track releases for code reuse, validates the edit, compares the API-reported
bundle hash to the local AAB, and errors rather than cancelling changes
already in review. It does not change tester lists, listings or declarations;
the edit commit may still enter Play's review/publishing process. Stop if
cleanup fails or the API returns ambiguous state;
inspect fresh track state before retrying.

## Credentials and scope

- Use the existing app-scoped publisher account and
  `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
- Never read key content into logs, prompts, screenshots or versioned files.
- Do not create another key or widen account-level/app-level permissions to
  make a failed operation pass.
- Store private machine paths in ignored `AGENTS.local.md`, never here.

## Human-owned Console operations

Use the authenticated owner Console for visual review, declarations, tester
cohorts, review/production-access applications and actions the API cannot
reliably complete. Verify every saved or submitted state in the Console.

## References

- App workflow: `docs/release-prep/google-play-publishing-runbook.md`
- Workspace API model: `../../../../docs/platforms/google-play-developer-api.md`
- External tooling review: `TOOLING.md`

## Lessons from the 2026-10-19 tooling review

- Serialize **every** authenticated API command, including reads: a new edit
  invalidates the account's previous edit. The CLI lock protects this OS user
  and package across checkouts, not Console, another user or another host.
- Upload verifies its committed track automatically. `verifiedTrack` and
  `completed` do not prove publication; inspect Console Publishing overview.
- Use `google_play.sh screenshots --source <root> --output <gallery>` for
  validated, pixel-preserving 9:16 upload copies and a SHA-256 manifest.
- Chrome extension file uploads may require file-URL access. Prefer the native
  macOS picker instead of broadening the extension's permissions. Upload the
  six PNGs only, remove old phone selections, then select replacements in order.
- Saved listing changes can remain **ready to send for review** while a binary
  is in review. Never cancel the binary review merely to submit screenshots.
- For an emulator Wait/Close dialog, collect `android_diagnose.sh` first;
  identify the process and timestamp. Do not assume an app ANR or auto-dismiss
  it. Screenshot tests seed premium state; restore a normal release install
  on a disposable QA emulator before handing it back.

## Website screenshots after UI changes

The public website has its own repository at `../../niduna-site` relative to
this app repo. Follow its `docs/screenshot-refresh-and-deploy.md`. Reuse the
reviewed original 1080×2400 gallery with
`SITE_SCREENSHOT_SOURCE_DIR=<capture-root> ./.devtools/capture_site_screenshots.sh`.
This updates five site PNGs, eight responsive WebP copies and HTML cache keys;
Play's padded 1350×2400 images are not the website source. The script prepares
local files only. The website is deployed separately via its existing VPS SSH
script after a reviewed commit/push and deployment authorization; no Nginx
restart is needed. Keep Coming Soon until Production is public.

## Latest build-9 lessons

- Before any release edit, inspect Console Publishing overview for the **whole
  saved change batch**, including store listings. A code-9 track commit also
  submitted the already-saved en-GB screenshots. Confirm existing authorization
  covers that batch; an app-scoped track update does not isolate review submission.
- Use `--output <new-file.json>` for durable plan/upload/status receipts. Never
  reuse an existing receipt path. A save error after a successful API operation
  is not authorization to re-upload; retain stdout and inspect live state.
- `setup` requires Python 3.11+ and preserves an obsolete environment before
  replacement. Do not restore a raw httplib2 transport: Google's `build_http()`
  handles HTTP 308 as resumable progress rather than a redirect.
- HTTP 503 can be transient. After a failed command, inspect fresh track state
  and unused-code preflight before deciding to retry the same AAB. Do not add
  automatic whole-release retries or assume API `completed` means installable.

## Regional one-time product prices

- Read `pricing/README.md` and the policy status before pricing work. Launch
  values are proposals until Luis approves the exact amounts/region scope.
- Use `pricing catalog` for a fresh authenticated catalog snapshot and
  `pricing plan` for an offline JSON/CSV comparison. These are read-only and
  do not create a release edit. Reuse the existing package lock/credentials.
- Inspect `purchaseOptionId`, state, legacy compatibility, regional prices and
  availability, regionsVersion and future-region defaults. Do not infer that
  a configured product country is an enabled distribution country.
- Currency is not market: this catalog has many countries priced in USD/EUR
  as fallback currencies. Prefer explicit region selection for priority markets.
- The current tool has no apply command. A future writer needs approved diff,
  fresh-state comparison, validated update mask/version, preservation of all
  unrelated fields and post-write readback. Catalogue write permission is not
  proven by successful reads. Do not recreate legacy SKUs or widen permissions.
- Preserve the accepted AAB: localized prices come from Play Billing at runtime.
