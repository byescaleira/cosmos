---
tags: [metodologia, reference]
aliases: [Phase 2 Research Workflow, Workflow de Pesquisa]
related: [[Verificação Adversarial]], [[Átomos Overview]], [[Home]]
---

# Phase 2 Research Workflow

> Fonte: `.claude/workflows/phase2-atom-research.js` — um **workflow** de 3 fases (determinístico, multi-agent) que produziu `PHASE2.md`.

## Por que um workflow

A pesquisa de átomos precisa ser **abrangente** (16 átomos × múltiplos eixos) e **confiável** (o projeto já levou surras da SDK: `Color(.systemBackground)` unavailable em tvOS, `.glassProminent` unavailable em visionOS, `BlurReplaceTransition` não-erasable em `AnyTransition`). Um workflow fan-out + verificação adversarial é a estrutura que produz isso.

## 3 fases

```
Research (1 agent/átomo)  →  Verify (adversarial, 1 agent/átomo)  →  Synthesize (1 agent)
```

Usa `pipeline()` (sem barreira entre stages — o átomo A pode estar em Verify enquanto o B ainda pesquisa). 16 átomos, ~16 research + 16 verify + 1 synthesize.

### Stage 1 — Research
Um agente por átomo. Fontes:
1. **Apple Developer docs** (uso/behavior/HIG) — `WebFetch https://developer.apple.com/documentation/swiftui/<slug>` — behavior, uso pretendido, notas de plataforma, a11y, patterns novos.
2. **Xcode 27 SDK `.swiftinterface`** (AUTORITATIVO p/ API + availability) — `grep`/`sed` em:
   - `SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface`
   - `SwiftUICore.swiftmodule/arm64e-apple-macos.swiftinterface`
   Procura: struct/protocol declaration, inits, conformances (`View`? protocols?), e **todo** `@available(...)` no tipo + style protocol + membros key. Especialmente `@available(<platform>, unavailable)` e min-version. Grep linhas ao redor (`sed -n`) p/ ler a declaração envolvente. Reporta linhas exatas como evidence.

Output: schema `ATOM_SPEC` (structured) — pattern, styleProtocolConformable, platformAvailability per-platform, cosmosGuard, availabilityGates, keyInits, keyModifiers, accessibilityNotes, hapticsFit, motionKind, motionNotes, sdkEvidence, risks, tier.

### Stage 2 — Adversarial Verify
Um agente por átomo, default skeptic, tenta **refutar** cada claim arriscada re-checkando a SDK interface independentemente. Verifica os RISKIEST: platformAvailability, cosmosGuard, styleProtocolConformable + customizationLimits, availabilityGates, motionKind. Output: `{claim, verdict (confirmed|refuted|uncertain), evidence}` + `overallConfidence` + `correctedSpec` (cópia com fixes). → [[Verificação Adversarial]].

### Stage 3 — Synthesize
Um agente recebe os **16 specs verificados** (JSON) + regras binding do projeto e produz o doc Markdown implementation-ready (`PHASE2.md`) com 7 seções: overview/ordem, per-atom spec, motion-intent matrix, platform-guard reference, cross-cutting checklist, open risks/TODOs, test plan per atom.

## Slugs pesquisados (16)

Toggle, Label, ProgressView, GroupBox, Slider, Stepper, TextField-group, DatePicker, Picker, List, Section, TabView, Divider, Image, Link, Menu. → [[Átomos Overview]].

## Lições / princípios

- **SDK interface é autoritativa**, docs são só guia de uso. Não guess availability de memória — grep.
- **Uncertain > false confirmed** — honestidade sobre incerteza.
- **Verificar é mais valioso que pesquisar** — o valor está em pegar claims erradas (projeto já foi queimado).
- Schema structured força completude; `pipeline()` evita barreira de latency.