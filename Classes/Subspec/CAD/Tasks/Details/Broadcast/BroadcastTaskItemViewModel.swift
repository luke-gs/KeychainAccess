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
        super.init(iconImage: iconImage, iconTintColor: iconTintColor, color: color, statusText: statusText, itemName: itemName, subtitleText: captionText)
        
        self.navTitle = NSLocalizedString("Broadcast details", comment: "")
        self.compactNavTitle = itemName
        
        self.viewModels = [
            BroadcastOverviewViewModel(identifier: broadcastNumber)
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
    
    override open func reloadFromModel() {
        viewModels.forEach {
            $0.reloadFromModel()
        }
    }
    
    open override func refreshTask() -> Promise<Void> {
        // TODO: Add method to CADStateManager to fetch individual broadcast
        return Promise<Void>()
    }

}
