# Localization

Cosmos resolves every text key through ``CosmosLocalizationConfiguration``.
This makes it possible to drive screens from JSON while still supporting
host-app translations.

## Default behavior

`CosmosLocalizationConfiguration` defaults to `CosmosResources.bundle`, the resource
bundle shipped with `CosmosBase`. If a key is not found in that bundle, the raw
key is returned as a fallback.

## Overriding the bundle, locale, or table

Host apps typically override localization to use `Bundle.main` and the current
user locale:

```swift
ContentView()
    .environment(
        \.cosmosConfiguration,
        .default.withLocalization(
            bundle: .main,
            locale: .current
        )
    )
```

## Locale-aware lookup

`CosmosLocalizationConfiguration` selects a language-specific `.lproj` bundle
when one exists. It tries the full locale identifier first (for example
`pt-BR`), then the base language code (`pt`), so regional variants and
platform-specific identifier formats are handled automatically.
