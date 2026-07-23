import SwiftUI

/// Where a toast is anchored within the presenting view.
public enum CosmosToastPlacement: Sendable, Hashable, CaseIterable {
    /// Anchored to the top (slides in from the top via `.cosmosTransition(.slide)`).
    case top
    /// Anchored to the bottom (slides in from the bottom via `.cosmosTransition(.sheet)`).
    case bottom

    /// SwiftUI alignment used by the overlay/ZStack.
    var alignment: Alignment {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        }
    }
}

/// Which semantic color a role-tinted ``CosmosToastContent`` resolves its icon to.
public enum CosmosToastTint: Sendable, Hashable, CaseIterable {
    case primary, success, warning, error
}

/// A toast role: bundles an SF Symbol, a semantic tint, and the appear haptic. Used by the role
/// conveniences (``View/cosmosToast(_:isPresented:)`` / ``View/cosmosToast(_:item:)``) to build a
/// ``CosmosToastContent`` and wire the appear haptic in one call.
public struct CosmosToastRole: Sendable, Hashable {
    public let icon: String
    public let tint: CosmosToastTint
    public let appearHaptic: CosmosHapticsFeedback?

    public init(icon: String, tint: CosmosToastTint, appearHaptic: CosmosHapticsFeedback? = nil) {
        self.icon = icon
        self.tint = tint
        self.appearHaptic = appearHaptic
    }

    /// Informational (no haptic — neutral appearance).
    public static let info = CosmosToastRole(icon: "info.circle.fill", tint: .primary)
    /// Success (green tint + `.success` haptic).
    public static let success = CosmosToastRole(icon: "checkmark.circle.fill", tint: .success, appearHaptic: .success)
    /// Warning (warning tint + `.warning` haptic).
    public static let warning = CosmosToastRole(icon: "exclamationmark.triangle.fill", tint: .warning, appearHaptic: .warning)
    /// Error (error tint + `.error` haptic).
    public static let error = CosmosToastRole(icon: "xmark.circle.fill", tint: .error, appearHaptic: .error)
}

/// A transient, non-modal toast presentation with the same binding API as `.sheet` / `.alert`:
/// ``View/cosmosToast(isPresented:placement:dismissAfter:dismissOnTap:haptic:onDismiss:content:)``
/// and the `item:` form. There is no native SwiftUI `.toast` modifier (iOS 26 / 27), so this
/// composes the two native primitives that back the pattern — the binding/presentation shape of
/// `.alert(_:isPresented:)` / `.sheet(item:)`, and a custom overlay surfaced with `.regularMaterial`
/// entering/leaving via `.cosmosTransition` gated by ``CosmosMotionPolicy``. `.glassEffect()` is
/// intentionally not used: Apple reserves Liquid Glass for the navigation/controls layer.
///
/// See `vault/03-componentes/cosmos-toast.md` for the research.
///
/// Auto-dismiss (~3s default) runs via a cancellable `Task` keyed to the presentation identity; no
/// `DispatchQueue`, no `NSLock`. Tap-to-dismiss (default on) flips the binding. The appear haptic
/// is gated by ``CosmosHapticsPolicy`` + Reduce Motion. Tracking fires `.appear` / `.disappear`.
@MainActor
private struct CosmosToastHost<Key: Hashable, ToastContent: View>: View {
    /// `nil` = not presented. For the `isPresented` form this is a `Bool`; for the `item` form the
    /// item's `ID`. A change to a new non-`nil` value re-presents (a new toast replaces the visible
    /// one).
    let presentedKey: Key?
    /// Flips the source binding back to "not presented" (`isPresented = false` / `item = nil`).
    /// `@Sendable` because it is captured by the auto-dismiss `Task`.
    let dismiss: @Sendable () -> Void
    let placement: CosmosToastPlacement
    let dismissAfter: Duration?
    let dismissOnTap: Bool
    let haptic: CosmosHapticsFeedback?
    let onDismiss: (@Sendable () -> Void)?
    @ViewBuilder let content: () -> ToastContent

    @Environment(\.cosmosConfiguration) private var configuration
    @Environment(\.cosmosTheme) private var theme
    @Environment(\.cosmosTrackingId) private var trackingId
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Bumped on every present (initial + re-present). Drives the appear haptic (`@Sendable`,
    /// `Equatable`) and the toast content's `.id(presentToken)` so a re-present animates out/in.
    @State private var presentToken = 0

    private var shadowHidden: Bool {
        CosmosMotionPolicy.shouldCollapseTransparency(
            respectReduceTransparency: configuration.motion.respectReduceTransparency,
            reduceTransparency: reduceTransparency,
            policy: configuration.motion.reduceTransparencyPolicy
        ) || reduceMotion
    }

    /// Caps the toast width on regular width classes so it doesn't span the screen.
    private var maxToastWidth: CGFloat {
        horizontalSizeClass == .regular ? 420 : .infinity
    }

    @ViewBuilder
    var body: some View {
        // Bind Sendable locals before the `.task` closure so it captures these, not `self`
        // (the host is `@MainActor`; a `@Sendable` closure may not capture it).
        let isPresent = presentedKey != nil
        let autoDismissAfter = dismissAfter
        let autoDismiss = dismiss
        ZStack(alignment: placement.alignment) {
            if presentedKey != nil {
                toastSurface
                    .id(presentToken)
                    .cosmosTransition(transitionPreset)
                    .onAppear { bumpForPresent() }     // initial-present (host appeared already showing)
                    .onChange(of: presentedKey) { old, new in
                        if new != nil { bumpForPresent() }
                        else if old != nil { handleDismiss() }
                    }
                    .task(id: presentedKey) {          // auto-dismiss, cancelled on key change / nil
                        guard isPresent, let autoDismissAfter else { return }
                        try? await Task.sleep(for: autoDismissAfter)
                        if !Task.isCancelled { autoDismiss() }
                    }
                    .padding(placement == .top ? .top : .bottom, CosmosSpacingTokens.medium)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: placement.alignment)
        .allowsHitTesting(presentedKey != nil)
        .padding(CosmosSpacingTokens.medium)
    }

    @ViewBuilder
    private var toastSurface: some View {
        let chrome = toastChrome
        if dismissOnTap {
            // `.plain` so the Button does not restyle the toast; nested inner buttons (caller's
            // actions) win their own taps — tap-to-dismiss fires only on the surrounding chrome.
            Button(action: dismiss) { chrome }
                .buttonStyle(.plain)
        } else {
            chrome
        }
    }

    @ViewBuilder
    private var toastChrome: some View {
        content()
            .padding(CosmosSpacingTokens.value(for: theme.padding))
            .frame(maxWidth: maxToastWidth, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: 32))
            .shadow(
                color: theme.colors.primary.opacity(shadowHidden ? 0 : theme.motion.shadowOpacity),
                radius: shadowHidden ? 0 : theme.motion.shadowRadius,
                y: 4
            )
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isStaticText)
            .modifier(OptionalHapticModifier(feedback: haptic, trigger: presentToken))
    }

    private var toastBackgroundStyle: AnyShapeStyle {
        if CosmosMotionPolicy.shouldCollapseTransparency(
            respectReduceTransparency: configuration.motion.respectReduceTransparency,
            reduceTransparency: reduceTransparency,
            policy: configuration.motion.reduceTransparencyPolicy
        ) {
            AnyShapeStyle(theme.colors.surface)
        } else {
            AnyShapeStyle(.regularMaterial)
        }
    }

    private var transitionPreset: CosmosTransition {
        placement == .top ? .slide : .sheet
    }

    private func bumpForPresent() {
        presentToken &+= 1
        configuration.tracking.track(.init(
            name: "toast_appear",
            component: "CosmosToast",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .appear
        ))
    }

    private func handleDismiss() {
        onDismiss?()
        configuration.tracking.track(.init(
            name: "toast_disappear",
            component: "CosmosToast",
            componentId: trackingId ?? configuration.accessibility.identifier,
            action: .disappear
        ))
    }
}

/// Applies `.cosmosHaptic` only when a feedback is configured; a no-op pass-through otherwise.
private struct OptionalHapticModifier<Trigger: Equatable & Sendable>: ViewModifier {
    let feedback: CosmosHapticsFeedback?
    let trigger: Trigger
    func body(content: Content) -> some View {
        guard let feedback else { return AnyView(content) }
        return AnyView(content.cosmosHaptic(feedback, trigger: trigger))
    }
}

// MARK: - Core modifiers (caller-provided content)

private struct CosmosToastIsPresentedModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let placement: CosmosToastPlacement
    let dismissAfter: Duration?
    let dismissOnTap: Bool
    let haptic: CosmosHapticsFeedback?
    let onDismiss: (@Sendable () -> Void)?
    @ViewBuilder let content: () -> ToastContent

    func body(content: Content) -> some View {
        // Capture the `Binding<Bool>` (Sendable) as a local so the dismiss closure captures it,
        // not `self` (the modifier is `@MainActor` via `ViewModifier` and is not `Sendable`).
        let binding = $isPresented
        return content.overlay(alignment: placement.alignment) {
            CosmosToastHost(
                presentedKey: isPresented,
                dismiss: { binding.wrappedValue = false },
                placement: placement,
                dismissAfter: dismissAfter,
                dismissOnTap: dismissOnTap,
                haptic: haptic,
                onDismiss: onDismiss,
                content: self.content
            )
        }
    }
}

private struct CosmosToastItemModifier<Item: Identifiable & Sendable, ToastContent: View>: ViewModifier {
    @Binding var item: Item?
    let placement: CosmosToastPlacement
    let dismissAfter: Duration?
    let dismissOnTap: Bool
    let haptic: CosmosHapticsFeedback?
    let onDismiss: (@Sendable () -> Void)?
    @ViewBuilder let content: (Item) -> ToastContent

    func body(content: Content) -> some View {
        let binding = $item
        return content.overlay(alignment: placement.alignment) {
            CosmosToastHost(
                presentedKey: item?.id,
                dismiss: { binding.wrappedValue = nil },
                placement: placement,
                dismissAfter: dismissAfter,
                dismissOnTap: dismissOnTap,
                haptic: haptic,
                onDismiss: onDismiss,
                content: { if let item { self.content(item) } }
            )
        }
    }
}

// MARK: - Role-convenience modifiers (CosmosToastContent + role haptic)

private struct CosmosToastRoleIsPresentedModifier<Message: View>: ViewModifier {
    let role: CosmosToastRole
    @Binding var isPresented: Bool
    let placement: CosmosToastPlacement
    let dismissAfter: Duration?
    let dismissOnTap: Bool
    let onDismiss: (@Sendable () -> Void)?
    @ViewBuilder let message: () -> Message

    func body(content: Content) -> some View {
        content.modifier(CosmosToastIsPresentedModifier(
            isPresented: $isPresented,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            haptic: role.appearHaptic,
            onDismiss: onDismiss
        ) {
            CosmosToastContent(role: role, message: message)
        })
    }
}

private struct CosmosToastRoleItemModifier<Item: Identifiable & Sendable, Message: View>: ViewModifier {
    let role: CosmosToastRole
    @Binding var item: Item?
    let placement: CosmosToastPlacement
    let dismissAfter: Duration?
    let dismissOnTap: Bool
    let onDismiss: (@Sendable () -> Void)?
    @ViewBuilder let message: (Item) -> Message

    func body(content: Content) -> some View {
        content.modifier(CosmosToastItemModifier(
            item: $item,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            haptic: role.appearHaptic,
            onDismiss: onDismiss
        ) { item in
            CosmosToastContent(role: role) { message(item) }
        })
    }
}

// MARK: - Public API

extension View {
    /// Presents a toast when `isPresented` becomes `true`, mirroring `.sheet(isPresented:)`.
    ///
    /// - Parameters:
    ///   - placement: `.top` (default) or `.bottom`.
    ///   - dismissAfter: auto-dismiss delay; `nil` = manual (caller flips the binding), parity with
    ///     `.sheet`. Default `.seconds(3)`.
    ///   - dismissOnTap: when true (default), a tap on the toast flips the binding to dismiss.
    ///   - haptic: optional feedback fired on present, gated by the haptics config + Reduce Motion.
    ///   - onDismiss: fired when the toast leaves (auto-dismiss, tap, or programmatic).
    @preconcurrency
    public func cosmosToast<Content: View>(
        isPresented: Binding<Bool>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: Duration? = .seconds(3),
        dismissOnTap: Bool = true,
        haptic: CosmosHapticsFeedback? = nil,
        onDismiss: (@Sendable () -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(CosmosToastIsPresentedModifier(
            isPresented: isPresented,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            haptic: haptic,
            onDismiss: onDismiss,
            content: content
        ))
    }

    /// Presents a toast for a non-`nil` `item`, mirroring `.sheet(item:)`. Re-presents when the
    /// item's identity changes (a new toast replaces the visible one without flicker). `Item` must
    /// be `Sendable` so the dismiss path is concurrency-safe under Swift 6 (toast payloads are
    /// typically `Sendable` value types).
    @preconcurrency
    public func cosmosToast<Item: Identifiable & Sendable, Content: View>(
        item: Binding<Item?>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: Duration? = .seconds(3),
        dismissOnTap: Bool = true,
        haptic: CosmosHapticsFeedback? = nil,
        onDismiss: (@Sendable () -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(CosmosToastItemModifier(
            item: item,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            haptic: haptic,
            onDismiss: onDismiss,
            content: content
        ))
    }

    /// Role convenience: presents a role-tinted ``CosmosToastContent`` (icon + message) for a
    /// `Bool` binding, wiring the role's appear haptic automatically.
    @preconcurrency
    public func cosmosToast<Message: View>(
        _ role: CosmosToastRole,
        isPresented: Binding<Bool>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: Duration? = .seconds(3),
        dismissOnTap: Bool = true,
        onDismiss: (@Sendable () -> Void)? = nil,
        @ViewBuilder message: @escaping () -> Message
    ) -> some View {
        modifier(CosmosToastRoleIsPresentedModifier(
            role: role,
            isPresented: isPresented,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            onDismiss: onDismiss,
            message: message
        ))
    }

    /// Role convenience: presents a role-tinted ``CosmosToastContent`` for an `item` binding.
    /// `Item` must be `Sendable` (see the core `item` form).
    @preconcurrency
    public func cosmosToast<Item: Identifiable & Sendable, Message: View>(
        _ role: CosmosToastRole,
        item: Binding<Item?>,
        placement: CosmosToastPlacement = .top,
        dismissAfter: Duration? = .seconds(3),
        dismissOnTap: Bool = true,
        onDismiss: (@Sendable () -> Void)? = nil,
        @ViewBuilder message: @escaping (Item) -> Message
    ) -> some View {
        modifier(CosmosToastRoleItemModifier(
            role: role,
            item: item,
            placement: placement,
            dismissAfter: dismissAfter,
            dismissOnTap: dismissOnTap,
            onDismiss: onDismiss,
            message: message
        ))
    }
}
