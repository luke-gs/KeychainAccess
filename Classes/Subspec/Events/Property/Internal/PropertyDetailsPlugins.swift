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

    var viewModel: PropertyDetailsViewModel
    var delegate: AddPropertyDelegate

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    public func formItems() -> [FormItem] {
        return [
            HeaderFormItem(text: "General", style: .plain),
            ValueFormItem(title: "Type",
                          value: viewModel.report.property?.type)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnPropertyType()
            },

            ValueFormItem(title: "Sub Type",
                          value: viewModel.report.property?.subType)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnPropertySubtype()
            },

            DropDownFormItem(title: "Involvements")
                .allowsMultipleSelection(true)
                .options(viewModel.involvements)
                .selectedValue(viewModel.report.involvements)
                .width(.column(1))
                .onValueChanged { value in
                    self.viewModel.report.involvements = value
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

    weak var context: UIViewController?
    var viewModel: PropertyDetailsViewModel

    init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        self.viewModel = viewModel
        self.context = context
    }

    public func formItems() -> [FormItem] {

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
        let header = HeaderFormItem(text: "Media").actionButton(title: "Manage", handler: { button in
            if let viewController = mediaItem.delegate?.viewControllerForGalleryViewModel(gallery) {
                self.context?.present(viewController, animated: true, completion: nil)
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
    var viewModel: PropertyDetailsViewModel

    init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
    }

    public func formItems() -> [FormItem] {
        guard let details = viewModel.report.property?.detailNames else { return [] }
        var formItems = [FormItem]()

        for detail in details {
            formItems.append(formItem(for: detail))
        }

        return [HeaderFormItem(text: "Details", style: .plain)] + formItems
    }

    private func formItem(for propertyDetail: PropertyDetail) -> FormItem {
        switch propertyDetail.type {
        case let .picker(options):
            return DropDownFormItem(title: propertyDetail.title)
                .options(options)
                .width(.column(3))
                .selectedValue([viewModel.report.details[propertyDetail.title] ?? ""])
                .onValueChanged { value in
                    guard let value = value?.first else { return }
                    self.viewModel.report.details[propertyDetail.title] = value
            }
        case .text:
            return TextFieldFormItem(title: propertyDetail.title)
                .text(self.viewModel.report.details[propertyDetail.title])
                .width(.column(3))
                .onValueChanged { text in
                    self.viewModel.report.details[propertyDetail.title] = text
            }
        }
    }
}

