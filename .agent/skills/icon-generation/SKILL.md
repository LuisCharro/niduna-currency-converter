# Icon & Image Generation Skill (Flutter) — v3

> Generate app icons, flag icons, coin icons, and UI images using MiniMax CLI (`mmx`).
> General-purpose for any Flutter/Mobile project. For the full mmx CLI reference
> (all 7 commands: text, image, video, speech, music, vision, search), see
> `mobile/minimax-cli.SKILL.md` in your skills repo.

## Prerequisites

```bash
mmx quota show   # Check image-01 has remaining before starting
```

Requires:
- `mmx-cli`: `npm install -g mmx-cli` (v1.0.12+)
- ImageMagick (macOS): `brew install imagemagick`
- MiniMax Token Plan Plus ($20/mo, 50 images/day on `image-01`)

---

## v3 Methodology (Current — May 2026)

### Why v3? (Audit findings from currency-converter)

**All 34 existing icons scored ≤ 2.5/5** (only CHF 4.0, SEK 3.75 borderline). Universal problems:

| Problem | Old Icons | v3 Fix |
|---------|----------|--------|
| Drop/long shadows | Every icon had them | **NO drop shadow NO long shadow NO glow** in style lock |
| Glossy/3D/skeuomorphic | Web 2.0 dated look | **Flat geometric vector only**, no bevel/emboss |
| White symbol on white flag | GBP, MXN, PLN unreadable | Dark semi-transparent circle behind symbol |
| Low source resolution | 250px grid cell → 128px output | **1024×1024 generate → 256×256 output** (4x detail) |
| Over-complex flag details | 50 stars, wavy stripes | **Simplified stylized flag patterns**, 3-4 colors max |

### Prompt Engineering v3 — Style Lock Pattern

The key insight: **prepend an identical STYLE_LOCK block to every prompt**.
This locks visual identity across all generations.

```
STYLE_LOCK (prepend to EVERY prompt):
Geometric flat circular icon.
NO drop shadow NO long shadow NO glow NO bevel NO emboss NO gloss NO gradient NO 3D.
Flat vector design style like modern fintech app icon (Wise/Revolut quality).
Crisp clean pixel-perfect edges.
Vivid solid colors only.
Circle background filled with stylized simplified flag pattern.
Center overlay: bold thick white currency symbol with subtle dark semi-transparent
circle behind it for contrast.
```

### What WORKS in v3 (crisp, clean output)

- `geometric flat` — stronger than just "flat"
- `NO drop shadow NO long shadow NO glow` — must list ALL shadow types
- `pixel-perfect edges`, `crisp clean`
- `vivid solid colors` — never "subtle" or "muted"
- `stylized simplified flag pattern` — tells AI to simplify, not reproduce exactly
- `dark semi-transparent circle behind symbol` — solves white-on-white contrast
- `--width 1024 --height 1024` — high-res source for crisp downscaling
- `--prompt-optimizer true` — auto-improves prompts
- `--seed 42` — reproducible regeneration

### What DOESN'T (produces blurry/soft output)

- ❌ "subtle", "muted", "soft background wash"
- ❌ "at X% opacity" (except for the dark backing circle)
- ❌ "gradient" anywhere in prompt
- ❌ 3D terms: "glossy", "shiny", "bevel", "emboss"
- ❌ "long shadow", "drop shadow", "glow effect"
- ❌ Photorealistic flag descriptions ("waving", "fabric texture")
- ❌ Over-detailed flag specs ("50 stars", "13 alternating stripes")

### Template: circular currency flag icon (v3)

```
[STYLE_LOCK]
Currency: [CODE]. Symbol: bold white "[SYMBOL]" centered.
Flag: [SIMPLIFIED FLAG DESCRIPTION using flat solid color areas only].
The circular background shows a stylized simplified version of this country's flag.
```

**Example — USD:**
```
Geometric flat circular icon.
NO drop shadow NO long shadow NO glow NO bevel NO emboss NO gloss NO gradient NO 3D.
Flat vector design style like modern fintech app icon.
Crisp clean pixel-perfect edges.
Vivid solid colors only.
Circle background filled with stylized simplified flag pattern.
Center overlay: bold thick white currency symbol with subtle dark semi-transparent
circle behind it for contrast.
Currency: USD. Symbol: bold white "$" centered.
Flag: red and white horizontal stripes, blue canton upper left with white star dots,
simplified to bold red-white-blue geometric blocks.
The circular background shows a stylized simplified version of this country's flag
using flat solid color areas only.
```

---

## Generation Workflow (v3)

### Automated Script (recommended)

The repo includes `.devtools/generate_currency_icons.sh` which automates:

```bash
# Step 0: Check status
.devtools/generate_currency_icons.sh --quota

# Step 1: Generate anchor (9 quota)
.devtools/generate_currency_icons.sh --anchor
# → Review 9 USD candidates, pick best → copy to .tmp/icon-v3/best/usd.png

# Step 2: Test subject-ref consistency (3 quota)
.devtools/generate_currency_icons.sh --test-ref
# → Check if EUR/CHF match anchor style

# Step 3: Batch generate remaining (~32 quota)
.devtools/generate_currency_icons.sh --batch

# Step 4: Quality gate (0 quota — uses vision describe)
.devtools/generate_currency_icons.sh --quality

# Step 5: Deploy to assets (0 quota)
.devtools/generate_currency_icons.sh --deploy
```

### Manual Method (for one-off icons)

```bash
# Single high-res icon
mmx image generate \
  --prompt "[FULL V3 PROMPT]" \
  --n 3 \
  --width 1024 \
  --height 1024 \
  --aspect-ratio 1:1 \
  --prompt-optimizer \
  --seed 42 \
  --out-dir .tmp/icon-v3/ \
  --out-prefix myicon

# Resize to target size
sips -z 256 256 .tmp/icon-v3/myicon_001.png --out assets/icons/myicon.png
```

---

## Generation Methods Comparison

| Method | Quota/Icon | Consistency | Best For |
|--------|-----------|-------------|----------|
| **A: Single + high-res** | 1 (or `--n N` for variations) | Prompt-dependent | Anchor, app launcher (1024px+) |
| **B: Subject-ref chain** | 1 | **High** (from anchor) | Icon sets, if ref works |
| **C: Grid batch** | 1/N (N=icons per grid) | High (same gen call) | Quick sets, lower res (~250px/cell) |
| **D: Consistent prefix** | 1 | Medium-High (same prefix) | Fallback if subject-ref fails |

### v3 Recommendation: A → B → D priority

1. **Generate anchor** at high-res with `--n 9` → pick best
2. **Test subject-ref** with 2 currencies against anchor
3. **If ref works**: use `--subject-ref` for all remaining (Method B)
4. **If ref fails**: use identical STYLE_LOCK prefix for all (Method D)

---

## Subject-Reference Details

```bash
mmx image generate \
  --prompt "[PROMPT FOR NEW CURRENCY]" \
  --subject-ref "type=character,image=./best/usd.png" \
  --width 1024 --height 1024 \
  --aspect-ratio 1:1 \
  --prompt-optimizer
```

**Important limitations:**
- API `type` field only supports `"character"` (portrait-tuned)
- Works best for face/object consistency; **unproven for graphic style transfer**
- Always test with 2-3 icons before committing to full batch
- Reference image should be **512x512 minimum**, front-facing, simple background

---

## Grid Batch (legacy method, still useful for quick tests)

For icon sets where max resolution isn't critical (e.g., draft/mockup):

```bash
# 3x3 grid (9 icons, ~250px/cell)
mmx image generate \
  --prompt "A 3x3 grid of 9 flat circular currency icons on white:
Row 1: USD dollar American flag, EUR euro EU stars, GBP pound UK flag
Row 2: CHF Fr Swiss cross, JPY yen Japan flag, CAD dollar Canada flag
Row 3: AUD dollar Australia, BRL real Brazil, INR rupee India
[STYLE LOCK applied to each description]
Flat 2D design crisp edges." \
  --out-dir .tmp/ --out-prefix grid-3x3 --aspect-ratio 1:1
```

Grid sizes:

| Grid | Icons/Quota | Cell Size | Total | Risk |
|------|------------|-----------|-------|------|
| 2x2 | 4 | 300px | 600x600 | Low |
| 3x3 | 9 | 250px | 750x750 | Medium |
| 4x4 | 16 | 200px | 800x800 | Medium-High |
| 5x5 | 25 | 160px | 800x800 | **High** (too small) |

Crop with ImageMagick:
```bash
GRID=$(ls .tmp/grid-3x3*.png | head -1)
CELL=256
magick "$GRID" -crop ${CELL}x${CELL}+0+0    +repage icon-00.png
magick "$GRID" -crop ${CELL}x${CELL}+${CELL}+0 +repage icon-01px
# ... continue for all cells
```

---

## Quality Review Loop

After generating, run automated quality check:

```bash
# Via script
.devtools/generate_currency_icons.sh --quality

# Or manual per-icon
mmx vision describe --image icon.png \
  --prompt "Rate this fintech icon 26-40px: SHARPNESS:x/5 FLAG:x/5 SYMBOL:x/5 VERDICT:PASS or FAIL" \
  --quiet --non-interactive
```

If FAIL:
1. Regenerate with stronger keywords: add "extra vivid", simplify flag description
2. Try different `--seed` value
3. If still failing after 2 attempts, accept best effort + note in SKILL.md

---

## Post-Processing: Deploy to Flutter App

### Resize for currency icons (target 256x256)

```bash
SRC=".tmp/icon-v3/best/${code}.png"   # 1024x1024 source from mmx
sips -z 256 256 "$SRC" --out "assets/icons/currencies/${code}.png"
```

### For launcher icons (multiple sizes)

```bash
SRC=".tmp/app_icon.png"   # 1024x1024 source

# Android mipmap
sips -z 48 48 "$SRC" --out android/app/src/main/res/mipmap-mdpi/ic_launcher.png
sips -z 72 72 "$SRC" --out android/app/src/main/res/mipmap-hdpi/ic_launcher.png
sips -z 96 96 "$SRC" --out android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
sips -z 144 144 "$SRC" --out android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
sips -z 192 192 "$SRC" --out android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# iOS AppIcon (16 sizes)
sips -z 20 20 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png
sips -z 40 40 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png
sips -z 60 60 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png
sips -z 29 29 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png
sips -z 58 58 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png
sips -z 87 87 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png
sips -z 40 40 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png
sips -z 80 80 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png
sips -z 120 120 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
sips -z 60 60 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
sips -z 90 90 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
sips -z 76 76 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
sips -z 152 152 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
sips -z 167 167 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
sips -z 1024 1024 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png
```

Note: `sips` is built into macOS. Use `magick` (ImageMagick) for Linux.

---

## Flutter Integration

### Add assets to pubspec.yaml

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/currencies/
```

### Widget pattern for image-based icons

```dart
class CurrencyFlagIcon extends StatelessWidget {
  const CurrencyFlagIcon({
    required this.code,
    required this.symbol,
    this.radius = 20,
    super.key,
  });

  final String code;
  final String symbol;
  final double radius;

  static const Map<String, String> _assetMap = <String, String>{
    'USD': 'assets/icons/currencies/usd.png',
    'EUR': 'assets/icons/currencies/eur.png',
    // ... extend for all icons
  };

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetMap[code.toUpperCase()];
    if (assetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(assetPath),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        symbol,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.75),
      ),
    );
  }
}
```

---

## Per-Currency Notes (from v2 experience)

| Currency | Known Issue | v3 Workaround |
|----------|------------|---------------|
| BRL | Brazil flag always slightly blurry (complex emblem) | Simplify to "green with yellow diamond and blue circle center" |
| CLP | Chile flag: star often wrong color/invisible | Explicitly say "white star on blue square" |
| ARS | Argentina sun sometimes ambiguous | "golden Sun of May face as simple circle with rays" |
| GBP | Union Jack: white symbol disappears on white stripe | Dark backing circle critical; describe as "navy blue base with white-red crosses" |
| JPY | Model sometimes uses Rising Sun (controversial) instead of Hinomaru | Explicitly say "solid red circle on plain white, Hinomaru flag ONLY" |
| TRY | Missing star, looks like Red Crescent | Explicitly say "red with white crescent AND five-pointed star" |
| THB | Often generates wrong text "TBB" instead of ฿ symbol | Give Unicode symbol explicitly |
| MXN | White symbol invisible on white middle stripe | Emphasize dark semi-transparent backing |
| PLN | White "zł" invisible on white stripe | Same — dark backing critical |
| COP | Very blurry (1/5 worst score) | Stronger "vivid" keywords, simpler tricolor desc |
| SGD | Wrong star count (3 vs actual 5) | Explicitly say "five-pointed stars" |
| MYR | Heavy glossy bubble effect | Extra NO-gloss emphasis |
| KRW | Trigrams too thin, symbol complex | Simplify to "red-blue yin-yang center circle only" |
| HKD | Bauhinia flower too detailed | "white stylized five-petal flower shape" |
| ZAR | Flag too complex for small size | Heavily simplify to "green-red-blue Y shape" |
| ILS | Wrong symbol (Y instead of ₪) | Explicitly give "Israeli shekel symbol that looks like U with double stroke" |
| PHP | Large X obscures flag, negative connotation | Explicitly give "P with double horizontal strike" |
| SEK | One of the better v2 icons (3.75) | Still regenerate for style consistency |
| CHF | Best v2 icon (4.0) | Still regenerate for style consistency |

---

## Quota Math (Plus plan = 50/day)

| Method | Icons/quota | 50 daily = |
|--------|-------------|------------|
| Individual calls | 1 | 50 icons |
| `--n 3` batch | 3 | 150 icons |
| `--n 9` max batch | 9 | **450 icons** |
| 3x3 grid | 9 | **450 icons** |
| 4x4 grid | 16 | **800 icons** |
| **v3 single high-res** | 1 | 50 icons (but at 1024px!) |

**v3 daily plan (46 of 50 quota):**
| Step | Quota | Output |
|------|-------|--------|
| Anchor (--n 9) | 9 | 9 USD variants → pick 1 |
| Subject-ref test | 2 | EUR + CHF validation |
| Remaining 31 currencies × 1 | 31 | All 34 total |
| Buffer for regens | ~4 | Fix failures |
| **Total** | **~46** | **34 production icons at 256x256** |

---

## Error Handling

| Exit Code | Meaning | Action |
|-----------|---------|--------|
| 0 | Success | Continue |
| 1 | General error | Check logs |
| 2 | Usage error | Check flags/args |
| 3 | Auth error | Run `mmx auth login` |
| **4** | **Quota exceeded** | Wait for midnight UTC reset |
| 5 | Timeout | Retry once |
| **10** | **Content filter** | Rewrite prompt, remove flagged terms |

---

## Project Example: Niduna Currency Converter

This skill was developed building the currency-converter Flutter app.

**Generated assets:**
- **App launcher icon** (1): €↔£ intersecting blue/white design
- **34 currency flag icons** (flag bg + white symbol overlay): USD through ZAR
- **Widget**: `CurrencyFlagIcon` in `lib/src/shared/widgets/currency_flag_icon.dart`
- **Wired into**: Convert rate rows, amount panel, Charts pair selector, Settings base picker

**Files:**
- `.devtools/generate_currency_icons.sh` — automated v3 pipeline script
- `.devtools/currency_icon_prompts.json` — 34 currency definitions with flag descriptions/colors
- `lib/src/shared/widgets/currency_flag_icon.dart` — widget with 34-code asset map
- `assets/icons/currencies/` — deployed PNG icons (target: 256x256)

**Version history:**
- v1: Initial generation, grid-batch method, 128x128 output
- v2: Individual regens for problematic currencies, added per-currency workarounds
- **v3 (current)**: Style-lock methodology, 1024→256 pipeline, subject-ref experiment, quality gate
