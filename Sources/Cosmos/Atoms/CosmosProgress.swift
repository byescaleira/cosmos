import SwiftUI
import CoreGraphics

/// A progress atom wrapping `ProgressView` with token-driven tint, accessibility, tracking, and
/// a custom conforming ``CosmosProgressChrome`` style for the `.cosmos` variant.
///
/// State and theme are **global**: this atom reads ``CosmosTheme`` and ``CosmosConfiguration``
/// from the environment and overrides per-instance via `.cosmos*` modifiers. The visual variant
/// comes from ``CosmosTheme/progressStyle`` (default `.automatic`).
///
/// **Motion:** the determinate fill is a value mutation → `.valueChange` (applied in
/// ``CosmosProgressChrome`` via the policy-gated `.cosmosAnimation`). The indeterminate case
/// delegates to the native circular spinner, which auto-respects Reduce Motion — Cosmos does
/// not double-gate it. Continuous-loop suppression is therefore handled natively; a custom
/// indefinite animation (not used here) would have to be suppressed via ``CosmosMotionPolicy``
/// unless progress is the sole state signal (`.preserve`).
public struct CosmosProgress: View {
    private let storage: Storage

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId

    private enum Storage {
        case indeterminate(label: AnyView?)
        case determinate(value: Double, total: Double, label: AnyView?)
    }

    /// Indeterminate progress (spinner), no label.
    public init() { storage = .indeterminate(label: nil) }

    /// Indeterminate progress with a custom label.
    public init<L: View>(@ViewBuilder label: () -> L) {
        storage = .indeterminate(label: AnyView(label()))
    }

    /// Indeterminate progress with a localized String Catalog title.
    public init(_ titleKey: String) {
        storage = .indeterminate(label: AnyView(CosmosLocalizedText(key: titleKey)))
    }

    /// Determinate progress. A `nil` value falls back to indeterminate.
    public init(value: Double?, total: Double = 1.0) {
        storage = Self.determinateStorage(value: value, total: total, label: nil)
    }

    /// Determinate progress with a custom label.
    public init<L: View>(value: Double?, total: Double = 1.0, @ViewBuilder label: () -> L) {
        storage = Self.determinateStorage(value: value, total: total, label: AnyView(label()))
    }

    /// Determinate progress with a localized String Catalog title.
    public init(_ titleKey: String, value: Double?, total: Double = 1.0) {
        storage = Self.determinateStorage(value: value, total: total, label: AnyView(CosmosLocalizedText(key: titleKey)))
    }

    private static func determinateStorage(value: Double?, total: Double, label: AnyView?) -> Storage {
        if let value { return .determinate(value: value, total: total, label: label) }
        return .indeterminate(label: label)
    }

    public var body: some View {
        if configuration.enable.isVisible {
            progressView
                .modifier(CosmosProgressStyleApplier(style: theme.progressStyle))
                .tint(theme.colors.accent)
                .applyCosmosAccessibility(configuration.accessibility)
                .onAppear { trackAppear() }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var progressView: some View {
        switch storage {
        case .indeterminate(let label):
            if let label { ProgressView { label } }
            else { ProgressView() }
        case .determinate(let value, let total, let label):
            if let label { ProgressView(value: value, total: total) { label } }
            else { ProgressView(value: value, total: total) }
        }
    }

    private func trackAppear() {
        configuration.tracking.track(.init(
            name: "progress_appear",
            component: "CosmosProgress",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }
}

// MARK: - Style resolution

/// Resolves a ``CosmosProgressStyle`` to a concrete `ProgressViewStyle`: built-ins delegate to the
/// native statics; `.cosmos` routes through the custom ``CosmosProgressChrome``.
private struct CosmosProgressStyleApplier: ViewModifier {
    let style: CosmosProgressStyle
    func body(content: Content) -> some View {
        switch style {
        case .automatic: content.progressViewStyle(.automatic)
        case .circular:  content.progressViewStyle(.circular)
        case .linear:    content.progressViewStyle(.linear)
        case .cosmos:    content.progressViewStyle(CosmosProgressChrome())
        }
    }
}

/// Pure accessibility helpers for progress rendering (testable without rendering views).
public enum CosmosProgressAccessibility {
    /// `true` when there is no fraction → indeterminate (continuous) progress.
    public static func isIndeterminate(fractionCompleted: Double?) -> Bool {
        fractionCompleted == nil
    }

    /// The VoiceOver value string for a determinate fraction, clamped to `[0, 1]` and rendered as
    /// a rounded percent. Empty for indeterminate (the native spinner owns its own value).
    public static func valueString(fractionCompleted: Double?) -> String {
        guard let fraction = fractionCompleted else { return "" }
        let clamped = max(0, min(1, fraction))
        return "\(Int((clamped * 100).rounded()))%"
    }
}

/// Custom `ProgressViewStyle`: a token-driven determinate bar rendered from `fractionCompleted`
/// (with a policy-gated `.valueChange` animation and re-applied `.updatesFrequently` trait + value
/// string), delegating the indeterminate case to the native circular spinner. The native spinner
/// is requested with an explicit `.progressViewStyle(.circular)` to avoid recursing into this style.
/// The translucent track collapses to opaque when `accessibilityReduceTransparency` is active and
/// `configuration.motion.respectReduceTransparency` is set (config-aware, mirroring ``CosmosCard``).
public struct CosmosProgressChrome: ProgressViewStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        CosmosProgressChromeBody(configuration: configuration)
    }
}

private struct CosmosProgressChromeBody: View {
    let configuration: ProgressViewStyle.Configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosConfiguration) private var cosmosConfiguration
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    /// Collapses the translucent track to opaque when Reduce Transparency is active and respected
    /// by config (mirrors the ``CosmosCard`` shadow-suppression pattern — config-aware, not the
    /// bare env value).
    private var trackFillOpacity: Double {
        (reduceTransparency && cosmosConfiguration.motion.respectReduceTransparency) ? 1.0 : 0.4
    }

    var body: some View {
        if CosmosProgressAccessibility.isIndeterminate(fractionCompleted: configuration.fractionCompleted) {
            // Indeterminate: delegate to the native circular spinner (auto-respects Reduce Motion).
            ProgressView(configuration).progressViewStyle(.circular)
        } else {
            // Determinate: custom token-driven bar.
            let fraction = configuration.fractionCompleted ?? 0
            VStack(alignment: .leading, spacing: CosmosSpacingTokens.xs) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: CosmosRadiusTokens.small, style: .continuous)
                            .fill(theme.colors.outline.opacity(trackFillOpacity))
                        RoundedRectangle(cornerRadius: CosmosRadiusTokens.small, style: .continuous)
                            .fill(theme.colors.accent)
                            .frame(width: max(0, geo.size.width * CGFloat(max(0, min(1, fraction)))))
                    }
                }
                .frame(height: 6)
                if let label = configuration.label { label }
            }
            .cosmosAnimation(.valueChange, value: fraction)
            .accessibilityValue(Text(CosmosProgressAccessibility.valueString(fractionCompleted: fraction)))
            .accessibilityAddTraits(.updatesFrequently)
        }
    }
}

// MARK: - Previews

#Preview("Progress styles") {
    VStack(alignment: .leading, spacing: 24) {
        CosmosProgress()
        CosmosProgress("preview.description")
        CosmosProgress(value: 0.3)
        CosmosProgress(value: 0.7).cosmosProgressStyle(.linear)
        CosmosProgress(value: 0.45).cosmosProgressStyle(.cosmos)
        CosmosProgress().cosmosProgressStyle(.cosmos)
    }
    .padding()
}

#Preview("Progress – loading + dark") {
    VStack(alignment: .leading, spacing: 24) {
        CosmosProgress(value: 0.6).cosmosProgressStyle(.cosmos)
        CosmosProgress("preview.description").cosmosProgressStyle(.circular)
    }
    .padding()
    .preferredColorScheme(.dark)
}

#Preview("Progress – accessibility size + reduce motion", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 24) {
            CosmosProgress(value: 0.4).cosmosProgressStyle(.cosmos)
            CosmosProgress().cosmosProgressStyle(.cosmos)
        }
        .padding()
        .cosmosPreviewVariant(.reduceMotion)
        .cosmosPreviewEnv(dynamicTypeSize: .accessibility3)
    }
}

#Preview("Progress – reduce transparency collapses track", traits: .sizeThatFitsLayout) {
    CosmosPreviewContainer {
        VStack(alignment: .leading, spacing: 24) {
            CosmosProgress(value: 0.5).cosmosProgressStyle(.cosmos)
            CosmosProgress(value: 0.8).cosmosProgressStyle(.cosmos)
        }
        .padding()
        .cosmosPreviewVariant(.reduceTransparency)
    }
}