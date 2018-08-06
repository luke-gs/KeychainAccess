//
//  LocationAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class LocationAction<T: EventLocation>: ValueSelectionAction<T>, LocationSelectionMapViewModelDelegate {
    var viewModel: EventLocationSelectionMapViewModel

    init(viewModel: EventLocationSelectionMapViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.delegate = self
        viewModel.savedLocation = viewModel.eventLocation
    }

    public override func viewController() -> UIViewController {
        let viewController = EventLocationSearchViewController(viewModel: EventLocationSearchViewModel(recentLocations: []), selectionViewModel: viewModel)
        let navigationController = PopoverNavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }

    override func displayText() -> String? {
        guard let selectedValue = selectedValue else { return nil }
        return selectedValue.addressString
    }

    // MARK: - LocationSelectionMapViewModelDelegate
    func didCompleteWithLocation(_ location: LocationSelection?) {
        if let location = location as? T {
            self.selectedValue = location
            updateHandler?()
        }
    }

}
