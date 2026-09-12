# Honest Fern Currency Converter — Brand and UI refresh

> **Status:** Phase 1 accepted; Phase 2 SOL/COP badge batch completed locally;
> Phase 3 UI polish committed as `c08ec70`. This work targets the next
> closed-test candidate and does not
> authorize a version bump, Play upload, merge, or store submission.

## Goal

Give Currency Converter a clearer, more distinctive Honest Fern identity while
preserving the release-tested product behavior. Work in reviewable phases and
keep every visual change reversible.

## Fixed boundaries

- Android remains the first release platform, but the canonical icon pipeline
  must regenerate valid iOS assets for the later App Store release.
- Do not change rates, providers, billing, ads, consent, storage, navigation, or
  feature limits as part of this visual cycle, except the approved Chart
  presentation and control-placement refinements recorded in Phase 3.
- Do not add OXR/VPS, CoinGecko, accounts, analytics, or backend work.
- Do not overwrite canonical brand assets until a proposal has been inspected
  at full size and launcher size.
- Use one coherent product mark for the launcher and splash. The splash may
  simplify the mark, but it must not introduce a second logo.

## Phase 1 — App icon and splash

### Problem

The current double-rim coin and opposing arrows communicate conversion, but the
heavy rings feel generic and dated. The mark has little connection to Honest
Fern and becomes visually busy at small launcher sizes. The splash repeats the
same heavy coin.

### Direction

Explore a simple product mark that combines exchange motion with the Honest
Fern botanical language. Prefer two curved leaves or fronds forming a balanced
exchange loop. Retain the brand palette:

- forest `#285F3B`;
- warm paper `#F6F8EF`;
- moss `#6F8C49`;
- at most one small amber or coral accent.

Avoid currency symbols, letters, gradients, gloss, shadows, thin strokes,
detailed foliage, text, and financial-growth-chart imagery. The icon must read
as a utility for exchange, not trading or banking.

### Exploration and selection

1. Generate three distinct vector-friendly square concepts as non-canonical
   proposal files.
2. Inspect each at 1024, 192, 96, and 48 px and through an Android adaptive-icon
   safe-zone mask.
3. Select one direction with Luis; make only targeted refinements after that.
4. Rebuild the winning artwork as clean canonical SVG rather than shipping
   uncontrolled raster details.
5. Derive `app_icon.svg`, `app_icon_foreground.svg`, and `splash_mark.svg` from
   the approved geometry.
6. Run `scripts/generate_brand_icons.sh` to regenerate Android, iOS, web,
   macOS, and Windows outputs.

### Acceptance

- Recognizable at 48 px with no blurred or merged details.
- Looks balanced under Android circle, squircle, and rounded-square masks.
- Foreground stays within Android's adaptive safe zone.
- iOS 1024 icon is opaque and contains no platform mask baked into its corners.
- Android 12 light/dark splash and legacy Android splash show the same mark at
  an intentional scale; iOS launch screen uses the matching transparent mark.
- No embedded text or legacy Niduna identity.
- `./scripts/check.sh` passes and Android release-safe build launches.
- Final launcher and splash are inspected on the large emulator and one small
  Android configuration before acceptance.

### Exploration record — 2026-09-11

OpenAI's built-in image generator produced four independent concepts plus one
targeted refinement under `assets/brand/proposals/openai-20260911/`. None is a
canonical or shippable asset yet.

- **A — Circular fronds:** strongest immediate beauty and small-size balance;
  circular exchange motion is clear, though it could be mistaken for a general
  sustainability/wellness mark without a directional refinement.
- **B — Botanical swap:** clearest conversion meaning, but too close to generic
  swap arrows and the coral pivot lacks a necessary semantic role.
- **C/C2 — Split pod exchange:** strongest relationship to Honest Fern and most
  proprietary silhouette; the exchange meaning needs refinement and the
  generated tonal shading must be removed in the final SVG.
- **D — Opposing leaf directions:** very legible conversion cue, but still too
  literal and generic to be the preferred identity.

The A/C2 comparison was superseded by the coin-first direction below.

### Direction correction — 2026-09-11

Luis's review found the first round too botanical and asked for a visible gold
coin. That supersedes the A/C2 recommendation above. The revised hierarchy is:

1. unmistakable gold coin;
2. immediate two-way conversion symbol;
3. Honest Fern expressed mainly through forest/paper/moss color and calm form;
4. botanical detail optional and very small, never the main subject.

MiniMax `image-01` was used for three independent inspiration passes. Its third
composition — gold coin, circular exchange arrows, tiny center seed — supplied
a useful structure, but its glossy 3D finish and coffee-bean-like center are
not suitable production artwork. OpenAI then refined the coin direction in two
ways. Luis selected **F — modern gold swap** because the clean horizontal
two-arrow coin preserves instant category recognition and removes the plant
ambiguity. Its production form is deterministic SVG geometry with a restrained
gold gradient, one rim, a forest-green right arrow, and a warm-paper left arrow;
the generated PNG is inspiration only.

### Platform implementation — 2026-09-11

- Apple receives a full-bleed opaque square master without baked rounded
  corners; iOS applies the final launcher mask.
- Android receives separate adaptive background and transparent foreground
  layers, with the complete coin inside the central safe region. Pre-adaptive
  Android receives rounded and circular legacy rasters, and the manifest now
  declares the circular alternative through `roundIcon`.
- Android 12+ and legacy Android launch screens use dedicated transparent coin
  resources instead of embedding the full green launcher square.
- iOS uses the same isolated coin on a named launch background with light and
  dark appearances.
- `scripts/generate_brand_icons.sh` remains the single regeneration entry point
  for all derived launcher and splash assets.

### Phase 1 verification — 2026-09-11

- Canonical artwork regenerated successfully across Android, iOS, web, macOS,
  and Windows. Apple AppIcon outputs were checked and contain no alpha channel.
- `./scripts/check.sh` completed with clean analysis and all 244 tests passing.
- Android debug APK built, installed from a clean Medium Phone AVD, and launched
  successfully. The launcher icon and Android 12+ splash were inspected in
  light and dark mode; the complete coin remains visible and the splash has no
  nested launcher square.
- iOS simulator build completed successfully for iPhone 17 Pro. The system-masked
  launcher icon and matching light/dark launch screen were inspected directly.
- `xcrun ibtool` compiled the launch storyboard with no errors, warnings, or
  notices. Android XML and all canonical SVG sources passed XML validation.
- Review screenshots and launch video are temporary QA evidence under `.tmp/`;
  they are not store screenshots or release artifacts.

### Phase 1 closeout — 2026-09-11

Luis accepted the modern gold-swap coin after live Android and iOS review. The
launcher and splash assets are already part of the accepted predecessor commits;
do not regenerate or revisit them during the Phase 3 commit. The public website
icon refresh was completed separately by Luis.

## Phase 2 — Currency badges

Audit the 45 current badges at their real 32–48 px display sizes. Replace only
badges with an objective problem: wrong symbol or flag, blur, weak contrast,
inconsistent crop, or unreadable small-size detail. Preserve recognizable flag
meaning and use the repo's currency-badge generation/review workflow. Do not
regenerate the whole family merely to make it new.

### Phase 2 closeout — 2026-09-12

Luis accepted targeted replacements for only SOL and COP. SOL now uses a crisp
high-contrast Solana mark on a deep violet field; COP uses a centered `$` over
the correctly proportioned Colombian flag, replacing the misleading `COL$`.
Both assets remain 256×256 RGB PNGs and are masked by the existing
`CurrencyFlagIcon` `CircleAvatar`; no alpha conversion or widget change was
needed. The focused test, full `./scripts/check.sh`, debug APK build and visual
review passed. The detailed hashes, device/build provenance and remaining
compact-AVD automation limitation are recorded in
`phase2-currency-badge-audit-2026-09-11.md`. A3/A4 are closed without change;
no family-wide refresh, release version change, upload, commit or push follows
from this closeout.

## Phase 3 — UI polish

Capture Convert, Favorites, Charts, and Settings in light/dark mode after the
brand assets settle. Rank visible problems by user impact, then propose narrow
changes to hierarchy, spacing, icon consistency, empty/loading/error states,
and small-screen behavior. Explain each problem and proposed solution before
changing the interface. Keep the existing warm paper, forest, Manrope/Fraunces,
and dividers-not-cards system.

### Phase 3 closeout — 2026-09-11

The approved B1–B6 presentation batch is complete. It clarifies chart units and
signed deltas, fixes Android system-bar contrast, removes dangling Lens decimal
punctuation, improves Chart axis/readability and crypto density, makes temporary
chart-unlock markers track the restricted currency in either selector, and
consolidates the Chart swap action to the selector strip. The final header uses
the released space for the trend chip on wide layouts and wraps safely on compact
ones. No rate calculation, provider, billing, consent, entitlement persistence,
version, or release configuration changed.

`./scripts/check.sh` passed after the final UI adjustments. The latest locally
installed debug APK used `PROVIDER_PROFILE=release_safe` and
`APP_DEV_MODE=false`; its SHA-256 was
`bf9c21a938d2f27205de7b8d98d0a7ac25edf3498aace3f8153e881377d1e11c`.
Luis visually accepted the final Chart review on both large and small Android
emulators. The implementation is committed as `c08ec70`; B7 and unverified
loading/offline/accessibility matrices remain deferred rather than implicitly
accepted.

## Release integration

After the selected visual changes pass QA:

1. regenerate Play screenshots only if the visible application UI changed;
2. replace the Play launcher icon and any store asset that contains the old
   product icon;
3. synchronize the website's product icon, without changing unrelated images;
4. update the release checklist and record exact artifact hashes;
5. build with the next unused version code and test through Play before the
   closed-test clock starts.
