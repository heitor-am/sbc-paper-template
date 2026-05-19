#!/usr/bin/env bash
# Verifica saúde do paper TCC: citações, figuras, páginas, palavras.
# Uso: ./scripts/check.sh <comando>
#   citations  — lista \cite{TODO-*} pendentes, órfãs no .bib, e quebradas
#   figures    — figuras com label sem ref, ou refs sem label
#   pages      — páginas totais (alvo 6-12)
#   words      — palavras por seção (estimativa)
#   all        — todos os checks

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

CMD="${1:-all}"

check_citations() {
  echo "── Citações ──"
  echo
  local todo
  todo=$({ grep -roh '\\cite{TODO-[a-zA-Z0-9-]*}' sections/ main.tex 2>/dev/null || true; } | sort -u | grep -c . || true)
  echo "TODO-* pendentes: $todo"
  if [[ $todo -gt 0 ]]; then
    grep -roh '\\cite{TODO-[a-zA-Z0-9-]*}' sections/ main.tex 2>/dev/null | sort -u | head -10 | sed 's/^/  /'
    [[ $todo -gt 10 ]] && echo "  ... (+$((todo-10)) outras)"
  fi
  echo

  local cited
  cited=$(grep -roh '\\cite{[a-zA-Z0-9_-]*}' sections/ main.tex 2>/dev/null | sed 's/\\cite{//;s/}//' | sort -u)
  local defined
  defined=$(grep -E '^@[a-zA-Z]+\{[a-zA-Z0-9_-]+,' refs.bib 2>/dev/null | sed 's/^@[a-zA-Z]\+{//;s/,$//' | sort -u)

  local broken
  broken=$(comm -23 <(echo "$cited") <(echo "$defined") 2>/dev/null || true)
  local orphan
  orphan=$(comm -13 <(echo "$cited") <(echo "$defined") 2>/dev/null || true)

  if [[ -n "$broken" ]]; then
    echo "Citações quebradas (cite sem entry no .bib):"
    echo "$broken" | sed 's/^/  ❌ /'
  else
    echo "✅ Sem citações quebradas"
  fi
  echo

  if [[ -n "$orphan" ]]; then
    echo "Entries órfãs no .bib (não citadas):"
    echo "$orphan" | sed 's/^/  ⚠️  /'
  else
    echo "✅ Sem entries órfãs no refs.bib"
  fi
}

check_figures() {
  echo "── Figuras e tabelas ──"
  echo

  local labels
  labels=$(grep -roh '\\label{\(fig\|tab\):[a-zA-Z0-9_-]*}' sections/ 2>/dev/null | sort -u | sed 's/\\label{//;s/}//')
  local refs
  refs=$(grep -roh '\\ref{\(fig\|tab\):[a-zA-Z0-9_-]*}' sections/ main.tex 2>/dev/null | sort -u | sed 's/\\ref{//;s/}//')

  local unreffed
  unreffed=$(comm -23 <(echo "$labels") <(echo "$refs") 2>/dev/null || true)
  local missing
  missing=$(comm -13 <(echo "$labels") <(echo "$refs") 2>/dev/null || true)

  if [[ -n "$unreffed" ]]; then
    echo "Labels não referenciados no texto (fig/tab definidos mas não citados):"
    echo "$unreffed" | sed 's/^/  ⚠️  /'
  else
    echo "✅ Todos os labels são referenciados"
  fi
  echo

  if [[ -n "$missing" ]]; then
    echo "Refs sem label correspondente:"
    echo "$missing" | sed 's/^/  ❌ /'
  else
    echo "✅ Todas as refs têm label"
  fi
  echo

  if [[ -d figures ]]; then
    local figs
    figs=$(find figures/ -maxdepth 1 -type f \( -name '*.pdf' -o -name '*.png' -o -name '*.jpg' \) 2>/dev/null | wc -l)
    echo "Arquivos em figures/: $figs"
  fi
}

check_pages() {
  echo "── Páginas ──"
  echo
  if [[ ! -f main.pdf ]]; then
    echo "⚠️  main.pdf não existe — rode ./scripts/compile.sh primeiro"
    return
  fi
  local pages
  pages=$(pdfinfo main.pdf 2>/dev/null | awk '/^Pages:/ {print $2}')
  if [[ -z "$pages" ]]; then
    echo "❌ pdfinfo não disponível ou main.pdf inválido"
    return
  fi
  echo "Total: $pages páginas (alvo: 6-12)"
  if (( pages < 6 )); then
    echo "🟡 Abaixo do mínimo — expandir Sec. 4 ou Sec. 5"
  elif (( pages > 12 )); then
    echo "🔴 Acima do limite — cortar (ver CLAUDE.md para ordem de cortes)"
  else
    echo "🟢 Dentro do limite"
  fi
}

check_words() {
  echo "── Palavras por seção (estimativa) ──"
  echo
  for f in sections/*.tex; do
    local name
    name=$(basename "$f" .tex)
    local words
    # Conta palavras ignorando comentários e comandos LaTeX simples
    words=$(grep -v '^\s*%' "$f" | sed 's/\\[a-zA-Z]\+\(\[[^]]*\]\)\?\({[^}]*}\)\?//g' | wc -w)
    printf "  %-30s %5d palavras\n" "$name" "$words"
  done
}

case "$CMD" in
  citations) check_citations ;;
  figures)   check_figures ;;
  pages)     check_pages ;;
  words)     check_words ;;
  all)
    check_citations
    echo
    check_figures
    echo
    check_pages
    echo
    check_words
    ;;
  *)
    echo "Uso: $0 <citations|figures|pages|words|all>" >&2
    exit 1
    ;;
esac
