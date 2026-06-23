import Foundation
import CosmosBase

/// Content model for a text atom inside a screen.
public struct CosmosTextModel: Sendable, Codable, Equatable {
    public let contentKey: String

    public init(contentKey: String) {
        self.contentKey = contentKey
    }
}

/// Content model for a button atom inside a screen.
public struct CosmosButtonModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let action: CosmosAction?

    public init(titleKey: String, action: CosmosAction? = nil) {
        self.titleKey = titleKey
        self.action = action
    }
}

/// Content model for an icon atom inside a screen.
public struct CosmosIconModel: Sendable, Codable, Equatable {
    public let systemName: String

    public init(systemName: String) {
        self.systemName = systemName
    }
}

/// Content model for an image atom inside a screen.
public struct CosmosImageModel: Sendable, Codable, Equatable {
    public let source: Source

    public init(source: Source) {
        self.source = source
    }

    public enum Source: Sendable, Codable, Equatable {
        case resource(name: String, bundle: String?)
        case system(name: String)
        case url(String)
    }
}

/// Content model for a label atom inside a screen.
public struct CosmosLabelModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let systemImage: String?

    public init(titleKey: String, systemImage: String? = nil) {
        self.titleKey = titleKey
        self.systemImage = systemImage
    }
}

/// Content model for a spacer atom inside a screen.
public struct CosmosSpacerModel: Sendable, Codable, Equatable {
    public let minLength: CGFloat?

    public init(minLength: CGFloat? = nil) {
        self.minLength = minLength
    }
}

/// Content model for a link atom inside a screen.
public struct CosmosLinkModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let url: String

    public init(titleKey: String, url: String) {
        self.titleKey = titleKey
        self.url = url
    }
}

/// Content model for a text field atom inside a screen.
public struct CosmosTextFieldModel: Sendable, Codable, Equatable {
    public let promptKey: String?
    public let secure: Bool

    public init(promptKey: String? = nil, secure: Bool = false) {
        self.promptKey = promptKey
        self.secure = secure
    }
}

/// Content model for a labeled input row molecule inside a screen.
public struct CosmosInputRowModel: Sendable, Codable, Equatable {
    public let labelKey: String
    public let promptKey: String?
    public let secure: Bool
    public let initialText: String?
    public let textChangeAction: CosmosAction?

    public init(
        labelKey: String,
        promptKey: String? = nil,
        secure: Bool = false,
        initialText: String? = nil,
        textChangeAction: CosmosAction? = nil
    ) {
        self.labelKey = labelKey
        self.promptKey = promptKey
        self.secure = secure
        self.initialText = initialText
        self.textChangeAction = textChangeAction
    }
}

/// Content model for a toggle atom inside a screen.
public struct CosmosToggleModel: Sendable, Codable, Equatable {
    public let titleKey: String?
    public let systemImage: String?

    public init(titleKey: String? = nil, systemImage: String? = nil) {
        self.titleKey = titleKey
        self.systemImage = systemImage
    }
}

/// Content model for a progress atom inside a screen.
public struct CosmosProgressModel: Sendable, Codable, Equatable {
    public let value: Double?

    public init(value: Double? = nil) {
        self.value = value
    }
}

/// Content model for a slider atom inside a screen.
public struct CosmosSliderModel: Sendable, Codable, Equatable {
    public let lowerBound: Double
    public let upperBound: Double
    public let step: Double?

    public init(
        lowerBound: Double = 0,
        upperBound: Double = 1,
        step: Double? = nil
    ) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
    }
}

/// Content model for a picker atom inside a screen.
public struct CosmosPickerModel: Sendable, Codable, Equatable {
    public let selection: String
    public let options: [CosmosPicker.Option]

    public init(selection: String, options: [CosmosPicker.Option]) {
        self.selection = selection
        self.options = options
    }
}

/// Content model for a badge atom inside a screen.
public struct CosmosBadgeModel: Sendable, Codable, Equatable {
    public let text: String?
    public let variant: CosmosBadge.Variant

    public init(text: String?, variant: CosmosBadge.Variant = .primary) {
        self.text = text
        self.variant = variant
    }
}

/// Content model for a stepper atom inside a screen.
public struct CosmosStepperModel: Sendable, Codable, Equatable {
    public let lowerBound: Double
    public let upperBound: Double
    public let step: Double
    public let label: String?

    public init(
        lowerBound: Double = 0,
        upperBound: Double = 10,
        step: Double = 1,
        label: String? = nil
    ) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
        self.label = label
    }
}

/// Content model for a tab descriptor inside a screen.
public struct CosmosTabModel: Sendable, Codable, Equatable {
    public let id: String
    public let titleKey: String
    public let systemImage: String?
    public let role: CosmosTabRole
    public let components: [CosmosComponent]

    public init(
        id: String,
        titleKey: String,
        systemImage: String? = nil,
        role: CosmosTabRole = .default,
        components: [CosmosComponent] = []
    ) {
        self.id = id
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.role = role
        self.components = components
    }
}

/// Content model for a tab view atom inside a screen.
public struct CosmosTabViewModel: Sendable, Codable, Equatable {
    public let strategy: CosmosTabAdaptiveStrategy
    public let selectedTabID: String?
    public let tabs: [CosmosTabModel]

    public init(
        strategy: CosmosTabAdaptiveStrategy = .automatic,
        selectedTabID: String? = nil,
        tabs: [CosmosTabModel] = []
    ) {
        self.strategy = strategy
        self.selectedTabID = selectedTabID
        self.tabs = tabs
    }

    /// Explicit keys avoid the snake_case decoder converting `selectedTabID`
    /// to `selectedTabId`, which would break round-trips with the property.
    private enum CodingKeys: String, CodingKey {
        case strategy
        case selectedTabID = "selectedTabId"
        case tabs
    }
}

/// Content model for a date picker atom inside a screen.
public struct CosmosDatePickerModel: Sendable, Codable, Equatable {
    public let displayedComponents: DatePickerComponents
    public let label: String?

    public init(
        displayedComponents: DatePickerComponents = .dateAndTime,
        label: String? = nil
    ) {
        self.displayedComponents = displayedComponents
        self.label = label
    }

    /// Cross-platform description of `DatePicker.Components` so the model does
    /// not depend on SwiftUI symbols.
    public enum DatePickerComponents: String, Sendable, Codable, CaseIterable {
        case date
        case hourAndMinute
        case dateAndTime
    }
}

/// Content model for a menu atom inside a screen.
public struct CosmosMenuModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let actions: [CosmosAction]

    public init(titleKey: String, actions: [CosmosAction] = []) {
        self.titleKey = titleKey
        self.actions = actions
    }
}

/// Content model for a list container inside a screen.
public struct CosmosListModel: Sendable, Codable, Equatable {
    public let style: CosmosListStyle
    public let selectedItemIDs: [String]?
    public let sections: [CosmosSectionModel]?
    public let components: [CosmosComponent]?

    public init(
        style: CosmosListStyle = .automatic,
        selectedItemIDs: [String]? = nil,
        sections: [CosmosSectionModel]? = nil,
        components: [CosmosComponent]? = nil
    ) {
        self.style = style
        self.selectedItemIDs = selectedItemIDs
        self.sections = sections
        self.components = components
    }

    /// Explicit keys avoid the snake_case decoder converting `selectedItemIDs`
    /// to `selectedItemIds`, which would break round-trips with the property.
    private enum CodingKeys: String, CodingKey {
        case style
        case selectedItemIDs = "selectedItemIds"
        case sections
        case components
    }
}

/// Content model for a section container inside a screen.
public struct CosmosSectionModel: Sendable, Codable, Equatable {
    public let header: [CosmosComponent]?
    public let footer: [CosmosComponent]?
    public let components: [CosmosComponent]

    public init(
        header: [CosmosComponent]? = nil,
        footer: [CosmosComponent]? = nil,
        components: [CosmosComponent] = []
    ) {
        self.header = header
        self.footer = footer
        self.components = components
    }
}

/// Content model for an empty-state molecule inside a screen.
public struct CosmosEmptyStateModel: Sendable, Codable, Equatable {
    public let image: CosmosImageModel.Source?
    public let titleKey: String
    public let subtitleKey: String?
    public let buttonTitleKey: String?
    public let buttonAction: CosmosAction?

    public init(
        image: CosmosImageModel.Source? = nil,
        titleKey: String,
        subtitleKey: String? = nil,
        buttonTitleKey: String? = nil,
        buttonAction: CosmosAction? = nil
    ) {
        self.image = image
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.buttonTitleKey = buttonTitleKey
        self.buttonAction = buttonAction
    }
}

/// Content model for a full-width button row molecule inside a screen.
public struct CosmosButtonRowModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let systemImage: String?
    public let variant: CosmosButtonRow.Variant
    public let action: CosmosAction

    public init(
        titleKey: String,
        systemImage: String? = nil,
        variant: CosmosButtonRow.Variant = .primary,
        action: CosmosAction
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.variant = variant
        self.action = action
    }
}

/// Content model for a search bar molecule inside a screen.
public struct CosmosSearchBarModel: Sendable, Codable, Equatable {
    public let placeholderKey: String?
    public let initialText: String?
    public let textChangeAction: CosmosAction?
    public let clearAction: CosmosAction?

    public init(
        placeholderKey: String? = nil,
        initialText: String? = nil,
        textChangeAction: CosmosAction? = nil,
        clearAction: CosmosAction? = nil
    ) {
        self.placeholderKey = placeholderKey
        self.initialText = initialText
        self.textChangeAction = textChangeAction
        self.clearAction = clearAction
    }
}

/// Content model for a status row molecule inside a screen.
public struct CosmosStatusRowModel: Sendable, Codable, Equatable {
    public let image: CosmosImageModel.Source?
    public let systemImage: String?
    public let titleKey: String
    public let subtitleKey: String?
    public let badge: CosmosBadgeModel?

    public init(
        image: CosmosImageModel.Source? = nil,
        systemImage: String? = nil,
        titleKey: String,
        subtitleKey: String? = nil,
        badge: CosmosBadgeModel? = nil
    ) {
        self.image = image
        self.systemImage = systemImage
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.badge = badge
    }
}

/// Content model for a content card molecule inside a screen.
public struct CosmosCardModel: Sendable, Codable, Equatable {
    public let image: CosmosImageModel.Source?
    public let titleKey: String
    public let subtitleKey: String?
    public let badge: CosmosBadgeModel?
    public let buttonTitleKey: String?
    public let buttonAction: CosmosAction?

    public init(
        image: CosmosImageModel.Source? = nil,
        titleKey: String,
        subtitleKey: String? = nil,
        badge: CosmosBadgeModel? = nil,
        buttonTitleKey: String? = nil,
        buttonAction: CosmosAction? = nil
    ) {
        self.image = image
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.badge = badge
        self.buttonTitleKey = buttonTitleKey
        self.buttonAction = buttonAction
    }
}

/// Content model for an alert banner molecule inside a screen.
public struct CosmosAlertBannerModel: Sendable, Codable, Equatable {
    public let systemImage: String
    public let titleKey: String
    public let actionTitleKey: String?
    public let action: CosmosAction?
    public let variant: CosmosAlertBanner.Variant

    public init(
        systemImage: String,
        titleKey: String,
        actionTitleKey: String? = nil,
        action: CosmosAction? = nil,
        variant: CosmosAlertBanner.Variant = .info
    ) {
        self.systemImage = systemImage
        self.titleKey = titleKey
        self.actionTitleKey = actionTitleKey
        self.action = action
        self.variant = variant
    }
}

/// Content model for a loading-state molecule inside a screen.
public struct CosmosLoadingStateModel: Sendable, Codable, Equatable {
    public let titleKey: String?
    public let subtitleKey: String?
    public let progressValue: Double?

    public init(
        titleKey: String? = nil,
        subtitleKey: String? = nil,
        progressValue: Double? = nil
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.progressValue = progressValue
    }
}

/// Content model for a list row molecule inside a screen.
public struct CosmosListRowModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let subtitleKey: String?
    public let systemImage: String?
    public let trailing: CosmosListRow.Trailing
    public let action: CosmosAction?

    public init(
        titleKey: String,
        subtitleKey: String? = nil,
        systemImage: String? = nil,
        trailing: CosmosListRow.Trailing = .none,
        action: CosmosAction? = nil
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.systemImage = systemImage
        self.trailing = trailing
        self.action = action
    }
}

/// Content model for a form row molecule inside a screen.
public struct CosmosFormRowModel: Sendable, Codable, Equatable {
    public let titleKey: String
    public let systemImage: String?
    public let control: CosmosFormRow.ControlKind
    public let initialValue: FormRowValue?
    public let valueChangeAction: CosmosAction?

    public init(
        titleKey: String,
        systemImage: String? = nil,
        control: CosmosFormRow.ControlKind = .value,
        initialValue: FormRowValue? = nil,
        valueChangeAction: CosmosAction? = nil
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.control = control
        self.initialValue = initialValue
        self.valueChangeAction = valueChangeAction
    }

    /// A serializable initial value for a form row control.
    public enum FormRowValue: Sendable, Codable, Equatable {
        case bool(Bool)
        case string(String)
        case double(Double)

        private enum CodingKeys: String, CodingKey {
            case kind
            case value
        }

        private enum Kind: String, Sendable, Codable {
            case bool
            case string
            case double
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Kind.self, forKey: .kind)
            switch kind {
            case .bool:
                self = .bool(try container.decode(Bool.self, forKey: .value))
            case .string:
                self = .string(try container.decode(String.self, forKey: .value))
            case .double:
                self = .double(try container.decode(Double.self, forKey: .value))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .bool(let value):
                try container.encode(Kind.bool, forKey: .kind)
                try container.encode(value, forKey: .value)
            case .string(let value):
                try container.encode(Kind.string, forKey: .kind)
                try container.encode(value, forKey: .value)
            case .double(let value):
                try container.encode(Kind.double, forKey: .kind)
                try container.encode(value, forKey: .value)
            }
        }
    }
}

/// Content model for a stack container inside a screen.
public struct CosmosStackModel: Sendable, Codable, Equatable {
    public let components: [CosmosComponent]
    public let spacing: CosmosPadding
    public let alignment: CosmosStackAlignment

    public init(
        components: [CosmosComponent] = [],
        spacing: CosmosPadding = .medium,
        alignment: CosmosStackAlignment = .center
    ) {
        self.components = components
        self.spacing = spacing
        self.alignment = alignment
    }
}
