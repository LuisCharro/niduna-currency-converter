# Currency Badge Generation — Knowledge Base

> Working notes for generating currency badges for the Niduna currency-converter app.
> Last updated: 2026-05-16

## Current Verdict

The **v4 toolkit structure is better** than the earlier v3 tooling, but only after restoring the
historical context and color metadata from v3.

What improved:

- `.devtools/generate_currency_icons.sh` is now a proper CLI with `--quota`, `--anchor`,
  `--test-ref`, `--batch`, `--one CODE`, `--quality`, and `--deploy`.
- `.devtools/currency_icon_prompts.json` now stores generation controls per currency:
  `text_color`, `contrast_layer`, `subject_ref`, `notes`, and restored `flag_colors`.
- Subject-reference is no longer blindly applied to every currency.

What must stay preserved:

- The v2 audit results and v3 generation history explain why the new rules exist.
- Human QA overrides matter; a vision score can still miss issues like CLP showing `CL€`.

## Quick Reference

| Item | Value |
|------|-------|
| Tool | `mmx-cli` (`mmx image generate`) |
| Model | `image-01` |
| Plan quota | Plus plan = 50 images/day |
| Generate size | 1024×1024 |
| App asset size | 256×256 PNG in `assets/icons/currencies/` |
| Widget | `lib/src/shared/widgets/currency_flag_icon.dart` |
| v3 accepted sources | `.tmp/icon-v3/best/*.png` |
| v4 working sources | `.tmp/icon-v4/best/*.png` |
| Current script | `.devtools/generate_currency_icons.sh` |
| Resize tools | Prefer `sips` on macOS for simple resize; `magick` (ImageMagick) is also supported and better for crop workflows |

## Core Method

This project works best when prompts describe a **circular badge**, not an **icon**.

The winning loop is:

1. Generate one USD anchor at 1024×1024.
2. Manually review and copy the winner to `.tmp/icon-v4/best/usd.png`.
3. Test subject-reference on EUR and CHF.
4. Generate one currency at a time.
5. Disable subject-reference for drift-prone currencies.
6. Review each output manually or with vision.
7. Copy accepted sources to `.tmp/icon-v4/best/`.
8. Run `--deploy` to downscale/copy into `assets/icons/currencies/`.
9. Rebuild the iOS simulator app and inspect at actual app sizes.

## Provider Pipelines

The generator script supports two providers from the same prompt JSON:

| Provider | Command | Output root | Notes |
|----------|---------|-------------|-------|
| MiniMax | `--provider minimax` | `.tmp/icon-v4/minimax/` | Default; supports `--subject-ref` from the USD anchor when JSON allows it. |
| OpenAI | `--provider openai` | `.tmp/icon-v4/openai/` | Requires `OPENAI_API_KEY`; text-to-image only in this script, no reference image style transfer yet. |

Examples:

```bash
# MiniMax (default)
.devtools/generate_currency_icons.sh --one CLP

# OpenAI
OPENAI_API_KEY=... .devtools/generate_currency_icons.sh --provider openai --one CLP

# OpenAI quality/cost knobs
OPENAI_IMAGE_MODEL=gpt-image-1 \
OPENAI_IMAGE_QUALITY=medium \
OPENAI_IMAGE_SIZE=1024x1024 \
  .devtools/generate_currency_icons.sh --provider openai --one CLP
```

## Non-Negotiable Prompt Rules

Use these ideas in every prompt:

- `badge`, not `icon`
- `plain white background`
- `perfect filled circle`
- `flat 2D graphic`
- `NO 3D`
- `NO gloss`
- `NO shadow outside circle`
- `NO drop shadow`
- `NO long shadow`
- `NO bevel`
- `NO emboss`
- `NO ring`
- `NO bubble border`
- `NO gradient`

Do **not** use `--prompt-optimizer`; it can reintroduce shadow/gloss language.

## Prompt Builder

The v4 script builds prompts from `.devtools/currency_icon_prompts.json`:

```text
A simple circular badge for [name] currency on plain white background.
The badge is a perfect filled circle.
Inside: [flag_desc].
Over the center sits a large bold [text_color] text [symbol].
Use these flag color references: [flag_colors].
[Optional contrast-layer sentence]
[Optional per-currency notes]
Flat 2D graphic NO 3D NO gloss NO shadow outside circle.
NO drop shadow NO long shadow NO bevel NO emboss NO ring NO bubble border NO gradient.
Plain white background. Ultra sharp crisp edges.
```

## Subject-Reference Policy

Subject-reference helps style consistency, but it caused drift on several currencies.

Use `subject_ref: "never"` for:

- JPY
- CAD
- AUD
- INR
- SGD
- CLP
- PHP
- COP

Why:

- JPY drifted into 3D/gloss.
- CAD got blurry.
- AUD produced the wrong symbol / over-complex style.
- INR failed tricolor handling and needed solid saffron.
- SGD became cartoon-like.
- CLP confused `$`, `€`, and `₱`.
- PHP needed sharp symbol handling.
- COP repeatedly gained glossy bubble rings.

## Vision Quality Check

Preferred review order:

| Rank | Method | Notes |
|------|--------|-------|
| 1 | Native multimodal review | Best for quick human-like accept/reject and catching symbol mistakes |
| 2 | `zai-mcp-server_analyze_image` | Useful structured scoring, but can be over-generous |
| 3 | `MiniMax_understand_image` | Good when connected, but unreliable |
| 4 | `mmx vision describe` | Avoid for normal QA; it burns quota and was inconsistent |

Quality rubric:

- Sharpness: 1–5
- Flag accuracy: 1–5
- Symbol clarity: 1–5

Accept only if the average is >= 3.5 **and** there are no human-visible dealbreakers.

## v2 Audit Summary

The old v2 set averaged around 2/5. Common problems:

- Long shadows / drop shadows muddied the icon at 26–40px.
- Glossy Web 2.0 / skeuomorphic look.
- White symbols disappeared on white flag areas.
- Flag details were too complex after downscaling.
- Several symbols were wrong or unreadable.

Score distribution from the v2 audit:

| Score | Count | Codes |
|-------|-------|-------|
| 4.0 | 1 | CHF |
| 3.75 | 1 | SEK |
| 3.0 | 2 | EUR, RON |
| 2.5 | 5 | AUD, BGN, CAD, NOK, NZD/CZK area |
| <2.5 | 25 | Most of the set |

Worst v2 cases:

- COP: extreme blur, about 1/5.
- TRY: missing star / not recognizable, about 1/5.
- THB: wrong text (`TBB`) and blur.
- CLP/MXN/PLN/GBP: white-on-white or wrong symbol issues.

## v3 Generation Results

The first complete v3 run generated 34/34 currency badges and deployed 256×256 assets.

What worked:

- `badge` prompt framing solved the baked-in long-shadow behavior.
- Single-shot generation was sharper than batch variations.
- 1024×1024 source → 256×256 asset was visibly better than old 128×128 assets.
- Solid-color simplification worked well for BRL and INR.

Notable v3 wins:

- BRL improved from blurry/garbled to a clean green/yellow `R$` badge.
- COP improved dramatically in automated scoring, but human review later disliked the glossy ring.
- INR succeeded after switching from tricolor to solid saffron with navy `₹`.
- EUR needed an explicit `exactly twelve yellow stars` instruction.

Human review follow-ups from the v3 set:

- CLP: wrong symbol (`CL€` / later `CL₱` attempts). Use plain `$` only.
- COP: visually ugly glossy bubble ring. Forbid ring/border/bubble frame and review manually.
- EUR: initial version lost stars; v4 candidate fixed 12 stars.
- PHP: initial version looked blurry; v4 candidate improved sharpness.

## Known Currency-Specific Fixes

| Code | Fix |
|------|-----|
| EUR | Say **exactly twelve yellow stars arranged in a circle**. |
| JPY | Keep prompt extremely simple; no subject-ref. |
| CAD | No subject-ref; use simple red-white split and plain `$`. |
| AUD | No subject-ref; keep simplified Union Jack/star cluster. |
| INR | Use solid saffron/orange background, not tricolor. |
| BRL | Solid green background with yellow `R$` gives sharper output. |
| TRY | Require **crescent moon and five-pointed star**. |
| CLP | Use only a plain `$`; avoid `CL$` if the model confuses it. |
| PHP | Emphasize `₱` shape and ultra-sharp crisp edges. |
| THB | Say Thai baht symbol `฿`, not `TBB`. |
| SGD | No subject-ref; avoid anything cartoon-like. |
| COP | No subject-ref; forbid glossy ring, border, bevel, and bubble frame. |

## Commands

```bash
# Check quota
.devtools/generate_currency_icons.sh --quota

# Generate USD anchor candidate
.devtools/generate_currency_icons.sh --anchor

# Generate subject-ref test candidates
.devtools/generate_currency_icons.sh --test-ref

# Generate one currency
.devtools/generate_currency_icons.sh --one CLP

# Generate one currency with OpenAI
OPENAI_API_KEY=... .devtools/generate_currency_icons.sh --provider openai --one CLP

# Generate remaining currencies missing from best/
.devtools/generate_currency_icons.sh --batch

# Write QA guide
.devtools/generate_currency_icons.sh --quality

# Deploy accepted best/ images to app assets
.devtools/generate_currency_icons.sh --deploy
```

Provider-specific deploy uses the selected provider's `best/` folder:

```bash
.devtools/generate_currency_icons.sh --provider minimax --deploy
.devtools/generate_currency_icons.sh --provider openai --deploy
```

The deploy step resizes accepted source images to 256×256. It uses macOS `sips` when
available and falls back to ImageMagick `magick`. If future grid/crop workflows return, use
`magick` for cropping; for the current one-badge-per-image workflow, resize-only is enough.

After deploy, rebuild the simulator app:

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} \
  BUNDLE_ID=com.niduna.currencyConverter \
  ./.devtools/sim_reinstall_build.sh
```

## App Integration

- Final app assets live at `assets/icons/currencies/*.png`.
- `CurrencyFlagIcon` maps currency codes to asset paths.
- `pubspec.yaml` includes `assets/icons/currencies/` under Flutter assets.
