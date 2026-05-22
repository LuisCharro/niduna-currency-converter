# App Icon Generation — MiniMax First, OpenAI Final

> Purpose: improve the Niduna Currency Converter launcher icon without spending OpenAI money on broad exploration.
> Use MiniMax for concept search, shortlist manually, then run one paid OpenAI pass only after the direction is clear.

---

## Current Icon Diagnosis

The current app icon communicates currency exchange, but it still feels closer to generic fintech/travel utility than the current Niduna app identity.

### Keep

- Clear currency/exchange idea
- Strong simple composition
- Rounded mobile-app friendliness

### Improve

- Replace cold blue fintech palette with Niduna warm paper, forest, moss, and coral
- Remove tiny airplane/path details; they disappear at launcher size
- Avoid overlapping transparent shapes that become muddy at small sizes
- Create a stronger one-glance silhouette
- Make it feel like a premium warm finance instrument, not a travel-card app

---

## Icon North Star

**A warm, premium currency instrument mark for Niduna.**

It should feel:

- crafted
- warm
- trustworthy
- readable at 29px and 40px
- visibly related to currency conversion
- visually aligned with the app UI: warm paper, forest ink, moss/coral accents

It should not feel:

- blue fintech
- crypto exchange
- travel booking
- default Flutter/mobile template
- busy with flags or tiny details

---

## Workflow Overview

| Stage | Provider | Spend goal | Output |
|-------|----------|------------|--------|
| 1. Baseline audit | none | free | Current icon weaknesses and target traits |
| 2. MiniMax concept search | MiniMax | use daily quota, no OpenAI | 12-24 candidate icons |
| 3. Human shortlist | none | free | 2-4 promising directions |
| 4. MiniMax refinement | MiniMax | still no OpenAI | 4-8 variants of best direction |
| 5. OpenAI final pass | OpenAI | paid, limited | 1-3 final attempts from winning prompt |
| 6. Deploy | local tooling | free | iOS/Android/macOS/web launcher assets |

Rule: **Do not call OpenAI until there is a MiniMax candidate the user likes.**

---

## Directory Plan

Use a separate directory from currency badges:

```text
.tmp/app-icon/
  baseline/
  minimax-concepts/
  minimax-refined/
  openai-final/
  review/
  approved/
```

Do not mix app-icon work with `.tmp/icon-v4/`, which is for currency badges.

---

## MiniMax Prompt Strategy

Generate single 1:1 launcher icons, not grids. App icons need 1024px quality.

Always include:

- `mobile app launcher icon`
- `1024x1024`
- `no text, no letters, no tiny details`
- `simple bold silhouette`
- `warm paper background`
- `forest green and moss accents`
- `flat premium vector-like design`
- `currency conversion metaphor`

Avoid:

- blue fintech palette
- flags
- airplanes
- tiny arrows
- many currency symbols
- glossy 3D coin stacks
- crypto neon
- screenshots/UI mockups
- transparent background

### Prompt Family A — Instrument Dial

```text
Mobile app launcher icon, 1024x1024, warm premium currency converter.
Centered circular instrument dial on warm paper background, forest green ink, moss accent, subtle coral detail.
The mark suggests currency conversion through two bold opposing arcs around a single clean currency glyph, like a crafted financial instrument.
Flat vector-like design, soft rounded geometry, strong silhouette, readable at tiny iPhone home screen size.
No text, no app name, no flags, no airplanes, no tiny arrows, no blue, no purple, no neon, no glossy 3D.
```

### Prompt Family B — Exchange Seal

```text
Mobile app launcher icon, 1024x1024, warm editorial finance seal for a privacy-first currency converter.
One simple monogram-like exchange symbol built from two thick curved arrows inside a soft circular seal.
Warm cream paper background, deep forest green symbol, moss shadow accent, tiny coral highlight only if needed.
Premium flat vector mark, tactile paper feel, high contrast, centered, uncluttered, strong at 29px.
No words, no letters, no flags, no airplanes, no coin pile, no crypto style, no blue gradients.
```

### Prompt Family C — Currency Ledger Mark

```text
Mobile app launcher icon, 1024x1024, elegant warm currency conversion mark.
A minimal paper ledger tile with one bold exchange curve crossing between two simplified currency dots, inspired by editorial finance notebooks.
Palette: warm cream, forest green, moss, subtle coral. Rounded corners, flat vector, premium crafted feel.
Very simple silhouette, few shapes, no small decorative details, readable at app icon sizes.
No text, no flags, no airplanes, no bank building, no blue fintech, no neon crypto, no realistic coins.
```

### Prompt Family D — Single Symbol

```text
Mobile app launcher icon, 1024x1024, privacy-first currency converter for Niduna.
One bold abstract exchange symbol: two interlocking rounded strokes forming a calm circular motion around a small currency dot.
Warm paper background, forest green main stroke, moss secondary stroke, restrained coral accent.
Flat premium vector style, centered, balanced, no clutter, no tiny elements, clear silhouette at 29px.
No text, no letters, no flags, no airplanes, no blue, no purple, no crypto neon, no glass effect.
```

---

## MiniMax Commands

Start with quota:

```bash
mmx quota show
```

Generate concept batches:

```bash
mkdir -p .tmp/app-icon/minimax-concepts

mmx image generate \
  --prompt "<PROMPT FAMILY A>" \
  --aspect-ratio 1:1 \
  --n 4 \
  --out-dir .tmp/app-icon/minimax-concepts \
  --out-prefix family-a \
  --quiet
```

Repeat for families B-D.

Use `--n 4` for exploration efficiency. For final MiniMax refinements, use `--n 1` or `--n 2` with tighter prompts.

---

## Review Rubric

Score each candidate 1-5:

| Criterion | Question |
|-----------|----------|
| Silhouette | Is it recognizable at 29px without zooming? |
| Niduna fit | Does it match warm paper + forest/moss/coral UI? |
| Currency clarity | Does it imply conversion without generic finance clichés? |
| Premium feel | Does it feel crafted, not template-generated? |
| Platform readiness | Would it survive iOS/Android masking and home-screen backgrounds? |

Reject immediately if:

- it uses blue/purple/neon as primary color
- it includes tiny airplanes, flags, micro arrows, or unreadable details
- it has text or fake app letters
- it looks like a crypto exchange token
- it relies on a white borderless background

Shortlist only candidates with average score ≥ 4/5.

---

## Small-Size Review

For every promising candidate, create quick preview sizes:

```bash
mkdir -p .tmp/app-icon/review
sips -z 180 180 candidate.png --out .tmp/app-icon/review/candidate-180.png
sips -z 120 120 candidate.png --out .tmp/app-icon/review/candidate-120.png
sips -z 80 80 candidate.png --out .tmp/app-icon/review/candidate-80.png
sips -z 58 58 candidate.png --out .tmp/app-icon/review/candidate-58.png
```

Human review should look at 180, 120, 80, and 58 px before approving a direction.

---

## OpenAI Final Pass

Only run OpenAI after a MiniMax candidate is selected.

OpenAI prompt should not ask for a new broad concept. It should translate the winning MiniMax direction into a more polished final asset.

Template:

```text
Create a polished 1024x1024 mobile app launcher icon based on this approved direction:
<describe winning MiniMax candidate in 2-4 sentences>

Brand: Niduna Currency Converter, privacy-first, warm premium finance instrument.
Palette: warm cream paper background, deep forest green main mark, moss accent, restrained coral highlight.
Style: clean flat vector-like icon, strong silhouette, centered, few shapes, high contrast, readable at 29px.
Metaphor: currency conversion / exchange motion, not travel, not crypto trading.

Do not include text, letters, flags, airplanes, tiny details, blue, purple, neon, glossy 3D, screenshots, UI panels, or realistic coin piles.
```

Cost control:

- Start with `OPENAI_IMAGE_QUALITY=medium`
- Generate `n=1` equivalent per attempt
- Stop after 1 strong candidate unless user approves more spend
- Keep outputs in `.tmp/app-icon/openai-final/`

---

## Deployment Gate

Before replacing app icons:

- User explicitly approves one 1024x1024 source image
- Preview sizes pass 180/120/80/58 px review
- Icon has no transparency for iOS App Store asset
- No secrets or API keys are committed
- Existing launcher icon files are backed up or recoverable through git

Then generate platform assets for:

- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- `android/app/src/main/res/mipmap-*dpi/ic_launcher.png`
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- `web/favicon.png`

Do not deploy generated icons automatically during concept search.

---

## Recommended Next Step

Run MiniMax concept search with families A-D, then build a small contact sheet for human review. Pick one direction before any OpenAI call.
