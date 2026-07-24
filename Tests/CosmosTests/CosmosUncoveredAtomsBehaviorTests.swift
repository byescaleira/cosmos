import Testing
import SwiftUI
@testable import Cosmos

/// Wave-1 test coverage (T2 + T3): construction-smoke tests for atoms that previously had **only**
/// selector/availability coverage (no init-construction smoke), plus the three atoms that had
/// **no tests at all** (CosmosSecureField, CosmosAdaptiveStack, CosmosLocalizedText). Value-level
/// construction only — no rendering, no ViewInspector / snapshots (per the test contract). The
/// `_ = CosmosX(...)` smoke guarantees every public init builds a view without crashing across
/// the realistic input shapes; bindings use `Binding.constant` (construction smoke does not
/// mutate). Platform-gated atoms use `.disabled(if:)` so the test is always registered (and
/// reported as skipped on the unsupported host) rather than invisible — a Swift Testing trait
/// preferred over `#if os()` guards (WWDC24-10179).
@MainActor
@Suite("Cosmos Atoms — uncovered behavior")
struct CosmosUncoveredAtomsBehaviorTests {

    // MARK: - CosmosSecureField (T3 — previously zero coverage)

    @Test func secureFieldConstructsFromLocalizedKey() {
        _ = CosmosSecureField("preview.title", text: .constant(""))
    }

    @Test func secureFieldConstructsFromLocalizedKeyWithPrompt() {
        _ = CosmosSecureField("preview.title", text: .constant(""), prompt: Text("preview.description"))
    }

    @Test func secureFieldConstructsFromVerbatimTitle() {
        _ = CosmosSecureField(verbatim: "Password", text: .constant(""))
    }

    @Test func secureFieldConstructsWithCustomLabel() {
        _ = CosmosSecureField(text: .constant("")) { Text(verbatim: "Secret") }
    }

    // MARK: - CosmosAdaptiveStack (T3 — previously zero coverage)

    @Test func adaptiveStackConstructsWithContent() {
        _ = CosmosAdaptiveStack { CosmosText(verbatim: "A"); CosmosText(verbatim: "B") }
    }

    @Test func adaptiveStackConstructsViaModifier() {
        _ = CosmosText(verbatim: "row").cosmosAdaptiveStack()
    }

    @Test func adaptiveStackConstructsWithExplicitSpacingsAndAlignments() {
        _ = CosmosAdaptiveStack(
            horizontalSpacing: 8, verticalSpacing: 12,
            horizontalAlignment: .top, verticalAlignment: .leading
        ) { CosmosText(verbatim: "Content") }
    }

    // MARK: - CosmosLocalizedText (T3 — previously zero coverage)

    @Test func localizedTextConstructsFromKey() {
        _ = CosmosLocalizedText(key: "welcome.headline")
    }

    @Test func localizedTextConstructsFromUnresolvedKey() {
        // An unresolved key renders nothing; construction must not crash.
        _ = CosmosLocalizedText(key: "this.key.does.not.exist")
    }

    // MARK: - CosmosDatePicker (T2; gated off tvOS — DatePicker type unavailable there)

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsFromLocalizedKey() {
        _ = CosmosDatePicker("preview.title", selection: .constant(Date()))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsFromVerbatimTitle() {
        _ = CosmosDatePicker(verbatim: "Pick a date", selection: .constant(Date()))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsWithCustomLabelAndComponents() {
        _ = CosmosDatePicker(selection: .constant(Date()), displayedComponents: .date) { Text(verbatim: "When") }
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func datePickerConstructsWithClosedRange() {
        let range = Date()...Date().addingTimeInterval(3600)
        _ = CosmosDatePicker(selection: .constant(Date()), in: range) { Text(verbatim: "In range") }
    }

    @Test(.disabled(if: isTvOS), .tags(.availability, .selector), arguments: CosmosDatePickerStyle.allCases)
    func datePickerAcceptsEveryStyleVariant(_ style: CosmosDatePickerStyle) {
        _ = CosmosDatePicker("preview.title", selection: .constant(Date())).cosmosDatePickerStyle(style)
    }

    // MARK: - CosmosGroupBox (T2)

    @Test func groupBoxConstructsWithContentOnly() {
        _ = CosmosGroupBox { CosmosText(verbatim: "Content") }
    }

    @Test func groupBoxConstructsWithContentAndCustomLabel() {
        _ = CosmosGroupBox(content: { CosmosText(verbatim: "Content") },
                           label: { Text(verbatim: "Group") })
    }

    @Test func groupBoxConstructsFromLocalizedTitleKey() {
        _ = CosmosGroupBox("preview.title") { CosmosText(verbatim: "Content") }
    }

    @Test func groupBoxConstructsFromVerbatimTitle() {
        _ = CosmosGroupBox(verbatim: "Group") { CosmosText(verbatim: "Content") }
    }

    @Test(.tags(.selector), arguments: CosmosGroupBoxStyle.allCases)
    func groupBoxAcceptsEveryStyleVariant(_ style: CosmosGroupBoxStyle) {
        _ = CosmosGroupBox("preview.title") { CosmosText(verbatim: "Content") }
            .cosmosGroupBoxStyle(style)
    }

    // MARK: - CosmosMenu (T2; Menu unavailable on watchOS — atom falls back to CosmosButton)

    @Test func menuConstructsFromLocalizedTitleKey() {
        _ = CosmosMenu("preview.title") { CosmosText(verbatim: "Item") }
    }

    @Test func menuConstructsFromVerbatimTitle() {
        _ = CosmosMenu(verbatim: "Menu") { CosmosText(verbatim: "Item") }
    }

    @Test func menuConstructsWithCustomLabel() {
        _ = CosmosMenu(content: { CosmosText(verbatim: "Item") },
                       label: { Text(verbatim: "Open") })
    }

    @Test func menuConstructsWithPrimaryAction() {
        _ = CosmosMenu(content: { CosmosText(verbatim: "Item") },
                       label: { Text(verbatim: "Open") },
                       primaryAction: {})
    }

    @Test func menuConstructsFromLocalizedTitleKeyAndSystemImage() {
        _ = CosmosMenu("preview.title", systemImage: "ellipsis.circle") { CosmosText(verbatim: "Item") }
    }

    @Test(.tags(.selector), arguments: CosmosMenuStyle.allCases)
    func menuAcceptsEveryStyleVariant(_ style: CosmosMenuStyle) {
        _ = CosmosMenu("preview.title") { CosmosText(verbatim: "Item") }.cosmosMenuStyle(style)
    }

    // MARK: - CosmosLabel (T2)

    @Test func labelConstructsWithCustomTitleAndIcon() {
        _ = CosmosLabel(title: { Text(verbatim: "Title") }, icon: { Image(systemName: "star") })
    }

    @Test func labelConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosLabel("preview.title", systemImage: "star")
    }

    @Test func labelConstructsFromLocalizedKeyAndAssetImage() {
        _ = CosmosLabel("preview.title", image: "PlaceholderAsset")
    }

    @Test func labelConstructsFromVerbatimTitleAndSystemImage() {
        _ = CosmosLabel(verbatim: "Label", systemImage: "star")
    }

    @Test func labelConstructsFromVerbatimTitleAndAssetImage() {
        _ = CosmosLabel(verbatim: "Label", image: "PlaceholderAsset")
    }

    @Test(.tags(.selector), arguments: CosmosLabelStyle.allCases)
    func labelAcceptsEveryStyleVariant(_ style: CosmosLabelStyle) {
        _ = CosmosLabel("preview.title", systemImage: "star").cosmosLabelStyle(style)
    }

    // MARK: - CosmosList (T2)

    @Test func listConstructsWithContentOnly() {
        _ = CosmosList { CosmosText(verbatim: "Row") }
    }

    @Test func listConstructsFromIdentifiableData() {
        _ = CosmosList([ListRow(id: 1, text: "A"), .init(id: 2, text: "B")]) { CosmosText(verbatim: $0.text) }
    }

    @Test func listConstructsFromDataWithIDKeyPath() {
        _ = CosmosList([ListRow(id: 1, text: "A")], id: \.id) { CosmosText(verbatim: $0.text) }
    }

    @Test func listConstructsFromRange() {
        _ = CosmosList(0..<3) { CosmosText(verbatim: "Row \($0)") }
    }

    @Test(.tags(.selector), arguments: CosmosListStyle.allCases)
    func listAcceptsEveryStyleVariant(_ style: CosmosListStyle) {
        _ = CosmosList { CosmosText(verbatim: "Row") }.cosmosListStyle(style)
    }

    // MARK: - CosmosSelectableList (T2)

    @Test func selectableListConstructsOptionalSingleWithContent() {
        _ = CosmosSelectableList(selection: .constant(Int?.none)) { CosmosText(verbatim: "Row") }
    }

    @Test func selectableListConstructsOptionalSingleWithIdentifiableData() {
        _ = CosmosSelectableList(selection: .constant(Int?.none), [ListRow(id: 1, text: "A")]) { CosmosText(verbatim: $0.text) }
    }

    @Test func selectableListConstructsOptionalSingleWithDataAndIDKeyPath() {
        _ = CosmosSelectableList(selection: .constant(Int?.none), [ListRow(id: 1, text: "A")], id: \.id) { CosmosText(verbatim: $0.text) }
    }

    @Test(.disabled(if: isWatchOS), .tags(.availability))
    func selectableListConstructsSetWithContent() {
        _ = CosmosSelectableList(selection: .constant(Set<Int>())) { CosmosText(verbatim: "Row") }
    }

    @Test(.disabled(if: isWatchOS), .tags(.availability))
    func selectableListConstructsSetWithIdentifiableData() {
        _ = CosmosSelectableList(selection: .constant(Set<Int>()), [ListRow(id: 1, text: "A")]) { CosmosText(verbatim: $0.text) }
    }

    // MARK: - CosmosPicker (T2)

    @Test func pickerConstructsFromLocalizedKey() {
        _ = CosmosPicker("preview.title", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsFromVerbatimTitle() {
        _ = CosmosPicker(verbatim: "Pick", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosPicker("preview.title", systemImage: "tag", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
    }

    @Test func pickerConstructsWithCustomLabel() {
        _ = CosmosPicker(selection: .constant("a"), content: { Text(verbatim: "A").tag("a") },
                         label: { Text(verbatim: "Pick") })
    }

    @Test(.tags(.selector), arguments: CosmosPickerStyle.allCases)
    func pickerAcceptsEveryStyleVariant(_ style: CosmosPickerStyle) {
        _ = CosmosPicker("preview.title", selection: .constant("a")) { Text(verbatim: "A").tag("a") }
            .cosmosPickerStyle(style)
    }

    // MARK: - CosmosTabView (T2)

    @Test func tabViewConstructsSelectableWithSelection() {
        _ = CosmosTabView(selection: .constant("a")) {
            Tab("A", systemImage: "1.circle", value: "a") { CosmosText(verbatim: "A") }
            Tab("B", systemImage: "2.circle", value: "b") { CosmosText(verbatim: "B") }
        }
    }

    @Test func tabViewConstructsNonSelectable() {
        _ = CosmosTabView {
            Tab("A", systemImage: "1.circle") { CosmosText(verbatim: "A") }
            Tab("B", systemImage: "2.circle") { CosmosText(verbatim: "B") }
        }
    }

    @Test(.tags(.selector), arguments: CosmosTabViewStyle.allCases)
    func tabViewAcceptsEveryStyleVariant(_ style: CosmosTabViewStyle) {
        _ = CosmosTabView(selection: .constant("a")) {
            Tab("A", systemImage: "1.circle", value: "a") { CosmosText(verbatim: "A") }
        }.cosmosTabViewStyle(style)
    }

    // MARK: - CosmosTextField (T2)

    @Test func textFieldConstructsFromLocalizedKey() {
        _ = CosmosTextField("preview.title", text: .constant(""))
    }

    @Test func textFieldConstructsFromVerbatimTitle() {
        _ = CosmosTextField(verbatim: "Name", text: .constant(""))
    }

    @Test func textFieldConstructsFromLocalizedKeyWithPrompt() {
        _ = CosmosTextField("preview.title", text: .constant(""), prompt: Text("preview.description"))
    }

    @Test func textFieldConstructsWithCustomLabel() {
        _ = CosmosTextField(text: .constant("")) { Text(verbatim: "Field") }
    }

    @Test func textFieldConstructsWithOnSubmit() {
        _ = CosmosTextField(text: .constant(""), onSubmit: {}) { Text(verbatim: "Field") }
    }

    @Test(.tags(.selector), arguments: CosmosTextFieldStyle.allCases)
    func textFieldAcceptsEveryStyleVariant(_ style: CosmosTextFieldStyle) {
        _ = CosmosTextField("preview.title", text: .constant("")).cosmosTextFieldStyle(style)
    }

    // MARK: - CosmosTextEditor (T2; gated off tvOS + watchOS — TextEditor unavailable there)

    @Test(.disabled(if: isTvOS || isWatchOS), .tags(.availability))
    func textEditorConstructsWithTextBinding() {
        _ = CosmosTextEditor(text: .constant(""))
    }

    @Test(.disabled(if: isTvOS || isWatchOS), .tags(.availability, .selector), arguments: CosmosTextEditorStyle.allCases)
    func textEditorAcceptsEveryStyleVariant(_ style: CosmosTextEditorStyle) {
        _ = CosmosTextEditor(text: .constant("")).cosmosTextEditorStyle(style)
    }

    // MARK: - CosmosToggle (T2 — per-init construction smoke)

    @Test func toggleConstructsFromLocalizedKey() {
        _ = CosmosToggle("preview.title", isOn: .constant(false))
    }

    @Test func toggleConstructsFromVerbatimTitle() {
        _ = CosmosToggle(verbatim: "Toggle", isOn: .constant(false))
    }

    @Test func toggleConstructsFromLocalizedKeyAndSystemImage() {
        _ = CosmosToggle("preview.title", systemImage: "wifi", isOn: .constant(false))
    }

    @Test func toggleConstructsWithCustomLabel() {
        _ = CosmosToggle(isOn: .constant(false)) { Text(verbatim: "Custom") }
    }

    @Test(.tags(.selector), arguments: CosmosToggleStyle.allCases)
    func toggleAcceptsEveryStyleVariant(_ style: CosmosToggleStyle) {
        _ = CosmosToggle("preview.title", isOn: .constant(false)).cosmosToggleStyle(style)
    }

    // MARK: - CosmosProgress (T2 — per-init construction smoke)

    @Test func progressConstructsIndeterminate() {
        _ = CosmosProgress()
    }

    @Test func progressConstructsIndeterminateWithLabel() {
        _ = CosmosProgress { Text(verbatim: "Loading") }
    }

    @Test func progressConstructsFromLocalizedTitleKey() {
        _ = CosmosProgress("preview.title")
    }

    @Test func progressConstructsDeterminateWithValue() {
        _ = CosmosProgress(value: 0.5)
    }

    @Test func progressConstructsDeterminateWithValueAndLabel() {
        _ = CosmosProgress(value: 0.5, total: 1.0) { Text(verbatim: "Half") }
    }

    @Test func progressConstructsDeterminateFromLocalizedKey() {
        _ = CosmosProgress("preview.title", value: 0.5)
    }

    @Test(.tags(.selector), arguments: CosmosProgressStyle.allCases)
    func progressAcceptsEveryStyleVariant(_ style: CosmosProgressStyle) {
        _ = CosmosProgress().cosmosProgressStyle(style)
    }

    // MARK: - CosmosSlider (T2; gated off tvOS — Slider unavailable there)

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithCustomLabelAndValueLabels() {
        _ = CosmosSlider(value: .constant(0.5),
                          label: { Text(verbatim: "Slider") },
                          minimumValueLabel: { Text(verbatim: "0") },
                          maximumValueLabel: { Text(verbatim: "1") })
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithLabelOnly() {
        _ = CosmosSlider(value: .constant(0.5), label: { Text(verbatim: "Slider") })
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsWithNoLabels() {
        _ = CosmosSlider(value: .constant(0.5))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsFromLocalizedKeyAndStep() {
        _ = CosmosSlider("preview.title", value: .constant(0.5), step: 0.1)
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsFromVerbatimTitle() {
        _ = CosmosSlider(verbatim: "Slider", value: .constant(0.5))
    }

    @Test(.disabled(if: isTvOS), .tags(.availability))
    func sliderConstructsClusterWithCurrentValueLabel() {
        _ = CosmosSlider(value: .constant(0.5),
                         label: { Text(verbatim: "Slider") },
                         currentValueLabel: { Text(verbatim: "50%") })
    }

    // MARK: - CosmosStepper (T2; tvOS renders a CosmosButton fallback — public API uniform)

    @Test func stepperConstructsWithOnIncrementOnDecrement() {
        _ = CosmosStepper(label: { Text(verbatim: "Stepper") },
                          onIncrement: {}, onDecrement: {})
    }

    @Test func stepperConstructsFromLocalizedKeyWithOnIncrementOnDecrement() {
        _ = CosmosStepper("preview.title", onIncrement: {}, onDecrement: {})
    }

    @Test func stepperConstructsWithValueAndStep() {
        _ = CosmosStepper("preview.title", value: .constant(0), step: 1)
    }

    @Test func stepperConstructsWithValueAndBounds() {
        _ = CosmosStepper("preview.title", value: .constant(0), in: 0...10)
    }

    @Test func stepperConstructsFromVerbatimTitleWithValue() {
        _ = CosmosStepper(verbatim: "Count", value: .constant(0))
    }

    @Test func stepperConstructsWithCustomLabelAndValue() {
        _ = CosmosStepper(value: .constant(0), step: 2) { Text(verbatim: "Count") }
    }
}

// MARK: - Host-platform helpers

private var isTvOS: Bool {
    #if os(tvOS)
    return true
    #else
    return false
    #endif
}

private var isWatchOS: Bool {
    #if os(watchOS)
    return true
    #else
    return false
    #endif
}

// MARK: - Shared test fixture

private struct ListRow: Identifiable, Sendable {
    let id: Int
    let text: String
}