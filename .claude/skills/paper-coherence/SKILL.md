---
name: paper-coherence
description: Verifica coerência argumentativa do paper — alinhamento entre contribuição declarada na Introdução e defendida na Conclusão, consistência de terminologia, encadeamento lógico entre seções. Invocar quando o usuário pedir verificação de coerência, consistência, alinhamento intro↔conclusão, ou antes de mandar versão completa para coautor/revisor. NÃO substitui /paper-review (que cobre critérios mecânicos).
---

# paper-coherence

Verifica **qualidade argumentativa** do paper. Foca em três eixos:

1. Coerência **vertical** (Introdução ↔ Conclusão)
2. Coerência **horizontal** (terminologia consistente entre seções)
3. Encadeamento lógico (cada seção responde à anterior)

## Por que essa skill é distinta de `/paper-review`

- `/paper-review` ataca **mecânicos** (cite quebrado, figura sem caption, modelo no corpo)
- `/paper-coherence` ataca **conteúdo** (a contribuição declarada é a defendida? a terminologia é a mesma?)

Revisores pegam o segundo tipo de problema com mais frequência, mas é menos detectável por checklist.

## Procedimento

### Passo 1 — Extrair a contribuição declarada

Ler `sections/01-introducao.tex` e identificar a **frase ou bullets** que declaram a contribuição.

Reportar a contribuição em **uma frase única**.

### Passo 2 — Extrair a contribuição defendida

Ler `sections/06-conclusao.tex` e identificar como o paper recapitula a contribuição.

Reportar em **uma frase única**, sem olhar o passo 1.

### Passo 3 — Comparar

Confrontar as duas frases:

- ✅ **Alinhadas** — mesma essência, mesma quantidade de itens, mesma ordem aproximada
- ⚠️ **Drift de escopo** — uma das duas adiciona ou remove itens
- ⚠️ **Drift de ênfase** — itens iguais mas pesos diferentes
- ❌ **Desalinhamento real** — itens incompatíveis, ou conclusão promete o que intro não preparou

Para cada divergência, citar `arquivo:linha` e sugerir edição concreta.

### Passo 4 — Conferir terminologia

Listar os termos técnicos centrais do paper. Para cada:

- É escrito sempre da mesma forma? (ex: "Knowledge Graph" vs "knowledge graph" vs "grafo de conhecimento")
- Aparece em itálico de forma consistente?
- A primeira ocorrência define ou cita?

### Passo 5 — Encadeamento lógico

Para cada par de seções consecutivas, conferir:

- A última frase da seção N introduz o tópico da seção N+1?
- A primeira frase da seção N+1 referencia o que foi dito antes?
- Há transição explícita ou o leitor cai num novo tópico sem aviso?

### Passo 6 — Estado do contrato com o leitor

A Introdução faz **promessas** (problema X, contribuição Y, experimento Z). A Conclusão deve **honrar cada promessa**.

| Promessa em Sec. 1 | Onde foi cumprida | Cumprida? |
|---|---|---|
| ... | ... | ✅/⚠️/❌ |

Promessas não cumpridas = candidatas a remoção da Intro **ou** seção nova no corpo.

## Saída esperada

```
# Coerência Argumentativa — [nome do paper]

## Contribuição declarada (Sec. 1)
> "..."

## Contribuição defendida (Sec. 6)
> "..."

## Diagnóstico
[✅/⚠️/❌] [explicação em 1-2 frases]

## Drifts detectados
- ...

## Inconsistências terminológicas
| Termo | Variantes encontradas | Sugestão |
| ... | ... | ... |

## Encadeamento entre seções
- 1→2: ✅/⚠️ [explicação]
- 2→3: ...

## Auditoria de promessas
[tabela]

## Edições sugeridas (priorizadas)
1. [arquivo:linha] [diff]
2. ...
```

## Cadência ideal

- 1ª passada: após Introdução e Conclusão chegarem a draft
- 2ª passada: após review de coautor/orientador
- 3ª passada: antes da submissão
