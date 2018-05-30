//
//  AddPropertyPlugins.swift
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

    init(viewModel: DefaultPropertyViewModel, delegate: DefaultPropertyViewControllerSelectionHandler) {
        decorator = AddPropertyGeneralPluginDecorator(viewModel: viewModel, delegate: delegate)
        presenter = AddPropertyGeneralPluginPresenter()
    }
}

public struct AddPropertyGeneralPluginDecorator: FormBuilderPluginDecorator {

    var viewModel: DefaultPropertyViewModel
    var delegate: DefaultPropertyViewControllerSelectionHandler

    init(viewModel: DefaultPropertyViewModel, delegate: DefaultPropertyViewControllerSelectionHandler) {
        self.viewModel = viewModel
        self.delegate = delegate
    }

    public func formItems() -> [FormItem] {
        return [

        ]
    }
}

public struct AddPropertyGeneralPluginPresenter: FormBuilderPluginPresenter {

}

// Media



// Details

