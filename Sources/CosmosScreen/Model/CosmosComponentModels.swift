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
