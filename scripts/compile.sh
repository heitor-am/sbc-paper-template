#!/usr/bin/env bash
# Compila o paper e reporta status.
# Uso: ./scripts/compile.sh [--quiet]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

QUIET=0
[[ "${1:-}" == "--quiet" ]] && QUIET=1

if ! command -v latexmk >/dev/null; then
  echo "❌ latexmk não encontrado. Instale TeX Live (texlive-full)." >&2
  exit 1
fi

LOG=$(mktemp)
trap 'rm -f "$LOG"' EXIT

if [[ $QUIET -eq 1 ]]; then
  if latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex >"$LOG" 2>&1; then
    PAGES=$(pdfinfo main.pdf 2>/dev/null | awk '/^Pages:/ {print $2}')
    echo "✅ compila (${PAGES:-?} páginas)"
  else
    ERR=$(grep -E "^!" "$LOG" | head -1)
    echo "❌ falha: ${ERR:-erro desconhecido (ver main.log)}"
    exit 1
  fi
else
  latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
  PAGES=$(pdfinfo main.pdf 2>/dev/null | awk '/^Pages:/ {print $2}')
  echo ""
  echo "📄 PDF gerado: main.pdf (${PAGES:-?} páginas)"
fi
