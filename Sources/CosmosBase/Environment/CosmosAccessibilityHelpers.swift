import SwiftUI

// MARK: - Optional accessibility modifiers

extension View {
    /// Applies an accessibility label only when the provided string is non-nil.
    ///
    /// Use this helper to avoid overriding the default accessibility label
    /// inferred by SwiftUI (for example, the visible text of a button).
    @ViewBuilder
    public func accessibilityLabelOrNil(_ label: String?) -> some View {
        if let label {
            self.accessibilityLabel(Text(label))
        } else {
            self
        }
    }

    /// Applies an accessibility hint only when the provided string is non-nil.
    @ViewBuilder
    public func accessibilityHintOrNil(_ hint: String?) -> some View {
        if let hint {
            self.accessibilityHint(hint)
        } else {
            self
        }
    }
}
