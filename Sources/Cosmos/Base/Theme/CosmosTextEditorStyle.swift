import Foundation

/// Visual variant selectors for ``CosmosTextEditor``.
///
/// The selector enum itself is platform-agnostic (carried on all 5 platforms for API uniformity,
/// like ``CosmosDatePickerStyle``). `TextEditorStyle` — and its `.automatic`/`.plain`/
/// `.roundedBorder` built-ins — is `@available(iOS 17.0, macOS 14.0, visionOS 1.0, *)` and
/// **unavailable on tvOS/watchOS**, so the applier + the ``CosmosTextEditor`` atom are guarded with
/// `#if !os(tvOS) && !os(watchOS)`. `TextEditorStyleConfiguration` is an **empty** opaque struct:
/// a custom conforming style cannot read text/selection inside `makeBody`, so Cosmos forwards
/// the native built-ins only (no custom `CosmosTextEditorChrome`).
public enum CosmosTextEditorStyle: String, Sendable, Codable, CaseIterable {
    case automatic
    case plain
    case roundedBorder
}