
//
//  AddPropertyPlugin.swift
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

// Total Section

public class AddPropertyPlugin: FormBuilderPlugin, AddPropertyDelegate, SearchDisplayableDelegate {
    public typealias Object = Property

    public var plugins: [FormBuilderPlugin]?
    public var decorator: FormBuilderPluginDecorator {
        return AddPropertyPluginDecorator(decorators: plugins?.compactMap{$0.decorator})
    }

    let viewModel: Weak<PropertyDetailsViewModel>
    let context: Weak<UIViewController>

    public init(viewModel: PropertyDetailsViewModel, context: UIViewController) {
        self.viewModel = Weak(viewModel)
        self.context = Weak(context)

        self.plugins = [
            AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self),
            AddPropertyMediaPlugin(viewModel: viewModel, context: context),
            AddPropertyDetailsPlugin(viewModel: viewModel)
        ]
    }

    // MARK: Presenter

    public func didTapOnPropertyType() {
        guard let viewModel = self.viewModel.object else { return }
        guard let context = self.context.object else { return }

        let displayableViewModel = PropertySearchDisplayableViewModel(properties: viewModel.properties)
        let viewController = SearchDisplayableViewController<AddPropertyPlugin, PropertySearchDisplayableViewModel>(viewModel: displayableViewModel)
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

public struct AddPropertyPluginDecorator: FormBuilderPluginDecorator {
    let decorators: [FormBuilderPluginDecorator]?

    public init(decorators: [FormBuilderPluginDecorator]?) {
        self.decorators = decorators
    }

    public func formItems() -> [FormItem] {
        return decorators?.flatMap{$0.formItems()} ?? []
    }
}
