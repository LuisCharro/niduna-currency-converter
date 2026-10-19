# Google Play store tooling

This directory is the Google Play adapter for the Honest Fern app workspace.
Keep the reusable workflow here and package-specific identifiers in
`apps/currency-converter.json`. Future stores can live beside `google-play/`
without moving the app repository or its release checklist.

## Current scope

- `scripts/google_play.py status` reads the app's tracks through a temporary
  Android Publisher edit and deletes that edit afterwards.
- `scripts/google_play.py verify-access` checks service-account access using
  the same create/delete verification edit without uploading or changing a
  track.
- `scripts/google_play.py plan-closed` validates a local candidate, checks the
  live Closed Alpha track and all listed bundles, then deletes its temporary
  read edit without uploading or changing a track.
- `scripts/google_play.py upload-closed` uploads one signed AAB to the
  configured Closed Alpha track in a single edit transaction. It requires an
  explicit artifact and version code, derives its release label from
  `pubspec.yaml`, checks that the code is unused across bundles and track
  releases, validates the edit, compares Google's SHA-256 with the local file,
  and prints the result. It cannot target Internal or Production.
- Candidate preparation remains app-owned: `.devtools/prepare_play_candidate.sh`
  runs checks, creates local APK/AAB artifacts and store screenshots, and
  writes them under `.tmp/play-candidate/`. It does not upload anything.
- Internal promotion, listing changes, separate review management and
  Production release are not implemented by this adapter. A track commit may
  still enter Play's review/publishing process; check Console before telling
  testers an update is available.

Set up the local isolated environment once, then use the wrapper for commands.
It stores the virtual environment under ignored `.tmp/` and never handles the
credential file itself:

```bash
./.devtools/google_play.sh setup
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/app-scoped-key.json
./.devtools/google_play.sh status
```

Before any authorized upload, run the non-mutating preflight and review its target,
version code, file size and SHA-256:

```bash
./.devtools/google_play.sh plan-closed \
  --aab .tmp/play-candidate/<candidate>/artifacts/app-release.aab \
  --version-code <next-version-code>
```

After the owner explicitly authorizes that artifact for Closed Alpha, replace
`plan-closed` with `upload-closed`. The upload command checks the code again
inside its write transaction. After an upload, run `status` in a fresh API edit
and confirm track, release name, code and status. If commit outcome is
ambiguous, inspect fresh track state before retrying.

## Regional pricing

See [pricing strategy and live comparison](pricing/README.md) before changing
one-time-product prices. `pricing catalog` reads the modern catalog directly;
`pricing plan` compares a saved catalog with the proposed policy offline and
exports JSON/CSV. Neither command writes prices or modifies release tracks.
`pricing apply` executes an explicitly approved hash-bound plan with fresh-state
checks, receipt journaling and full catalog readback; no automatic write retries.
The 2026-10-19 launch policy has been applied. Keep pricing authorization
separate from an AAB upload; no app rebuild is needed solely for catalog prices.

```bash
./.devtools/google_play.sh pricing --help
```

## Which surface to use

Owner Console dashboard for this app:
[Currency Converter Honest Fern](https://play.google.com/console/developers/6219086036817053258/app/4973875544480645622/app-dashboard).
Use the authenticated Chrome session for visual review and Console-only
decisions; the command line cannot replace those owner flows.

| Work | Preferred surface | Notes |
| --- | --- | --- |
| Read track release/version state | Android Publisher API CLI | `status` opens and deletes a temporary read edit; verify the returned API track name. |
| Upload an approved AAB or change a track | Android Publisher API | Use a single edit transaction, then read the committed track in a fresh edit. |
| Listing assets, declarations, tester cohorts and review tasks | Play Console in Chrome | The Store presence API previously returned 403; assets were reviewed and saved in the owner Console. |
| Production-access application and human review | Play Console in Chrome | Review and release approval are separate decisions. |

The Android Publisher API successfully uploaded and verified past Internal
releases. A temporary edit followed by `tracks.list` was also used to confirm
the exact release code. The workflow must not infer a Play state from a local
build, a Console screenshot, an email, or an earlier API result alone; read the
relevant live track when preparing a release.

Credentials stay outside Git. Set `GOOGLE_APPLICATION_CREDENTIALS` to the
existing app-scoped service-account JSON path in the invoking shell. Never
pass or print key contents.

The CLI needs the packages in `requirements.txt`. The wrapper installs them in
a dedicated local virtual environment; it does not change the app's Flutter
dependencies.

See [`SKILL.md`](SKILL.md) for the operating workflow and stop conditions.
See [`TOOLING.md`](TOOLING.md) for the reviewed external automation options and
the current recommendation before adding another Play dependency.

## Reliability and local gallery commands

All authenticated commands acquire a nonblocking per-package lock shared by
this OS user across checkouts. This prevents a simultaneous `status` or
`plan-closed` from invalidating an upload's edit. It cannot protect against
Console edits, another user or another host. Serialize those manually.
Google's [edits documentation](https://developers.google.com/android-publisher/edits)
explains the one-open-edit rule and invalidation behavior.

`upload-closed` verifies the committed track automatically, returns JSON-safe
artifact paths, and distinguishes definite HTTP rejections from ambiguous
commit responses. A post-commit verification failure explicitly warns not to
re-upload. Neither `verifiedTrack` nor API status `completed` establishes
Google review approval or download availability; check Publishing overview.

Help works before setup or credentials. Screenshot export is local and needs
Pillow, installed by `setup` (rerun setup after requirements change):

```bash
./.devtools/google_play.sh --help
./.devtools/google_play.sh screenshots --source .tmp/<capture-root> --output .tmp/<upload-gallery>
.tmp/google-play-venv/bin/python -m unittest discover -s stores/google-play/tests -v
```

The exporter validates six 1080×2400 light/dark captures, adds side margins
without rescaling app pixels, and writes six 1350×2400 PNGs, SHA-256 manifest
and `preview.jpg`. Upload only the six PNGs. See the runbook for native Chrome
file-picker fallback and the canonical gallery.

## Build-9 publishing lessons and improvements — 2026-10-19

- Resumable transfers use Google's `build_http()` transport. Raw httplib2
  treated HTTP 308 Resume Incomplete as a redirect and interrupted the upload.
  A separate transient HTTP 503 was resolved only after a fresh preflight
  confirmed that the version code was still unused; no duplicate was committed.
- Upload progress now identifies the phase: edit creation, code check, transfer,
  validation, commit and fresh verification. Messages go to stderr.
- All authenticated commands emit JSON only on stdout. `verify-access` now
  returns a JSON object (previously text); status cleanup messages go to stderr.
- Add `--output <new-path.json>` to save the successful result atomically, without
  overwriting an earlier receipt. An upload receipt contains the local and Play
  SHA-256, code, release name, commit and fresh verification result. No credentials
  or tokens are included. A receipt-save failure preserves stdout and explicitly
  warns against repeating a successful upload. Receipts do not prove publication.
- `setup` now selects Python 3.11+ instead of silently reusing the system Python
  3.9. Override with `GOOGLE_PLAY_PYTHON_BIN=/absolute/path/to/python`. An obsolete
  or broken environment is moved to a timestamped sibling before replacement;
  no keys are moved or read. Requirements remain in the isolated environment.
- Inspect Publishing overview **before** committing an authorized release: the
  code-9 commit also submitted the saved en-GB phone screenshots. Updating only
  one API track does not guarantee that all other saved changes stay unsent.
  Review the complete pending batch and its authorization before uploading.

Example (use the next unused code, not the already-uploaded code 9):

```bash
./.devtools/google_play.sh plan-closed --aab <candidate.aab> \
  --version-code <unused-code> --output .tmp/<candidate>/plan.json
# After authorization for the reviewed release and pending change batch:
./.devtools/google_play.sh upload-closed --aab <candidate.aab> \
  --version-code <unused-code> --output .tmp/<candidate>/upload.json
./.devtools/google_play.sh status --output .tmp/<candidate>/status.json
```

Automatic whole-upload retries remain deliberately absent: inspect the live
state after any ambiguous error. In-chunk transient retries already use the
Google client's bounded retry handling. A future separate AAB-only preparation
mode could avoid emulator/screenshot work for text-only releases; it is not
implemented here. The current full candidate helper still runs the app check
suite and captures screenshots.
