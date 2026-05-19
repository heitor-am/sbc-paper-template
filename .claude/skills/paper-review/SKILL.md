---
name: paper-review
description: Use ao revisar uma seção ou o paper inteiro contra critérios acadêmicos. Aplica checklist objetivo (originalidade, fundamentação, reprodutibilidade, análise crítica, formatação SBC) e simula perguntas que revisor/banca faria. Invocar antes de declarar uma seção "pronta", antes de mandar para coautor/orientador, ou antes de submissão.
---

# paper-review

Revisão estruturada contra critérios acadêmicos de paper SBC e venues equivalentes.

## Modos de revisão

### Modo 1 — Revisão de seção individual

Quando o usuário pede revisão de uma seção específica (ex: `/paper-review sec 4`).

1. Ler a seção em `sections/0N-nome.tex`
2. Compilar mentalmente contra os critérios abaixo
3. Reportar **achados estruturados** em 3 níveis: **bloqueante**, **sugestão**, **bônus**
4. Sugerir 2-3 edições concretas (com diff)

### Modo 2 — Revisão integral do paper

Quando o usuário pede revisão geral (`/paper-review`).

1. Ler `main.tex` + todas as `sections/*.tex`
2. Aplicar todos os critérios
3. Gerar relatório por seção + sumário executivo
4. Identificar problemas **transversais** (terminologia inconsistente, conceitos definidos duas vezes, contribuição mal articulada)

## Critérios acadêmicos

### A. Originalidade e Contribuição

- [ ] Contribuições **listadas explicitamente** na Introdução
- [ ] Cada contribuição **distinguível** das de trabalhos relacionados
- [ ] Conclusão recapitula as mesmas contribuições com evidência (sem repetir verbatim)
- [ ] **Pergunta-armadilha:** "Em uma frase, qual a contribuição?" — a frase está no paper?

### B. Fundamentação Teórica

- [ ] Toda afirmação técnica não-trivial tem `\cite{}` ou justificativa
- [ ] Conceitos centrais aparecem com referência na primeira menção
- [ ] Referencial Teórico cobre só o que é usado em múltiplas seções
- [ ] Não há conceito introduzido na Abordagem sem fundamentação prévia

### C. Trabalhos Relacionados

- [ ] Sistemas/abordagens representativos citados
- [ ] **Comparativo claro** (tabela ou texto) entre o trabalho e cada um
- [ ] **Lacuna identificada** — o que o paper preenche?

### D. Reprodutibilidade (Sec. Experimentos)

- [ ] Corpus/dataset descrito (origem, tamanho, idioma)
- [ ] Setup descrito (queries, anotação, processo)
- [ ] Métricas com fórmula ou referência
- [ ] Modelos com versão exata
- [ ] Hiperparâmetros declarados
- [ ] Hardware mencionado

### E. Análise crítica dos resultados

- [ ] Não só apresenta tabela — **interpreta**
- [ ] Discute **trade-offs**
- [ ] Identifica em quais cenários cada abordagem vence
- [ ] Limitações estão explícitas

### F. Formatação SBC

- [ ] Título em sentence case capitalizado
- [ ] `\address` correto
- [ ] Abstract (EN) e Resumo (PT) preenchidos
- [ ] Citações com `\cite{}` (sem citações em texto solto)
- [ ] Bibliografia em formato SBC (`\bibliographystyle{sbc}`)
- [ ] Sem citações órfãs em `refs.bib` (toda entrada é citada)
- [ ] Sem `\cite{}` quebrado
- [ ] Figuras/tabelas com `\caption` + `\label` + referenciadas

### G. Marcadores de IA (consistência editorial)

- [ ] Sem em-dashes parentéticos
- [ ] Sem setas (→) no texto corrido
- [ ] Sem `(i) (ii) (iii)` parelhos
- [ ] Sem "Esta seção apresenta..."
- [ ] Sem adjetivos avaliativos
- [ ] Variação de comprimento de frase

### H. Português

- [ ] Acentuação consistente
- [ ] Sem trechos em inglês "esquecidos" no meio do texto
- [ ] Termos técnicos em itálico
- [ ] Sem repetições óbvias
- [ ] Voz ativa predomina sobre passiva

## Simulação de banca/revisor

Após o checklist, simular **3 perguntas que um revisor pode fazer**:

1. Sobre **escolha técnica** ("Por que essa abordagem e não a alternativa X?")
2. Sobre **comparação** ("O que diferencia do trabalho Y citado?")
3. Sobre **limitações** ("Por que não testou em cenário Z?")

Para cada pergunta, conferir se o paper **antecipa** a resposta.

## Saída esperada

```
## Revisão — Sec X

### 🔴 Bloqueante (resolver antes de submissão)
- [arquivo:linha] item + sugestão concreta
- ...

### 🟡 Sugestão (melhora a qualidade)
- ...

### 🟢 Bônus (se sobrar tempo)
- ...

### Perguntas antecipadas
1. ...
2. ...
3. ...

### Edições concretas sugeridas
[diffs ou patches]
```
