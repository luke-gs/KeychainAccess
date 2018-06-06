//
//  AddPropertyDetailsPlugins.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

/// Provide the form items for the form builder to render
public protocol FormBuilderPluginDecorator {
    func formItems() -> [FormItem]
}

/// Acts as a kind of viewModel for the formbuilder
public protocol FormBuilderPlugin {
    var plugins: [FormBuilderPlugin]? { get set }
    var decorator: FormBuilderPluginDecorator { get }
}

// General section

public struct AddPropertyGeneralPlugin: FormBuilderPlugin, AddPropertyDelegate, SearchDisplayableDelegate {
    let viewModel: Weak<PropertyDetailsViewModel>
    let context: Weak<UIViewController>

    public var plugins: [FormBuilderPlugin]?
    public var decorator: FormBuilderPluginDecorator {
        return AddPropertyGeneralPluginDecorator(viewModel: viewModel.object!, delegate: self)
    }

    public init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        self.viewModel = Weak(viewModel)
        self.context = Weak(context)
    }

    // MARK: Presenting Delegates

    public func didTapOnPropertyType() {
        guard let viewModel = self.viewModel.object else { return }
        guard let context = self.context.object else { return }

        let displayableViewModel = PropertySearchDisplayableViewModel(properties: viewModel.properties)
        let viewController = SearchDisplayableViewController<AddPropertyGeneralPlugin, PropertySearchDisplayableViewModel>(viewModel: displayableViewModel)
        viewController.wantsTransparentBackground = false
        viewController.delegate = self
        context.show(viewController, sender: self)
    }

    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Property) {
        guard let viewModel = self.viewModel.object else { return }
        guard let context = self.context.object else { return }
        viewModel.updateDetails(with: object)
        context.navigationController?.popViewController(animated: true)
    }
}

public struct AddPropertyGeneralPluginDecorator: FormBuilderPluginDecorator {
    let viewModel: Weak<PropertyDetailsViewModel>
    let delegate: AddPropertyDelegate

    public init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        self.viewModel = Weak(viewModel)
        self.delegate = delegate
    }

    public func formItems() -> [FormItem] {
        guard let viewModel = viewModel.object else { return [] }

        return [
            LargeTextHeaderFormItem(text: "General").separatorColor(.clear),
            ValueFormItem(title: "Type",
                          value: viewModel.report.property?.type)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { [delegate] _ in
                    delegate.didTapOnPropertyType()
            },

            ValueFormItem(title: "Sub Type",
                          value: viewModel.report.property?.subType)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { [delegate] _ in
                    delegate.didTapOnPropertyType()
            },

            DropDownFormItem(title: "Involvements")
                .allowsMultipleSelection(true)
                .options(viewModel.involvements)
                .selectedValue(viewModel.report.involvements)
                .width(.column(1))
                .onValueChanged { [viewModel] value in
                    viewModel.report.involvements = value
            }
        ]
    }
}

// Media Section

public struct AddPropertyMediaPlugin: FormBuilderPlugin {
    public var plugins: [FormBuilderPlugin]?
    public let decorator: FormBuilderPluginDecorator

    public init(report: PropertyDetailsReport, context: UIViewController) {
        decorator = AddPropertyMediaPluginDecorator(report: report, context: context)
    }
}

public struct AddPropertyMediaPluginDecorator: FormBuilderPluginDecorator {

    let context: Weak<UIViewController>
    let report: Weak<PropertyDetailsReport>

    public init(report: PropertyDetailsReport, context: UIViewController) {
        self.report = Weak(report)
        self.context = Weak(context)
    }

    public func formItems() -> [FormItem] {
        guard let report = report.object else { return [] }
        guard let context = context.object else { return [] }

        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: report.media, container: report))
        let gallery = MediaGalleryCoordinatorViewModel(storeCoordinator: localStore)

        let mediaItem = MediaFormItem()
            .dataSource(gallery)
            .emptyStateContents(EmptyStateContents(
                title: "No Media",
                subtitle: "Edit media by tapping on 'Edit' button."))

        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            mediaItem.previewingController(viewController)
        }

        let header = LargeTextHeaderFormItem(text: "Media")
            .separatorColor(.clear)
            .actionButton(title: "Manage", handler: { [mediaItem, context] button in
                if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                    context.present(viewController, animated: true, completion: nil)
                }
            })

        return [
            header,
            mediaItem
        ]
    }
}

// Details Section

public struct AddPropertyDetailsPlugin: FormBuilderPlugin {
    public var plugins: [FormBuilderPlugin]?
    public let decorator: FormBuilderPluginDecorator
    public init(report: PropertyDetailsReport) {
        decorator = AddPropertyDetailsPluginDecorator(report: report)
    }
}

public struct AddPropertyDetailsPluginDecorator: FormBuilderPluginDecorator {
    let report: Weak<PropertyDetailsReport>

    public init(report: PropertyDetailsReport) {
        self.report = Weak(report)
    }

    public func formItems() -> [FormItem] {
        guard let report = report.object else { return [] }
        guard let details = report.property?.detailNames else { return [] }
        return [LargeTextHeaderFormItem(text: "Property Details").separatorColor(.clear)] + details.compactMap{formItem(for: $0)}
    }

    // MARK: Private

    private func formItem(for propertyDetail: PropertyDetail) -> FormItem? {
        guard let report = report.object else { return nil }

        switch propertyDetail.type {
        case let .picker(options):
            return DropDownFormItem(title: propertyDetail.title)
                .options(options)
                .width(.column(3))
                .selectedValue([report.details[propertyDetail.title] ?? ""])
                .onValueChanged { [report] value in
                    guard let value = value?.first else { return }
                    report.details[propertyDetail.title] = value
            }
        case .text:
            return TextFieldFormItem(title: propertyDetail.title)
                .text(report.details[propertyDetail.title])
                .width(.column(3))
                .onValueChanged { [report] text in
                    report.details[propertyDetail.title] = text
            }
        }
    }
}

