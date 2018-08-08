//
//  LocationSelectionFormAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Form item action for selecting a location
open class LocationSelectionFormAction: ValueSelectionAction<LocationSelection> {

    // MARK: - PUBLIC

    public init(viewModel: LocationSelectionMapViewModel, modalPresentationStyle: UIModalPresentationStyle = .formSheet) {
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

    override open func displayText() -> String? {
        return selectedValue?.addressString
    }

    /// Dismiss the presented view controller
    open func dismiss(viewController: UIViewController?) {
        if modalPresentationStyle == .none {
            viewController?.navigationController?.popViewController(animated: true)
        } else {
            viewController?.dismissAnimated()
        }
    }

    // MARK: - PRIVATE

    private let viewModel: LocationSelectionMapViewModel

    /// The required modal presentation style for view controller, use .none for push
    private var modalPresentationStyle: UIModalPresentationStyle

}
