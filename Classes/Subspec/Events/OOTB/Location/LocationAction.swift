//
//  LocationAction.swift
//  MPOLKit
//
//  Created by Pavel Boryseiko on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit


class LocationAction<T: EventLocation>: ValueSelectionAction<[T]> {

    public var options: [T] = []

    var viewModel: LocationSelectionViewModel

    init(viewModel: LocationSelectionViewModel) {
        self.viewModel = viewModel
    }

    public override func viewController() -> UIViewController {
        let viewController = LocationMapSelectionViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet

        return navigationController
    }
}
