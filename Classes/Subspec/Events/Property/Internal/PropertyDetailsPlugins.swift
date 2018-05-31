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

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyMediaPluginDecorator(viewModel: viewModel, delegate: delegate)
    }
}

internal struct AddPropertyMediaPluginDecorator: FormBuilderPluginDecorator {

    var viewModel: PropertyDetailsViewModel
    var delegate: AddPropertyDelegate

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    public func formItems() -> [FormItem] {
        return [
            HeaderFormItem(text: "Media", style: .plain)
        ]
    }
}

// Details

internal struct AddPropertyDetailsPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator

    init(property: Property, viewModel: PropertyDetailsViewModel) {
        decorator = AddPropertyDetailsPluginDecorator(property: property, viewModel: viewModel)
    }
}

internal struct AddPropertyDetailsPluginDecorator: FormBuilderPluginDecorator {
    var viewModel: PropertyDetailsViewModel
    var property: Property

    init(property: Property, viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
        self.property = property
    }

    public func formItems() -> [FormItem] {
        guard let details = property.detailNames else { return [] }
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

