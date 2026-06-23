import Foundation

/// A serializable description of any Cosmos component or layout container.
///
/// `CosmosComponent` is the core value type of the data-driven renderer. It can
/// represent leaf atoms (text, button, icon, divider) or layout containers
/// (vStack, hStack, zStack, spacer). The `CosmosScreenRenderer` turns it into
/// a SwiftUI view tree at runtime.
///
/// JSON encoding uses a keyed envelope per case:
///
/// ```json
/// { "text": { "content_key": "hello" } }
/// { "button": { "title_key": "Save", "action": { "id": "save" } } }
/// { "spacer": {} }
/// ```
public enum CosmosComponent: Sendable, Codable, Equatable {
    case text(CosmosTextModel)
    case button(CosmosButtonModel)
    case icon(CosmosIconModel)
    case image(CosmosImageModel)
    case label(CosmosLabelModel)
    case link(CosmosLinkModel)
    case textField(CosmosTextFieldModel)
    case inputRow(CosmosInputRowModel)
    case formRow(CosmosFormRowModel)
    case toggle(CosmosToggleModel)
    case progress(CosmosProgressModel)
    case slider(CosmosSliderModel)
    case picker(CosmosPickerModel)
    case badge(CosmosBadgeModel)
    case stepper(CosmosStepperModel)
    case datePicker(CosmosDatePickerModel)
    case menu(CosmosMenuModel)
    case divider
    case spacer(CosmosSpacerModel)
    case list(CosmosListModel)
    case section(CosmosSectionModel)
    case listRow(CosmosListRowModel)
    case emptyState(CosmosEmptyStateModel)
    case buttonRow(CosmosButtonRowModel)
    case searchBar(CosmosSearchBarModel)
    case statusRow(CosmosStatusRowModel)
    case card(CosmosCardModel)
    case alertBanner(CosmosAlertBannerModel)
    case loadingState(CosmosLoadingStateModel)
    case tabView(CosmosTabViewModel)

    case vStack(CosmosStackModel)
    case hStack(CosmosStackModel)
    case zStack(CosmosStackModel)

    private enum CodingKeys: String, CodingKey {
        case text
        case button
        case icon
        case image
        case label
        case link
        case textField
        case inputRow
        case formRow
        case toggle
        case progress
        case slider
        case picker
        case badge
        case stepper
        case datePicker
        case menu
        case divider
        case spacer
        case list
        case section
        case listRow
        case emptyState
        case buttonRow
        case searchBar
        case statusRow
        case card
        case alertBanner
        case loadingState
        case tabView
        case vStack
        case hStack
        case zStack
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(CosmosTextModel.self, forKey: .text) {
            self = .text(value)
        } else if let value = try container.decodeIfPresent(CosmosButtonModel.self, forKey: .button) {
            self = .button(value)
        } else if let value = try container.decodeIfPresent(CosmosIconModel.self, forKey: .icon) {
            self = .icon(value)
        } else if let value = try container.decodeIfPresent(CosmosImageModel.self, forKey: .image) {
            self = .image(value)
        } else if let value = try container.decodeIfPresent(CosmosLabelModel.self, forKey: .label) {
            self = .label(value)
        } else if let value = try container.decodeIfPresent(CosmosLinkModel.self, forKey: .link) {
            self = .link(value)
        } else if let value = try container.decodeIfPresent(CosmosTextFieldModel.self, forKey: .textField) {
            self = .textField(value)
        } else if let value = try container.decodeIfPresent(CosmosInputRowModel.self, forKey: .inputRow) {
            self = .inputRow(value)
        } else if let value = try container.decodeIfPresent(CosmosFormRowModel.self, forKey: .formRow) {
            self = .formRow(value)
        } else if let value = try container.decodeIfPresent(CosmosToggleModel.self, forKey: .toggle) {
            self = .toggle(value)
        } else if let value = try container.decodeIfPresent(CosmosProgressModel.self, forKey: .progress) {
            self = .progress(value)
        } else if let value = try container.decodeIfPresent(CosmosSliderModel.self, forKey: .slider) {
            self = .slider(value)
        } else if let value = try container.decodeIfPresent(CosmosPickerModel.self, forKey: .picker) {
            self = .picker(value)
        } else if let value = try container.decodeIfPresent(CosmosBadgeModel.self, forKey: .badge) {
            self = .badge(value)
        } else if let value = try container.decodeIfPresent(CosmosStepperModel.self, forKey: .stepper) {
            self = .stepper(value)
        } else if let value = try container.decodeIfPresent(CosmosDatePickerModel.self, forKey: .datePicker) {
            self = .datePicker(value)
        } else if let value = try container.decodeIfPresent(CosmosMenuModel.self, forKey: .menu) {
            self = .menu(value)
        } else if let value = try container.decodeIfPresent(CosmosStackModel.self, forKey: .vStack) {
            self = .vStack(value)
        } else if let value = try container.decodeIfPresent(CosmosStackModel.self, forKey: .hStack) {
            self = .hStack(value)
        } else if let value = try container.decodeIfPresent(CosmosStackModel.self, forKey: .zStack) {
            self = .zStack(value)
        } else if let value = try container.decodeIfPresent(CosmosSpacerModel.self, forKey: .spacer) {
            self = .spacer(value)
        } else if let value = try container.decodeIfPresent(CosmosListModel.self, forKey: .list) {
            self = .list(value)
        } else if let value = try container.decodeIfPresent(CosmosSectionModel.self, forKey: .section) {
            self = .section(value)
        } else if let value = try container.decodeIfPresent(CosmosListRowModel.self, forKey: .listRow) {
            self = .listRow(value)
        } else if let value = try container.decodeIfPresent(CosmosEmptyStateModel.self, forKey: .emptyState) {
            self = .emptyState(value)
        } else if let value = try container.decodeIfPresent(CosmosButtonRowModel.self, forKey: .buttonRow) {
            self = .buttonRow(value)
        } else if let value = try container.decodeIfPresent(CosmosSearchBarModel.self, forKey: .searchBar) {
            self = .searchBar(value)
        } else if let value = try container.decodeIfPresent(CosmosStatusRowModel.self, forKey: .statusRow) {
            self = .statusRow(value)
        } else if let value = try container.decodeIfPresent(CosmosCardModel.self, forKey: .card) {
            self = .card(value)
        } else if let value = try container.decodeIfPresent(CosmosAlertBannerModel.self, forKey: .alertBanner) {
            self = .alertBanner(value)
        } else if let value = try container.decodeIfPresent(CosmosLoadingStateModel.self, forKey: .loadingState) {
            self = .loadingState(value)
        } else if let value = try container.decodeIfPresent(CosmosTabViewModel.self, forKey: .tabView) {
            self = .tabView(value)
        } else if container.contains(.divider) {
            self = .divider
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: CodingKeys.text,
                in: container,
                debugDescription: "No known CosmosComponent case found in JSON."
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text(let value):
            try container.encode(value, forKey: .text)
        case .button(let value):
            try container.encode(value, forKey: .button)
        case .icon(let value):
            try container.encode(value, forKey: .icon)
        case .image(let value):
            try container.encode(value, forKey: .image)
        case .label(let value):
            try container.encode(value, forKey: .label)
        case .link(let value):
            try container.encode(value, forKey: .link)
        case .textField(let value):
            try container.encode(value, forKey: .textField)
        case .inputRow(let value):
            try container.encode(value, forKey: .inputRow)
        case .formRow(let value):
            try container.encode(value, forKey: .formRow)
        case .toggle(let value):
            try container.encode(value, forKey: .toggle)
        case .progress(let value):
            try container.encode(value, forKey: .progress)
        case .slider(let value):
            try container.encode(value, forKey: .slider)
        case .picker(let value):
            try container.encode(value, forKey: .picker)
        case .badge(let value):
            try container.encode(value, forKey: .badge)
        case .stepper(let value):
            try container.encode(value, forKey: .stepper)
        case .datePicker(let value):
            try container.encode(value, forKey: .datePicker)
        case .menu(let value):
            try container.encode(value, forKey: .menu)
        case .divider:
            try container.encodeNil(forKey: .divider)
        case .spacer(let value):
            try container.encode(value, forKey: .spacer)
        case .list(let value):
            try container.encode(value, forKey: .list)
        case .section(let value):
            try container.encode(value, forKey: .section)
        case .listRow(let value):
            try container.encode(value, forKey: .listRow)
        case .emptyState(let value):
            try container.encode(value, forKey: .emptyState)
        case .buttonRow(let value):
            try container.encode(value, forKey: .buttonRow)
        case .searchBar(let value):
            try container.encode(value, forKey: .searchBar)
        case .statusRow(let value):
            try container.encode(value, forKey: .statusRow)
        case .card(let value):
            try container.encode(value, forKey: .card)
        case .alertBanner(let value):
            try container.encode(value, forKey: .alertBanner)
        case .loadingState(let value):
            try container.encode(value, forKey: .loadingState)
        case .tabView(let value):
            try container.encode(value, forKey: .tabView)
        case .vStack(let value):
            try container.encode(value, forKey: .vStack)
        case .hStack(let value):
            try container.encode(value, forKey: .hStack)
        case .zStack(let value):
            try container.encode(value, forKey: .zStack)
        }
    }
}
