---
name: paper-write
description: Use ao escrever ou editar uma seção do paper acadêmico. Carrega contexto do projeto (CLAUDE.md, refs.bib), aplica convenções (conceito + ref + instância, \cite{TODO-*} durante drafts, página-budget). Invocar quando o usuário pedir para escrever, redigir, editar, expandir, encolher ou estruturar qualquer seção do paper.
---

# paper-write

Skill de escrita assistida para paper acadêmico no template SBC. Garante que cada seção segue convenções, respeita o budget de páginas e cita corretamente.

## Antes de escrever

1. **Identificar a seção** que será trabalhada (1-6 ou customizada).
2. **Conferir o esqueleto atual** em `sections/0N-nome.tex` — os TODOs comentados já guiam o conteúdo.
3. **Ler `CLAUDE.md`** para regras editoriais do projeto.
4. **Conferir páginas alvo** declaradas em `CLAUDE.md`.

## Regras de redação

### Estrutura de cada parágrafo técnico

```
[Conceito] [Referência acadêmica] [Aplicação no trabalho].
```

**Exemplo correto:**
> "A fusão dos rankings é feita via **Reciprocal Rank Fusion** [Cormack et al. 2009], que combina os top-k de busca densa e esparsa sem exigir calibração de scores."

### Citações

- Usar `\cite{TODO-xxx}` se referência ainda não está em `refs.bib`.
- Após cada draft, listar todas as `\cite{TODO-*}` introduzidas para resolver depois com `./scripts/resolve-ref.sh`.

### Modelos específicos

- No corpo geral: **proibidos** como protagonistas (no máximo em "instanciado com X")
- Em Seção Experimentos: **obrigatórios** — é onde se reporta a configuração experimental

### Figuras e tabelas

- Toda figura: `\caption{}`, `\label{fig:slug}`, e referenciada via `\ref{fig:slug}` ou "Figura~\ref{fig:slug}"
- Toda tabela: idem com `\label{tab:slug}`

### Português

- Acentuação correta (não confiar em editor sem corretor)
- Termos técnicos consagrados em inglês: itálico (`\textit{embedding}`, `\textit{chunk}`)
- Nomes próprios de tecnologias e padrões: sem itálico (FastAPI, Qdrant, Strategy Pattern)

## Checklist pós-draft

- [ ] TODOs comentados da seção resolvidos ou postergados explicitamente
- [ ] Pelo menos 1 figura ou tabela onde apropriado (em Sec. Abordagem normalmente sim)
- [ ] Toda figura/tabela tem `\caption` + `\label` + é referenciada no texto
- [ ] Conceitos centrais têm `\cite{}` (mesmo que TODO)
- [ ] Português revisado (leitura em voz alta detecta 80% dos problemas)
- [ ] Transições entre subseções/parágrafos não engasgam

## Marcadores de IA a evitar

- Em-dashes (—) para parêntese → use parêntese, vírgula, ponto ou ponto-e-vírgula
- Setas (→ ←) no texto corrido → use palavras
- Enumerações `(i) (ii) (iii)` parelhas → varie conectivos ("primeiro / em seguida / depois")
- Scaffolding "Esta seção apresenta..." → comece direto
- Adjetivos avaliativos ("particularmente útil", "deliberadamente diversa")
- Paralelismos perfeitos em listas de 4+ itens → varie a estrutura

## Comandos úteis durante a sessão

```bash
./scripts/compile.sh                    # compilar e verificar páginas
./scripts/check.sh citations            # listar \cite{TODO-*} pendentes
./scripts/check.sh words                # contar palavras por seção
```

## Quando NÃO usar

- Para revisar (use `/paper-review`)
- Para verificar coerência intro/conclusão (use `/paper-coherence`)
- Para snapshot de status (use `/paper-status`)
