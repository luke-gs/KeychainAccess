//
//  BroadcastTaskItemViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 14/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

open class BroadcastTaskItemViewModel: TaskItemViewModel {
    open private(set) var broadcast: CADBroadcastType?
    
    public init(broadcastNumber: String, iconImage: UIImage?, iconTintColor: UIColor?, color: UIColor?, statusText: String?, itemName: String?) {
        let captionText = "#\(broadcastNumber)"
        super.init(taskItemIdentifier: broadcastNumber, iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, subtitleText: captionText)
        
        self.navTitle = NSLocalizedString("Broadcast details", comment: "")
        self.compactNavTitle = itemName
        
        self.viewModels = [
            BroadcastOverviewViewModel()
        ]
    }
    
    public convenience init(broadcast: CADBroadcastType) {
        self.init(broadcastNumber: broadcast.identifier,
                  iconImage: AssetManager.shared.image(forKey: .tabBarTasks),
                  iconTintColor: .disabledGray,
                  color: .primaryGray,
                  statusText: NSLocalizedString("Broadcast", comment: "").uppercased(),
                  itemName: broadcast.title)
        self.broadcast = broadcast
    }
    
    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        let broadcast = CADStateManager.shared.broadcastsById[taskItemIdentifier]!
        return Promise<CADTaskListItemModelType>.value(broadcast)
    }

    override open func reloadFromModel() {
        if let broadcast = broadcast {
            viewModels.forEach {
                $0.reloadFromModel(broadcast)
            }
        }
        super.reloadFromModel()
    }
    
    open override func refreshTask() -> Promise<Void> {
        // TODO: Add method to CADStateManager to fetch individual broadcast
        return Promise<Void>()
    }

}
