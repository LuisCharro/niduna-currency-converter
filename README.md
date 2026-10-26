# Currency Converter

## Current release status — 2026-10-26

- **Public Android release:** Currency Converter **1.0.0 (11)** is live on
  Google Play in **EU27 + Switzerland**. Submission 7 was published on
  **22 October 2026 at 07:27** (Console time); the public listing was verified
  on 26 October. This supersedes older In review / Coming Soon checkpoints.
- **Website:** the launch copy, availability badges and Google Play download
  links are deployed at https://honestfern.com/ and
  https://honestfern.com/currency-converter/. Site commit **`8773a22`** was
  deployed on **26 October** via the existing VPS script. All five HTML
  routes, CSS, OG image, app-ads.txt and security.txt returned HTTP 200 with
  bytes matching the local release. Nginx and OpenClaw remained active.
  Later documentation commits are not new website deployments.
- **Android update in review:** **1.0.1 (12)** from app source **`272e07d`**
  was published to Closed Alpha on 26 October; Luis installed it through Play
  and reported that it works. The exact tested bundle was promoted to the
  existing 28-country Production track with a 100% rollout and the en-GB note
  “Small usability improvements and minor fixes.” Console Submission **9**
  shows **In review**, submitted 26 October at 15:34 (Console time). Managed
  publishing is off, so approval may publish it automatically. The public
  version remains **1.0.0 (11)** until publication is verified. See the app
  release checklist and publishing runbook for artifact and submission receipts.
- **AdMob:** existing app linked to Google Play on 26 October; last observed
  status Getting ready / Review in progress, limited ad serving. app-ads.txt
  is verified; Policy centre showed no current issues. Await review outcome.

Older dated checkpoints below are historical evidence, not current release
instructions. Recheck live services before a new release operation.


## Historical: Latest Production submission — 2026-10-20

Production **1.0.0 (11)** and **EU27 + Switzerland** country additions were
submitted with Luis's authorization. Refreshed Console confirms **Changes in
review** after the API commit; **Submission 7**, source API, status In review
(20 October, 11:31 am as displayed in Console). Quick checks finished.
Managed publishing is **off**: approval may
publish automatically. Public availability is not yet confirmed. Do not cancel
or resubmit; inspect the app release plan/checklist for receipts and later status.
Six non-euro EU markets now have the approved local prices, independently
verified. Keep website Coming Soon until actual public availability is checked.
Older prepared/not-submitted records below precede this submission.

Privacy-first Flutter currency converter for the Honest Fern portfolio.

**Android MVP release** | Android first, iOS later | No account, no first-party analytics, no backend.

## Historical: Current release checkpoint — 2026-10-20

`1.0.0+11` is the current Closed Alpha candidate. Its recorded upload and
Google/local artifact hashes match. Luis reports a fresh installation on his
physical Android and successful general use of build 11. Refreshed Console
confirms Closed 11 and the description/Data safety changes Published; this is
not a Production release. Detailed build-10 Billing checks remain historical.
Internal remains code 7. Production now has an unsubmitted draft using the same
code-11 library artifact. EU27 + Switzerland is owner-confirmed and saved;
release and countries await review submission. See the EU distribution decision record for rationale and
Google territory groups. Reviewer access remains uncertain; final sending and
publication need owner instruction.
See `RELEASE_CHECKLIST.md` and `docs/release-prep/google-play-publishing-runbook.md`
for the exact artifact, receipts and remaining reviewer-access/country decisions.
The website deployment session records revision `e181347` (including terms).
Keep Coming Soon until Production is public. The tooling friction plan under
`docs/superpowers/plans/` is a backlog, not implemented release automation.

## What's in the Android launch scope

- 45 currencies total — 34 fiat + 11 crypto (USD, EUR, GBP, JPY, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON, CAD, AUD, MXN, BRL, ARS, CLP, COP, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR, TWD, NZD, CNY, TRY, AED, ILS, ZAR + BTC, ETH, SOL, XRP, ADA, DOGE, AVAX, USDT, USDC, BNB, POL); source of truth: `lib/src/core/currency/supported_currencies.dart`
- Multi-currency conversion view (type one amount, see all conversions)
- Four-tab shell: Convert, Favorites, Chart, and Settings
- Historical charts (up to 2 years, unlimited free)
- Favorites (3 free; temporary rewarded boost to 6; Favorites Pro up to 16)
- Offline mode (cached rates, no network required)
- Dark mode (free in 2026 — do not charge for this)
- Banner ads plus user-initiated rewarded ads for temporary unlocks
- Three one-time IAPs: Remove Ads (2 CHF in Switzerland), Charts Pro (3 CHF),
  Favorites Pro (1 CHF); localized prices come from Play Billing. No launch subscription

**Not in the Android launch:** metals (XAU/XAG), push notifications,
backend, accounts, subscriptions, or real-time/intraday rates.

**Future backend direction (post-release, not current scope):** OXR Developer
will be the planned hourly-fiat upstream ($12/month or $120/year). The OXR App
ID stays on the Hostinger VPS, where a worker pulls, validates and stores the
rates. A public Honest Fern API under `honestfern.com/currency/` then serves
those stored results to this app and future Honest Fern apps. The mobile app
must never contain the OXR credential and will keep its current providers as
fallbacks. **No CoinGecko: the crypto track was closed on 2026-09-06 — crypto
stays on fawazahmed0 (CC0, daily, direct)** for launch. Its only material risk
is that the dataset stops updating (2026-10-20 decision, see
`docs/providers/fawazahmed0.md`). Once the app earns revenue, the same VPS API
can also serve crypto from a paid, licensed subscription (key held only on the
VPS, attribution as the vendor requires), removing that dependency.

## Core app docs

| Doc | Purpose |
|-----|---------|
| `DEFINITIONS.md` | Product definition, competitive study, API strategy, pricing decisions, phase roadmap |
| `ROADMAP.md` | Delivery order, screen contracts, API/cache contracts, vertical slices |
| `PLAN.md` | Development plan, navigation structure, file layout, Phase 1 TODO |
| `AGENTS.md` | Agent instructions, skills, verification rules, modularity rules |
| `agent/README.md` | Repo-specific guidance, commands, iOS simulator notes |
| `docs/FEATURE_IDEAS.md` | Ranked post-launch feature backlog from competitive research (v0.2+) |

## UI Guidance Resources For Agents

These resources are already present in the repo and should be consulted for
mobile UI decisions before large layout changes:

- `./.agent-local/skills/mobile/mobile-ui-review.SKILL.md`
- `./.agent-local/skills/mobile/flutter/flutter-small-screen-ui.SKILL.md`
- `./.agent-local/skills/mobile/references/native-platform-ui-notes.md`
- `./.agent-local/skills/mobile/references/store-ui-readiness-checklist.md`

Use them together with `ROADMAP.md` and `AGENTS.md` when deciding interaction
patterns, top-of-screen density, and touch-target/accessibility constraints.

When a future task involves Stitch:

- use the mobile/UI skills first to refine interaction and constraints
- then use `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md`
  to generate or iterate screens with better prompts and clearer acceptance
  criteria

## Development phases

| Phase | Goal | Trigger |
|-------|------|---------|
| **Phase 1 (MVP)** | Free + ads + one-time Remove Ads | Now |
| **Phase 2** | OXR-backed VPS service + subscriptions (rate alerts, hourly refresh, optional crypto API strategy) | ~2,000 DAU |
| **Phase 3** | Crypto charts + metals (XAU/XAG) + extensions | After Phase 2 |

See `DEFINITIONS.md` → Phase Roadmap for full details.

## Data sources

| Source | Use | Auth |
|--------|-----|------|
| Frankfurter v2 (`api.frankfurter.dev`) | Blended fiat latest/history | No API key |
| fawazahmed0 / exchange-api | Release crypto latest/history via jsDelivr/Cloudflare | No API key |
| Local cache | Fiat rates, chart data, favorites, settings | SharedPreferences |

Current licensing evidence, disclosure recommendations and the 2026-10-20
crypto-source risk decision (availability risk only) are recorded in
[`2026-10-19 data/disclosure review`](docs/release-prep/data-licensing-and-disclosure-review-2026-10-19.md).
Provider profile names are not a legal certification.

## Quick start

```bash
flutter pub get
flutter run
```

## Verification

```bash
./scripts/check.sh
```

If Flutter is not on `PATH`:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

## iOS smoke test

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

## Screenshot capture

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh
```

## Machine setup on a new Mac

Expected tools:

- Xcode with iOS Simulator
- Android Studio with Android SDK and Emulator
- Flutter SDK
- CocoaPods for iOS plugin builds

Recommended install path:

```bash
brew install --cask flutter
brew install cocoapods
```

Then confirm the toolchain:

```bash
open -a Simulator
xcode-select -p
flutter doctor -v
```

Accept Android licenses when prompted:

```bash
flutter doctor --android-licenses
```

If an older build used a different Flutter SDK and iOS builds fail with stale SDK-path errors, regenerate:

```bash
flutter clean
flutter pub get
```

## Product constraints

- privacy-first: no Honest Fern account, no first-party analytics, no backend;
  AdMob collection/sharing is disclosed and requires UMP/privacy controls
- offline only in Phase 1
- no backend
- no login
- no cloud sync

## Run scripts reference

| Script | What it does |
|--------|-------------|
| `./scripts/check.sh` | analyze + test |
| `./scripts/analyze.sh` | static analysis only |
| `./scripts/test.sh` | unit tests |
| `./scripts/build_apk.sh` | Android release APK |
| `./scripts/build_web.sh` | Flutter web build |
| `./scripts/pub_get.sh` | fetch dependencies |
| `./scripts/clean-deep-files.sh` | deep clean build artifacts |

## Historical: Current phase (reviewed 2026-09-30)

Read `RELEASE_CHECKLIST.md` **Latest operational truth — 2026-09-30** first,
then `docs/release-prep/google-play-publishing-runbook.md`. Internal and Closed
Alpha serve `1.0.0+7`; Closed is available to selected testers in Spain and
Switzerland. The 20-email list is selected; invitations are planned for
2026-10-01, not yet recorded as sent. Email eligibility is not Closed opt-in.

Next: share the Closed acceptance link, verify Dashboard opt-ins/eligibility,
gather real feedback and complete the 12-testers/14-days gate. Licence testing
is separate: only a one-account list is enabled, and its mobile test payment
instrument remains unverified. Other cohort purchases may charge real money.
No Production release yet; the website remains Coming Soon. Production access,
final monetisation QA, release approval and the site launch batch remain later.
