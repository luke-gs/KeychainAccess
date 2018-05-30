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
            ValueFormItem(title: "Type",
                          value: viewModel.report.type)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnAddProperty()
            },

            ValueFormItem(title: "Sub Type",
                          value: viewModel.report.subtype)
                .accessory(ItemAccessory.dropDown)
                .width(.column(2))
                .onSelection { _ in
                    self.delegate.didTapOnAddProperty()
            },

            ValueFormItem(title: "Involvements",
                          value: viewModel.report.involvements?.joined(separator: ", "))
                .width(.column(1))
        ]
    }
}

public struct AddPropertyGeneralPluginPresenter: FormBuilderPluginPresenter {

}

// Media



// Details

