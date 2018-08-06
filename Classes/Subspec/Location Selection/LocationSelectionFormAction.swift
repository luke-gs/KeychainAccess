//
//  LocationSelectionFormAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Form item action for selecting a location
open class LocationSelectionFormAction: ValueSelectionAction<LocationSelection> {

    private var viewModel: LocationSelectionMapViewModel

    /// The required presentation style
    private var modalPresentationStyle: UIModalPresentationStyle

    init(viewModel: LocationSelectionMapViewModel, modalPresentationStyle: UIModalPresentationStyle = .formSheet) {
        self.viewModel = viewModel
        self.modalPresentationStyle = modalPresentationStyle
        super.init()
    }

    /// Create the view controller for selecting the location
    override open func viewController() -> UIViewController {
        let viewController = LocationSelectionMapViewController(viewModel: viewModel)
        viewController.selectionHandler = { [weak self, weak viewController] selectionViewModel in
            self?.selectedValue = self?.viewModel.location
            self?.dismiss(viewController: viewController)
            self?.updateHandler?()
            self?.dismissHandler?()
        }

        viewController.cancelHandler = { [weak self, weak viewController] in
            self?.dismiss(viewController: viewController)
            self?.dismissHandler?()
        }

        if modalPresentationStyle == .none {
            viewController.modalPresentationStyle = modalPresentationStyle
            return viewController
        }
        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = modalPresentationStyle
        return navigationController
    }

    /// Dismiss the presented view controller
    private func dismiss(viewController: UIViewController?) {
        if modalPresentationStyle == .none {
            viewController?.navigationController?.popViewController(animated: true)
        } else {
            viewController?.dismissAnimated()
        }
    }

    override open func displayText() -> String? {
        return selectedValue?.addressString
    }

}
