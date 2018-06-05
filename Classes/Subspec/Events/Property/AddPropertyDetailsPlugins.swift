//
//  AddPropertyDetailsPlugins.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//


// General section

public struct AddPropertyGeneralPlugin: FormBuilderPlugin {
    public var plugins: [FormBuilderPlugin]?
    public let decorator: FormBuilderPluginDecorator
    public init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyGeneralPluginDecorator(viewModel: viewModel, delegate: delegate)
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

    public init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        decorator = AddPropertyMediaPluginDecorator(viewModel: viewModel, context: context)
    }
}

public struct AddPropertyMediaPluginDecorator: FormBuilderPluginDecorator {

    let context: Weak<UIViewController>
    let viewModel: Weak<PropertyDetailsViewModel>

    public init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        self.viewModel = Weak(viewModel)
        self.context = Weak(context)
    }

    public func formItems() -> [FormItem] {
        guard let viewModel = viewModel.object else { return [] }
        guard let context = context.object else { return [] }

        let localStore = DataStoreCoordinator(dataStore: MediaStorageDatastore(items: viewModel.report.media, container: viewModel.report))
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
    public init(viewModel: PropertyDetailsViewModel) {
        decorator = AddPropertyDetailsPluginDecorator(viewModel: viewModel)
    }
}

public struct AddPropertyDetailsPluginDecorator: FormBuilderPluginDecorator {
    let viewModel: Weak<PropertyDetailsViewModel>

    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = Weak(viewModel)
    }

    public func formItems() -> [FormItem] {
        guard let viewModel = viewModel.object else { return [] }
        guard let details = viewModel.report.property?.detailNames else { return [] }
        return [LargeTextHeaderFormItem(text: "Property Details").separatorColor(.clear)] + details.compactMap{formItem(for: $0)}
    }

    private func formItem(for propertyDetail: PropertyDetail) -> FormItem? {
        guard let viewModel = viewModel.object else { return nil }

        switch propertyDetail.type {
        case let .picker(options):
            return DropDownFormItem(title: propertyDetail.title)
                .options(options)
                .width(.column(3))
                .selectedValue([viewModel.report.details[propertyDetail.title] ?? ""])
                .onValueChanged { [viewModel] value in
                    guard let value = value?.first else { return }
                    viewModel.report.details[propertyDetail.title] = value
            }
        case .text:
            return TextFieldFormItem(title: propertyDetail.title)
                .text(viewModel.report.details[propertyDetail.title])
                .width(.column(3))
                .onValueChanged { [viewModel] text in
                    viewModel.report.details[propertyDetail.title] = text
            }
        }
    }
}

