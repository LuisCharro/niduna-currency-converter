#!/usr/bin/env bash
#
# generate_currency_icons.sh — Regenerate all currency flag icons via MiniMax image-01
#
# Usage:
#   ./generate_currency_icons.sh              # Full pipeline (anchor → test → batch → deploy)
#   ./generate_currency_icons.sh --anchor     # Step 1 only: generate anchor (9 quota)
#   ./generate_currency_icons.sh --test-ref   # Step 2 only: test subject-reference (3 quota)
#   ./generate_currency_icons.sh --batch      # Step 3 only: generate remaining (~32 quota)
#   ./generate_currency_icons.sh --quality    # Step 4 only: quality gate + report
#   ./generate_currency_icons.sh --deploy     # Step 5 only: resize + copy to assets
#
# Quota budget: ~46 of 50/day (Plus plan)
#   - Anchor:       9 quota  (--n 9 for USD)
#   - Subject-ref:  3 quota  (EUR + CHF test)
#   - Batch gen:   ~32 quota (remaining 31 currencies)
#   - Regens:       ~6 quota (buffer for failures)
#
# Output:
#   .tmp/icon-v3/anchor/     — anchor generation
#   .tmp/icon-v3/test-ref/   — subject-ref test
#   .tmp/icon-v3/singles/    — individual currency icons
#   .tmp/icon-v3/best/       — curated best picks
#   assets/icons/currencies/ — final deployed icons (256x256)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS_FILE="$SCRIPT_DIR/currency_icon_prompts.json"
OUT_DIR="$PROJECT_ROOT/.tmp/icon-v3"
FINAL_DIR="$PROJECT_ROOT/assets/icons/currencies"
ANCHOR_DIR="$OUT_DIR/anchor"
TEST_REF_DIR="$OUT_DIR/test-ref"
SINGLES_DIR="$OUT_DIR/singles"
BEST_DIR="$OUT_DIR/best"
QUALITY_LOG="$OUT_DIR/quality-report.txt"

TARGET_SIZE=256
GENERATE_SIZE=1024

# Style lock prefix — prepended to EVERY prompt for consistency
STYLE_LOCK="Geometric flat circular icon. NO drop shadow NO long shadow NO glow NO bevel NO emboss NO gloss NO gradient NO 3D. Flat vector design style like modern fintech app icon. Crisp clean pixel-perfect edges. Vivid solid colors only. Circle background filled with stylized simplified flag pattern. Center overlay: bold thick white currency symbol with subtle dark semi-transparent circle behind it for contrast."

mkdir -p "$ANCHOR_DIR" "$TEST_REF_DIR" "$SINGLES_DIR" "$BEST_DIR" "$OUT_DIR/logs"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }

check_prereqs() {
  log "Checking prerequisites..."
  if ! command -v mmx &>/dev/null; then
    log "ERROR: mmx-cli not found. Run: npm install -g mmx-cli"
    exit 1
  fi
  if ! command -v magick &>/dev/null; then
    log "ERROR: ImageMagick not found. Run: brew install imagemagick"
    exit 1
  fi
  if ! command -v sips &>/dev/null; then
    log "ERROR: sips not found (macOS only)"
    exit 1
  fi
  if [ ! -f "$PROMPTS_FILE" ]; then
    log "ERROR: Prompts file not found: $PROMPTS_FILE"
    exit 1
  fi
  log "mmx $(mmx --version 2>&1 | head -1)"
}

check_quota() {
  log "Checking quota..."
  local remaining
  remaining=$(mmx quota show --quiet --non-interactive 2>/dev/null | \
    python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d.get('model_remains',[]):
    if m['model_name']=='image-01':
        daily=m['current_interval_total_count']-m['current_interval_usage_count']
        print(daily)
        sys.exit()
print('0')
" 2>/dev/null || echo "?")
  log "image-01 daily remaining: ${remaining}"
  echo "$remaining"
}

build_prompt() {
  local code="$1"
  local symbol="$2"
  local flag_desc="$3"

  echo "${STYLE_LOCK} Currency: ${code}. Symbol: bold white \"${symbol}\" centered. Flag: ${flag_desc}. The circular background shows a stylized simplified version of this country's flag using flat solid color areas only."
}

generate_anchor() {
  log "=== STEP 1: ANCHOR GENERATION (9 quota) ==="
  log "Generating USD anchor at ${GENERATE_SIZE}x${GENERATE_SIZE} with --n 9..."

  local prompt
  prompt=$(build_prompt "USD" "\$" "red and white horizontal stripes, blue canton upper left with white star dots, simplified to bold red-white-blue geometric blocks")

  mmx image generate \
    --prompt "$prompt" \
    --n 9 \
    --width "$GENERATE_SIZE" \
    --height "$GENERATE_SIZE" \
    --aspect-ratio 1:1 \
    --prompt-optimizer \
    --seed 42 \
    --out-dir "$ANCHOR_DIR" \
    --out-prefix usd-anchor \
    --quiet \
    --non-interactive \
    2>>"$OUT_DIR/logs/anchor.log"

  log "Anchor files generated:"
  ls -la "$ANCHOR_DIR/"*.png "$ANCHOR_DIR/"*.jpg 2>/dev/null | awk '{print "  " $NF}' || log "  (no files yet)"

  log ""
  log "MANUAL ACTION REQUIRED: Review the 9 USD anchor candidates and pick the best one."
  log "  Files are in: $ANCHOR_DIR/"
  log "  Copy the best to: $BEST_DIR/usd.png"
  log "  Then run: $0 --test-ref"
}

test_subject_ref() {
  log "=== STEP 2: SUBJECT-REFERENCE TEST (3 quota) ==="

  local anchor="$BEST_DIR/usd.png"
  if [ ! -f "$anchor" ]; then
    log "ERROR: Anchor not found at $anchor. Run --anchor first and pick best."
    exit 1
  fi

  log "Testing subject-ref consistency with EUR and CHF..."
  log "Anchor: $anchor"

  local eur_prompt chf_prompt
  eur_prompt=$(build_prompt "EUR" "€" "solid blue circle with ring of yellow star dots around perimeter, European Union flag")
  chf_prompt=$(build_prompt "CHF" "Fr" "solid red background with white equilateral cross centered, Swiss cross flag")

  # Test EUR with subject-ref
  log "Generating EUR with subject-ref..."
  mmx image generate \
    --prompt "$eur_prompt" \
    --subject-ref "type=character,image=${anchor}" \
    --n 1 \
    --width "$GENERATE_SIZE" \
    --height "$GENERATE_SIZE" \
    --aspect-ratio 1:1 \
    --prompt-optimizer \
    --out-dir "$TEST_REF_DIR" \
    --out-prefix eur-ref-test \
    --quiet \
    --non-interactive \
    2>>"$OUT_DIR/logs/ref-test.log"

  # Test CHF with subject-ref
  log "Generating CHF with subject-ref..."
  mmx image generate \
    --prompt "$chf_prompt" \
    --subject-ref "type=character,image=${anchor}" \
    --n 1 \
    --width "$GENERATE_SIZE" \
    --height "$GENERATE_SIZE" \
    --aspect-ratio 1:1 \
    --prompt-optimizer \
    --out-dir "$TEST_REF_DIR" \
    --out-prefix chf-ref-test \
    --quiet \
    --non-interactive \
    2>>"$OUT_DIR/logs/ref-test.log"

  log ""
  log "Subject-ref test files:"
  ls -la "$TEST_REF_DIR/"*ref* 2>/dev/null | awk '{print "  " $NF}' || log "  (no files)"
  log ""
  log "MANUAL ACTION REQUIRED: Compare EUR/CHF ref outputs against anchor style."
  log "  If style matches well → run --batch (will use subject-ref for all)"
  log "  If style drifts → edit this script: set USE_SUBJECT_REF=false"
}

USE_SUBJECT_REF=true

batch_generate() {
  log "=== STEP 3: BATCH GENERATION ==="

  local anchor="$BEST_DIR/usd.png"
  if [ ! -f "$anchor" ]; then
    log "ERROR: Anchor not found. Run --anchor first."
    exit 1
  fi

  local ref_flag=""
  if [ "$USE_SUBJECT_REF" = true ] && [ -f "$anchor" ]; then
    ref_flag="--subject-ref type=character,image=${anchor}"
    log "Using subject-ref mode (style-consistent from anchor)"
  else
    log "Using consistent-prompt-prefix mode (no subject-ref)"
  fi

  local total=0
  local skip_codes=("USD")

  while IFS= read -r line; do
    code=$(echo "$line" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['code'])" 2>/dev/null)
    symbol=$(echo "$line" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['symbol'])" 2>/dev/null)
    flag_desc=$(echo "$line" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['flag_desc'])" 2>/dev/null)

    [ -z "$code" ] && continue

    # Skip already-generated codes
    for skip in "${skip_codes[@]}"; do
      if [ "$code" = "$skip" ]; then
        log "  SKIP $code (already have anchor)"
        continue 2
      fi
    done

    # Skip if best already exists
    if [ -f "$BEST_DIR/${code,,}.png" ]; then
      log "  SKIP $code (already in best/)"
      continue
    fi

    total=$((total + 1))
    prompt=$(build_prompt "$code" "$symbol" "$flag_desc")

    log "  [$total] Generating ${code} ($symbol)..."

    mmx image generate \
      --prompt "$prompt" \
      $ref_flag \
      --n 1 \
      --width "$GENERATE_SIZE" \
      --height "$GENERATE_SIZE" \
      --aspect-ratio 1:1 \
      --prompt-optimizer \
      --out-dir "$SINGLES_DIR" \
      --out-prefix "${code,,}-v3" \
      --quiet \
      --non-interactive \
      2>>"$OUT_DIR/logs/batch.log" && \
      log "  [$total] ${code} OK" || \
      log "  [$total] ${code} FAILED (see logs/batch.log)"

    sleep 1
  done < <(python3 -c "
import json
with open('$PROMPTS_FILE') as f:
    data = json.load(f)
for item in data:
    print(json.dumps(item))
")

  log ""
  log "Batch complete. Generated: $total currencies"
  log "Output: $SINGLES_DIR/"
}

quality_gate() {
  log "=== STEP 4: QUALITY GATE ==="
  log "Running vision quality check on all generated icons..."

  echo "# Icon Quality Report — $(date)" > "$QUALITY_LOG"
  echo "" >> "$QUALITY_LOG"
  echo "| Code | Sharpness | Flag OK | Symbol OK | Verdict |" >> "$QUALITY_LOG"
  echo "|------|-----------|---------|-----------|---------|" >> "$QUALITY_LOG"

  local pass=0 fail=0

  for f in "$SINGLES_DIR/"*-v3_001.* "$TEST_REF_DIR/"*ref*_001.* "$ANCHOR_DIR/"usd-anchor_001.*; do
    [ -f "$f" ] || continue

    local fname
    fname=$(basename "$f")
    local code
    code=$(echo "$fname" | sed 's/-v3_001\..*//' | sed 's/-ref-test_001\..*//' | sed 's/-anchor_001\..*//')

    log "  Checking $code..."
    local result
    result=$(mmx vision describe \
      --image "$f" \
      --prompt "Rate this fintech currency icon for 26-40px display. Reply ONLY as: SHARPNESS:x/5 FLAG:x/5 SYMBOL:x/5 VERDICT:PASS or FAIL. One line." \
      --quiet \
      --non-interactive 2>/dev/null | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
    print(d.get('content','')[:200])
except: print('PARSE_ERROR')
" 2>/dev/null)

    local verdict="FAIL"
    echo "$result" | grep -qi "VERDICT:PASS" && verdict="PASS"

    if [ "$verdict" = "PASS" ]; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
    fi

    echo "| ${code^^} | $result | $verdict |" >> "$QUALITY_LOG"

    if [ "$verdict" = "PASS" ]; then
      cp "$f" "$BEST_DIR/${code,,}.png" 2>/dev/null
    fi
  done

  echo "" >> "$QUALITY_LOG"
  echo "**Summary: $pass passed, $fail failed**" >> "$QUALITY_LOG"

  log ""
  log "Quality gate: $pass PASS / $fail FAIL"
  log "Full report: $QUALITY_LOG"
  log "Passed icons copied to: $BEST_DIR/"
}

deploy() {
  log "=== STEP 5: DEPLOY TO ASSETS ==="
  log "Resizing best icons to ${TARGET_SIZE}x${TARGET_SIZE} and deploying to $FINAL_DIR/"

  local deployed=0
  for f in "$BEST_DIR/"*.png; do
    [ -f "$f" ] || continue
    local fname
    fname=$(basename "$f")
    local target="$FINAL_DIR/$fname"

    sips -z "$TARGET_SIZE" "$TARGET_SIZE" "$f" --out "$target" 2>/dev/null
    deployed=$((deployed + 1))
  done

  log "Deployed $deployed icons to $FINAL_DIR/"
  log ""
  log "Next: rebuild Flutter app and verify on simulator"
  log "  IOS_SIMULATOR_ID=\${IOS_SIMULATOR_ID} BUNDLE_ID=com.niduna.currencyConverter ./.devtools/sim_reinstall_build.sh"
}

case "${1:-}" in
  --anchor)
    check_prereqs
    check_quota >/dev/null
    generate_anchor
    ;;
  --test-ref)
    check_prereqs
    check_quota >/dev/null
    test_subject_ref
    ;;
  --batch)
    check_prereqs
    check_quota >/dev/null
    batch_generate
    ;;
  --quality)
    quality_gate
    ;;
  --deploy)
    deploy
    ;;
  --quota)
    check_prereqs
    check_quota
    ;;
  "")
    check_prereqs
    remaining=$(check_quota)
    if [ "$remaining" -lt 10 ] 2>/dev/null; then
      log "WARNING: Only $remaining image-01 quota remaining today. Consider waiting for reset."
      log "  Continue anyway? (Ctrl+C to abort)"
      read -r _
    fi
    generate_anchor
    log ""
    log "=== PAUSED: Review anchor before continuing ==="
    log "Pick best USD anchor → copy to $BEST_DIR/usd.png"
    log "Then re-run: $0 --test-ref"
    ;;
  *)
    echo "Usage: $0 [--anchor|--test-ref|--batch|--quality|--deploy|--quota]"
    echo ""
    echo "  (no args)    Full pipeline step 1 (anchor only, then pauses)"
    echo "  --anchor     Generate 9x USD anchor variations"
    echo "  --test-ref   Test subject-ref style consistency"
    echo "  --batch      Generate all remaining currencies"
    echo "  --quality    Vision quality gate on generated icons"
    echo "  --deploy     Resize + copy best icons to assets/"
    echo "  --quota      Show remaining image-01 quota"
    exit 1
    ;;
esac
