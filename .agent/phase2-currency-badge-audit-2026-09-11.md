# Phase 2 currency badges — reviewed implementation dossier

## Authoritative review — Astra, 2026-09-11

This section supersedes the historical audit retained below. Read it first.
Stream A owns currency badge artwork only; Stream B owns UI presentation.
Status: **A0, A1 and A2 completed; A3/A4 remain deferred.** Only the approved
SOL and COP canonical badges changed. The execution record below retains the
earlier generation-route stop condition and records the later approved completion.

Baseline: `codex/ui-freshness-and-brand-assets` at `f60ee97`.
Only this file and the companion Phase 3 document were untracked at review start.
Phase 1 launcher/splash work is accepted context; the website was updated by Luis.
Do not repeat those jobs. Public identity remains Honest Fern.

The primary reviewed current SOL/CLP/COP PNGs and the large-emulator captures.
A native **Luna Medium** worker independently checked support lists, routing,
generation tooling, and historical claims. The primary resolved its findings.
No generation, deployment, app-code changes, or asset replacement occurred in
that initial Astra review. The later execution record is authoritative for the
subsequent bounded work.

### Evidence and confidence

- Current installed app on `Medium_Phone`, `emulator-5554`: Android API 36,
  1080×2400 pixels, density 420, approximately 411×914 logical pixels.
- Installed metadata: version `0.1.0`, code `2`, last update
  `2026-09-11 12:02:14`. The installed bytes were not matched to HEAD;
  this is current-device evidence plus separately inspected current source.
- Old Pixel7 screenshots explicitly came from code 1. They are historical,
  not proof of current UI or build configuration.
- Current captures under `.tmp/screens/android/`: `astra-convert-165411.png`,
  `astra-convert-scroll-165433.png`, `astra-swipe-165507.png`, and
  `astra-lens-attempt2-165642.png` (despite its name, the last is the normal
  dark Convert screen, not an open Lens).
- Source artwork: `assets/icons/currencies/{sol,cop,clp}.png` inspected directly.
  Smallest-size acceptance of replacement artwork is still a future gate.
- Temporary screenshots may disappear. Preserve selected before/after evidence
  with the implementation handoff and update these references if moved.

### Corrections that change the work queue

| Historical assertion | Verified conclusion | Execution consequence |
|---|---|---|
| CLP contains `CLP$` and clips | Current `clp.png` contains a centered `$`; `CLP$` is runtime text, not artwork | Remove automatic CLP replacement |
| COP contains `COL$` | Confirmed in PNG; application uses `COP$` | Correct artwork identifier; do not change app currency definition |
| SOL is broken everywhere | Low contrast/readability is visible in reviewed surfaces, but the wordmark is present | Treat as P2 polish, not missing asset or P0 failure |
| No badge workflow exists | `.agent/skills/icon-generation/SKILL.md`, `.devtools/generate_currency_icons.sh`, prompt JSON and knowledge base exist | Reuse them; do not create a competing generator |
| Removing the BGN PNG falls back safely | Text fallback occurs only when no map entry exists; a mapped missing PNG is not this fallback | Never delete PNG while leaving its mapping |
| 32–48 px covers all sizes | `currency_chip.dart` uses radius 10: diameter 20 logical px; other call sites use radii 14–20 | Include 20 px identity-only inspection and current routed sizes |
| Matching region counts proves geography correct | Counts match; source lists AUD under Americas | Counts are not geography validation; grouping change is outside asset batch |
| Glyph-count taxonomy proves readability | Original categories mix one-, two-, three- and four-character symbols | Judge actual pixels, not that taxonomy |

Current inventory remains **45 supported currencies (34 fiat + 11 crypto),
46 PNGs and 46 map entries**, including unsupported BGN. Region membership
and support policy stay unchanged in this phase.

## Design decision and priority vocabulary

Keep the circular family, recognizable country/coin identity, and existing scale.
Keep good badges. Do not add the new launcher coin behind currency badges.
Use P1 for misleading identifiers, P2 for legibility/polish, P3 for optional cleanup.
No release-blocking P0 was established by this review.

Primary recommendation: prepare **SOL and COP**, separately reviewable.
SOL is visually weaker than neighboring BTC/ETH; COP's four-character artwork
is cramped and says `COL$`. A clean `$` with Colombian flag identity is the
preferred proposal, matching the strategy already used by CLP. Keep the adjacent
`COP` code as the unambiguous identifier. Do not change `supported_currencies.dart`.
SOL may use a more saturated field and recognizable mark, but a specific gradient,
deep-purple fill, or glyph-plus-wordmark combination is not mandatory. Avoid
crowding both a detailed logo and text into the same small circle.

## Executable batches for Terra

### A0 — evidence and generation preflight

**Status:** required prerequisite, no asset changes. **Owner:** Terra or Luna.
Read `AGENTS.md`, the icon-generation skill, `.agent/ICON_GENERATION_KNOWLEDGE.md`,
the relevant JSON entries, and the generator's current selection/deploy behavior.
Confirm the anchor exists and a generation route is available before a paid call.
Resolve provider-specific paths from the script: anchors currently live under
`.tmp/icon-v4/<provider>/best/usd.png`, not necessarily the generic skill path.
Record provider and original prompt entry before any prompt edit.
The skill records provider-specific paths; the active image-tool instructions
govern any actual generation. Do not silently substitute a paid API/provider.

Allowed inspection paths:

- `.agent/skills/icon-generation/SKILL.md`
- `.agent/ICON_GENERATION_KNOWLEDGE.md`
- `.devtools/generate_currency_icons.sh`
- `.devtools/currency_icon_prompts.json`
- `lib/src/shared/widgets/currency_flag_icon.dart`
- call sites found with `rg -n 'CurrencyFlagIcon' lib/src`

Acceptance: record the selected source/output paths, current hashes, actual logical
diameters and proposed generation route. Review original and candidate at
20, 28, 32, 34, 36, 40 and 48 logical px, plus source resolution, on light and
dark surrounds. At 20 px judge silhouette/identity; do not demand tiny text be
fully readable when the adjacent code supplies the identity.

Stop if the source asset differs from this review, the anchor is missing, or
the only available operation overwrites an unbounded set. Resolve the specific
preflight issue; do not regenerate the family to recover.

### A1 — SOL contrast and recognition

**Status:** completed 2026-09-12. **Dependency:** A0 and batch approval.
Problem: pale mint/purple interior and white wordmark lose visual strength beside
BTC/ETH at real Convert size. Mapping is correct (`currency_flag_icon.dart:53`).
No runtime fix is needed.

Allowed changes after approval: `assets/icons/currencies/sol.png`, the SOL entry
in `.devtools/currency_icon_prompts.json` if used, and this document's evidence.
Candidate/master files must have an explicit noncanonical location until selected.
Do not edit the shared badge widget to compensate for one weak asset.

Acceptance:

- SOL is recognizable in light and dark beside unchanged BTC/ETH/USDT.
- Centered mark, no clipped edges, no washed placeholder effect.
- Preserve family scale; no glossy rim, drop shadow or extra frame.
- Manual score at least 3.5/5 across sharpness, identity accuracy and clarity,
  with no individual correctness defect hidden by the average.
- Same PNG routing and canonical 256×256 dimensions; review all A0 display
  sizes including 20 logical px; no unrelated asset hashes change.

Verify Convert, Add currencies, a base selector, Favorites identity and Charts
pair selector where supported. Screens absent from the test state remain explicitly
unverified. One local asset replacement is not evidence of all-surface QA.
Stop after the bounded candidate attempt if it fails; record why before another
generation cycle. Human visual selection precedes canonical replacement.

### A2 — COP artwork identifier and fit

**Status:** completed 2026-09-12. **Dependency:** A0 and approval.
Evidence: current PNG clearly reads `COL$` across the circle; runtime symbol is
`COP$`. Hard clipping was not established in the new review and must not be
reported as confirmed. Preferred artwork uses `$` on a recognizable simplified
Colombian flag background. No CLP replacement is included.

Allowed changes: `assets/icons/currencies/cop.png`, COP prompt entry if used,
and this document. Acceptance: no `COL$`, centered readable symbol, correct flag
identity, no crop, same scale as CLP, and the adjacent app code remains COP.
Compare COP and unchanged CLP at the A0 sizes and in the picker in both themes.
Stop if the proposal needs a change to currency support, formatter or routing.

### A3 — optional BGN maintenance

**Status:** deferred, P3; no visual benefit. Run separately only if selected.
BGN is absent from supported codes but retained in mapping, flags, colors and
prompt definitions. Historical records may legitimately retain BGN references.

Minimal optional cleanup is the PNG plus matching map entry together. A broader
cleanup would additionally inspect `currency_flags.dart`, `currency_colors.dart`
and the prompt JSON; do not automatically sweep every historical mention.
Remove the map entry before or atomically with the PNG. If broad cleanup is
selected, list removed definitions and deliberately retained historical references.
First check whether persisted/legacy inputs can still request BGN. Acceptance:
supported-code routing remains complete; no mapped asset is missing; unknown-code
fallback still works; supported count remains 45. Stop on a compatibility concern.

### A4 — other badges

**Status:** deferred unless new measured evidence exists.
CHF, NOK/DKK, PLN/CZK/HUF/RON/IDR/AED, JPY/CNY, AUD/NZD and other crypto badges
are not an approved family refresh. Country recognition preferences alone do not
establish defects. Record the code, size, surface and specific failed criterion
before bringing one into scope. AUD's regional placement belongs to a separately
selected grouping task, not image generation.

## Integration and verification contract

The generator's `deploy_best()` loops over **all files in BEST_DIR**
(`generate_currency_icons.sh:492-516`). Do not run `--deploy` against an old populated
best directory for a two-asset task. `--one` writes to the provider's singles
directory, not automatically to best. After selection, resolve the exact approved
candidate path and resize that one file into its canonical 256×256 PNG using the
existing resize tooling, or inspect a best directory containing only the approved
set before deploying. Do not clear/repopulate an existing best directory to make
this convenient. Verify only intended PNGs changed.

Before acceptance: run the repo's `./scripts/check.sh`, inspect asset resolution,
rebuild/restart the explicitly selected Android device with `release_safe` and
`APP_DEV_MODE=false`, and inspect large plus compact layouts. Reuse one build for
A1/A2 if both selected; retain separate before/after evidence. Tests cannot judge
visual quality. Do not claim the current documentation review ran full app QA.

Record per batch: status, changed paths, before/after hashes, selected artwork,
device/build provenance, sizes reviewed, captures, checks, residual concerns and
Luis's acceptance. No version bump, upload, commit, push or website change follows
automatically. Stop if unrelated files change.

## Execution record — 2026-09-11

**A0 — completed, no asset change.** The inspected generator is
`.devtools/generate_currency_icons.sh`; `--one` writes only to
`.tmp/icon-v4/<provider>/singles`, while `--deploy` iterates every pre-existing
file in `<provider>/best`. The OpenAI anchor path existed at
`.tmp/icon-v4/openai/best/usd.png` (SHA-256
`8201452016242920955ffe82656fe59019de03de8b15133cf5f6406c73c06460`). The
current canonical asset hashes are recorded below. The runtime map and all call
sites still route through `CurrencyFlagIcon`; no code change is needed for either
proposed image.

**A1/A2 — stopped before candidate creation.** One bounded OpenAI anchor attempt
returned `429 credit_balance_exhausted`; it did not write a candidate or alter a
canonical asset. MiniMax quota returned `?`, so availability could not be
established. Per the batch stop condition, no provider was substituted, no retry
loop was run, and `--deploy` was not invoked. A usable funded/provider-confirmed
generation route plus visual selection is required before either SOL or COP can
advance. The JSON still has COP's historical `COL$` prompt value; it was not
edited because no image batch was produced.

**A1/A2 — completed, 2026-09-12.** MiniMax produced one temporary candidate
for each badge, both rejected for blur, halo and glow. The selected flat
alternatives were then generated as noncanonical sources, manually accepted by
Luis, and resized directly to the two intended 256×256 RGB PNGs. `--deploy`
was not run, so no pre-existing `best/` candidate could affect another asset.
COP's prompt is now aligned with the selected artwork: a single `$`, Colombian
flag proportions (yellow half; blue and red quarters), and an explicit ban on
`COL$`/`COP$` lettering. Changed canonical hashes are:

```text
SOL 42a1af56c0730971ff35f6d81c78e685711df2cec83b79ab887a76ae35f74d3b
COP 2c390cdd815b50964fb090ece2cb74beed1bdf9fb8ff53697f7756794751e4c8
```

`./scripts/check.sh` passed with clean analysis and 178 tests. A debug APK
with `PROVIDER_PROFILE=release_safe`, `APP_DEV_MODE=false` and test ads was
built and installed on both Android API 36 emulators. Visual evidence confirms
SOL in the large-emulator Convert list and COP in the compact-emulator Add
currencies selector (`.tmp/screens/android/badges-large-app-20260912.png` and
`.tmp/screens/android/badges-small-cop-20260912.png`). The compact AVD's
stylus overlay intercepted later text-field automation, so this is not claimed
as a complete every-surface or dark-theme asset matrix. No app code, routing,
currency support, version, upload, commit or push changed.

**A3/A4 — deferred unchanged.** No BGN cleanup or family-wide refresh was
attempted. This preserves supported-code and legacy compatibility scope.

**Cross-stream verification provenance.** The original UI build used for the
initial Stream B verification was source `f60ee97`, `release_safe`,
`APP_DEV_MODE=false`, with APK SHA-256
`e64f8e7a924245391696339f08441c59a32ba9a8f4b2b567b04265602b168620`.
Subsequent approved Chart UI work was rebuilt and installed over existing data
on both emulators; its final pre-commit APK SHA-256 is
`bf9c21a938d2f27205de7b8d98d0a7ac25edf3498aace3f8153e881377d1e11c`.
That UI implementation is committed as `c08ec70`. Neither artifact is evidence
of an asset replacement or a store candidate.

Current hashes (SHA-256, before changes):

```text
SOL c297959354fa8023cea902c796d703d49e9ffe025f68754f59cb7d2e6807f074
COP c6cc867c9e1d415f89b8b77e9e6520008192e33caf4711ccf087afaa982f767a
CLP 728ccd780588d8d038cfca11850245070c613cd2fed9379d61efb71a7004cdc9
```

## Historical audit — retained for provenance, not execution

The text below is the original six-pass material. Its claims and proposed order
are superseded by the review above, including its P0 labels, CLP claim, missing
workflow claim and all-surface claims. Do not implement from this appendix.

### Original title: Phase 2 currency badge audit — 2026-09-11

> **Status:** observations only. Pairs with `brand-and-ui-refresh-plan.md`
> Phase 2. **This is Stream A** — the icons / currency-badge work stream.
> Stream B (UI/UX) lives in `phase3-ui-remarks-2026-09-11.md`.
>
> **Method:** three independent passes.
>
> **Branch (2026-09-11):** `codex/ui-freshness-and-brand-assets` @ `f60ee97` (clean, plus the two untracked `.md` files in this folder).
> 1. **Asset pass** — rendered all 45 active badge assets at 32 px and
>    48 px via PIL on the laptop.
> 2. **Live-app pass** (×2) — captured on the Pixel 7 AVD at the **actual**
>    render sizes: ~36 px in the RATES list, ~44 px in the base-currency
>    picker + the Add currencies sheet. Both light + dark.
> 3. **Code pass** — read the badge widget (`currency_flag_icon.dart`),
>    the symbol/formatter (`convert_quote_builder.dart`), the
>    preferences store (`app_preferences.dart`), and the regional
>    grouping (`currency_groups.dart`).

## What the plan mandates (verbatim)

> *Phase 2 — Currency badges.*
> *Audit the 45 current badges at their real 32–48 px display sizes. Replace
> only badges with an objective problem: wrong symbol or flag, blur, weak
> contrast, inconsistent crop, or unreadable small-size detail. Preserve
> recognizable flag meaning and use the repo's currency-badge generation/
> review workflow. Do not regenerate the whole family merely to make it new.*

Five objective-problem categories. Recognisable flag meaning preserved. No
whole-family regen. Replace only the broken ones.

## Code-level confirmations

### Asset routing — confirmed broken-is-asset, not mapping

`lib/src/shared/widgets/currency_flag_icon.dart`:

```dart
static const Map<String, String> _assetMap = <String, String>{
  'USD': 'assets/icons/currencies/usd.png',
  ...
  'SOL': 'assets/icons/currencies/sol.png',
  ...
  'BGN': 'assets/icons/currencies/bgn.png',
};

Widget build(BuildContext context) {
  final assetPath = _assetMap[code.toUpperCase()];
  if (assetPath != null) {
    return CircleAvatar(
      backgroundImage: AssetImage(assetPath),  // the bug we're chasing
      ...
    );
  }
  // graceful fallback for unknown codes
  return CircleAvatar(child: Text(symbol, ...));
}
```

**Bug source for SOL: confirmed the asset.** `_assetMap['SOL']` resolves to
`sol.png`, which is a desaturated purple-to-teal gradient on near-white
background (per PIL inspection of full-size asset). The code is correct;
the asset is broken. ✅ Phase 2 P0 #1 confirmed.

**Orphan handling is robust**: if a code is missing from `_assetMap`, the
widget renders the `symbol` text on a `CircleAvatar`. So `bgn.png`
**removal is purely cosmetic** — `BGN` is in the map but unreachable
(neither supported nor used). Removing the asset from the asset folder
will not break anything rendered.

### Regional grouping — confirmed live

`lib/src/core/currency/currency_groups.dart` defines:

| Region | Codes | Count |
|---|---|---|
| Europe | EUR, GBP, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON | 10 |
| Americas | USD, CAD, AUD, MXN, BRL, ARS, CLP, COP | 8 |
| Asia Pacific | JPY, CNY, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR, TWD, NZD | 12 |
| Middle East & Africa | TRY, AED, ILS, ZAR | 4 |
| Crypto | (11 entries) | 11 |
| **Total** | | **45** |

Live capture of the "Add currencies" sheet (light + dark, this pass)
shows the section header counts exactly matching the source: `Europe (10)
Americas (8) Asia Pacific (12) Middle East & Africa (4) Crypto (11)`.
**No need to fix.**

## Inventory (verified against code, not file system)

| Source | Count |
|---|---|
| `supported_currencies.dart` — fiat + crypto | **45 active codes** (34 fiat + 11 crypto) |
| `assets/icons/currencies/*.png` (filesystem) | **46 files** — 45 active + 1 orphan (`bgn.png`) |
| `currency_flag_icon.dart` — `_assetMap` keys | **46 codes** — including `BGN` (orphan) |
| `pubspec.yaml` — bundle directive | `assets/icons/currencies/` wholesale (1:1 mapping, no per-asset entries) |
| Live render sizes (this pass) | **RATES list ≈ 36 px** (small), **picker / sheet ≈ 44 px** (large) |

### Codes by symbol type (from `supported_currencies.dart`)

**Single-glyph** (1 char, best at 32 px): EUR `€` · GBP `£` · JPY `¥` ·
CNY `¥` · INR `₹` · KRW `₩` · THB `฿` · PHP `₱` · TRY `₺` · ILS `₪` ·
USD `$` · CHF `Fr`

**Two-character** (fit at 32 px with care): SEK/NOK/DKK `kr` · PLN `zł` ·
CZK `Kč` · HUF `Ft` · RON `lei` · ZAR `R` · IDR `Rp` · MYR `RM` ·
CAD `CA$` · AUD `AU$` · MXN `MX$` · BRL `R$` · ARS `AR$` · SGD `S$` ·
HKD `HK$` · TWD `NT$` · NZD `NZ$` · AED `AED`

**Three-character** (clip-prone at 32 px): CLP `CLP$` · COP `COP$`

**Crypto**: BTC/ETH/DOGE/USDT use a glyph (`₿`/`Ξ`/`Ð`/`₮`) on the
asset. SOL/XRP/ADA/AVAX/USDC/BNB/MATIC use plain text on the asset.

### Code-level formatter (relevant for understanding what shows)

`lib/src/features/convert/domain/convert_quote_builder.dart`:

```dart
int _cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;  // ETH, SOL, XRP, ADA, AVAX, BNB, MATIC
}

String _formatAmount(double value, String code, int decimalPlaces) {
  final digits = isCryptoCurrency(code) ? _cryptoDigits(code) : decimalPlaces;
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}
```

⚠️ This is **intentional design**: crypto precision is fixed per coin and
ignores the user's `Decimal places` setting. The user's setting only
controls **fiat** precision. So the BTC/ETH/SOL rows in Convert showing
8/6/6 decimals is **not a bug** — the design intent is "crypto precision
is a coin property, not a user preference". The chart header using a
**different** formatter that ignores the setting too is the real bug —
see `phase3-ui-remarks-2026-09-11.md` P1 #3.

Audit artifacts (rendered today):

- `/tmp/openclaw/badges-32.png` — full set at floor size.
- `/tmp/openclaw/badges-48.png` — full set at ceiling size.
- `/tmp/openclaw/sol-256.png` — SOL asset at full source size (corner
  pixels `(254,254,254)` — near-white background, no alpha).
- `/tmp/openclaw/emu-shots-2/11-convert-dark.png` — Convert dark, RATES
  list ≈ 36 px circles.
- `/tmp/openclaw/emu-shots-2/12-add-currencies.png` — Add currencies
  sheet ≈ 44 px circles.
- `/tmp/openclaw/emu-shots-2/13-base-currency-picker.png` — Settings →
  Default base currency picker ≈ 44 px circles.
- `/tmp/openclaw/emu-shots-2/15-add-currencies-scrolled.png` — same
  sheet scrolled into crypto section.
- `/tmp/openclaw/emu-shots-2/23-euro-swiped-right-y.png` — Convert, EUR
  row in **swiped state**. SOL badge visible at the bottom of the
  list inside the scrim — same broken render.
- `/tmp/openclaw/emu-shots-2/25-longpress-euro.png` — Convert, EUR row
  in **long-press state** (Conversion Lens sheet). SOL row partially
  visible behind the scrim — same broken render.

The SOL bug is therefore observed in **every surface** the badge can
appear in (RATES list dark + light, picker both sizes, swiped,
long-press). One asset fix lands the bug fix on every screen at once.

## Asset-format observation (root cause for the SOL issue)

Every asset is RGB, no alpha, on a near-white background
(`(254,254,254)` corner pixels). Against brand paper `#F6F8EF`,
the white merges cleanly **only when the badge fills the cell**. When
a badge is internally desaturated (low contrast against its own white
surround), the whole badge visually fades. The pattern that works at
small sizes:

> **Solid saturated color + glyph, no white field inside the badge.**

BTC (`₿` on orange), ETH (`Ξ` on near-black), DOGE (`Ð` on gold),
USDT (`₮` on teal) all hold up. The broken SOL violates this pattern.

## Findings, prioritized

### 🔴 P0 — objective problems, replace the asset

1. **SOL (Solana)** — asset is a desaturated purple-to-teal gradient on
   a near-white background, with medium-weight "SOL" wordmark.
   Against brand paper at the RATES-list size the white field merges
   out, the gradient washes to lavender, and the result reads as an
   empty placeholder. **Confirmed live in light + dark**, and at the
   picker size (≈44 px circle) the same broken rendering persists
   (visible in `15-add-currencies-scrolled.png`). **Fix:** regenerate
   with the Solana brand glyph (three slanted rounded rectangles,
   gradient `#9945FF → #14F195`) on a deep purple solid field, white
   bold wordmark — mirroring BTC/ETH/DOGE/USDT.

2. **CLP (Chilean Peso)** — `CLP$` symbol overflows the badge boundary
   at both 32 and 48 px; the `$` clips against the outer edge.
   **Fix:** drop the country code, use just `$` (or `CLP`), keep the
   flag in the upper half / background.

3. **COP (Colombian Peso)** — `COL$` symbol overflows the badge
   boundary. Same shape of bug as CLP. **Fix:** same as CLP.

### 🟡 P1 — text dominates the badge (replacement candidate at RATES-list size)

4. **CHF** — plain "CHF" text on red. At RATES-list size (~36 px) the
   text reads but the Swiss-flag option is more recognizable. At the
   picker size (~44 px) it's acceptable. **Fix priority:** medium if
   CHF appears in the user's default RATES list; low otherwise.

5. **NOK / DKK** — both "kr" on similar-looking Nordic flags (red with
   crosses). At 32 px the cross detail is lost. At picker size the
   Norwegian blue+white cross inside red is distinguishable. **Fix
   priority:** low (acceptable at picker size; defer).

6. **PLN, CZK, HUF, RON, IDR, AED** — short obscure abbreviations that
   read as text-only at RATES-list size. Most visible if surfaced in
   the user's default RATES list. **Fix:** batch-regenerate as
   flag-dominant badges.

### 🟢 P2 — could improve, not blocking

7. **JPY vs CNY** — both red circles with `¥`. At picker size both
   readable; at 32 px both read. Acceptable.

8. **MXN** — Mexican flag with a generic `$` symbol. Acceptable.

9. **AUD / NZD** — Union Jack + stars. Acceptable.

10. **XRP / ADA / AVAX / USDC / BNB / MATIC** — text-only on coloured
    backgrounds. At picker size most are OK; SOL/MATIC still look weak.

### ✗ Cleanup

11. **`bgn.png` (Bulgarian Lev)** — confirmed orphan. Present in
    `currency_flag_icon.dart` `_assetMap` AND on disk, but `BGN` is
    removed from `supported_currencies.dart`. The widget never renders
    the asset (only supported codes are passed in). Removal is purely
    cosmetic — no rendered widget breaks. **Fix:** drop both
    `assets/icons/currencies/bgn.png` and the `'BGN':` line from
    `_assetMap`. One commit.

## Suggested order of work (Stream A — icons)

Each PR/commit per group. The plan requires "Explain each problem and
proposed solution before changing the interface" before each merge.

1. **P0 — SOL.** Single asset. Companion to the Stream B chart fix
   (the visible symptom is the same row).
2. **P0 — CLP / COP.** Two assets, one PR.
3. **P1 — CHF.** Single asset, only if surfaced in default RATES list.
4. **P1 — NOK / DKK.** Defer.
5. **P1 — Fiat text-only batch.** Defer.
6. **P2 — JPY/CNY visual differentiation.** Defer.
7. **P2 — Crypto brand-glyph batch.** Optional.
8. **Cleanup — `bgn.png` + `_assetMap` entry.** One commit.

## Workflow question (must be answered before scaling beyond ~3 replacements)

The plan calls out the "repo's currency-badge generation/review workflow"
but **no such workflow exists in the repo today**. Phase 1's
`scripts/generate_brand_icons.sh` is for the app icon pipeline
(`rsvg-convert` + `ImageMagick` + Dart helpers), not per-currency
badges.

Three paths forward — pick one with Luis before scaling:

| Path | Cost | Trade-off |
|---|---|---|
| Hand-craft each replacement | low (≤ 3 changes) | Doesn't scale; doesn't match the plan's "generation/review workflow" wording |
| New `scripts/generate_currency_badges.sh` | medium | Matches plan wording; needs SVG sources per currency |
| Outsource to prior-art badge set | low | Fastest; copyright / brand-accuracy risk |

For the immediate P0 (SOL), hand-craft is fine. The decision only matters
if we go past 3 replacements in this phase.

## What this third pass corrected

- **Confirmed**: SOL bug is the **asset**, not a code-side mapping.
  Found the exact line in `currency_flag_icon.dart:71`. The Flutter
  widget is correct; `sol.png` is broken.
- **Confirmed**: regional grouping counts in the live sheet match the
  source list (10+8+12+4+11 = 45).
- **Confirmed**: `bgn.png` removal is safe (graceful fallback in the
  widget, and nothing renders it anyway).
- **Reframed**: my earlier pass 3 finding "BTC/ETH/SOL ignore Decimal
  places" → **not a bug** (intentional in `convert_quote_builder.dart`).
  The chart header's 6-decimal output **is** a bug — separate path,
  separate fix in Stream B.
- **Reframed**: most P1 "text dominates" findings are only a problem
  at the RATES-list size (~36 px). The picker (~44 px) shows most
  flags readably. The audit grid I rendered at 32 px and 48 px
  bracketed the full plan range; the 32 px edge was harshest.

### Pass 5/6 (this round)

- **SOL badge observed broken in the picker** (Add currencies sheet,
  ≈44 px circle) — same broken render as the RATES list. Already
  called out in the artifacts block above.
- **SOL badge observed broken in the swipe-to-reveal state** of the
  EUR row (third capture, with scrim). One asset fix lands on every
  surface.
- **Code confirmed**: `currency_flag_icon.dart:71` maps `SOL` to
  `assets/icons/currencies/sol.png`. `_assetMap` is a const map; the
  mapping is correct. **Asset is the bug.**
- **Code confirmed**: `currency_flag_icon.dart` has a graceful fallback
  (renders `Text(symbol)` on `CircleAvatar`) for any code NOT in the
  map. **Removing the `BGN: '...bgn.png'` map entry** is safe and
  cosmetic — no rendered widget depends on it.

## Notes

- Captured APK is the older `0.1.0+1` debug build, not `0.1.0+2`. The
  audit was done by rendering source PNGs + re-capturing the live app
  on the Pixel 7 AVD.
- Companion file: `phase3-ui-remarks-2026-09-11.md` (Stream B).
