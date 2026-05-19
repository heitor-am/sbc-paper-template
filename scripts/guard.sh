#!/usr/bin/env bash
# Hook PreToolUse para Bash: bloqueia padrões que settings.json deny não cobre.
# Foco único: redirects sobrescrevendo arquivos críticos do paper.
#
# settings.json deny já bloqueia: rm -rf /, ~, git push --force, git reset --hard
# Aqui complementamos com: > main.tex, > refs.bib (não pegáveis por allow/deny)

set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Redirect sobrescrevendo arquivos críticos
if echo "$CMD" | grep -qE '(^|[^>])>\s*(main\.tex|refs\.bib)\b'; then
  echo "🛑 guard: redirect sobrescrevendo arquivo crítico" >&2
  echo "   Use a ferramenta Edit ou Write em vez de redirect bash." >&2
  exit 2
fi

exit 0
