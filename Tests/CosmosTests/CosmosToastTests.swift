import Testing
import SwiftUI
@testable import Cosmos

@MainActor
@Suite("CosmosToast (Wave H)")
struct CosmosToastTests {

    // MARK: - CosmosToastPlacement

    @Test func placementAllCases() {
        #expect(CosmosToastPlacement.allCases == [.top, .bottom])
    }

    @Test func placementAlignment() {
        #expect(CosmosToastPlacement.top.alignment == .top)
        #expect(CosmosToastPlacement.bottom.alignment == .bottom)
    }

    @Test func placementHashable() {
        // ForEach(id: \.self) over roles/placements requires Hashable; exercise set membership.
        #expect(Set([CosmosToastPlacement.top, .bottom]).count == 2)
        #expect(CosmosToastPlacement.top == .top)
        #expect(CosmosToastPlacement.top != .bottom)
    }

    // MARK: - CosmosToastTint

    @Test func tintAllCases() {
        #expect(CosmosToastTint.allCases == [.primary, .success, .warning, .error])
    }

    // MARK: - CosmosToastRole — preset mapping (icon × tint × appearHaptic)

    @Test func roleInfoMapping() {
        let role = CosmosToastRole.info
        #expect(role.icon == "info.circle.fill")
        #expect(role.tint == .primary)
        #expect(role.appearHaptic == nil) // neutral — no haptic on informational appear
    }

    @Test func roleSuccessMapping() {
        let role = CosmosToastRole.success
        #expect(role.icon == "checkmark.circle.fill")
        #expect(role.tint == .success)
        #expect(role.appearHaptic == .success)
    }

    @Test func roleWarningMapping() {
        let role = CosmosToastRole.warning
        #expect(role.icon == "exclamationmark.triangle.fill")
        #expect(role.tint == .warning)
        #expect(role.appearHaptic == .warning)
    }

    @Test func roleErrorMapping() {
        let role = CosmosToastRole.error
        #expect(role.icon == "xmark.octagon.fill")
        #expect(role.tint == .error)
        #expect(role.appearHaptic == .error)
    }

    @Test func roleCustomInit() {
        let role = CosmosToastRole(icon: "bolt.fill", tint: .warning, appearHaptic: .impact(weight: .medium))
        #expect(role.icon == "bolt.fill")
        #expect(role.tint == .warning)
        #expect(role.appearHaptic == .impact(weight: .medium))
    }

    @Test func roleCustomInitDefaultHaptic() {
        // `appearHaptic` defaults to nil.
        let role = CosmosToastRole(icon: "star", tint: .primary)
        #expect(role.appearHaptic == nil)
    }

    @Test func roleHashableAndDistinct() {
        // ForEach(id: \.self) over the four presets requires Hashable + distinctness.
        let roles: [CosmosToastRole] = [.info, .success, .warning, .error]
        #expect(Set(roles).count == 4)
        #expect(CosmosToastRole.success == .success)
        #expect(CosmosToastRole.success != .error)
    }

    // MARK: - CosmosToastContent — convenience inits construct without crashing

    @Test func toastContentLocalizedInitConstructs() {
        // The localized-key convenience init builds a CosmosText-backed content; value-level
        // construction only (no ViewInspector / snapshots per the test contract).
        let content = CosmosToastContent(role: .success, "common.save")
        _ = content
        #expect(content.role == .success)
    }

    @Test func toastContentVerbatimInitConstructs() {
        let content = CosmosToastContent(role: .warning, verbatim: "Heads up")
        _ = content
        #expect(content.role == .warning)
    }

    @Test func toastContentCustomMessageConstructs() {
        // Non-CosmosText message path (custom View).
        let content = CosmosToastContent(role: .error) {
            CosmosText(verbatim: "Could not reach the server.")
        }
        #expect(content.role == .error)
    }

    // MARK: - CosmosHapticsFeedback Hashable (added for CosmosToastRole.appearHaptic)

    @Test func hapticsFeedbackHashable() {
        // CosmosToastRole is Hashable; its appearHaptic: CosmosHapticsFeedback? field must be
        // Hashable for the synthesized conformance. Exercise set membership + equality.
        #expect(Set([CosmosHapticsFeedback.success, .warning, .error]).count == 3)
        #expect(CosmosHapticsFeedback.success == .success)
        #expect(CosmosHapticsFeedback.success != .error)
        #expect(CosmosHapticsFeedback.impact(weight: .light) == .impact(weight: .light))
        #expect(CosmosHapticsFeedback.impact(weight: .light) != .impact(weight: .heavy))
        #expect(CosmosHapticsFeedback.impact(weight: .medium, intensity: 0.5)
                == .impact(weight: .medium, intensity: 0.5))
        #expect(CosmosHapticsFeedback.impact(weight: .medium, intensity: 0.5)
                != .impact(weight: .medium, intensity: 0.8))
        #expect(CosmosHapticsFeedback.impact(weight: .light) == .impact(weight: .light, intensity: nil))
    }
}