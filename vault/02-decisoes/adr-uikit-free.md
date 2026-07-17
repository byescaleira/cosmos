---
tags: [adr, platform]
aliases: [ADR UIKit Free, UIKit Free]
related: [[ADR Multiplatform 5 v26]], [[Arquitetura Cosmos]]
---

# ADR — Pacote UIKit-free

> 2026-07-16 · Decided (consolidado; há um `.claude/plan.md` histórico de migração, agora superseded)

**Decisão.** Nunca autorar símbolos UIKit: sem `import UIKit`, `UIColor`, `UIViewController`, `UIHostingController`, `#if canImport(UIKit)`.
- APIs SwiftUI que encapsulam UIKit internamente são OK (não expõem UIKit no código do consumidor): `Color(.systemBackground)`, `Font.system`, `Image(systemName:)`.
- Fontes via **CoreText** (`CTFontManagerRegisterFontsForURL`), não UIKit.
- Haptics via **`.sensoryFeedback`** (SwiftUI, iOS 17+), não `UIImpactFeedbackGenerator`.

**Contexto histórico.** `.claude/plan.md` documentou a migração: únicas refs explícitas a UIKit eram `#if canImport(UIKit)` em `CosmosList.swift` (sidebar) e `Color(uiColor:)` em `CosmosColorTokens`. Corrigido para `.listStyle(.sidebar)` com `@available` + fallback, e `Color(.systemBackground)` (iOS/tvOS) / `Color(nsColor: .windowBackgroundColor)` (macOS, AppKit — não UIKit).

**Cuidado.** Um draft antigo erroneamente **removeu watchOS/visionOS** ao mesmo tempo — isso foi **revertido** ([[ADR Multiplatform 5 v26]]). UIKit-free ≠ reduzir plataformas.