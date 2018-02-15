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
    
    public init(patrolNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName)

        self.navTitle = NSLocalizedString("Patrol details", comment: "")
        self.compactNavTitle = itemName
        
        self.viewModels = [
            PatrolOverviewViewModel(identifier: patrolNumber)
        ]
    }
    
    public convenience init(patrol: SyncDetailsPatrol) {
        self.init(patrolNumber: patrol.identifier,
                  iconImage: AssetManager.shared.image(forKey: .tabBarTasks),
                  iconTintColor: .disabledGray,
                  color: .primaryGray,
                  statusText: NSLocalizedString("Patrol", comment: "").uppercased(),
                  itemName: patrol.type)
        self.patrol = patrol
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
