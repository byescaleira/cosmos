import SwiftUI

/// Centralizes URL-open handling for descendant ``CosmosLink`` (and native `Link`) views:
/// routes in-app URLs via the `inApp` predicate and hands everything else to the system, while
/// emitting a passive tracking event per open.
///
/// `Link` resolves opens through the environment's `openURL` action, so a single `.cosmosOpenURL`
/// modifier applied above a hierarchy of links intercepts all of them — neither the links nor
/// their container need to know about routing or tracking. Tracking is opt-in
/// (`cosmosConfiguration.tracking.isEnabled`); no network/PII.
///
/// The routing decision is a pure, render-free function (``CosmosOpenURLRouting/resolve(url:inApp:)``)
/// so it is unit-testable without an `OpenURLAction` (whose `Result` is `Sendable` but not
/// `Equatable`). The modifier maps the pure ``CosmosOpenURLResolution`` onto `OpenURLAction.Result`
/// at the wiring layer.
public enum CosmosOpenURLResolution: String, Sendable, Equatable, CaseIterable {
    /// The app handled the URL in-app; do not hand it to the system.
    case handled
    /// Hand the URL to the system (default).
    case systemAction
    /// Discard the URL (do nothing).
    case discarded
}

/// Pure URL→resolution routing. URLs the `inApp` predicate accepts are routed in-app
/// (`.handled`); everything else falls back to `.systemAction`. Testable without rendering.
public enum CosmosOpenURLRouting {
    public static func resolve(url: URL, inApp: @Sendable (URL) -> Bool) -> CosmosOpenURLResolution {
        inApp(url) ? .handled : .systemAction
    }
}

private struct CosmosOpenURLModifier: ViewModifier {
    let inApp: @Sendable (URL) -> Bool
    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTrackingId) private var trackingId

    func body(content: Content) -> some View {
        content.environment(\.openURL, OpenURLAction(handler: { url in
            let resolution = CosmosOpenURLRouting.resolve(url: url, inApp: inApp)
            configuration.tracking.track(.init(
                name: "open_url",
                component: "CosmosOpenURL",
                componentId: trackingId,
                action: .tap,
                metadata: ["url": url.absoluteString, "resolution": resolution.rawValue]
            ))
            switch resolution {
            case .handled: return .handled
            case .systemAction: return .systemAction(url)
            case .discarded: return .discarded
            }
        }))
    }
}

extension View {
    /// Centralizes URL handling for descendant ``CosmosLink``/`Link` views: the `inApp` predicate
    /// returns `true` for URLs the app routes internally (those resolve to `.handled` — the
    /// `openURL` action short-circuits and the app navigates); all other URLs fall back to the
    /// system. Emits a passive tracking event per open (opt-in via `cosmosConfiguration.tracking`).
    ///
    /// Apply once above a hierarchy of links. To additionally hand a URL to the system *in-app*
    /// (`OpenURLAction.Result.systemAction(_:prefersInApp:)`, iOS 26+), wrap at the call site
    /// rather than here — Cosmos keeps the baseline path platform-agnostic.
    public func cosmosOpenURL(inApp: @escaping @Sendable (URL) -> Bool = { _ in false }) -> some View {
        modifier(CosmosOpenURLModifier(inApp: inApp))
    }
}