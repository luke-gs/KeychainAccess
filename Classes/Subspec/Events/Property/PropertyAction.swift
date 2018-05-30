//
//  PropertyAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

class PropertyAction: ValueSelectionAction<String> {
    let delegate: DefaultPropertyViewControllerSelectionHandler
    let displayTextLol: String?
    let items: [String]?

    init(displayText: String?, items: [String]?, delegate: DefaultPropertyViewControllerSelectionHandler) {
        self.delegate = delegate
        self.displayTextLol = displayText
        self.items = items
        super.init()
    }

    public override func viewController() -> UIViewController {
        let viewModel = DefaultSearchDisplayableViewModel(items: items ?? [])
        let viewController = SearchDisplayableViewController<DefaultPropertyViewControllerSelectionHandler, DefaultSearchDisplayableViewModel>(viewModel: viewModel)
        viewController.delegate = delegate
        return viewController
    }

    override func displayText() -> String? {
        return displayTextLol
    }
}
