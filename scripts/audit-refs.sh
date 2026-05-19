#!/usr/bin/env bash
# Auditoria da qualidade da bibliografia em refs.bib.
#
# Reporta distribuição (sem juízo de valor automático):
#   - Total de entries
#   - Por tipo (article, inproceedings, book, misc, ...)
#   - Pre-prints (entries com "arXiv preprint" no journal)
#   - Sem venue (sem journal nem booktitle)
#   - Sem DOI nem URL
#   - Distribuição por ano
#   - Idade média
#
# Uso: ./scripts/audit-refs.sh [--strict]
#   --strict: trata sinais como erro (exit 1) — útil para CI

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

STRICT=0
[[ "${1:-}" == "--strict" ]] && STRICT=1

if [[ ! -f refs.bib ]]; then
  echo "❌ refs.bib não encontrado" >&2
  exit 1
fi

CURRENT_YEAR=$(date +%Y)

# Lê o arquivo todo (entries começam com @ e fecham com }, considerando aninhamento simples)
TOTAL=$(grep -cE '^@[a-zA-Z]+\{' refs.bib || echo 0)

echo "── Auditoria de qualidade — refs.bib ──"
echo
echo "Total de entries: $TOTAL"
[[ $TOTAL -eq 0 ]] && exit 0

# Distribuição por tipo
echo
echo "Por tipo:"
grep -oE '^@[a-zA-Z]+\{' refs.bib | sed 's/^@//;s/{$//' | sort | uniq -c \
  | awk '{printf "  %-20s %d\n", $2, $1}'

# Pre-prints
echo
PREPRINTS=$(grep -ciE 'journal\s*=\s*\{[^}]*(arxiv|preprint)' refs.bib || true)
PREPRINT_PCT=$(awk -v p="$PREPRINTS" -v t="$TOTAL" 'BEGIN { printf "%.0f", (p/t)*100 }')
echo "Pre-prints: $PREPRINTS de $TOTAL (${PREPRINT_PCT}%)"
[[ $PREPRINT_PCT -gt 40 ]] && echo "  ⚠️  alto — banca pode questionar; preferir versões publicadas onde possível"

# Sem venue
echo
NO_VENUE=$(awk '
  BEGIN { RS="@"; FS="\n" }
  NR > 1 {
    has_venue = 0
    has_url = 0
    has_doi = 0
    type = ""
    if ($1 ~ /^([a-zA-Z]+)\{/) {
      match($1, /^[a-zA-Z]+/)
      type = tolower(substr($1, RSTART, RLENGTH))
    }
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^[[:space:]]*(journal|booktitle|publisher|howpublished)[[:space:]]*=/) has_venue = 1
      if ($i ~ /^[[:space:]]*url[[:space:]]*=/) has_url = 1
      if ($i ~ /^[[:space:]]*doi[[:space:]]*=/) has_doi = 1
    }
    # misc/online sem venue tolerável; article/inproceedings/book sem venue é problema
    if (!has_venue && type != "misc" && type != "online" && type != "unpublished") count++
  }
  END { print count + 0 }
' refs.bib)
echo "Sem venue (article/inproceedings/book sem journal/booktitle/publisher): $NO_VENUE"
[[ $NO_VENUE -gt 0 ]] && echo "  ⚠️  conferir manualmente — entries assim parecem incompletas"

# Sem DOI nem URL
NO_LINK=$(awk '
  BEGIN { RS="@"; FS="\n" }
  NR > 1 {
    has_url = 0
    has_doi = 0
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^[[:space:]]*url[[:space:]]*=/) has_url = 1
      if ($i ~ /^[[:space:]]*doi[[:space:]]*=/) has_doi = 1
    }
    if (!has_url && !has_doi) count++
  }
  END { print count + 0 }
' refs.bib)
echo "Sem DOI nem URL: $NO_LINK"
[[ $NO_LINK -gt 0 ]] && echo "  ⚠️  difícil para banca verificar — adicionar onde possível"

# Distribuição por ano
echo
echo "Distribuição por ano:"
grep -oE 'year[[:space:]]*=[[:space:]]*\{?[0-9]{4}\}?' refs.bib \
  | grep -oE '[0-9]{4}' | sort | uniq -c \
  | awk '{printf "  %s: %s\n", $2, $1}' | sort

# Idade média e máxima
echo
AGES=$(grep -oE 'year[[:space:]]*=[[:space:]]*\{?[0-9]{4}\}?' refs.bib | grep -oE '[0-9]{4}')
AVG_AGE=$(echo "$AGES" | awk -v cur="$CURRENT_YEAR" '{ sum += cur - $1; count++ } END { if (count) printf "%.1f", sum/count }')
OLDEST=$(echo "$AGES" | sort -n | head -1)
NEWEST=$(echo "$AGES" | sort -n | tail -1)
echo "Idade média: $AVG_AGE anos"
echo "Mais antiga: $OLDEST    Mais nova: $NEWEST"

# Entries com keys ainda em prefixo TODO-
TODO_KEYS=$(grep -cE '^@[a-zA-Z]+\{TODO-' refs.bib || echo 0)
echo
echo "Keys ainda com prefixo TODO-: $TODO_KEYS de $TOTAL"
[[ $TODO_KEYS -gt 0 ]] && echo "  💡 renomear para padrão final (ex: cormack2009rrf) ao resolver cada referência"

# Resumo qualitativo
echo
echo "── Resumo ──"
SIGNALS=0
[[ $PREPRINT_PCT -gt 40 ]] && SIGNALS=$((SIGNALS+1))
[[ $NO_VENUE -gt 0 ]] && SIGNALS=$((SIGNALS+1))
[[ $NO_LINK -gt 2 ]] && SIGNALS=$((SIGNALS+1))

if [[ $SIGNALS -eq 0 ]]; then
  echo "✅ Bibliografia parece saudável"
else
  echo "⚠️  $SIGNALS sinais para conferir manualmente"
fi

if [[ $STRICT -eq 1 && $SIGNALS -gt 0 ]]; then
  exit 1
fi

exit 0
