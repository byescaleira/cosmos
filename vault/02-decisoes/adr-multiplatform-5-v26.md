---
tags: [adr, platform]
aliases: [ADR Multiplatform 5 v26]
related: [[ADR UIKit Free]], [[Versionamento]], [[Plataforma Guards]]
---

# ADR — Multiplatform, 5 plataformas em `.v26`

> 2026-07-16 · Decided (restaurado depois de um draft ter errado)

**Decisão.** Todo componente compila e se comporta bem em **iOS / macOS / tvOS / watchOS / visionOS — todos em `.v26`** (Xcode 26, Liquid Glass). `Package.swift` targets os 5; `swift-tools-version: 6.4`; componentes ausentes em alguma plataforma guardados com `#if os()`.

**Contexto.** Usuário quer que cada componente responda o melhor por plataforma. Um draft de docs chegou a listar só iOS/macOS/tvOS 27 e "drop watchOS+visionOS" — **incorreto**; reconciliado 2026-07-17 ([[Roadmap]] Later). `Package.swift` + `CLAUDE.md` são autoritativos: 5 plataformas `.v26`.

**Consequências.** CI deve ter matrix per-platform (hoje só `macos-latest` — [[Roadmap]] Later). Átomos ausentes (Slider/Stepper em tvOS, DatePicker em tvOS, TextEditor em tvOS/watchOS, Menu em watchOS, GroupBox em tvOS/watchOS) precisam de guards + fallbacks — ver [[Plataforma Guards]].