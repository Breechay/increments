#!/usr/bin/env bash
# Regenerate The Four-Week Arc PDF from INCREMENTS/Psych/THE_FOUR_WEEK_ARC.md
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PSYCH="$(cd "$ROOT/.." && pwd)"
MD="$PSYCH/THE_FOUR_WEEK_ARC.md"
HTML="$ROOT/arc.html"
PDF="$ROOT/The Four-Week Arc.pdf"
OUT_PDF="$PSYCH/THE_FOUR_WEEK_ARC.pdf"

python3 "$ROOT/build_pdf.py" "$MD" "$HTML"

if command -v weasyprint >/dev/null 2>&1; then
  weasyprint "$HTML" "$PDF"
  cp "$PDF" "$OUT_PDF"
  echo "PDF: $OUT_PDF"
else
  echo "weasyprint not found — HTML written to $HTML"
  echo "Install: pip install weasyprint  (or brew install weasyprint)"
  exit 1
fi
