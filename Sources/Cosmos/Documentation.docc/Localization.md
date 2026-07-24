# Localization

String Catalogs (`.xcstrings`) compiled via `.process("Resources")` in `Package.swift`.
Resolve with ``CosmosLocalizationConfiguration`` and the public string-constant symbols in
``CosmosPreviewStrings``. Baseline `en` + `pt-BR`, extensible. No `Bundle.module` string-table
plumbing, no build plugin.

## Topics

- ``CosmosLocalizationConfiguration``
- ``CosmosLocalizedText``
- ``CosmosPreviewStrings``