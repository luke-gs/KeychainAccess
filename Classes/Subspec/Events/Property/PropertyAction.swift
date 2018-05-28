//
//  PropertyAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

class PropertyAction: ValueSelectionAction<String> {
    var viewModel: DefaultPropertyViewModel
    var delegate: DefaultPropertyViewControllerSelectionHandler

    init(viewModel: DefaultPropertyViewModel, delegate: DefaultPropertyViewControllerSelectionHandler) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init()
    }

    public override func viewController() -> UIViewController {
        let viewModel = DefaultSearchDisplayableViewModel(items: self.viewModel.types())
        let viewController = SearchDisplayableViewController<DefaultPropertyViewControllerSelectionHandler, DefaultSearchDisplayableViewModel>(viewModel: viewModel)
        viewController.delegate = delegate
        return viewController
    }

    override func displayText() -> String? {
        return viewModel.report.type
    }
}
