# Google Play automation options

Reviewed 2026-10-19. This is a short decision record for tools that could
complement this repository's app-scoped workflow. Recheck upstream docs before
adopting a tool because command flags, API coverage and project maintenance can
change.

## 2026-10-19 update

The local `google_play.py` adapter now has a read-only `plan-closed` and a
guarded `upload-closed` operation for a reviewed AAB. The preflight checks the
candidate and current track; the upload rechecks all listed bundles and track
releases in its edit, validates the local and Play SHA-256 values, and uses
`ERROR_IF_IN_REVIEW` to avoid cancelling a pending review. It remains limited
to configured Closed Alpha and the existing app-scoped service account. A
successful edit commit may still enter Google's review/publishing process;
the Console remains the source for whether testers can install the update.

The first upload completed as `1.0.0 (8)` on Alpha. The official API reference
also recommends a two-minute request timeout for bundle upload; the client is
now configured with a three-minute timeout and resumable 8 MiB chunks. Fastlane,
`gpd` and GitHub Actions remain unevaluated for actual uploads.

Candidate preparation also now checks emulator `/data` space before running
tests and builds. The first attempt had to switch to an emulator with more free
space, so the preflight surfaces that issue before spending time on the build.

## Recommendation for this repository

Keep the small Python CLI for track status, access checks and the narrow
Closed Alpha upload. Keep candidate creation in
`.devtools/prepare_play_candidate.sh`. These fit the current workflow and
preserve the existing app-scoped credential boundary. The upload command is a
track operation and still requires Luis's explicit instruction naming the
artifact and Closed target; it does not decide whether or when to release.

If we later want broader release, promotion or listing automation, evaluate
**Fastlane Supply** first. It is a mature, well-documented option for AAB
uploads, tracks, metadata and screenshots. Configure any lane explicitly to skip metadata,
images and screenshots unless those exact changes are part of the reviewed
release; Fastlane documents that its screenshot uploads replace the current
listing screenshots. Its API calls use the same Play access and therefore do
not work around the Store Presence 403 or Console-only review/declaration work.

**gpd (Google Play Developer CLI)** is an interesting agent-oriented pilot:
its repository provides JSON output, dry-run commands and auth/release skills.
It is third-party software with broad API coverage. Before using it with this
app, review the source and pinned release, credential handling, exact scopes,
and write/dry-run behavior. Do not install its skill pack as an authority: its
instructions are written for `gpd`, while this repository's local skill is the
source of truth for our app, gates and credentials. If adopted, borrow useful
ideas such as machine-readable output and preflight checks, not its release
authorization policy.

The `r0adkll/upload-google-play` GitHub Action may fit a later CI workflow, but
CI is not our current local release path. Pin an audited action version and
configure the track and release status explicitly before considering it.

## Not adopted

- This review did not find a Google-maintained Play Console agent skill.
- Other community `gpc` projects surfaced, but their broad claims and/or limited
  project history did not justify adding another dependency.
- Do not add an MCP/browser automation layer for Play operations already
  supported by the official API. Continue to use the owner Console for visual
  review and tasks the API cannot reliably complete.

## Operational constraint

The official Android Publisher API groups changes in an edit transaction.
Google documents that Console changes made while an edit is open discard that
edit and take effect instead. Avoid simultaneous Console edits and API edits;
commit or delete the API edit before using the Console, and verify the final
state with a fresh API read. Bundle uploads return a version code and SHA-256;
compare that hash against the local artifact before committing.

## Upstream references

- [Google Android Publisher API](https://developers.google.com/android-publisher/index)
- [Google API edit transactions and Console interaction](https://developers.google.com/android-publisher/edits)
- [Bundle upload and its recommended request timeout](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/bundles/upload)
- [Bundle list and API-reported SHA-256](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/bundles)
- [Commit behavior when other changes are in review](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit)
- [Fastlane Supply documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/docs/upload_to_play_store.md)
- [gpd CLI and its agent skill pack](https://github.com/dl-alexandre/Google-Play-Developer-CLI)
- [r0adkll GitHub Action](https://github.com/r0adkll/upload-google-play)
