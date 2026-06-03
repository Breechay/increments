#!/usr/bin/env bash
# Regenerate what_i_want_v7.pdf from markdown (canonical source).
# Requires: pandoc, typst (`brew install pandoc typst`)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SRC="$ROOT/WHAT_I_WANT.md"
OUT="$ROOT/../what_i_want_v7.pdf"

if [[ ! -f "$SRC" ]]; then
  echo "Missing $SRC" >&2
  exit 1
fi

pandoc "$SRC" \
  -o "$OUT" \
  --pdf-engine=typst \
  -V documentclass=article \
  -V geometry:margin=1in \
  -V fontsize=11pt

echo "Wrote $OUT"
