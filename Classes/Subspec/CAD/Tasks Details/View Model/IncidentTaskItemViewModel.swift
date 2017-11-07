//
//  IncidentTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

class IncidentTaskItemViewModel: TaskItemViewModel {
    
    override func detailViewControllers() -> [UIViewController] {
        return [
            IncidentOverviewViewController(),
            IncidentAssociationsViewModel().createViewController(),
            IncidentNarrativeViewModel().createViewController(),
        ]
    }
}
