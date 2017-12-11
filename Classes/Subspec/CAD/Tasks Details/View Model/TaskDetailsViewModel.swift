//
//  TaskDetailsViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import Foundation

public protocol TaskDetailsViewModel {

    // Create view controller for the view model
    func createViewController() -> UIViewController

    // Reload the content of view model from data model
    func reloadFromModel()
}
