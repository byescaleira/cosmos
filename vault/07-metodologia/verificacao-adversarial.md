---
tags: [metodologia]
aliases: [Verificação Adversarial, Adversarial Verification]
related: [[Phase 2 Research Workflow]], [[Itens Refutados]]
---

# Verificação Adversarial

> O padrão que protegeu o Phase 2 de claims erradas de API/availability.

## Princípio

Default skeptic. Tenta **refutar** cada claim arriscada, não confirmar. O projeto já foi queimado por suposições erradas de availability (`Color(.systemBackground)` em tvOS, `.glassProminent` em visionOS, `BlurReplaceTransition` não-erasable). O valor do verificador está em pegar claims erradas — default `refuted=true` se incerto é melhor que `confirmed` falso.

## Método

Abre a SDK interface **independentemente** (não confia no spec):
- `SwiftUI.swiftmodule/arm64e-apple-macos.swiftinterface`
- `SwiftUICore.swiftmodule/...`

`grep`/`sed` re-confirma ou refuta, com evidence (linha da interface), as claims mais arriscadas:
1. **platformAvailability** — re-grep `@available(...)` p/ o tipo + style protocol; cada plataforma (available/unavailable/`<ver>`); pega `@available(<platform>, unavailable)` que o spec perdeu.
2. **cosmosGuard** — o `#if os(...)` proposto casa com a availability real? (spec diz guard tvOS mas o tipo IS available em tvOS, ou vice-versa).
3. **styleProtocolConformable + customizationLimits** — o style protocol é mesmo conformable/customizable, ou opaco/native-bridged? Checar declaration + return types opacos.
4. **availabilityGates** — confirmar a min OS version real de cada feature gated dos `@available` lines (não confiar na memória).
5. **motionKind** — sanity-check que o `CosmosMotionKind` escolhido é apropriado.

## Output

`{claim, verdict (confirmed|refuted|uncertain), evidence}`. `overallConfidence` (high/medium/low). `correctedSpec` = cópia do spec com fields refuted/uncertain **corrigidos** pra verdade verificada (mesmo schema). Se tudo confirmed, `correctedSpec` == input.

## Resultado no Cosmos

As correções que sobreviveram viraram [[Itens Refutados]] — pontos para **não recair** durante implementação.