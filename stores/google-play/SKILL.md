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
2. Read Play track state with `python3 stores/google-play/scripts/google_play.py status`.
   Inspect the returned API `track` values; a Console track label or numeric
   Console track ID is not necessarily the API track key. In particular, do
   not assume the API key `closed`; resolve the Closed Alpha track from a fresh
   API list first.
3. Prepare the candidate on clean `main` with
   `EXPECTED_VERSION_CODE=<unused-code> ./.devtools/prepare_play_candidate.sh`.
   Review its local APK/AAB, screenshots and checksums before upload. This
   helper never changes Play Console state.
4. Before any upload or edit commit, obtain Luis's explicit instruction naming
   the artifact and target track. API credentials alone are not release approval.
5. After an authorized upload, verify the committed track in a fresh API read
   and compare package, version code, status and artifact checksum with the
   approved candidate.
6. Production promotion/publication and website launch are separate owner gates.

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

The initial CLI supports only `status` and `verify-access`. Both create a
temporary empty API edit to read the app-scoped resource and delete it in a
`finally` path. They must not upload artifacts, change tracks, tester lists,
listings, declarations, or review state. Stop if cleanup fails or the API
returns ambiguous state; inspect the Console before retrying.

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
