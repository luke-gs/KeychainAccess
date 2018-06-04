//
//  LocationAction.swift
//  MPOLKit
//
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class LocationAction<T: EventLocation>: ValueSelectionAction<T>, LocationSelectionViewModelDelegate {

    var viewModel: LocationSelectionViewModel

    init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        super.init()
        viewModel.delegate = self
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

    // LocationSelectionViewModelDelegate Method
    func didSelect(location: EventLocation?) {
        if let location = location as? T {
            self.selectedValue = location
            updateHandler?()
        }
    }
}
