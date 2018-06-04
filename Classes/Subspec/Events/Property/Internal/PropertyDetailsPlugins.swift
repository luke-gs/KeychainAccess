//
//  PropertyDetailsPlugins.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

internal protocol FormBuilderPluginDecorator {
    func formItems() -> [FormItem]
}

internal protocol FormBuilderPlugin {
    var decorator: FormBuilderPluginDecorator { get }
}

// General

internal struct AddPropertyGeneralPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyGeneralPluginDecorator(viewModel: viewModel, delegate: delegate)
    }
}

internal struct AddPropertyGeneralPluginDecorator: FormBuilderPluginDecorator {

    let viewModel: Weak<PropertyDetailsViewModel>
    let delegate: AddPropertyDelegate

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
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
                    delegate.didTapOnPropertySubtype()
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

// Media

internal struct AddPropertyMediaPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator

    init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        decorator = AddPropertyMediaPluginDecorator(viewModel: viewModel, context: context)
    }
}

internal struct AddPropertyMediaPluginDecorator: FormBuilderPluginDecorator {

    let context: Weak<UIViewController>
    let viewModel: Weak<PropertyDetailsViewModel>

    init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
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
            .actionButton(title: "Manage", handler: { [context] button in
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

// Details

internal struct AddPropertyDetailsPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator

    init(viewModel: PropertyDetailsViewModel) {
        decorator = AddPropertyDetailsPluginDecorator(viewModel: viewModel)
    }
}

internal struct AddPropertyDetailsPluginDecorator: FormBuilderPluginDecorator {
    let viewModel: Weak<PropertyDetailsViewModel>

    init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = Weak(viewModel)
    }

    public func formItems() -> [FormItem] {
        guard let viewModel = viewModel.object else { return [] }
        guard let details = viewModel.report.property?.detailNames else { return [] }
        var formItems = [FormItem]()

        for detail in details {
            formItems.append(formItem(for: detail)!)
        }

        return [LargeTextHeaderFormItem(text: "Property Details").separatorColor(.clear)] + formItems
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

