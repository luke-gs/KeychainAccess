//
//  ResourceTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 11/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

public class ResourceTaskItemViewModel: TaskItemViewModel {
    
    override func detailViewControllers() -> [UIViewController] {
        return [
            ResourceOfficerListViewModel().createViewController(),
            ResourceActivityLogViewModel().createViewController(),
        ]
    }
}
