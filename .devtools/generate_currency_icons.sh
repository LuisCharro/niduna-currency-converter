#!/usr/bin/env bash
#
# generate_currency_icons.sh — Generate flat circular currency badges via MiniMax or OpenAI
#
# Usage:
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --quota
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --anchor
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --test-ref
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --batch
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --one CODE
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --quality
#   .devtools/generate_currency_icons.sh [--provider minimax|openai] --deploy
#
# Design decisions:
# - Use the word "badge", not "icon"
# - Never use --prompt-optimizer
# - Generate one image at a time for sharper single-shot results
# - MiniMax: use subject-ref only for currencies that allow it in JSON
# - OpenAI: text-to-image only for now; no subject-ref/reference image pipeline
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS_FILE="$SCRIPT_DIR/currency_icon_prompts.json"

PROVIDER="${IMAGE_PROVIDER:-minimax}"
COMMAND=""
COMMAND_ARG=""

OPENAI_IMAGE_MODEL="${OPENAI_IMAGE_MODEL:-gpt-image-1}"
OPENAI_IMAGE_QUALITY="${OPENAI_IMAGE_QUALITY:-medium}"
OPENAI_IMAGE_SIZE="${OPENAI_IMAGE_SIZE:-1024x1024}"

MINIMAX_IMAGE_MODEL="${MINIMAX_IMAGE_MODEL:-image-01}"

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --provider)
        PROVIDER="${2:-}"
        [[ -n "$PROVIDER" ]] || {
          log "ERROR: --provider requires minimax or openai"
          exit 1
        }
        shift 2
        ;;
      --quota|--anchor|--test-ref|--batch|--quality|--deploy)
        COMMAND="$1"
        shift
        ;;
      --one)
        COMMAND="$1"
        COMMAND_ARG="${2:-}"
        shift 2
        ;;
      *)
        log "ERROR: unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  case "$PROVIDER" in
    minimax|openai) ;;
    *)
      log "ERROR: unsupported provider: $PROVIDER"
      log "Supported providers: minimax, openai"
      exit 1
      ;;
  esac
}

OUT_DIR_BASE="$PROJECT_ROOT/.tmp/icon-v4"
OUT_DIR=""
ANCHOR_DIR="$OUT_DIR/anchor"
TEST_REF_DIR="$OUT_DIR/test-ref"
SINGLES_DIR="$OUT_DIR/singles"
BEST_DIR="$OUT_DIR/best"
LOG_DIR="$OUT_DIR/logs"
QUALITY_REPORT="$OUT_DIR/quality-review.md"

FINAL_DIR="$PROJECT_ROOT/assets/icons/currencies"

GENERATE_SIZE=1024
TARGET_SIZE=256
ANCHOR_CODE="USD"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

usage() {
  cat <<'USAGE'
Usage:
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --quota
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --anchor
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --test-ref
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --batch
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --one CODE
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --quality
  .devtools/generate_currency_icons.sh [--provider minimax|openai] --deploy

Environment:
  IMAGE_PROVIDER=minimax|openai        Default provider if --provider is omitted
  OPENAI_API_KEY=...                  Required for --provider openai generation
  OPENAI_IMAGE_MODEL=gpt-image-1      OpenAI model override
  OPENAI_IMAGE_QUALITY=low|medium|high
  OPENAI_IMAGE_SIZE=1024x1024
USAGE
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    log "ERROR: required command not found: $1"
    exit 1
  }
}

lowercase() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

check_prereqs() {
  local mode="${1:-generation}"
  require_cmd python3
  [[ -f "$PROMPTS_FILE" ]] || {
    log "ERROR: prompts file not found: $PROMPTS_FILE"
    exit 1
  }
  case "$PROVIDER" in
    minimax)
      if [[ "$mode" != "deploy" ]]; then
        require_cmd mmx
      fi
      ;;
    openai)
      if [[ "$mode" != "deploy" ]]; then
        [[ -n "${OPENAI_API_KEY:-}" ]] || {
          log "ERROR: OPENAI_API_KEY is not set"
          exit 1
        }
        python3 - <<'PY' >/dev/null 2>&1 || {
import openai
PY
          log "ERROR: Python package 'openai' is not installed"
          log "Install with: python3 -m pip install openai"
          exit 1
        }
      fi
      ;;
  esac
  if command -v sips >/dev/null 2>&1; then
    RESIZE_TOOL="sips"
  elif command -v magick >/dev/null 2>&1; then
    RESIZE_TOOL="magick"
  else
    RESIZE_TOOL=""
  fi
}

configure_paths() {
  OUT_DIR="$OUT_DIR_BASE/$PROVIDER"
  ANCHOR_DIR="$OUT_DIR/anchor"
  TEST_REF_DIR="$OUT_DIR/test-ref"
  SINGLES_DIR="$OUT_DIR/singles"
  BEST_DIR="$OUT_DIR/best"
  LOG_DIR="$OUT_DIR/logs"
  QUALITY_REPORT="$OUT_DIR/quality-review.md"
  mkdir -p "$ANCHOR_DIR" "$TEST_REF_DIR" "$SINGLES_DIR" "$BEST_DIR" "$LOG_DIR" "$FINAL_DIR"
}

quota_remaining() {
  case "$PROVIDER" in
    minimax)
      mmx quota show --quiet --non-interactive 2>/dev/null | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    print("?")
    raise SystemExit
for item in data.get("model_remains", []):
    if item.get("model_name") == "image-01":
        total = item.get("current_interval_total_count", 0)
        used = item.get("current_interval_usage_count", 0)
        print(max(total - used, 0))
        raise SystemExit
print("?")
'
      ;;
    openai)
      echo "OpenAI API has billing/rate limits instead of mmx-style daily image quota. Check dashboard usage."
      ;;
  esac
}

all_codes() {
  python3 - "$PROMPTS_FILE" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    rows = json.load(f)
for row in rows:
    print(row["code"])
PY
}

json_value() {
  local code="$1"
  local key="$2"
  python3 - "$PROMPTS_FILE" "$code" "$key" <<'PY'
import json, sys
path, code, key = sys.argv[1], sys.argv[2].upper(), sys.argv[3]
with open(path, "r", encoding="utf-8") as f:
    rows = json.load(f)
row = next((r for r in rows if r["code"].upper() == code), None)
if row is None:
    raise SystemExit(f"Unknown currency code: {code}")
value = row.get(key, "")
if isinstance(value, bool):
    print("true" if value else "false")
else:
    print(value)
PY
}

build_prompt() {
  local code="$1"
  python3 - "$PROMPTS_FILE" "$code" <<'PY'
import json, sys
path, code = sys.argv[1], sys.argv[2].upper()
with open(path, "r", encoding="utf-8") as f:
    rows = json.load(f)
row = next((r for r in rows if r["code"].upper() == code), None)
if row is None:
    raise SystemExit(f"Unknown currency code: {code}")

parts = [
    f"A simple circular badge for {row['name']} currency on plain white background.",
    "The badge is a perfect filled circle.",
    f"Inside: {row['flag_desc']}.",
    f"Over the center sits a large bold {row['text_color']} text {row['symbol']}.",
]
flag_colors = (row.get("flag_colors") or "").strip()
if flag_colors:
    parts.append(f"Use these flag color references: {flag_colors}.")
if row.get("contrast_layer"):
    parts.append("Behind the symbol is a dark semi-transparent circular layer for contrast.")
notes = (row.get("notes") or "").strip()
if notes:
    parts.append(notes)
parts.extend([
    "Flat 2D graphic NO 3D NO gloss NO shadow outside circle.",
    "NO drop shadow NO long shadow NO bevel NO emboss NO ring NO bubble border NO gradient.",
    "Plain white background. Ultra sharp crisp edges.",
])
print(" ".join(parts))
PY
}

subject_ref_allowed() {
  local code="$1"
  [[ "$(json_value "$code" "subject_ref")" != "never" ]]
}

generate_one() {
  local code="$1"
  local target_dir="$2"
  local prefix="$3"
  local anchor_path="${4:-}"

  local prompt
  prompt="$(build_prompt "$code")"

  case "$PROVIDER" in
    minimax)
      generate_one_minimax "$code" "$target_dir" "$prefix" "$anchor_path" "$prompt"
      ;;
    openai)
      generate_one_openai "$code" "$target_dir" "$prefix" "$prompt"
      ;;
  esac
}

generate_one_minimax() {
  local code="$1"
  local target_dir="$2"
  local prefix="$3"
  local anchor_path="${4:-}"
  local prompt="$5"

  local -a cmd=(
    mmx image generate
    --prompt "$prompt"
    --width "$GENERATE_SIZE"
    --height "$GENERATE_SIZE"
    --aspect-ratio 1:1
    --out-dir "$target_dir"
    --out-prefix "$prefix"
    --quiet
    --non-interactive
  )

  if [[ -n "$anchor_path" && -f "$anchor_path" && "$code" != "$ANCHOR_CODE" ]] && subject_ref_allowed "$code"; then
    cmd+=(--subject-ref "type=character,image=${anchor_path}")
  fi

  "${cmd[@]}"
}

generate_one_openai() {
  local code="$1"
  local target_dir="$2"
  local prefix="$3"
  local prompt="$4"
  local output_path="$target_dir/${prefix}_001.png"

  mkdir -p "$target_dir"
  OPENAI_IMAGE_MODEL="$OPENAI_IMAGE_MODEL" \
  OPENAI_IMAGE_QUALITY="$OPENAI_IMAGE_QUALITY" \
  OPENAI_IMAGE_SIZE="$OPENAI_IMAGE_SIZE" \
  OPENAI_IMAGE_PROMPT="$prompt" \
  OPENAI_IMAGE_OUTPUT="$output_path" \
  python3 <<'PY'
import base64
import os
import urllib.request

from openai import OpenAI

client = OpenAI()
kwargs = {
    "model": os.environ["OPENAI_IMAGE_MODEL"],
    "prompt": os.environ["OPENAI_IMAGE_PROMPT"],
    "size": os.environ["OPENAI_IMAGE_SIZE"],
    "n": 1,
}

quality = os.environ.get("OPENAI_IMAGE_QUALITY", "").strip()
if quality:
    kwargs["quality"] = quality

result = client.images.generate(**kwargs)
image = result.data[0]
output_path = os.environ["OPENAI_IMAGE_OUTPUT"]

if getattr(image, "b64_json", None):
    with open(output_path, "wb") as f:
        f.write(base64.b64decode(image.b64_json))
elif getattr(image, "url", None):
    urllib.request.urlretrieve(image.url, output_path)
else:
    raise RuntimeError("OpenAI image response had neither b64_json nor url")

print(output_path)
PY
  log "Saved OpenAI $code badge: $output_path"
}

generate_anchor() {
  log "Generating USD anchor candidate with provider: $PROVIDER..."
  generate_one "$ANCHOR_CODE" "$ANCHOR_DIR" "usd-anchor"
  log "Review the output in: $ANCHOR_DIR"
  log "Copy the approved anchor to: $BEST_DIR/usd.png"
}

test_subject_ref() {
  local anchor="$BEST_DIR/usd.png"
  [[ -f "$anchor" ]] || {
    log "ERROR: missing approved USD anchor at $anchor"
    exit 1
  }

  if [[ "$PROVIDER" == "openai" ]]; then
    log "OpenAI provider does not use subject-ref in this script; generating EUR/CHF style checks without reference image."
  fi

  log "Generating EUR provider consistency test..."
  generate_one EUR "$TEST_REF_DIR" "eur-ref-test" "$anchor"

  log "Generating CHF provider consistency test..."
  generate_one CHF "$TEST_REF_DIR" "chf-ref-test" "$anchor"

  log "Review provider consistency tests in: $TEST_REF_DIR"
}

batch_generate() {
  local anchor="$BEST_DIR/usd.png"
  [[ -f "$anchor" ]] || {
    log "ERROR: missing approved USD anchor at $anchor"
    exit 1
  }

  while IFS= read -r code; do
    [[ "$code" == "$ANCHOR_CODE" ]] && continue
    local code_lower
    code_lower="$(lowercase "$code")"

    if compgen -G "$BEST_DIR/${code_lower}.*" >/dev/null; then
      log "SKIP $code — already present in best/"
      continue
    fi

    log "Generating $code..."
    if ! generate_one "$code" "$SINGLES_DIR" "${code_lower}-v4" "$anchor" 2>>"$LOG_DIR/batch.log"; then
      log "FAILED $code — see $LOG_DIR/batch.log"
    fi

    sleep 1
  done < <(all_codes)

  log "Batch generation finished. Review outputs in: $SINGLES_DIR"
}

generate_single() {
  local code="${1:-}"
  [[ -n "$code" ]] || {
    log "ERROR: --one requires a currency code, e.g. --one EUR"
    exit 1
  }

  local anchor="$BEST_DIR/usd.png"
  local code_lower
  code_lower="$(lowercase "$code")"
  if [[ -f "$anchor" ]]; then
    generate_one "$code" "$SINGLES_DIR" "${code_lower}-manual" "$anchor"
  else
    generate_one "$code" "$SINGLES_DIR" "${code_lower}-manual"
  fi
}

write_quality_guide() {
  cat > "$QUALITY_REPORT" <<'MD'
# Currency Badge Quality Review

Rate each generated badge from 1 to 5 for:

- Sharpness
- Flag accuracy
- Symbol clarity

Accept when the average is **>= 3.5**.

Suggested vision prompt:

> Rate [CURRENCY] badge 1-5 for: Sharpness, Flag accuracy, Symbol clarity.  
> Score format: Sharp:X Flag:X Symbol:X. Accept if average >= 3.5.

Recommended manual checks:

- The badge is a perfect filled circle.
- The background outside the circle is plain white.
- There is no glossy ring, 3D frame, bevel, drop shadow, or long shadow.
- The currency symbol is correct and centered.
- White symbols over pale flag areas remain readable.
MD

  log "Wrote QA guide to: $QUALITY_REPORT"
}

deploy_best() {
  [[ -n "${RESIZE_TOOL:-}" ]] || {
    log "ERROR: no supported resize tool found. Install ImageMagick or run on macOS with sips."
    exit 1
  }

  local deployed=0
  local src stem target
  shopt -s nullglob
  for src in "$BEST_DIR"/*; do
    [[ -f "$src" ]] || continue
    stem="$(basename "${src%.*}")"
    target="$FINAL_DIR/$stem.png"

    if [[ "$RESIZE_TOOL" == "sips" ]]; then
      sips -s format png -z "$TARGET_SIZE" "$TARGET_SIZE" "$src" --out "$target" >/dev/null
    else
      magick "$src" -resize "${TARGET_SIZE}x${TARGET_SIZE}!" "$target"
    fi

    deployed=$((deployed + 1))
  done
  shopt -u nullglob

  log "Deployed $deployed badge(s) to: $FINAL_DIR"
}

parse_args "$@"
configure_paths

case "$COMMAND" in
  --quota)
    if [[ "$PROVIDER" == "minimax" ]]; then
      check_prereqs
    fi
    log "$PROVIDER quota/status: $(quota_remaining)"
    ;;
  --anchor)
    check_prereqs
    generate_anchor
    ;;
  --test-ref)
    check_prereqs
    test_subject_ref
    ;;
  --batch)
    check_prereqs
    batch_generate
    ;;
  --one)
    check_prereqs
    generate_single "$COMMAND_ARG"
    ;;
  --quality)
    write_quality_guide
    ;;
  --deploy)
    check_prereqs deploy
    deploy_best
    ;;
  *)
    usage
    ;;
esac
