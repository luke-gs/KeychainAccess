//
//  PropertyDetailsViewController.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

public protocol AddPropertyDelegate {
    func didTapOnPropertyType()
}

public class PropertyDetailsViewController: FormBuilderViewController {

    let viewModel: PropertyDetailsViewModel

    required public init?(coder aDecoder: NSCoder) { MPLUnimplemented() }
    public init(viewModel: PropertyDetailsViewModel) {
        self.viewModel = viewModel
        super.init()
        title = "Add Property"
    }

    public override func construct(builder: FormBuilder) {
        builder.title = title
        viewModel.plugins?.forEach{builder += $0.decorator.formItems()}
    }
}

// MARK: SearchDisplayableDelegate

extension PropertyDetailsViewController: SearchDisplayableDelegate {
    public typealias Object = Property

    public func genericSearchViewController(_ viewController: UIViewController,
                                            didSelectRowAt indexPath: IndexPath,
                                            withObject object: Property) {
//        viewModel.updateDetails(with: object)
//        propertyDetailsDetailsViewController.plugins = [AddPropertyDetailsPlugin(viewModel: viewModel)]
//        propertyDetailsGeneralViewController.plugins = [AddPropertyGeneralPlugin(viewModel: viewModel, delegate: self)]
//        presenter.switchState()
    }
}
