---
name: paper-status
description: Use para obter snapshot rápido do estado do paper — número de páginas, citações pendentes (TODO-*), citações órfãs, build OK/falha, status por seção. Invocar quando o usuário pedir status, progresso, "como está", ou ao começar uma sessão para ver onde parou.
---

# paper-status

Snapshot rápido do estado do paper. Não escreve nem edita — só reporta.

## O que reportar

Executar os scripts em `scripts/` e consolidar saída:

### 1. Build

```bash
./scripts/compile.sh --quiet
```

- ✅ Compila / ❌ Falha (com 1ª linha do erro)
- Tamanho do PDF (em páginas)
- Última compilação (timestamp)

### 2. Páginas vs orçamento

```bash
./scripts/check.sh pages
```

- Total: X páginas (alvo configurado em CLAUDE.md)
- 🔴 Estourou / 🟡 Apertado / 🟢 Confortável

### 3. Citações

```bash
./scripts/check.sh citations
```

- `\cite{TODO-*}` pendentes: N (lista as 5 primeiras)
- Citações órfãs em `refs.bib` (entries não citadas): N
- Citações quebradas (cite sem entry): N

### 4. Figuras e tabelas

```bash
./scripts/check.sh figures
```

- Labels não referenciados: N
- Refs sem label: N
- Arquivos em `figures/`: N

### 5. Status por seção

Ler cada `sections/0N-nome.tex` e classificar por densidade de TODOs/conteúdo:

| Seção | Status estimado |
|---|---|
| 1 | (não iniciado / outline / draft / review / final) |
| ... | ... |

### 6. Bibliografia

```bash
./scripts/audit-refs.sh
```

- Total de entries
- Pre-prints (% sobre o total)
- Sem DOI nem URL: N
- Idade média

## Saída final

Formato compacto:

```
📄 Paper Status

Build:    ✅ compila (8 páginas)
Budget:   🟡 8/6-12 (apertado, espaço para Sec. X expandir)
Citações: N TODO-* pendentes, 0 órfãs, 0 quebradas
Figuras:  M com label, X órfãs, Y ausentes
Refs:     R entries, P% pre-prints, idade média K anos

Por seção:
  1 Introdução          📝 outline
  2 Referencial         📝 outline
  3 Relacionados        📝 outline
  4 Abordagem           ✏️  draft
  5 Experimentos        📝 outline
  6 Conclusão           ⏳ não iniciado
```

## Quando NÃO usar

- Para escrever (use `/paper-write`)
- Para revisar contra critérios (use `/paper-review`)
- Para coerência argumentativa (use `/paper-coherence`)
