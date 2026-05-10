# Icon & Image Generation Skill

> Generate app icons, currency icons, and UI images using MiniMax CLI (`mmx`).
> Learned from the currency-converter project (May 2026).

## Prerequisites

- `mmx-cli` installed globally: `npm install -g mmx-cli`
- Authenticated: `mmx auth login --api-key sk-cp-xxxxx`
- ImageMagick installed (macOS): `brew install imagemagick`

## Quota Check (ALWAYS do this first)

```bash
mmx quota show
```

Look for `image-01` model:
- **Daily limit**: 50 images/day (Token Plan Plus)
- **Weekly limit**: 350 images/week
- Resets at midnight UTC
- **Check before generating** — if at 0, don't waste time

## CLI Usage

### Single image

```bash
mmx image "your prompt here" --out output/path/image.png
```

### Batch: Multiple icons in ONE image (QUOTA SAVER)

**Key insight**: Generate a grid of icons in a single image, then crop into individual files.
This turns 1 quota unit into **9-16 icons**.

#### Step 1: Generate a grid image

```bash
# 3x3 grid (9 icons) — each cell ~256px, total ~768x768
mmx image "A 3x3 grid of 9 flat circular currency icons on white background:
Row 1: USD \$ with American flag, EUR € with EU stars, GBP £ with UK flag
Row 2: CHF Fr with Swiss cross, JPY ¥ with Japan flag, CAD \$ with Canada leaf
Row 3: AUD \$ with Australia stars, NZD \$ with NZ stars, SEK kr with Sweden flag
Each icon is a perfect circle with flag background and bold white currency symbol.
Flat 2D design NO blur NO 3D crisp edges." \
  --out icons/grid-3x3.png
```

Grid sizes that work well:
| Grid | Icons per image | Cell size | Total size | Recommended |
|------|----------------|-----------|------------|-------------|
| 2x2 | 4 | 300px | 600x600 | Quick test |
| 3x3 | 9 | 250px | 750x750 | Best balance |
| 4x4 | 16 | 200px | 800x800 | Max quality |
| 5x5 | 25 | 160px | 800x800 | Small icons OK |
| 6x6 | 36 | 133px | 800x800 | Risky — too small |

> **Tip**: Don't go above 4x4 for currency icons — cells get too small and symbols become unreadable.
> For app launcher icons (need 1024px), always generate **singly**.

#### Step 2: Crop grid into individual icons

```bash
# Using ImageMagick (magick command)
GRID="icons/grid-3x3.png"
CELL=250  # must match the cell size used in prompt

# Crop each cell (offset = col * CELL, row * CELL)
magick "$GRID" -crop ${CELL}x${CELL}+0+0 +repage icons/usd.png    # row 0, col 0
magick "$GRID" -crop ${CELL}x${CELL}+${CELL}+0 +repage icons/eur.png   # row 0, col 1
magick "$GRID" -crop ${CELL}x${CELL}+$((CELL*2))+0 +repage icons/gbp.png # row 0, col 2
magick "$GRID" -crop ${CELL}x${CELL}+0+${CELL} +repage icons/chf.png   # row 1, col 0
magick "$GRID" -crop ${CELL}x${CELL}+${CELL}+${CELL} +repage icons/jpy.png
# ... continue for all cells
```

#### Step 3: Verify crop results

```bash
# Quick check all cropped images have correct dimensions
for f in icons/*.png; do sips -g pixelWidth -g pixelHeight "$f"; done
```

### Batch generation (parallel, one image each)

```bash
# Run multiple in parallel for speed (uses 1 quota per image)
mmx image "prompt A" --out icons/a.png &
mmx image "prompt B" --out icons/b.png &
wait
```

Output goes to `minimax-output/` by default if `--out` is omitted.

## Prompt Engineering for Icons

### What WORKS (sharp, clean results)

**Key words that produce crisp flat icons:**
- `flat 2D vector icon`
- `NO blur NO softness NO 3D NO gloss NO gradient`
- `flat design only like material design icon`
- `solid circle` (not "circle with background")
- `pixel-perfect edges`, `crisp clean edges`
- `BOLD THICK white [symbol]`
- `vivid` colors (not "subtle" or "muted" — those cause blur)

### What DOESN'T work (produces blurry/soft results)

- ❌ "subtle", "muted", "soft background wash"
- ❌ "at 12% opacity" or "at 15% opacity" → produces blur
- ❌ "gradient" → produces blur
- ❌ 3D terms: "glossy", "shiny", "bevel", "emboss"
- ❌ Long complex prompts with too many details

### Best prompt template for currency icons

```
Perfect flat 2D vector icon circle for [CURRENCY NAME] [CODE].
NO blur NO softness NO 3D NO gloss NO gradient.
Flat design only like material design icon.
Background: solid circle filled with [COUNTRY] flag description
flat solid colors no gradient.
Center overlay: large bold white [SYMBOL] pure white flat
crisp clean edges pixel-perfect.
```

### Best prompt template for app icons

```
Modern flat app icon for [APP DESCRIPTION].
Clean minimal design: [VISUAL ELEMENTS],
[COLOR SCHEME], fintech style,
no text letters, pure graphic only,
flat modern design style (not skeuomorphic),
professional, recognizable at small size
```

## Post-Processing with ImageMagick

### Resize to multiple sizes (for launcher icons)

```bash
SRC="source_icon.png"

# Android mipmap sizes
sips -z 48 48 "$SRC" --out mipmap-mdpi/ic_launcher.png
sips -z 72 72 "$SRC" --out mipmap-hdpi/ic_launcher.png
sips -z 96 96 "$SRC" --out mipmap-xhdpi/ic_launcher.png
sips -z 144 144 "$SRC" --out mipmap-xxhdpi/ic_launcher.png
sips -z 192 192 "$SRC" --out mipmap-xxxhdpi/ic_launcher.png

# iOS AppIcon sizes (16 total)
sips -z 20 20 "$SRC" --out Icon-App-20x20@1x.png
sips -z 40 40 "$SRC" --out Icon-App-20x20@2x.png
sips -z 60 60 "$SRC" --out Icon-App-20x20@3x.png
# ... etc for all iOS sizes
sips -z 1024 1024 "$SRC" --out Icon-App-1024x1024@1x.png
```

Note: `sips` is built into macOS. Use `magick` (ImageMagick) for Linux.

### Check image properties

```bash
sips -g all image.png   # macOS
magick identify image.png  # ImageMagick
```

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
  static const Map<String, String> _assetMap = <String, String>{
    'USD': 'assets/icons/currencies/usd.png',
    'EUR': 'assets/icons/currencies/eur.png',
    // ...
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
      child: Text(symbol),
    );
  }
}
```

## Known Issues & Workarounds

| Issue | Cause | Fix |
|-------|-------|-----|
| Blurry output | Model adds blur/gloss/3D | Use "flat 2D vector NO blur NO 3D" keywords |
| Wrong symbol | Ambiguous symbol name | Spell out symbol explicitly: "$ dollar sign", "€ euro" |
| Flag not recognized | Obscure country flag | Describe flag colors/pattern explicitly |
| Quota exhausted | 50/day limit | Check with `mmx quota show`, wait for reset |
| Some flags always blurry | Model weakness (e.g., Brazil, Chile) | Regenerate with simpler prompt or accept + iterate tomorrow |

## Workflow Summary

### Option A: Grid batch (quota-efficient, recommended for icon sets)

1. **Check quota**: `mmx quota show` → confirm image-01 has remaining
2. **Design grid**: Plan 3x3 or 4x4 layout of icons to generate
3. **Generate grid**: `mmx image "grid prompt" --out grid.png` (1 quota = 9-16 icons)
4. **Crop**: `magick grid.png -crop WxH+X+Y +repage icon.png` per cell
5. **Review quality**: Use vision tool to check each cropped icon
6. **Regenerate blurry ones**: Single `mmx image` with "flat 2D NO blur" keywords
7. **Resize/deploy**: Copy to assets, resize for platforms
8. **Integrate**: Wire into Flutter widget as AssetImage
9. **Verify**: Rebuild app, screenshot to confirm

### Option B: Individual (for high-res or single icons)

1. **Check quota**: `mmx quota show`
2. **Generate individually**: One `mmx image` call per icon (parallelize)
3. **Review → regenerate** blurry ones
4. **Resize/deploy → integrate → verify**

### Quota math

| Method | Icons per quota | 50 daily quota = |
|--------|---------------|-----------------|
| Individual | 1 | 50 icons |
| 3x3 grid | 9 | **450 icons** |
| 4x4 grid | 16 | **800 icons** |
