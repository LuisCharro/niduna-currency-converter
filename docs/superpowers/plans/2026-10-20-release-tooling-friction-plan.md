# Release tooling friction — implementation plan (app repo)

Written 2026-10-20 right after the build-11 Closed Alpha release, from the
frictions actually hit in that session. Everything needed to implement it is
in this file; you should not need to run another release to rediscover the
failures. Sibling plan for the website:
`../../niduna-site/docs/2026-10-20-release-tooling-plan.md`.

## Ground rules (do not break while improving tooling)

- **Never upload, promote or change Play Console state** while doing this
  work. Only `status` / `plan-closed` reads are allowed for testing, and only
  serialized (one API command at a time; a new edit invalidates the previous).
- Uploads keep requiring Luis's explicit approval naming the artifact SHA-256
  and track. Tooling may *pause and print* the approval request; it must never
  auto-approve or add a `--yes` that skips it in an agent flow.
- Do not read secret file contents into logs/prompts. `.env.local` exists in
  the repo root (gitignored, contents unknown to agents; the sandbox denies
  reading `.env*`). Ask Luis before using or renaming it.
- Do not widen the service account's permissions.
- Each step below is independent unless marked; commit per step, run
  `./scripts/check.sh` after each step that touches Dart or scripts used by it.

## Environment facts learned the hard way

- `flutter` (Homebrew, `/opt/homebrew/bin/flutter`) must write
  `/opt/homebrew/share/flutter/bin/cache/engine.stamp`; inside the Claude Code
  sandbox it fails with "Operation not permitted". Run flutter/gradle/adb
  commands unsandboxed.
- `adb` is **not on PATH**: `~/Library/Android/sdk/platform-tools/adb`.
  `scripts/common.sh` has `resolve_adb_bin`; reuse it.
- `aapt2`: `~/Library/Android/sdk/build-tools/35.0.0/aapt2` (also 34.0.0).
  `keytool` is on PATH.
- The prepare script requires a **1080x2400** emulator. The only such AVD is
  `Pixel7_EN` (`~/.android/avd/Pixel7_EN.avd/config.ini`). Boot with
  `EMULATOR_HEADLESS=1 ./.devtools/android_boot_emulator.sh Pixel7_EN`
  (prints the serial, e.g. `emulator-5556`).
- On 2026-10-20 `Pixel7_EN` had only ~450 MB free on `/data` (5.8 GB, 93 %
  used; `pm trim-caches` freed nothing). Installed 3rd-party packages:
  `com.niduna.currency_converter` (legacy) and
  `com.honestfern.currency_converter`. Installing the debug APK for store
  screenshots failed with `INSTALL_FAILED_INSUFFICIENT_STORAGE`.
- Play credentials path is only written in ignored `AGENTS.local.md`
  ("Key file: `/…json`"). Session used:
  `export GOOGLE_APPLICATION_CREDENTIALS=$(grep -o '/[^\` ]*\.json' AGENTS.local.md | head -1)`.
- Production AdMob IDs are public in `RELEASE_CHECKLIST.md` § "B4 — Real
  AdMob IDs" (app `ca-app-pub-1525645598421616~2391849252`, banner
  `…/6412809148`, rewarded `…/7452604243`). They are not secrets (they ship in
  the manifest) but are intentionally kept out of source defaults.
- Expected upload certificate SHA-256 (codes 10 and 11):
  `80:8C:FB:19:B2:98:36:B7:9E:82:99:E3:AC:03:C6:20:B6:C9:DF:79:DF:20:B0:6C:9F:5F:F9:13:92:5C:F7:61`.
- Receipts of the reference run:
  `.tmp/play-candidate/20261020-build11b/` (plan.json, upload.json,
  status-before.json, status-after.json, upload.log). Prepare log:
  `.tmp/prepare-build11b.log`. Failed first attempts: `.tmp/prepare-build11.log`.

## Timeline of what went wrong (build 11, 2026-10-20)

1. `./scripts/bump_version.sh` → `sed: 1: "pubspec.yaml": extra characters at
   the end of p command`. Version was bumped by hand with `sed -i ''`.
2. `./scripts/check.sh` had **4 stale failing tests** (fixed in `e7caca6`).
   They had been red since `0b6326a`/`6990795`/`b28e9e6` (2026-10-19). Build 10
   was prepared without running tests (`candidate.json`: `"automatedTests":
   "not run"`), so nobody noticed.
3. `prepare_play_candidate.sh` (attempt 1) → refused: `/data` 463540 KiB free,
   needs 1500000. Overrode with `PLAY_PREP_MIN_DATA_FREE_KIB=400000`.
4. Attempt 2 → ran full `check.sh` (~1 min), then `build_apk.sh` failed:
   `Release AdMob config is incomplete while ADMOB_USE_TEST_ADS=false`.
   IDs were copied by hand from the checklist.
5. Attempt 3 → APK + AAB built, then `capture_store_screens.sh` failed
   (debug APK install, insufficient storage). Script aborted under `set -e`
   before printing checksums. Manifest/signature verification was then done
   by hand with `aapt2 dump badging`, `aapt2 dump xmltree`, `keytool
   -printcert -jarfile` and `shasum`.
6. `rm -rf` of a failed candidate dir was denied by the permission layer; a new
   dir `…-build11b` was used instead. Prefer unique dirs over deletion.
7. Play: `status`, `plan-closed`, `upload-closed`, `status` all worked first
   time (good — no change needed in `google_play.py`).
8. Docs: release state had to be edited in `AGENTS.md`,
   the runbook and (normally) `RELEASE_CHECKLIST.md` by hand.

---

## Step 1 — Release env file loaded automatically, checked first (P1)

**Files:** `scripts/common.sh`, `.devtools/prepare_play_candidate.sh`,
`scripts/build_apk.sh`, `scripts/build_appbundle.sh`, `.gitignore`,
new `.env.release.example`.

Current: `require_android_release_admob_config` (common.sh ~line 126) only
checks env vars; nobody sets them. It is called inside `build_apk.sh` /
`build_appbundle.sh`, i.e. after `check.sh` already ran in the prepare script.

Do:
1. Add `load_release_env()` in `common.sh`: if `${RELEASE_ENV_FILE:-$repo_root/.env.release}`
   exists, `set -a; source it; set +a`. Never echo values. `.gitignore`
   already ignores `.env.*` (line 75) — verify `.env.release` is matched and
   add `!.env.release.example`.
2. Commit `.env.release.example` containing the three `ADMOB_ANDROID_*` keys
   with the production values from the checklist (they are public) and a
   comment that real secrets must never go there. Ask Luis whether to just
   create `.env.release` from it locally (agent may create it; it is not a
   secret) — or whether `.env.local` already holds these (do not read it
   without asking).
3. In `prepare_play_candidate.sh`, right after the clean-tree/version checks
   and **before** `check.sh`: call `load_release_env` and
   `ADMOB_USE_TEST_ADS=false require_android_release_admob_config`.
4. Also validate the format: app ID matches `^ca-app-pub-[0-9]+~[0-9]+$`,
   unit IDs `^ca-app-pub-[0-9]+/[0-9]+$`, and that none equals Google's test
   IDs (`ca-app-pub-3940256099942544…`).

Accept: with `.env.release` absent, prepare fails in <5 s with a message
naming the file; with it present, prepare passes the config step without any
exported vars.

## Step 2 — Screenshots optional; space check only when needed (P1)

**File:** `.devtools/prepare_play_candidate.sh` (screenshots block ~line 85,
space check ~lines 45-56, checksum block ~line 93).

Do:
1. New flag `PLAY_PREP_SCREENSHOTS=${PLAY_PREP_SCREENSHOTS:-0}` (default **off**;
   the listing rarely changes and screenshots have their own
   `capture_store_screens.sh` / `google_play.sh screenshots` flow).
2. When off: do not require an Android device at all, skip the 1080x2400 and
   `/data` checks. When on: keep the current checks (1.5 GB is justified: the
   debug APK install failed at 450 MB).
3. Make the checksum block hash only files that exist (`find … -type f` then
   `shasum`), so a missing screenshot never hides the AAB hash.
4. Optional helper `.devtools/android_free_space.sh <serial>`: print `/data`
   usage and list 3rd-party packages; offer (never auto-run) uninstalling
   `com.niduna.currency_converter` (legacy package). Wiping the AVD is
   Luis's decision.

Accept: `EXPECTED_VERSION_CODE=<n> ./.devtools/prepare_play_candidate.sh`
succeeds with no emulator running and prints AAB/APK SHA-256.

## Step 3 — Automatic artifact verification + candidate.json (P1)

**Files:** new `.devtools/verify_play_artifact.sh` (or Python under
`stores/google-play/scripts/verify_artifact.py`, consistent with the existing
CLI; prefer Python, no extra deps), called at the end of the prepare script;
`stores/google-play/apps/currency-converter.json`.

Add to the app JSON:
```json
"uploadCertificateSha256": "80:8C:FB:19:B2:98:36:B7:9E:82:99:E3:AC:03:C6:20:B6:C9:DF:79:DF:20:B0:6C:9F:5F:F9:13:92:5C:F7:61",
"admobAndroidAppId": "ca-app-pub-1525645598421616~2391849252"
```

The verifier must check (exact commands that worked on 2026-10-20):
- `aapt2 dump badging <apk> | head -1` → `package: name='com.honestfern.currency_converter' versionCode='<expected>' versionName='<pubspec name>'`.
- `aapt2 dump xmltree --file AndroidManifest.xml <apk>`: no
  `android:debuggable` set true; meta-data
  `com.google.android.gms.ads.APPLICATION_ID` equals `admobAndroidAppId`.
- `keytool -printcert -jarfile <aab>` SHA256 line equals `uploadCertificateSha256`
  (also for the APK if signed with the same key).
- The APK and AAB come from the same source commit (record `git rev-parse HEAD`
  before building; fail if HEAD/tree changed during the run).

Then write `<output_root>/candidate.json` automatically, same shape as the
hand-written `.tmp/play-candidate/20261019-build10/candidate.json`, but with
`"automatedTests": "passed (<count>)"` taken from `check.sh` output, the
cert SHA-256, sizes, hashes, commit, versionName/code, config flags, and
`"screenshots": "skipped"|"captured"`.

Accept: running prepare yields `candidate.json` without manual work; a
deliberately wrong expected cert makes it fail.

## Step 4 — Fix `scripts/bump_version.sh` (P1)

Current bugs:
- `sed -i "s/…/"` (GNU syntax) fails on macOS BSD sed.
- Writes `lib/src/app_info.dart`, which no longer exists (version is read
  elsewhere; grep `AppInfo` / `package_info` first to confirm nothing needs it,
  and do not recreate the file unless something imports it).
- `git add` + `git commit` automatically (surprising; mixes with other work).

Do:
1. Use a portable edit (e.g. `python3 - <<EOF` or `perl -pi -e`), updating only
   the `^version:` line.
2. Keep version name by default: `build` mode = `X.Y.Z+N → X.Y.Z+(N+1)`
   (repo policy: name stays `1.0.0` for the first public release).
3. Optional `--check-play`: refuse if the new code is already used on Play.
   `plan-closed` cannot be used here (it needs an AAB), and track `status`
   alone is not enough: `plan-closed` reported `usedBundleCount: 8`, and
   bundles uploaded but not on a track still consume codes. Add a read-only
   subcommand `max-version-code` to `stores/google-play/scripts/google_play.py`
   that lists all bundles + track releases (the upload path already does this
   for its reuse check — reuse that function) and prints the max code.
4. No auto-commit; print the suggested commit command instead.
5. Also fix stale docs: `CLAUDE.md` line 60 says "Version stays `0.x.x` until
   MVP is explicitly confirmed" — false since 1.0.0; replace with a pointer to
   `AGENTS.md` § "Versioning policy". `CLAUDE.md` line 11 says the site is "on
   Vercel, auto-deploys on push to main" — false; production is the Hostinger
   VPS, deployed by `/root/bin/deploy-honestfern.sh` over SSH.

Accept: `./scripts/bump_version.sh` on macOS changes only `pubspec.yaml`
from `+11` to `+12`, no commit made.

## Step 5 — Play credentials without grepping AGENTS.local.md (P2)

**File:** `.devtools/google_play.sh` (credential block at the end).

Do: if `GOOGLE_APPLICATION_CREDENTIALS` is unset, source
`${repo_root}/.devtools/google_play.local.env` when it exists (gitignored;
add to `.gitignore`) containing only
`GOOGLE_APPLICATION_CREDENTIALS=/abs/path/to/key.json`. Keep the existing
error text otherwise. Ask Luis before creating the local file (it reveals a
private path, but no secret; it's acceptable for the agent to create it from
`AGENTS.local.md` with his OK). Never print the key contents.

Accept: `./.devtools/google_play.sh status` works in a fresh shell.

## Step 6 — Catch stale tests early (P2)

Build 10 shipped with 4 red tests nobody saw. Options (ask Luis which; both
are cheap):
- **Local pre-push hook** (`.githooks/pre-push` + `git config core.hooksPath
  .githooks`, documented in AGENTS.md): run `./scripts/check.sh`; skip with
  `SKIP_CHECK=1`. Note check.sh takes ~1 min.
- **GitHub Actions** (`.github/workflows/check.yml`, none exists today):
  `subosito/flutter-action` pinned to the repo's Flutter version, run
  `flutter pub get && flutter analyze && flutter test --concurrency=1`. The
  repo is `LuisCharro/niduna-currency-converter`.

Also make `prepare_play_candidate.sh` refuse `automatedTests` = skipped (it
already runs check.sh; just ensure no flag bypasses it).

## Step 7 — One guided command for a Closed release (P2, after 1-5)

New `.devtools/release_closed.sh`:
1. Require clean `main`, up to date with `origin/main` (`git fetch` + compare).
2. Read version code from pubspec; verify unused (Step 4 helper).
3. Run prepare (Steps 1-3) into `.tmp/play-candidate/<YYYYMMDD>-build<code>`
   (append `-b`, `-c` if it exists — never delete old dirs).
4. Run `google_play.sh plan-closed --aab … --version-code … --output …/plan.json`.
5. **Stop.** Print artifact path, size, SHA-256, track `alpha`, release name,
   and the exact upload command. Exit 0. (The agent asks Luis; Luis's
   approval message must name the SHA-256 or say "build <code>" explicitly.)
6. Separate subcommand `release_closed.sh upload <candidate-dir>`: re-hash the
   AAB, compare with plan.json, run `upload-closed --output …/upload.json`
   then `status --output …/status-after.json`, and print a summary block
   ready to paste into the runbook (Step 8).

Remember `upload-closed` uses `changesInReviewBehavior="ERROR_IF_IN_REVIEW"`
(`stores/google-play/scripts/google_play.py` ~line 382) and that a track
commit also submits any already-saved Console changes (see SKILL.md
"Latest build-9 lessons"). The stop in step 5 must remind to check Console
Publishing overview first.

## Step 8 — Single release-state file (P3, docs)

Release state today is duplicated in `AGENTS.md` ("Current state", "Versioning
policy"), `RELEASE_CHECKLIST.md` (1300+ lines), the runbook (500+ lines),
`AGENTS.local.md`, and the site's `AGENTS.md` (which still says build 9 is
current, lines 5-7). Each release step needed 3+ manual edits.

Do:
1. Create `RELEASE_STATE.md` (short, ≤40 lines): current tracks (code per
   track), last candidate dir + SHA-256, acceptance status, pending Console
   items, next gate. Everything else links to it.
2. Have `release_closed.sh upload` print (or optionally append) the new state
   block; the agent pastes it and commits.
3. Replace "Current state" blocks in `AGENTS.md` and the site `AGENTS.md`
   with a link + one-line summary. Move historical per-build sections of the
   runbook to `docs/release-prep/history/` if Luis agrees (don't delete).

## Current state when this plan was written

- Play `alpha` = `1.0.0 (11)` (SHA-256 `c39022153281a229e0faa0bc73fd786c3393967a99f6e22a78396bc892c5a98c`),
  `internal` = 7, `production` empty. Code 11 awaits Google review + owner
  phone acceptance. Commits: `716ac17` (copy), `e7caca6` (tests), `d22a64d` (docs).
- No tooling changes from this plan have been made yet.
