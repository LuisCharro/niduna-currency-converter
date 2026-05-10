# Icon & Image Generation Skill (Flutter)

> Generate app icons, flag icons, coin icons, and UI images using MiniMax CLI (`mmx`).
> General-purpose for any Flutter/Mobile project. For the full mmx CLI reference
> (all 7 commands: text, image, video, speech, music, vision, search), see
> `mobile/minimax-cli.SKILL.md` in your skills repo.

## Prerequisites

```bash
mmx quota show   # Check image-01 has remaining before starting
```

Requires:
- `mmx-cli`: `npm install -g mmx-cli`
- ImageMagick (macOS): `brew install imagemagick`
- MiniMax Token Plan (image-01 model)

---

## Prompt Engineering for Sharp Icons

### What WORKS (crisp, clean output)

- `flat 2D vector icon`
- `NO blur NO softness NO 3D NO gloss NO gradient`
- `flat design only like material design icon`
- `solid circle` (not "circle with background")
- `pixel-perfect edges`, `crisp clean edges`
- `BOLD THICK white [symbol]`
- `vivid` colors (never "subtle" or "muted" — those produce blur)
- `prompt_optimizer: true` flag (auto-improves prompts)

### What DOESN'T (produces blurry/soft output)

- ❌ "subtle", "muted", "soft background wash"
- ❌ "at X% opacity" → produces blur
- ❌ "gradient" → produces blur
- ❌ 3D terms: "glossy", "shiny", "bevel", "emboss"
- ❌ Long complex prompts with too many details

### Template: circular icon (flags, coins, avatars, subjects)

```
Perfect flat 2D vector icon circle for [SUBJECT NAME].
NO blur NO softness NO 3D NO gloss NO gradient.
Flat design only like material design icon.
Background: solid circle filled with [COLORS] flat solid colors no gradient.
Center overlay: large bold white [SYMBOL] pure white flat
crisp clean edges pixel-perfect.
```

### Template: app launcher icon

```
Modern flat app icon for [APP DESCRIPTION].
Clean minimal design: [VISUAL ELEMENTS],
[COLOR SCHEME], fintech style,
no text letters, pure graphic only,
flat modern design style (not skeuomorphic),
professional, recognizable at small size
```

### Template: coin / crypto icon

```
Perfect flat 2D vector coin icon for [COIN NAME].
NO blur NO softness NO 3D NO gloss NO gradient.
Flat design only like material design icon.
Background: solid circle filled with [METAL COLOR] flat solid no gradient.
Center overlay: large bold white [SYMBOL] pure white flat
crisp clean edges pixel-perfect.
Metallic sheen subtle highlight on upper-left edge.
```

**Coin color examples**: gold (#FFD700), silver (#C0C0C0), bronze (#CD7F32),
bitcoin orange (#F7931A), ethereum purple (#627EEA).

### Common icon prompts used in currency-converter project

**App icon (launcher)**:
```
Modern flat app icon for currency converter app.
Clean minimal design: two currency symbols (€ and £) intersecting,
blue and white color scheme, fintech style,
no text letters, pure graphic only,
flat modern design style (not skeuomorphic),
professional, recognizable at small size
```

**Currency grid (3x3 example)**:
```
A 3x3 grid of 9 flat circular currency icons on white:
Row 1: USD dollar with American flag, EUR euro with EU stars, GBP pound with UK flag
Row 2: CHF Fr with Swiss cross, JPY yen with Japan flag, CAD dollar with Canada flag
Row 3: AUD dollar with Australia stars, BRL real with Brazil flag, JPY yen with Japan flag
Each icon is a perfect circle with flag background and bold white currency symbol.
Flat 2D design NO blur NO 3D crisp edges.
```

---

## Generation Methods

### Method A: Single image

```bash
mmx image generate --prompt "[icon prompt]" --out-dir .tmp/
```

Best for: app launcher icons (need 1024px), one-off assets.

### Method B: Batch n — multiple variations in ONE call (1 quota unit)

Generate up to **9** images at once. Uses 1 quota unit, returns N outputs.

```bash
# Generate 3 variations — pick the best one
mmx image generate --prompt "Mountain landscape" --n 3 --aspect-ratio 1:1 --out-dir ./out/
```

| Flag | Range | Default |
|------|-------|---------|
| `--n <count>` | 1–9 | 1 |

### Method C: Grid batch — multiple icons in ONE image (quota saver)

For icon sets, generate a grid of icons in one image, then crop with ImageMagick.
Turns **1 quota unit into 4–16 icons**.

```bash
# 3x3 grid (9 icons) — cell ~256px, total ~768x768
mmx image generate \
  --prompt "A 3x3 grid of 9 flat circular currency icons on white:
Row 1: USD dollar with American flag, EUR euro with EU stars, GBP pound with UK flag
Row 2: CHF Fr with Swiss cross, JPY yen with Japan flag, CAD dollar with Canada flag
Row 3: AUD dollar with Australia stars, BRL real with Brazil flag, JPY yen with Japan flag
Each icon is a perfect circle with flag background and bold white currency symbol.
Flat 2D design NO blur NO 3D crisp edges." \
  --out-dir .tmp/ --out-prefix grid-3x3 --aspect-ratio 1:1
```

Grid sizes:

| Grid | Icons | Cell size | Total | Use for |
|------|-------|-----------|-------|---------|
| 2x2 | 4 | 300px | 600x600 | Quick test |
| 3x3 | 9 | 250px | 750x750 | Currency / coin icons |
| 4x4 | 16 | 200px | 800x800 | Small icons |
| 5x5 | 25 | 160px | 800x800 | Risky — too small |

> For app launcher icons (need 1024px), always generate **singly** (Method A).

### Method D: Subject-ref — consistent identity across generations

Use `--subject-ref` to keep the same character/icon style across multiple generations.

```bash
mmx image generate \
  --prompt "A girl stands by the library window, gazing into the distance" \
  --subject-ref "type=character,image=reference-character.png" \
  --out-dir .tmp/
```

Best for: maintaining consistent brand mascot/app icon across variations.

### Crop grid into individual icons

```bash
GRID=$(ls .tmp/grid-3x3*.png | head -1)
CELL=256  # must match the cell size in the prompt

magick "$GRID" -crop ${CELL}x${CELL}+0+0    +repage .tmp/icons/icon-00.png  # row 0, col 0
magick "$GRID" -crop ${CELL}x${CELL}+${CELL}+0 +repage .tmp/icons/icon-01.png  # row 0, col 1
magick "$GRID" -crop ${CELL}x${CELL}+$((CELL*2))+0 +repage .tmp/icons/icon-02.png  # row 0, col 2
magick "$GRID" -crop ${CELL}x${CELL}+0+${CELL}   +repage .tmp/icons/icon-10.png  # row 1, col 0
magick "$GRID" -crop ${CELL}x${CELL}+${CELL}+${CELL} +repage .tmp/icons/icon-11.png  # row 1, col 1
# ... continue for all cells
```

### Verify cropped results

```bash
for f in .tmp/icons/*.png; do sips -g pixelWidth -g pixelHeight "$f"; done
```

---

## Quality Review Loop

After generating (especially batch/grid), review each output before deploying:

```bash
# Quick quality check with vision
mmx vision describe --image .tmp/icons/usd.png --prompt "Is this icon sharp and clean? Any blur?" --quiet

# Or review manually in your agent's vision tool
```

If blurry:
1. Regenerate single with stronger keywords: "flat 2D NO blur NO 3D vivid"
2. Use explicit color descriptions if flag not recognized
3. Accept and move on (some flags are inherently harder for the model)

---

## Post-Processing: Deploy to Flutter App

### Resize for launcher icons

```bash
SRC=".tmp/app_icon.png"   # 1024x1024 source from mmx

# Android mipmap (5 sizes)
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
sips -z 120 120 "$SRC" --out iosRunner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png
sips -z 60 60 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png
sips -z 90 90 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png
sips -z 76 76 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png
sips -z 152 152 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png
sips -z 167 167 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png
sips -z 1024 1024 "$SRC" --out ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png

# Web favicon
sips -z 32 32 "$SRC" --out web/favicon.png
```

Note: `sips` is built into macOS. Use `magick` (ImageMagick) for Linux.

### Check image properties

```bash
sips -g all image.png    # macOS
magick identify image.png  # ImageMagick
```

---

## Flutter Integration

### Add assets to pubspec.yaml

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/icons/
```

Use a single directory per icon set and reference it with a trailing slash — all files inside are addressable by path relative to that directory.

### Widget pattern for image-based icons

```dart
class FlagIcon extends StatelessWidget {
  final String code;
  final double radius;

  static const Map<String, String> _assetMap = <String, String>{
    'USD': 'assets/icons/usd.png',
    'EUR': 'assets/icons/eur.png',
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
      child: Text(code),
    );
  }
}
```

---

## Known Issues & Workarounds

### Generic issues (any icon generation)

| Issue | Cause | Fix |
|-------|-------|-----|
| Blurry output | Model adds blur/gloss/3D | Use "flat 2D vector NO blur NO 3D" + `vivid` colors |
| Wrong symbol | Ambiguous symbol name | Spell out explicitly: "$ dollar sign", "€ euro", "£ pound" |
| Flag/element not recognized | Obscure country/flag | Describe colors: "green yellow blue horizontal stripes" |
| Quota exhausted | Daily/weekly limit hit | Check `mmx quota show`, wait for reset (midnight UTC) |
| Element always blurry | Model weakness for that style | Regenerate simpler or accept + iterate tomorrow |
| Content filter triggered | Sensitive content in prompt | Rewrite prompt, avoid flagged terms |

### Per-currency issues (from currency-converter project experience)

| Currency | Issue | Workaround |
|----------|-------|------------|
| BRL | Brazil flag always slightly blurry | Accept — re-generate when quota allows |
| CLP | Chile flag blurry | Regenerate with "red white blue stripes with star" |
| ARS | Argentina sun sometimes ambiguous | Use "sun with face rays" description |
| GBP | UK flag (Union Jack) sometimes too dark | Regenerate with "bright vivid colors" |

---

## Workflow Summary

### Option A: Grid + crop (quota-efficient, recommended for icon sets)

1. **Check quota**: `mmx quota show` → confirm image-01 has remaining
2. **Design grid**: Plan layout (3x3 or 4x4), write prompt with all items
3. **Generate grid**: `mmx image generate --prompt "..." --out-dir .tmp/ --out-prefix grid --aspect-ratio 1:1`
4. **Crop**: `magick grid.png -crop WxH+X+Y +repage icon.png` per cell
5. **Verify**: `for f in .tmp/icons/*.png; do sips -g pixelWidth "$f"; done`
6. **Review quality**: `mmx vision describe --image icon.png` per icon (or use agent vision tool)
7. **Regenerate blurry ones**: Single `mmx image generate` with stronger keywords
8. **Resize/deploy**: `sips` to target platform directories
9. **Integrate**: Add to pubspec.yaml + wire into widget
10. **Verify**: Rebuild app, screenshot to confirm

### Option B: Batch n (multiple variations, pick best)

1. `mmx image generate --prompt "..." --n 3 --aspect-ratio 1:1 --out-dir ./out/`
2. Review all N outputs with `mmx vision describe` or agent vision tool
3. Pick the best, discard rest
4. Continue from step 8 above

### Quota math (Plus plan = 50/day)

| Method | Icons per quota | 50 daily quota = |
|--------|----------------|-----------------|
| Individual calls | 1 | 50 icons |
| `--n 3` batch (×50) | 3 | **150 icons** |
| `--n 9` max batch (×50) | 9 | **450 icons** |
| 3x3 grid | 9 | **450 icons** |
| 4x4 grid | 16 | **800 icons** |

For full command reference (text, video, speech, music, vision, search, exit codes,
piping patterns, config), see `mobile/minimax-cli.SKILL.md`.

---

## Project Example: Niduna Currency Converter

This skill was developed building the currency-converter Flutter app. Here's what was generated:

- **App launcher icon** (1): €↔£ intersecting blue/white design, deployed to Android (5 mipmap) + iOS (16 AppIcon sizes) + web favicon
- **32 currency flag icons** (flag bg + white symbol): ARS, AUD, BGN, BRL, CAD, CHF, CLP, CNY, COP, CZK, DKK, EUR, GBP, HKD, HUF, IDR, ILS, INR, JPY, KRW, MXN, MYR, NOK, NZD, PHP, PLN, RON, SEK, SGD, THB, TRY, TWD, USD, ZAR
- **Widget**: `CurrencyFlagIcon` in `lib/src/shared/widgets/currency_flag_icon.dart` — maps 32 codes to PNG assets with text-symbol fallback
- **Wired into**: Convert rate rows, amount panel, Charts pair selector, Chart picker tiles, Settings base picker, Convert picker sheet

See `.agent/skills/icon-generation/SKILL.md` in the currency-converter repo for the live version
with deploy scripts and per-currency known issues.