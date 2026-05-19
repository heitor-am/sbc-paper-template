#!/usr/bin/env bash
# Verifica ortografia das seções em PT-BR usando aspell.
# Uso: ./scripts/spell-check.sh [secao]
#   secao: opcional, ex: "04-abordagem". Sem arg: todas as seções.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v aspell >/dev/null; then
  echo "❌ aspell não encontrado. Instale: sudo apt install aspell aspell-pt-br" >&2
  exit 1
fi

# Verifica se dicionário PT-BR está instalado
if ! aspell dicts | grep -q '^pt_BR$'; then
  echo "❌ Dicionário pt_BR não instalado. Instale: sudo apt install aspell-pt-br" >&2
  exit 1
fi

# Lista de palavras técnicas a ignorar (compartilhada com Vale)
PERSONAL_WORDS=$(mktemp)
trap 'rm -f "$PERSONAL_WORDS"' EXIT

cat > "$PERSONAL_WORDS" <<'EOF'
personal_ws-1.1 pt 0
EOF
# Concatena vocabulário do Vale
if [[ -f styles/config/vocabularies/Tech/accept.txt ]]; then
  grep -v '^$' styles/config/vocabularies/Tech/accept.txt >> "$PERSONAL_WORDS"
fi

check_file() {
  local file="$1"
  local name
  name=$(basename "$file" .tex)

  echo "── $name ──"

  # Remove comandos LaTeX e comentários antes de verificar
  local misspelled
  misspelled=$(sed 's/%.*$//' "$file" \
    | sed 's/\\[a-zA-Z]\+\(\[[^]]*\]\)*\({[^}]*}\)*//g' \
    | sed 's/\$[^$]*\$//g' \
    | aspell --lang=pt_BR --personal="$PERSONAL_WORDS" --encoding=utf-8 list \
    | sort -u)

  if [[ -z "$misspelled" ]]; then
    echo "  ✅ sem problemas detectados"
  else
    echo "$misspelled" | sed 's/^/  ❓ /'
  fi
  echo
}

if [[ $# -eq 1 ]]; then
  FILE="sections/${1}.tex"
  [[ ! -f "$FILE" ]] && { echo "❌ Seção não encontrada: $FILE" >&2; exit 1; }
  check_file "$FILE"
else
  for f in sections/*.tex; do
    check_file "$f"
  done
fi

echo "💡 Palavras desconhecidas mas corretas: adicionar em styles/config/vocabularies/Tech/accept.txt"
