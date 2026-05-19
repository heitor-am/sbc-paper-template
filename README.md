# SBC Paper Template

LaTeX paper template para venues da Sociedade Brasileira de Computação (SBC), com integração Claude Code, CI/CD e tooling embutido. Use como ponto de partida para artigos novos — basta clonar, atualizar metadados e começar a escrever.

## Features

- ✅ Template SBC paper (`sbc-template.cls`) já incluído no repo (não precisa Overleaf ou pacote externo)
- ✅ Skeleton de 6 seções (Introdução, Referencial, Relacionados, Abordagem, Experimentos, Conclusão) — customizável
- ✅ Latin Modern font (`lmodern`) para rendering limpo com acentuação correta
- ✅ GitHub Actions que compila a cada push, anexa PDF como artifact, falha se >12 páginas
- ✅ Scripts de tooling: compilação, validação de citações, busca CrossRef/arXiv, audit de bibliografia, spell-check
- ✅ Pre-commit hook que bloqueia commits com citações quebradas
- ✅ Configuração Claude Code completa:
  - 4 skills (`/paper-write`, `/paper-review`, `/paper-coherence`, `/paper-status`)
  - Agent `academic-reviewer` para simular revisão de banca/par
  - Hooks de proteção contra comandos destrutivos
  - Permissions allowlist para reduzir prompts
- ✅ Vale lint com regras PT-BR custom (hedging, wordiness, redundância, voz passiva, tom acadêmico)
- ✅ Vocabulário técnico (`styles/config/vocabularies/Tech/accept.txt`)

## Como usar

### Setup inicial

```bash
# 1. Clonar
git clone <este-repo> meu-paper
cd meu-paper

# 2. Atualizar metadados em main.tex
#    - \title{}
#    - \author{}
#    - \address{}

# 3. (Opcional) Instalar git hook
ln -sfn ../../scripts/git-hooks/pre-commit .git/hooks/pre-commit

# 4. Compilar localmente
./scripts/compile.sh

# 5. Escrever as seções em sections/*.tex
```

### Escrever uma seção

Dentro de qualquer sessão Claude Code:

```
/paper-write
```

A skill carrega contexto (CLAUDE.md, convenções) e te guia. Termos consistentes, citações como `\cite{TODO-xxx}` durante drafts, conceito + ref + instância no corpo, modelos específicos só em Sec. Experimentos.

### Revisar

```
/paper-review
```

Critérios acadêmicos (originalidade, fundamentação, reprodutibilidade, análise crítica, formato SBC) + simula 3 perguntas que a banca/revisor faria.

### Resolver citações

```bash
./scripts/resolve-ref.sh search "Reciprocal Rank Fusion Cormack"
./scripts/resolve-ref.sh fetch 10.1145/1571941.1572114
./scripts/resolve-ref.sh arxiv 2404.16130
```

### Auditoria

```bash
./scripts/check.sh all           # citações + figuras + páginas + palavras
./scripts/audit-refs.sh          # qualidade da bibliografia
./scripts/spell-check.sh         # aspell PT-BR (requer aspell-pt-br instalado)
```

## Estrutura de pastas

```
.
├── main.tex                 # documento principal (preâmbulo + \input das seções)
├── refs.bib                 # bibliografia BibTeX
├── sbc-template.sty         # classe SBC (vendored)
├── sbc.bst                  # estilo de bibliografia SBC
├── caption2.sty             # dependência SBC
├── CLAUDE.md                # contexto auto-carregado para Claude Code
├── README.md                # este arquivo
├── .gitignore               # ignora artefatos LaTeX
├── sections/                # uma seção por arquivo
│   ├── 01-introducao.tex
│   ├── 02-referencial-teorico.tex
│   ├── 03-trabalhos-relacionados.tex
│   ├── 04-abordagem.tex
│   ├── 05-experimentos.tex
│   └── 06-conclusao.tex
├── figures/                 # PDFs vetoriais, PNGs, diagramas (.excalidraw, .drawio)
├── scripts/                 # tooling
│   ├── compile.sh
│   ├── check.sh
│   ├── audit-refs.sh
│   ├── resolve-ref.sh
│   ├── spell-check.sh
│   ├── guard.sh
│   └── git-hooks/pre-commit
├── styles/                  # configuração Vale
│   ├── PT/                  # regras PT-BR custom
│   │   ├── AcademicTone.yml
│   │   ├── Hedging.yml
│   │   ├── PassiveVoice.yml
│   │   ├── Redundancy.yml
│   │   └── Wordiness.yml
│   └── config/vocabularies/Tech/accept.txt
├── .github/workflows/ci.yml # GitHub Actions
└── .claude/
    ├── settings.json        # permissions + hooks
    ├── skills/
    │   ├── paper-write/SKILL.md
    │   ├── paper-review/SKILL.md
    │   ├── paper-coherence/SKILL.md
    │   └── paper-status/SKILL.md
    └── agents/academic-reviewer.md
```

## Compilação

### Local

```bash
./scripts/compile.sh              # latexmk + reporta páginas
./scripts/compile.sh --quiet      # silencia output
```

Requer TeX Live com `latexmk`, `pdflatex` e `bibtex` (geralmente em `texlive-full`).

### Overleaf

1. Faça upload do repo (zip) ou conecte via GitHub Sync
2. Defina `main.tex` como Main document
3. Compile normalmente

### GitHub Actions

A cada push para `main` ou pull request, o workflow:
1. Compila `main.tex` via `xu-cheng/latex-action@v3`
2. Reporta contagem de páginas
3. Falha se passar de 12 páginas
4. Anexa `main.pdf` como artifact (retenção 30 dias)

## Convenções editoriais

Ver `CLAUDE.md` para a lista completa. Sumário:

- Conceito + Referência + Instância no corpo
- Modelos específicos só em Sec. Experimentos
- Citações como `\cite{TODO-xxx}` durante drafts, resolver depois
- Português consistente, termos estrangeiros em itálico
- Sem em-dashes parentéticos, sem setas no texto, sem `(i)(ii)(iii)` parelhos
- Texto enxuto + figuras + tabelas

## Licença

MIT (do template). O conteúdo que você escrever é seu.

A classe SBC e arquivos relacionados (`sbc-template.sty`, `sbc.bst`, `caption2.sty`) seguem suas próprias licenças (geralmente LPPL).

## Contribuições

Pull requests bem-vindos. Sugestões de skills, agents, scripts ou regras de lint que tornem o template mais útil são especialmente desejadas.
