import Testing
import Foundation
import SwiftUI
@testable import Cosmos

@Suite("Theme")
struct CosmosThemeTests {

    @Test func defaults() {
        let theme = CosmosTheme.default
        #expect(theme.version == .cosmos26)
        #expect(theme.textStyle == .body)
        #expect(theme.padding == .medium)
        #expect(theme.buttonStyle == .primary)
        #expect(theme.controlSize == .medium)
    }

    @Test func fluentBuildersReturnMutatedCopies() {
        let base = CosmosTheme.default
        #expect(base.withTextStyle(.headline).textStyle == .headline)
        #expect(base.withPadding(.large).padding == .large)
        #expect(base.withButtonStyle(.glass).buttonStyle == .glass)
        #expect(base.withControlSize(.small).controlSize == .small)
        #expect(base.withVersion(.cosmos26).version == .cosmos26)

        let customFont = base.withCustomFont("DMSans-Regular")
        #expect(customFont.typography.customFontName == "DMSans-Regular")
        let systemAgain = customFont.withCustomFont(nil)
        #expect(systemAgain.typography.customFontName == nil)
    }

    @Test func fluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTextStyle(.headline)
        #expect(base.textStyle == .body)
    }

    @MainActor
    @Test func observableDefaultsAndMutation() {
        let observable = CosmosThemeObservable()
        // CosmosTheme holds non-Equatable Color tokens, so compare a representative field.
        #expect(observable.theme.textStyle == CosmosTheme.default.textStyle)
        #expect(observable.theme.version == CosmosTheme.default.version)
        observable.theme = .default.withTextStyle(.title)
        #expect(observable.theme.textStyle == .title)
    }

    // MARK: - Per-atom style selectors (defaults + fluent builders)
    //
    // Every atom whose customization surface is a `Cosmos*Style` selector exposes a theme default
    // and a `with*` fluent builder on `CosmosTheme`. These tests cover the selectors not already
    // exercised by `defaults` / `fluentBuildersReturnMutatedCopies` above (toggle/label/progress,
    // groupBox/menu/datePicker, textField/textEditor, picker/list/tabView). Consolidated here
    // (from the retired Wave A/C/D/E suites) because they test `CosmosTheme`, not an atom view.

    // MARK: Toggle / Label / Progress

    @Test func toggleLabelProgressThemeDefaults() {
        let theme = CosmosTheme.default
        #expect(theme.toggleStyle == .automatic)
        #expect(theme.labelStyle == .automatic)
        #expect(theme.progressStyle == .automatic)
    }

    @Test func toggleLabelProgressFluentBuildersReturnMutatedCopies() {
        let base = CosmosTheme.default
        #expect(base.withToggleStyle(.button).toggleStyle == .button)
        #expect(base.withLabelStyle(.cosmos).labelStyle == .cosmos)
        #expect(base.withProgressStyle(.linear).progressStyle == .linear)
    }

    @Test func toggleLabelProgressFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withToggleStyle(.button)
        _ = base.withLabelStyle(.iconOnly)
        _ = base.withProgressStyle(.cosmos)
        #expect(base.toggleStyle == .automatic)
        #expect(base.labelStyle == .automatic)
        #expect(base.progressStyle == .automatic)
    }

    // MARK: GroupBox / Menu / DatePicker

    @Test func groupBoxMenuDatePickerThemeDefaults() {
        let theme = CosmosTheme.default
        #expect(theme.groupBoxStyle == .automatic)
        #expect(theme.menuStyle == .automatic)
        #expect(theme.datePickerStyle == .automatic)
    }

    @Test func groupBoxMenuDatePickerFluentBuilders() {
        let base = CosmosTheme.default
        #expect(base.withGroupBoxStyle(.cosmos).groupBoxStyle == .cosmos)
        #expect(base.withMenuStyle(.button).menuStyle == .button)
        #expect(base.withDatePickerStyle(.graphical).datePickerStyle == .graphical)
    }

    @Test func groupBoxMenuDatePickerFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withGroupBoxStyle(.cosmos)
        _ = base.withMenuStyle(.button)
        _ = base.withDatePickerStyle(.wheel)
        #expect(base.groupBoxStyle == .automatic)
        #expect(base.menuStyle == .automatic)
        #expect(base.datePickerStyle == .automatic)
    }

    // MARK: TextField / TextEditor

    @Test func textFieldEditorThemeDefaults() {
        let theme = CosmosTheme.default
        #expect(theme.textFieldStyle == .automatic)
        #expect(theme.textEditorStyle == .automatic)
    }

    @Test func textFieldEditorFluentBuilders() {
        let base = CosmosTheme.default
        #expect(base.withTextFieldStyle(.cosmos).textFieldStyle == .cosmos)
        #expect(base.withTextFieldStyle(.bordered).textFieldStyle == .bordered)
        #expect(base.withTextEditorStyle(.roundedBorder).textEditorStyle == .roundedBorder)
    }

    @Test func textFieldEditorFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTextFieldStyle(.cosmos)
        _ = base.withTextEditorStyle(.plain)
        #expect(base.textFieldStyle == .automatic)
        #expect(base.textEditorStyle == .automatic)
    }

    // MARK: Picker

    @Test func pickerThemeDefaults() {
        let theme = CosmosTheme.default
        #expect(theme.pickerStyle == .automatic)
    }

    @Test func pickerFluentBuilders() {
        let base = CosmosTheme.default
        #expect(base.withPickerStyle(.menu).pickerStyle == .menu)
        #expect(base.withPickerStyle(.wheel).pickerStyle == .wheel)
        #expect(base.withPickerStyle(.radioGroup).pickerStyle == .radioGroup)
    }

    @Test func pickerFluentBuildersDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withPickerStyle(.segmented)
        #expect(base.pickerStyle == .automatic)
    }

    // MARK: List

    @Test func themeDefaultsForListSelector() {
        #expect(CosmosTheme.default.listStyle == .automatic)
    }

    @Test func themeFluentBuildersForList() {
        let base = CosmosTheme.default
        #expect(base.withListStyle(.grouped).listStyle == .grouped)
        #expect(base.withListStyle(.sidebar).listStyle == .sidebar)
        #expect(base.withListStyle(.bordered).listStyle == .bordered)
    }

    @Test func themeFluentBuildersForListDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withListStyle(.grouped)
        #expect(base.listStyle == .automatic)
    }

    // MARK: TabView

    @Test func themeDefaultsForTabViewSelector() {
        #expect(CosmosTheme.default.tabViewStyle == .automatic)
    }

    @Test func themeFluentBuildersForTabView() {
        let base = CosmosTheme.default
        #expect(base.withTabViewStyle(.page).tabViewStyle == .page)
        #expect(base.withTabViewStyle(.sidebarAdaptable).tabViewStyle == .sidebarAdaptable)
        #expect(base.withTabViewStyle(.grouped).tabViewStyle == .grouped)
    }

    @Test func themeFluentBuildersForTabViewDoNotMutateOriginal() {
        let base = CosmosTheme.default
        _ = base.withTabViewStyle(.page)
        #expect(base.tabViewStyle == .automatic)
    }
}