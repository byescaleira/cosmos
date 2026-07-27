---
tags: [audit, risk, performance, accessibility, motion, concurrency, cosmos]
aliases: [cosmos audit 2026-07-24, post-0.8.0 audit, round-2 improvement audit]
related: [[Home]], [[cosmos-improvement-proposals-2026-07]], [[cosmos-org-audit-2026-07]], [[unwired-accessibility-gates]]
---

# Audit pós-0.8.0 — melhoria + performance (2026-07-24)

**Status:** aberto — findings de 5 auditores paralelos (performance, concorrência,
acessibilidade, ergonomia de API/contratos, motion/haptics) sobre `Sources/Cosmos/`
no estado pós-v0.8.0. Síntese deduplicada e ranqueada por impacto÷(esforço×risco).
A fonte de verdade permanece o código; esta nota é navegação/síntese. Em conflito,
o código (ou um re-verify) vence.

## Resumo por dimensão

- **Concorrência/Sendable:** LIMPO. `swift build`/`swift test`/`-c release` com **zero
  warnings** em Swift 6 mode v6 (Xcode 27 beta 3). Sem `@unchecked Sendable`, sem
  `NSLock`/`DispatchQueue`/`nonisolated(unsafe)`, sem `static var` mutável, sem
  data races. Apenas higiene (enums `Availability` caseless sem `: Sendable`;
  `static let default` de `CosmosThemeObservable` frágil mas correto;
  `@preconcurrency` no `cosmosToast` é supressão deliberada). **Nenhum defeito de
  correção.**
- **Performance:** 12 findings. Raiz amplificadora = agregados não-`Equatable`
  (bloqueado por closures de handler não-Equatable → exige short-circuit por
  sub-slice, não `==` integral). + AnyView reduce chain em customContent, @State
  lidos em `body`, theme-env não-lido.
- **Acessibilidade:** 11 findings. Gaps de VoiceOver (Toast/AsyncImage/Label) +
  `CosmosCard` bypass do chokepoint de motion.
- **Ergonomia de API/contratos:** 8 findings. `.cosmosReduceMotion(_:)` reseta a
  config inteira; SE-0299 faltando em 3 chromes; `ScrollViewProxy` sem prefixo.
- **Motion/haptics:** 8 findings. 2 bypasses de reduce-transparency (Toast
  `.glassEffect` + TextField `.ultraThinMaterial`); bug funcional de haptic no
  menu destrutivo; `CosmosButton` raw `.animation`.

## Findings de alta confiança (≥3 auditores independentes)

Estes foram flaggados por múltiplos auditores lendo o código de ângulos diferentes
— alta confiança de que são reais:

1. **`CosmosButton.swift:188-197`** — `ChromeBody` escreve `.animation(_:value:)`
   cru em vez do chokepoint `.cosmosAnimation(.press, value:)`; inlina
   `CosmosMotionPolicy.shouldEmit` + `theme.motion.animation(for:)` e duplica
   `CosmosAnimationModifier`. Quebra o "atoms never write raw animation". O
   `@Environment(\.accessibilityReduceMotion)` em `:149` fica órfão após o fix.
   (flaggado por a11y #6, motion #4, contracts #2)
2. **`CosmosCard.swift:30` (+ `CosmosToastModifier.swift:103`)** — `shadowHidden`
   usa `|| reduceMotion` (env bare), bypassando
   `configuration.motion.respectReduceMotion`. Um consumer com
   `respectReduceMotion = false` ainda perde a sombra. (a11y #1, motion #7,
   contracts #3)
3. **`CosmosHapticsAndTrackingModifiers.swift:38`** — `.cosmosReduceMotion(_:)`
   reconstrói `CosmosMotionConfiguration` via init memberwise
   `(respectReduceMotion:)`, resetando todos os campos irmãos (`isEnabled`,
   `reduceMotionPolicy`, `respectReduceTransparency`, `stagger`, `handler`) e
   clobberando a config up-tree. Viola o padrão read-env → `.with*` → reinject.
   (contracts #1; raiz na mesma família dos bypasses acima)

## Plano em ondas (impacto÷(esforço×risco), low-risk-first)

### Wave 1 — Disciplina de chokepoints (motion/a11y gates + override pattern)
Coerente, baixo-esforço, baixo-risco (muda comportamento só sob reduce-motion /
`respect*` flags — exatamente o comportamento pretendido).
- W1.1 `CosmosButton` raw `.animation` → `.cosmosAnimation(.press, value:)` + drop
  `reduceMotion` env órfão (#1).
- W1.2 `CosmosCard` + `CosmosToastModifier` shadow: `|| reduceMotion` →
  `CosmosMotionPolicy.shouldEmit(...)` (#2).
- W1.3 `.cosmosReduceMotion(_:)` → modifier que lê env, muta `var m =
  configuration.motion; m.respectReduceMotion = …`, reinjeta via
  `configuration.withMotion(m)` (espelha `CosmosEnabledModifier`) (#3).
- W1.4 `CosmosToastModifier:160` — `.glassEffect` nunca colapsa sob
  reduce-transparency; `toastBackgroundStyle` (morto hoje) é o path de colapso.
  Conectar via `CosmosMotionPolicy.shouldCollapseTransparency(...)`. Resolve
  também o "dead code" P12. (motion #1)
- W1.5 `CosmosTextField:232` — chrome `.cosmos` `.ultraThinMaterial` não colapsa
  sob reduce-transparency → swap para `theme.colors.surface` quando
  `shouldCollapseTransparency` (espelhar `CosmosProgressChrome`) (motion #2).

### Wave 2 — Higiene de performance
- W2.1 **`accessibilityCustomContentIfPresent` AnyView reduce chain**
  (`CosmosAccessibilityHelpers.swift:69-77`) — aloca `AnyView` por entrada por
  body re-eval, apagando identidade estrutural. Trocar por fold `@ViewBuilder` /
  modifier chain tipado. (perf #2 — ALTO valor, risco baixo-médio)
- W2.2 Short-circuit por modifier: nos `.cosmos*` que mudam um sub-slice, comparar
  o novo sub-valor com o existente e pular re-inject se igual. (Atenção: `==`
  integral dos agregados é **bloqueado** por closures de handler não-Equatable —
  fazer por sub-slice, não `Equatable` global.) (perf #1, #8)
- W2.3 `CosmosScrollView:72` — `@Environment(\.cosmosTheme)` declarado, nunca lido
  → deletar. (perf #6, trivial)
- W2.4 `CosmosSlider` `steppedValue` computed 3×/body → hoistar `let stepped =
  steppedValue` no topo de `body`. (perf #4, trivial)
- W2.5 `tapCounter` @State em `CosmosButton`/`CosmosMenu` lido em `body` força
  recompute por tap → disparar haptic + `motion.handler(.press)` direto em
  `performAction()`. (perf #3; coordena com W1.1)
- W2.6 `CosmosAsyncImage` `failureToken` @State em `body` re-roda o phase switch
  → emitir `.error` haptic direto em `reportFailure(_:)`. (perf #5)
- W2.7 `CosmosDivider` lê `cosmosConfiguration` só por `enable.isVisible` →
  `@Entry cosmosEnableVisible` estreito (opcional; mitigado por W2.2). (perf #7)
- W2.8 `CosmosPlatform.current`/`localizedTextDeviceKey` `static var` getter →
  `static let` (one-shot). (perf #9, trivial)

### Wave 3 — Gaps de VoiceOver / a11y  ✅ ships in 0.10.0
- W3.1 `CosmosToastContent` nunca chama `applyCosmosAccessibility` →
  label/hint/identifier/traits/role dropping no VoiceOver. Adicionar
  `applyCosmosAccessibility` + label de role prefixado. (a11y #3) ✅
- W3.2 `CosmosAsyncImageFailure` icon `exclamationmark.triangle` não
  `.accessibilityHidden(true)` → VoiceOver lê o nome do símbolo. (a11y #2,
  trivial) ✅
- W3.3 `CosmosAsyncImageFailure` `.font(.system(size: 32))` fixo, sem Dynamic
  Type → `theme.typography.font(for: .largeTitle)`. (a11y #4, trivial) ✅
- W3.4 `CosmosLabel` sem `.isHeader` para estilos de título (diferente de
  `CosmosText`) → espelhar o check `isHeading`. (a11y #5) ✅ — resolvido
  extraindo `CosmosTextStyle.isHeading` (fonte única de verdade do trait
  `.isHeader`); `CosmosLabel` e `CosmosText` agora ambos consultam `theme
  .textStyle.isHeading`, então qualquer átomo futuro de título herda o trait
  automaticamente (ver [[cosmos-textheader-pattern]]).
- W3.5 `CosmosGroupBox` fallback tvOS/watchOS sem `.isHeader`. (a11y #8, trivial) ✅
- W3.6 `CosmosMenu` fallback watchOS double `.isButton` → dropar o externo. (a11y
  #9, trivial) ✅
- W3.7 (opcional) `CosmosIcon` sem forma decorative para SF Symbols →
  `init(decorativeSystemName:)`. (a11y #7, API aditiva) ✅
- W3.8 (opcional) docs de TextField/SecureField afirmam `.textContentType`
  forwardado mas não há param → adicionar `textContentType:` (`#if os(iOS) ||
  os(tvOS)`) ou corrigir docs. (a11y #10) ✅ — resolvido corrigindo os docs
  (modifiers são caller-applied e propagam para o field interno, não
  re-forwardados pelo átomo); nenhum parâmetro adicionado.

### Wave 4 — Ergonomia de API + bug funcional de haptic
- W4.1 **`CosmosMenu:79`** — `primaryActionFeedback(isDestructive: false)`
  hardcoded → menu destrutivo de primary-action nunca emite `.impact(.rigid)`.
  Adicionar `primaryActionIsDestructive: Bool = false`. (motion #3 — **bug
  funcional**)
- W4.2 SE-0299 `where Self ==` faltando em `CosmosLabelChrome` /
  `CosmosProgressChrome` / `CosmosGroupBoxChrome` (a `.cosmos` existe mas sem
  conveniência dot-syntax). (contracts #4, aditivo)
- W4.3 `CosmosButton` statics `cosmosPrimary/Secondary/Danger/Ghost` fora do
  `extension … where Self ==` e não referenciados → mover ou remover (dead public
  API). (contracts #5)
- W4.4 `CosmosScrollView` `scrollToTop()/scrollToBottom()/scrollTo(_:)` estendem
  `ScrollViewProxy` sem prefixo `cosmos` → poluição de namespace. **Breaking** →
  runway de deprecation (`cosmosScrollTo…`). (contracts #6)
- W4.5 `CosmosAsyncImage.resolvedAnimation` re-implementa o gate inline (risco de
  drift) → helper compartilhado `CosmosMotionTokens.transaction(for:…)`. (contracts
  #7; coordena com motion #5 — handler de tracking não dispara em phase transition)
- W4.6 (opcional) `CosmosToggleChrome` SE-0299 borderline. (contracts #8)

### Higiene de concorrência (baixuíssima prioridade, sem defeito)
- `Cosmos*Availability` enums caseless sem `: Sendable` (derivado trivial) —
  traz a superfície pública em linha com a regra. (concorrência #3)
- Documentar requisito MainActor no `static let default` de
  `CosmosThemeObservable`. (concorrência #1)
- Documentar que `cosmosWithAnimation` invoca `handler` sincronamente no actor do
  chamador. (concorrência #4)

## Out-of-scope / deferido
- O P2 cosmetic de v0.8.0 (generalizar `*StyleApplier` + `.cosmosControlChrome()`)
  permanece deferido — parcialmente coberto por W4.2/W4.3 agora.
- `CosmosImage` atom unificado (feature track separada).
- PHASE4 Wave H (`CosmosForm`) / Wave I (`CosmosNavigation`) — roadmap, não audit.

## Recomendação
Executar **Wave 1** primeiro: é o cluster mais coerente (tudo é "gates pelo
chokepoint, overrides pelo `with*`"), baixo risco, e 3 dos findings têm alta
confiança multi-auditor. Depois Wave 3 (gaps de VoiceOver, alto impacto de
usuário, trivial). Wave 2 (perf) e Wave 4 (API) depois. `swift test` deve
permancer em 355; cada wave numa feature branch, merge `--no-ff` após verde.