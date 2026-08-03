import Foundation

/// String-catalog keys used by co-located `#Preview` blocks and the localization tests, so previews
/// exercise the real localization pipeline (``CosmosLocalizationConfiguration``). Baseline `en` +
/// `pt-BR` in `Resources/Localizable.xcstrings`; extensible to more languages.
///
/// These stay hand-authored `String` constants (rather than the auto-generated `LocalizedStringResource`
/// symbols that Xcode emits from `Localizable.xcstrings`) because the project's primary build/verify
/// path is `swift build` (SwiftPM), and **SwiftPM does not run the Xcode "Generate String Catalog
/// Symbols" codegen** — a clean `swift build` produces no `GeneratedStringSymbols_Localizable.swift`,
/// so generated symbols (`Text(.welcomeHeadline)`) don't resolve under `swift build`. Hand-authoring
/// the same `LocalizedStringResource` extension in checked-in source is not an option either: it would
/// redeclare the symbols that `xcodebuild` (the cross-compile matrix) *does* generate, causing a
/// duplicate-declaration failure under `xcodebuild`. The manual `String` constants are therefore the
/// only path that works under **both** build systems without collision. ``CosmosButton``'s
/// `init(_:action:) where Label == Text` accepts a `LocalizedStringResource` so *consumers* can pass
/// their own app's generated symbols; Cosmos's own previews use these `String` keys via the config pipeline.
public enum CosmosPreviewStrings {
    public static let welcomeHeadline = "welcome.headline"
    public static let welcomeContinue = "welcome.continue"
    public static let previewTitle = "preview.title"
    public static let previewDescription = "preview.description"
    public static let previewName = "preview.name"
    /// Shared loading label (exercises the localization pipeline for the `Loading` catalog key).
    public static let loading = "Loading"
}