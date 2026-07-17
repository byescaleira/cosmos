import Foundation

/// String-catalog keys used by co-located `#Preview` blocks, so previews exercise the
/// real localization pipeline (``CosmosLocalizationConfiguration``). Baseline `en` + `pt-BR`
/// in `Resources/Localizable.xcstrings`; extensible to more languages.
public enum CosmosPreviewStrings {
    public static let welcomeHeadline = "welcome.headline"
    public static let welcomeContinue = "welcome.continue"
    public static let previewTitle = "preview.title"
    public static let previewDescription = "preview.description"
    public static let previewName = "preview.name"
    /// Shared loading label (exercises the localization pipeline for the `Loading` catalog key).
    public static let loading = "Loading"
}