//
//  PatrolTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 13/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class PatrolTaskItemViewModel: TaskItemViewModel {
    open private(set) var patrol: CADPatrolType?
    
    public init(patrolNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        let captionText = "#\(patrolNumber)"
        super.init(taskItemIdentifier: patrolNumber, iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, subtitleText: captionText)

        self.navTitle = NSLocalizedString("Patrol details", comment: "")
        self.compactNavTitle = itemName

        self.viewModels = [
            PatrolOverviewViewModel()
        ]
    }
    
    public convenience init(patrol: CADPatrolType) {
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
    
    
    open override func loadTask() -> Promise<Void> {
        viewController?.setLoadingState(.loading)
        self.patrol = CADStateManager.shared.patrolsById[taskItemIdentifier]
        viewController?.setLoadingState(.loaded)
        reloadFromModel()
        return Promise<Void>()
    }
    
    override open func reloadFromModel() {
        if let patrol = patrol {
            viewModels.forEach {
                $0.reloadFromModel(patrol)
            }
        }
        super.reloadFromModel()
    }
    
    open override func refreshTask() -> Promise<Void> {
        // TODO: Add method to CADStateManager to fetch individual patrol
        return Promise<Void>()
    }
    
}
