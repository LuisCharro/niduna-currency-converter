# Skill: Currency Badge Generation

Use this skill to regenerate the fintech app's circular currency badges with MiniMax `image-01`.
The same script can also use the OpenAI Images API when `--provider openai` is passed.

## Inputs

- Prompt definitions:
  - `.devtools/currency_icon_prompts.json`
  - Each entry should include `symbol`, `text_color`, `flag_desc`, `flag_colors`,
    `contrast_layer`, `subject_ref`, and `notes`.
- Generator script:
  - `.devtools/generate_currency_icons.sh`
- Approved style anchor:
  - `.tmp/icon-v4/best/usd.png`

## Recommended commands

```bash
.devtools/generate_currency_icons.sh --quota
.devtools/generate_currency_icons.sh --anchor
.devtools/generate_currency_icons.sh --test-ref
.devtools/generate_currency_icons.sh --batch
.devtools/generate_currency_icons.sh --quality
.devtools/generate_currency_icons.sh --deploy
```

To use OpenAI instead of MiniMax:

```bash
OPENAI_API_KEY=... .devtools/generate_currency_icons.sh --provider openai --one CLP
OPENAI_API_KEY=... .devtools/generate_currency_icons.sh --provider openai --batch
.devtools/generate_currency_icons.sh --provider openai --deploy
```

OpenAI tuning environment variables:

```bash
OPENAI_IMAGE_MODEL=gpt-image-1
OPENAI_IMAGE_QUALITY=low|medium|high
OPENAI_IMAGE_SIZE=1024x1024
```

To regenerate one currency only:

```bash
.devtools/generate_currency_icons.sh --one EUR
```

## Prompt strategy

Always frame the asset as a **badge**:

- circular badge
- perfect filled circle
- plain white background
- flat 2D graphic

Never rely on the word **icon**, and never use `--prompt-optimizer`.

## Subject-reference

Use subject-reference from the approved USD anchor only when the JSON entry allows it and the
provider is MiniMax.

The OpenAI path is currently text-to-image only. Keep its outputs under `.tmp/icon-v4/openai/`
and compare them manually with MiniMax outputs before deploying.

The following default to `subject_ref: "never"` because they previously drifted or became unstable:

- JPY
- CAD
- AUD
- INR
- SGD
- CLP
- PHP
- COP

## Review expectations

Before accepting a badge, verify:

- no long/drop shadow
- no glossy edge or bubble frame
- correct centered currency symbol
- correct currency-specific symbol, not just a plausible symbol
- usable readability at small app sizes
- reasonably faithful simplified flag treatment

Accept after manual QA when average score is at least **3.5 / 5** across sharpness, flag accuracy, and symbol clarity.

## Resize/crop tooling

The deploy step supports macOS `sips` and ImageMagick `magick`. Use `magick` for any future
crop/grid workflow. For the current workflow, generate one 1024×1024 badge per image and resize
to 256×256 rather than asking the model for a small badge or a badge in one corner.

## Historical context

Do not delete `.agent/ICON_GENERATION_KNOWLEDGE.md` details when updating this skill. The
knowledge file records the failed prompt patterns, v2 audit, v3 generation results, and human
review follow-ups that explain why this workflow is strict about badge wording, selective
subject-reference, and manual QA.
