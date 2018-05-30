//
//  PropertyDetailsPlugins.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

public protocol FormBuilderPluginDecorator {
    func formItems() -> [FormItem]
}

public protocol FormBuilderPluginPresenter {

}

public protocol FormBuilderPlugin {
    var decorator: FormBuilderPluginDecorator { get }
    var presenter: FormBuilderPluginPresenter { get }
}

// General

public struct AddPropertyGeneralPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator
    public var presenter: FormBuilderPluginPresenter

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyGeneralPluginDecorator(viewModel: viewModel, delegate: delegate)
        presenter = AddPropertyGeneralPluginPresenter()
    }
}

public struct AddPropertyGeneralPluginDecorator: FormBuilderPluginDecorator {

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
                          value: viewModel.report.type)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnPropertyType()
            },

            ValueFormItem(title: "Sub Type",
                          value: viewModel.report.subtype)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnPropertySubtype()
            },

            DropDownFormItem(title: "Involvements")
                .allowsMultipleSelection(true)
                .options(viewModel.involvements())
                .selectedValue(viewModel.report.involvements)
                .width(.column(1))
                .onValueChanged { value in
                    self.viewModel.report.involvements = value
                }
        ]
    }
}

public struct AddPropertyGeneralPluginPresenter: FormBuilderPluginPresenter {

}

// Media

public struct AddPropertyMediaPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator
    public var presenter: FormBuilderPluginPresenter

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyMediaPluginDecorator(viewModel: viewModel, delegate: delegate)
        presenter = AddPropertyMediaPluginPresenter()
    }
}


public struct AddPropertyMediaPluginDecorator: FormBuilderPluginDecorator {

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

public struct AddPropertyMediaPluginPresenter: FormBuilderPluginPresenter {

}


// Details

public struct AddPropertyDetailsPlugin: FormBuilderPlugin {
    public var decorator: FormBuilderPluginDecorator
    public var presenter: FormBuilderPluginPresenter

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        decorator = AddPropertyDetailsPluginDecorator(viewModel: viewModel, delegate: delegate)
        presenter = AddPropertyDetailPluginPresenter()
    }
}


public struct AddPropertyDetailsPluginDecorator: FormBuilderPluginDecorator {

    var viewModel: PropertyDetailsViewModel
    var delegate: AddPropertyDelegate

    init(viewModel: PropertyDetailsViewModel, delegate: AddPropertyDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    public func formItems() -> [FormItem] {
        return [
            HeaderFormItem(text: "Details", style: .plain)

        ]
    }
}

public struct AddPropertyDetailPluginPresenter: FormBuilderPluginPresenter {

}
