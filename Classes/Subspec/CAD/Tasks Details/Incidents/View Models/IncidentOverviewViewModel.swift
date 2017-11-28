//
//  IncidentOverviewViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 29/11/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class IncidentOverviewViewModel: TaskDetailsViewModel {
    func createViewController() -> UIViewController {
        return IncidentOverviewViewController()
    }
}
