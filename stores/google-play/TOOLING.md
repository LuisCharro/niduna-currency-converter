# Google Play automation options

Reviewed 2026-10-19. This is a short decision record for tools that could
complement this repository's app-scoped workflow. Recheck upstream docs before
adopting a tool because command flags, API coverage and project maintenance can
change.

## Recommendation for this repository

Keep the current small Python CLI for read-only track status and access checks,
and keep candidate creation in `.devtools/prepare_play_candidate.sh`. They fit
the current workflow, preserve the existing app-scoped credential boundary and
make no release decisions.

If we later want a standard upload/promotion wrapper, evaluate **Fastlane
Supply** first. It is a mature, well-documented option for AAB uploads, tracks,
metadata and screenshots. Configure any lane explicitly to skip metadata,
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
state with a fresh API read.

## Upstream references

- [Google Android Publisher API](https://developers.google.com/android-publisher/index)
- [Google API edit transactions and Console interaction](https://developers.google.com/android-publisher/edits)
- [Fastlane Supply documentation](https://github.com/fastlane/fastlane/blob/master/fastlane/lib/fastlane/actions/docs/upload_to_play_store.md)
- [gpd CLI and its agent skill pack](https://github.com/dl-alexandre/Google-Play-Developer-CLI)
- [r0adkll GitHub Action](https://github.com/r0adkll/upload-google-play)
