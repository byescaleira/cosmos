import SwiftUI
import Cosmos

/// Renders a `CosmosScreen` into a SwiftUI view tree.
///
/// The renderer recursively walks the component model, producing atoms and
/// containers. It reads `CosmosTheme` from the environment to resolve spacing,
/// colors, and selectors. Interactive components dispatch actions through the
/// injected `CosmosActionRegistry`.
public struct CosmosScreenRenderer: View {
    let screen: CosmosScreen
    let registry: CosmosActionRegistry

    @Environment(\.cosmosTheme) private var theme

    /// Creates a screen renderer.
    public init(screen: CosmosScreen, registry: CosmosActionRegistry) {
        self.screen = screen
        self.registry = registry
    }

    public var body: some View {
        AnyView(
            renderContainer(
                type: screen.layout.root,
                components: screen.components,
                spacing: screen.layout.spacing,
                alignment: screen.layout.alignment
            )
            .padding(theme.spacing.value(for: screen.layout.padding))
        )
    }

    @ViewBuilder
    private func renderContainer(
        type: CosmosContainerType,
        components: [CosmosComponent],
        spacing: CosmosPadding,
        alignment: CosmosStackAlignment
    ) -> some View {
        let spacingValue = theme.spacing.value(for: spacing)

        switch type {
        case .vStack:
            VStack(alignment: horizontalAlignment(for: alignment), spacing: spacingValue) {
                renderComponents(components)
            }
        case .hStack:
            HStack(alignment: verticalAlignment(for: alignment), spacing: spacingValue) {
                renderComponents(components)
            }
        case .zStack:
            ZStack(alignment: zStackAlignment(alignment)) {
                renderComponents(components)
            }
        }
    }

    private func renderComponents(_ components: [CosmosComponent]) -> some View {
        ForEach(Array(components.enumerated()), id: \.offset) { _, component in
            AnyView(renderComponent(component))
        }
    }

    private func renderComponent(_ component: CosmosComponent) -> AnyView {
        switch component {
        case .text(let model):
            AnyView(CosmosText(model.contentKey))
        case .button(let model):
            AnyView(
                CosmosButton(model.titleKey) {
                    if let action = model.action {
                        try registry.handle(action.id)
                    }
                }
            )
        case .icon(let model):
            AnyView(CosmosIcon(model.systemName))
        case .image(let model):
            AnyView(renderImage(model))
        case .label(let model):
            AnyView(CosmosLabel(model.titleKey, systemImage: model.systemImage))
        case .link(let model):
            AnyView(CosmosLink(model.titleKey, urlString: model.url))
        case .textField(let model):
            AnyView(CosmosTextField(text: .constant(""), prompt: model.promptKey, secure: model.secure))
        case .inputRow(let model):
            AnyView(RenderedCosmosInputRow(model: model, registry: registry))
        case .formRow(let model):
            AnyView(RenderedCosmosFormRow(model: model, registry: registry))
        case .toggle(let model):
            AnyView(CosmosToggle(isOn: .constant(false), model.titleKey, systemImage: model.systemImage))
        case .progress(let model):
            AnyView(CosmosProgress(value: model.value))
        case .slider(let model):
            AnyView(CosmosSlider(value: .constant(model.lowerBound), in: model.lowerBound...model.upperBound, step: model.step))
        case .picker(let model):
            AnyView(CosmosPicker(selection: .constant(model.selection), options: model.options))
        case .badge(let model):
            AnyView(
                model.text != nil
                    ? CosmosBadge(model.text!, variant: model.variant)
                    : CosmosBadge(dot: model.variant)
            )
        case .stepper(let model):
            AnyView(
                CosmosStepper(
                    value: .constant(model.lowerBound),
                    in: model.lowerBound...model.upperBound,
                    step: model.step,
                    model.label
                )
            )
        case .datePicker(let model):
            AnyView(
                CosmosDatePicker(
                    selection: .constant(Date()),
                    displayedComponents: datePickerComponents(model.displayedComponents),
                    model.label
                )
            )
        case .menu(let model):
            AnyView(
                renderMenu(model)
            )
        case .divider:
            AnyView(CosmosDivider())
        case .spacer(let model):
            AnyView(CosmosSpacer(minLength: model.minLength))
        case .list(let model):
            AnyView(renderList(model))
        case .section(let model):
            AnyView(renderSection(model))
        case .listRow(let model):
            AnyView(renderListRow(model))
        case .emptyState(let model):
            AnyView(renderEmptyState(model))
        case .buttonRow(let model):
            AnyView(renderButtonRow(model))
        case .searchBar(let model):
            AnyView(RenderedCosmosSearchBar(model: model, registry: registry))
        case .statusRow(let model):
            AnyView(renderStatusRow(model))
        case .card(let model):
            AnyView(renderCard(model))
        case .alertBanner(let model):
            AnyView(renderAlertBanner(model))
        case .loadingState(let model):
            AnyView(renderLoadingState(model))
        case .tabView(let model):
            AnyView(renderTabView(model))
        case .vStack(let model):
            AnyView(
                renderContainer(
                    type: .vStack,
                    components: model.components,
                    spacing: model.spacing,
                    alignment: model.alignment
                )
            )
        case .hStack(let model):
            AnyView(
                renderContainer(
                    type: .hStack,
                    components: model.components,
                    spacing: model.spacing,
                    alignment: model.alignment
                )
            )
        case .zStack(let model):
            AnyView(
                renderContainer(
                    type: .zStack,
                    components: model.components,
                    spacing: model.spacing,
                    alignment: model.alignment
                )
            )
        }
    }
}

// MARK: - Alignment mapping

private extension CosmosScreenRenderer {
    func horizontalAlignment(for alignment: CosmosStackAlignment) -> HorizontalAlignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    func verticalAlignment(for alignment: CosmosStackAlignment) -> VerticalAlignment {
        switch alignment {
        case .leading: .top
        case .center: .center
        case .trailing: .bottom
        }
    }

    func zStackAlignment(_ alignment: CosmosStackAlignment) -> Alignment {
        switch alignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
    }

    func renderImage(_ model: CosmosImageModel) -> some View {
        switch model.source {
        case .resource(let name, _):
            CosmosImage(resourceName: name)
        case .system(let name):
            CosmosImage(systemName: name)
        case .url(let string):
            CosmosImage(urlString: string)
        }
    }

    func datePickerComponents(_ components: CosmosDatePickerModel.DatePickerComponents) -> DatePicker.Components {
        switch components {
        case .date: .date
        case .hourAndMinute: .hourAndMinute
        case .dateAndTime: [.date, .hourAndMinute]
        }
    }

    func renderMenu(_ model: CosmosMenuModel) -> some View {
        CosmosMenu(model.titleKey) {
            ForEach(model.actions, id: \.id) { action in
                Button(action.id) {
                    try? registry.handle(action.id)
                }
            }
        }
    }

    func renderSection(_ model: CosmosSectionModel) -> some View {
        CosmosSection(
            header: { renderComponents(model.header ?? []) },
            footer: { renderComponents(model.footer ?? []) },
            content: { renderComponents(model.components) }
        )
    }

    func renderList(_ model: CosmosListModel) -> some View {
        CosmosList(
            selection: .constant(Set(model.selectedItemIDs ?? [])),
            style: model.style
        ) {
            if let sections = model.sections {
                ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                    renderSection(section)
                }
            } else if let components = model.components {
                renderComponents(components)
            }
        }
    }

    func renderTabView(_ model: CosmosTabViewModel) -> some View {
        RenderedCosmosTabView(model: model) { components in
            AnyView(renderComponents(components))
        }
    }

    func renderListRow(_ model: CosmosListRowModel) -> some View {
        let row = CosmosListRow(
            model.titleKey,
            subtitle: model.subtitleKey,
            systemImage: model.systemImage,
            trailing: model.trailing
        )

        if let action = model.action {
            return AnyView(
                CosmosButton(action: { try registry.handle(action.id) }) {
                    row
                }
                .buttonStyle(.plain)
            )
        }

        return AnyView(row)
    }

    func renderEmptyState(_ model: CosmosEmptyStateModel) -> some View {
        CosmosEmptyState(
            image: model.image.map(imageSource),
            title: model.titleKey,
            subtitle: model.subtitleKey,
            buttonTitle: model.buttonTitleKey,
            buttonAction: model.buttonAction.map { action in
                { try registry.handle(action.id) }
            }
        )
    }

    func imageSource(_ model: CosmosImageModel.Source) -> CosmosImage.Source {
        switch model {
        case .resource(let name, let bundle):
            return .resource(name: name, bundle: bundle.flatMap(Bundle.init(identifier:)))
        case .system(let name):
            return .system(name: name)
        case .url(let string):
            if let url = URL(string: string) {
                return .url(url)
            }
            return .urlString(string)
        }
    }

    func renderButtonRow(_ model: CosmosButtonRowModel) -> some View {
        CosmosButtonRow(
            model.titleKey,
            systemImage: model.systemImage,
            variant: model.variant
        ) {
            try registry.handle(model.action.id)
        }
    }

    func renderStatusRow(_ model: CosmosStatusRowModel) -> some View {
        CosmosStatusRow(
            image: model.image.map(imageSource),
            systemImage: model.systemImage,
            title: model.titleKey,
            subtitle: model.subtitleKey,
            badge: model.badge.map(renderBadge)
        )
    }

    func renderBadge(_ model: CosmosBadgeModel) -> CosmosBadge {
        if let text = model.text {
            return CosmosBadge(text, variant: model.variant)
        }
        return CosmosBadge(dot: model.variant)
    }

    func renderCard(_ model: CosmosCardModel) -> some View {
        CosmosCard(
            image: model.image.map(imageSource),
            title: model.titleKey,
            subtitle: model.subtitleKey,
            badge: model.badge.map(renderBadge),
            buttonTitle: model.buttonTitleKey,
            buttonAction: model.buttonAction.map { action in
                { try registry.handle(action.id) }
            }
        )
    }

    func renderAlertBanner(_ model: CosmosAlertBannerModel) -> some View {
        CosmosAlertBanner(
            systemImage: model.systemImage,
            title: model.titleKey,
            actionTitle: model.actionTitleKey,
            action: model.action.map { action in
                { try registry.handle(action.id) }
            },
            variant: model.variant
        )
    }

    func renderLoadingState(_ model: CosmosLoadingStateModel) -> some View {
        CosmosLoadingState(
            title: model.titleKey,
            subtitle: model.subtitleKey,
            progressValue: model.progressValue
        )
    }
}

// MARK: - Stateful wrappers for interactive components

private struct RenderedCosmosTabView: View {
    let model: CosmosTabViewModel
    let render: ([CosmosComponent]) -> AnyView

    @State private var selection: String?

    init(
        model: CosmosTabViewModel,
        render: @escaping ([CosmosComponent]) -> AnyView
    ) {
        self.model = model
        self.render = render
        _selection = State(initialValue: model.selectedTabID)
    }

    var body: some View {
        CosmosTabView(
            selection: $selection,
            tabs: model.tabs.map {
                CosmosTab(
                    id: $0.id,
                    titleKey: $0.titleKey,
                    systemImage: $0.systemImage,
                    role: $0.role
                )
            },
            strategy: model.strategy
        ) { tab in
            if let tabModel = model.tabs.first(where: { $0.id == tab.id }) {
                render(tabModel.components)
            }
        }
    }
}

private struct RenderedCosmosInputRow: View {
    let model: CosmosInputRowModel
    let registry: CosmosActionRegistry

    @State private var text: String

    init(model: CosmosInputRowModel, registry: CosmosActionRegistry) {
        self.model = model
        self.registry = registry
        _text = State(initialValue: model.initialText ?? "")
    }

    var body: some View {
        CosmosInputRow(
            text: $text,
            label: model.labelKey,
            prompt: model.promptKey,
            secure: model.secure
        )
        .onChange(of: text) { _, newValue in
            if let action = model.textChangeAction {
                try? registry.handle(action.id)
            }
        }
    }
}

private struct RenderedCosmosSearchBar: View {
    let model: CosmosSearchBarModel
    let registry: CosmosActionRegistry

    @State private var text: String

    init(model: CosmosSearchBarModel, registry: CosmosActionRegistry) {
        self.model = model
        self.registry = registry
        _text = State(initialValue: model.initialText ?? "")
    }

    var body: some View {
        CosmosSearchBar(
            text: $text,
            placeholder: model.placeholderKey ?? "search.placeholder",
            onClear: {
                if let action = model.clearAction {
                    try? registry.handle(action.id)
                }
            }
        )
        .onChange(of: text) { _, _ in
            if let action = model.textChangeAction {
                try? registry.handle(action.id)
            }
        }
    }
}

private struct RenderedCosmosFormRow: View {
    let model: CosmosFormRowModel
    let registry: CosmosActionRegistry

    @State private var boolValue: Bool
    @State private var stringValue: String
    @State private var doubleValue: Double

    init(model: CosmosFormRowModel, registry: CosmosActionRegistry) {
        self.model = model
        self.registry = registry

        switch model.initialValue {
        case .bool(let value):
            _boolValue = State(initialValue: value)
            _stringValue = State(initialValue: "")
            _doubleValue = State(initialValue: 0)
        case .string(let value):
            _boolValue = State(initialValue: false)
            _stringValue = State(initialValue: value)
            _doubleValue = State(initialValue: 0)
        case .double(let value):
            _boolValue = State(initialValue: false)
            _stringValue = State(initialValue: "")
            _doubleValue = State(initialValue: value)
        case .none:
            _boolValue = State(initialValue: false)
            _stringValue = State(initialValue: "")
            _doubleValue = State(initialValue: 0)
        }
    }

    var body: some View {
        CosmosFormRow(
            model.titleKey,
            systemImage: model.systemImage,
            control: control
        )
        .onChange(of: boolValue) { _, _ in dispatchChange() }
        .onChange(of: stringValue) { _, _ in dispatchChange() }
        .onChange(of: doubleValue) { _, _ in dispatchChange() }
    }

    private var control: CosmosFormRow.Control {
        switch model.control {
        case .toggle:
            return .toggle($boolValue)
        case .picker:
            return .picker($stringValue, [])
        case .stepper:
            return .stepper($doubleValue, 0...100, 1)
        case .slider:
            return .slider($doubleValue, 0...100, nil)
        case .value:
            return .value(stringValue)
        }
    }

    private func dispatchChange() {
        if let action = model.valueChangeAction {
            try? registry.handle(action.id)
        }
    }
}
