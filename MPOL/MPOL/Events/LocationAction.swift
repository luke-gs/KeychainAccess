//
//  LocationAction.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import MPOLKit

class LocationAction<T: EventLocation>: ValueSelectionAction<T> {
    var viewModel: LocationSelectionViewModel

    init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
        super.init()
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
}
