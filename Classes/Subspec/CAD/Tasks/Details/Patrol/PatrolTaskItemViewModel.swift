//
//  PatrolTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class PatrolTaskItemViewModel: TaskItemViewModel {
    open private(set) var patrol: SyncDetailsPatrol?
    
    public init(patrolNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?, viewModels: [TaskDetailsViewModel]) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName)

        self.navTitle = NSLocalizedString("Patrol details", comment: "")
        self.compactNavTitle = itemName
        
        self.viewModels = [
            PatrolOverviewViewModel(patrolNumber: patrolNumber)
        ]
    }
    
    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }
    
    override open func reloadFromModel() {
        viewModels.forEach {
            $0.reloadFromModel()
        }
    }
}
