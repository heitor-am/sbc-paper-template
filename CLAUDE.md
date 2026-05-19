# SBC Paper Template

Contexto auto-carregado em qualquer sessão Claude Code neste projeto.

## Visão de 1 minuto

Paper acadêmico em formato **SBC paper expandido** (`sbc-template.cls`) para venues da Sociedade Brasileira de Computação ou similares.

- **Limite típico:** 6-12 páginas
- **Build:** `latexmk -pdf main.tex`
- **CI/CD:** GitHub Actions compila a cada push e anexa PDF como artifact

## Estrutura padrão (6 seções)

| # | Seção | Páginas alvo |
|---|---|---|
| 1 | Introdução (problema, justificativa, motivação, objetivos, contribuições) | 0,5–1 |
| 2 | Referencial Teórico (enxuto — só conceitos transversais) | 0,5–1 |
| 3 | Trabalhos Relacionados | 0,5–1 |
| 4 | **Abordagem** — miolo do paper | 3–5 |
| 5 | Experimentos (metodologia + resultados) | 1–2 |
| 6 | Conclusão (síntese + limitações + trabalhos futuros) | 0,3–0,5 |
| — | Referências | 0,5–1 |

Customizar livremente conforme o escopo do paper.

## Regras de escrita (defaults)

### 1. Conceito + Referência + Instância

No corpo, sempre nesta forma:

> *"Cross-encoder* [Nogueira & Cho, 2019], instanciado com ColBERTv2 [Santhanam et al., 2022]"

**Conceito acadêmico** (durável) é protagonista. **Modelos específicos** só viram protagonistas em Sec. Experimentos.

### 2. Citações como `\cite{TODO-xxx}` durante drafts

Não interromper fluxo de escrita pra caçar referência. Resolver na fase de polimento.

### 3. Texto enxuto + figuras + tabelas

1 figura/tabela vale 200 palavras em paper denso.

### 4. Português consistente

Conteúdo em PT-BR com acentuação correta. Termos técnicos consagrados em inglês ficam em itálico (*pipeline*, *embedding*, *chunk*, etc.).

### 5. Convenções tipográficas

- Texto normal: nomes de tecnologias (Qdrant, FastAPI, Neo4j) sem formatação especial
- Itálico (`\textit{}`): termos estrangeiros e padrões de projeto (*Strategy*, *Factory*)
- Aspas duplas (`"foo"`): identificadores de campo/atributo
- `\texttt{}`: snippets de código executável

### 6. Evitar marcadores de IA

- Sem em-dash (—) para parêntese — usar parêntese, vírgula, ponto, ponto-e-vírgula
- Sem setas (→ ←) no texto corrido — usar palavras
- Sem `(i) (ii) (iii)` — variar conectivos
- Sem "Esta seção apresenta..." — começar direto
- Sem adjetivos avaliativos ("particularmente útil", "deliberadamente diversa")
- Sem paralelismos perfeitos em listas de 4+ itens — variar estrutura

## Skills disponíveis

- `/paper-write` — escrever ou editar uma seção seguindo as convenções
- `/paper-review` — revisar uma seção contra critérios acadêmicos
- `/paper-coherence` — verificar coerência entre Introdução e Conclusão
- `/paper-status` — relatório do estado atual do paper (páginas, citações, build)

## Agente

- **`academic-reviewer`** — sub-agente que simula um revisor acadêmico (perfil de pesquisador da área), lendo o paper com olho fresco. Invocar antes de submissão ou da reunião com orientador/co-autor.

## Scripts utilitários (em `scripts/`)

```bash
./scripts/compile.sh                       # latexmk + reporta páginas
./scripts/check.sh all                     # citações, figuras, páginas, palavras
./scripts/audit-refs.sh                    # qualidade da bibliografia

# Caça de referências
./scripts/resolve-ref.sh search "query"    # busca CrossRef
./scripts/resolve-ref.sh fetch <DOI>       # baixa BibTeX de um DOI
./scripts/resolve-ref.sh arxiv <id>        # gera entry de ID arXiv

# Polimento
./scripts/spell-check.sh                   # aspell PT-BR (precisa aspell-pt-br instalado)
vale sections/                             # lint de estilo (precisa vale instalado)

# Hook git (instalar 1x após clone)
ln -sfn ../../scripts/git-hooks/pre-commit .git/hooks/pre-commit
```

## CI/CD

`.github/workflows/ci.yml` compila o paper a cada push e:
- Anexa o PDF como artifact (backup automático caso editor remoto falhe)
- Bloqueia se passar de 12 páginas
- Avisa se ficar abaixo de 6 páginas
- Roda `check.sh citations`

## NÃO FAZER

- Não amarrar arquitetura/método a modelos específicos no corpo geral (deixar para Sec. Experimentos)
- Não inflar Referencial Teórico repetindo o que vai na Abordagem
- Não fazer commit/push sem revisão
- Não rodar `git push --force` ou `rm -rf` sem confirmação
