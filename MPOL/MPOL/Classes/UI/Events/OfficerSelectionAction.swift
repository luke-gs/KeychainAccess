//
//  OfficerSelectionAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PublicSafetyKit
import DemoAppKit

class OfficerSelectionAction: ValueSelectionAction<Officer> {

    let viewModel: OfficerSearchViewModel
    private let preferredSize: CGSize

    init(viewModel: OfficerSearchViewModel, preferredSize: CGSize) {
        self.viewModel = viewModel
        self.preferredSize = preferredSize
    }

    public override func viewController() -> UIViewController {

        let officerSearchController = OfficerSearchViewController<OfficerSelectionAction>(viewModel: viewModel)
        officerSearchController.delegate = self
        officerSearchController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: officerSearchController,
            action: #selector(UIViewController.dismissAnimated))

        let navigationController = ModalNavigationController(rootViewController: officerSearchController)
        navigationController.modalPresentationStyle = .formSheet
        navigationController.preferredContentSize = preferredSize
        return navigationController
    }

    override func displayText() -> StringSizable? {
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
