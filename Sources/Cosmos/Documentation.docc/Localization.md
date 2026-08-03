# Localization

String Catalogs (`.xcstrings`) compiled via `.process("Resources")` in `Package.swift`.
Resolve with ``CosmosLocalizationConfiguration`` and the public string-constant symbols in
``CosmosPreviewStrings``. Baseline `en` + `pt-BR`, extensible. No `Bundle.module` string-table
plumbing, no build plugin.

> Note: Xcode's "Generate String Catalog Symbols" codegen emits a `LocalizedStringResource` extension
> from these keys, but SwiftPM's `swift build` does **not** run that codegen, so generated symbols are
> not available in-library under the project's primary build path. ``CosmosButton`` accepts a
> `LocalizedStringResource` so consumers can pass their own app's generated symbols; Cosmos's own
> previews use ``CosmosPreviewStrings`` keys through the config pipeline.

## Topics

- ``CosmosLocalizationConfiguration``
- ``CosmosLocalizedText``
- ``CosmosPreviewStrings``