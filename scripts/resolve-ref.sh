#!/usr/bin/env bash
# Busca metadados de referências bibliográficas via CrossRef e arXiv.
#
# Modos:
#   ./scripts/resolve-ref.sh search "<query>"  — busca top 3 candidatos
#   ./scripts/resolve-ref.sh fetch <DOI>        — baixa BibTeX de um DOI
#   ./scripts/resolve-ref.sh arxiv <id>         — baixa metadata do arXiv
#
# Exemplo:
#   ./scripts/resolve-ref.sh search "Reciprocal Rank Fusion Cormack 2009"
#   ./scripts/resolve-ref.sh fetch 10.1145/1571941.1572114

set -euo pipefail

if ! command -v jq >/dev/null; then
  echo "❌ jq não encontrado. Instale: sudo apt install jq" >&2
  exit 1
fi

if ! command -v curl >/dev/null; then
  echo "❌ curl não encontrado." >&2
  exit 1
fi

CMD="${1:-}"
shift || true

case "$CMD" in
  search)
    QUERY="$*"
    [[ -z "$QUERY" ]] && { echo "Uso: $0 search <query>" >&2; exit 1; }

    ENC=$(printf '%s' "$QUERY" | jq -sRr @uri)
    echo "🔍 CrossRef: $QUERY"
    echo

    if ! RESPONSE=$(curl -fsSL --max-time 15 \
        -H "User-Agent: tcc-docsmith/1.0 (mailto:heitorandrade2001@gmail.com)" \
        "https://api.crossref.org/works?query.bibliographic=$ENC&rows=5"); then
      echo "❌ Falha ao consultar CrossRef" >&2
      exit 1
    fi

    echo "$RESPONSE" | jq -r '
      .message.items[] |
      "── \(.title[0] // "(sem título)")
   Autor: \(if .author then (.author[0].family // "?") + ", " + (.author[0].given // "?") else "?" end)
   Ano:   \(.["published-print"]["date-parts"][0][0] // .["published-online"]["date-parts"][0][0] // .created["date-parts"][0][0] // "?")
   Tipo:  \(.type)
   DOI:   \(.DOI)"
    '

    echo
    echo "💡 Para baixar BibTeX:  $0 fetch <DOI>"
    ;;

  fetch)
    DOI="${1:-}"
    [[ -z "$DOI" ]] && { echo "Uso: $0 fetch <DOI>" >&2; exit 1; }

    # Usa content negotiation via doi.org (mais confiável que api.crossref.org/works/X)
    if ! BIBTEX=$(curl -fsSL --max-time 15 \
        -H "Accept: application/x-bibtex; charset=utf-8" \
        -H "User-Agent: tcc-docsmith/1.0 (mailto:heitorandrade2001@gmail.com)" \
        "https://doi.org/$DOI"); then
      echo "❌ Falha ao buscar BibTeX para DOI: $DOI" >&2
      exit 1
    fi

    echo "$BIBTEX"
    echo
    echo "💡 Editar a key gerada para o padrão do projeto." >&2
    echo "   Ex: \"Cormack_2009\" → \"cormack2009rrf\"" >&2
    ;;

  arxiv)
    ARXIV_ID="${1:-}"
    [[ -z "$ARXIV_ID" ]] && { echo "Uso: $0 arxiv <id>  (ex: 2404.16130)" >&2; exit 1; }

    URL="https://export.arxiv.org/api/query?id_list=$ARXIV_ID"
    if ! XML=$(curl -fsSL --max-time 15 "$URL"); then
      echo "❌ Falha ao consultar arXiv" >&2
      exit 1
    fi

    # arXiv retorna XML multi-linha; achatar antes de extrair
    FLAT=$(echo "$XML" | tr -d '\n' | sed 's/  */ /g')

    # Extrai do segundo <entry> em diante (o primeiro é metadata da query)
    ENTRY=$(echo "$FLAT" | grep -oE '<entry>.*</entry>' | head -1)

    TITLE=$(echo "$ENTRY" | grep -oE '<title>[^<]+</title>' | head -1 \
              | sed 's/<title>//;s/<\/title>//' | tr -s ' ')
    AUTHOR=$(echo "$ENTRY" | grep -oE '<author>[^<]*<name>[^<]+</name>' | head -1 \
              | sed 's/.*<name>//;s/<\/name>//')
    YEAR=$(echo "$ENTRY" | grep -oE '<published>[0-9]{4}' | head -1 | sed 's/<published>//')

    if [[ -z "$TITLE" || -z "$AUTHOR" ]]; then
      echo "❌ ID arXiv não encontrado ou XML inesperado: $ARXIV_ID" >&2
      exit 1
    fi

    LASTNAME=$(echo "$AUTHOR" | awk '{print tolower($NF)}')

    cat <<EOF
@article{${LASTNAME}${YEAR}arxiv,
  author    = {${AUTHOR}},
  title     = {${TITLE}},
  journal   = {arXiv preprint arXiv:${ARXIV_ID}},
  year      = {${YEAR}},
  url       = {https://arxiv.org/abs/${ARXIV_ID}}
}
EOF
    ;;

  *)
    cat <<EOF >&2
Uso:
  $0 search "<query>"   — busca top candidatos no CrossRef
  $0 fetch <DOI>         — baixa BibTeX de um DOI
  $0 arxiv <id>          — gera entrada para um ID arXiv (ex: 2404.16130)

Exemplos:
  $0 search "Reciprocal Rank Fusion Cormack 2009"
  $0 fetch 10.1145/1571941.1572114
  $0 arxiv 2404.16130
EOF
    exit 1
    ;;
esac
