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
- Candidate preparation remains app-owned: `.devtools/prepare_play_candidate.sh`
  runs checks, creates local APK/AAB artifacts and store screenshots, and
  writes them under `.tmp/play-candidate/`. It does not upload anything.
- Upload, track mutation, review submission and Production release are not
  implemented by this first slice. Use the app publishing runbook for the
  existing controlled release procedure.

## Which surface to use

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

The CLI needs `google-auth` and `google-api-python-client`. Install them in a
dedicated local virtual environment from `requirements.txt`; avoid changing
the app's Flutter dependencies.

See [`SKILL.md`](SKILL.md) for the operating workflow and stop conditions.
See [`TOOLING.md`](TOOLING.md) for the reviewed external automation options and
the current recommendation before adding another Play dependency.
