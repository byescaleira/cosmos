---
tags: [component, accessibility, pattern, design-token]
aliases: [cosmos isheading, cosmos textheader pattern, isheader trait source of truth]
related: [[cosmos-audit-2026-07-24]], [[unwired-accessibility-gates]]
---

# CosmosTextStyle.isHeading — fonte única de verdade do trait `.isHeader`

> Padrão compartilhado (visando escala): a decisão "este estilo de texto é um
> heading?" vive em **um** lugar, não duplicada em cada átomo.

## Problema

`CosmosText` e `CosmosLabel` renderizam texto/label num `CosmosTextStyle`. Para
estilos de título (`largeTitle` / `title` / `title2` / `title3`), o conteúdo deve
anunciar-se como **heading** ao VoiceOver (trait `.isHeader`), para ser navegável
como tal (rotor Headings, navegação por `VO+Cmd+H`).

Antes do **0.10.0** isso era decidido **privadamente em cada átomo** — um
`switch` local em `CosmosText` e nada em `CosmosLabel` (W3.4 do
[[cosmos-audit-2026-07-24]]). Cada novo átomo de título teria que re-implementar
o mesmo `switch`, e qualquer divergência (esquecer `.title3`, incluir `.headline`
por engano) viraria um bug de a11y silencioso.

## Padrão

A decisão mora em `CosmosTextStyle.isHeading` — `public var` computado, fonte
única:

```swift
public var isHeading: Bool {
    switch self {
    case .largeTitle, .title, .title2, .title3: return true
    default: return false
    }
}
```

Os átomos consultam `theme.textStyle.isHeading` e aplicam o trait condicionalmente:

```swift
.applyCosmosAccessibility(configuration.accessibility,
    extraTraits: theme.textStyle.isHeading ? .isHeader : [])
```

`CosmosText` e `CosmosLabel` agora usam exatamente essa forma. Qualquer átomo
futuro que renderize texto num `CosmosTextStyle` pega o trait automaticamente —
zero custo de manutenção, zero chance de divergência.

## Por que `isHeading` (não um enum de "papéis")

- O `CosmosTextStyle` existente já carrega o mapeamento estilo→`Font.TextStyle`
  + tamanho de ponto. Adicionar um enum paralelo de "papéis semânticos"
  (heading/body/caption) seria **duplicação** da mesma decisão em outra camada —
  exatamente o que este padrão elimina.
- `.isHeader` é o único trait que depende do estilo de texto; os outros
  (`.isButton`, `.isStaticText`, `.isLink`) vêm da natureza do átomo
  (`CosmosButton`, `CosmosToast`, `CosmosLink`), não do estilo. Então um único
  booleano derivado cobre o caso sem inflar o tipo.

## Cobertura de teste

`CosmosTokensTests.textStyleIsHeadingForTitleStylesOnly` faz o loop em
`CosmosTextStyle.allCases` e afirma que `isHeading` == `true` exatamente para
`{.largeTitle, .title, .title2, .title3}`. Trava o conjunto — adicionar um novo
estilo de título exige atualizar o `switch`, e o teste falha se alguém esquecer.

## Histórico

- **0.10.0** (2026-07-26): extraído de `CosmosText` (privado) para
  `CosmosTextStyle.isHeading` (público); `CosmosLabel` passou a usá-lo
  (corrige W3.4). `CosmosText` continuou usando o mesmo comportamento, agora via
  a fonte única.
- Antes: decisão duplicada/ausente — ver Wave 3 em [[cosmos-audit-2026-07-24]].