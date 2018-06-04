//
//  OfficerSelectionAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit
import ClientKit

class OfficerSelectionAction: ValueSelectionAction<Officer> {
    let viewModel: OfficerSearchViewModel
    init(viewModel: OfficerSearchViewModel) {
        self.viewModel = viewModel
    }

    public override func viewController() -> UIViewController {
        let officerSearchController = SearchDisplayableViewController<OfficerSelectionAction, OfficerSearchViewModel>(viewModel: viewModel)
        officerSearchController.delegate = self
        let navigationController = PopoverNavigationController(rootViewController: officerSearchController)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }

    override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }
        return OfficerSearchDisplayable(selectedValue).title
    }
}

extension OfficerSelectionAction: SearchDisplayableDelegate {
    public func genericSearchViewController(_ viewController: UIViewController, didSelectRowAt indexPath: IndexPath, withObject object: Officer) {
        self.selectedValue = object
        self.updateHandler?()
        viewController.dismiss(animated: true, completion: nil)
    }
}
