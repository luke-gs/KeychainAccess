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

    /// The optional summary loaded during construction
    open var broadcastSummary: CADBroadcastType?

    // MARK: - Init

    public init(broadcastNumber: String) {
        super.init(taskItemIdentifier: broadcastNumber)
        
        self.navTitle = NSLocalizedString("Broadcast details", comment: "")
        self.subtitleText = "#\(broadcastNumber)"

        // Load the summary if available
        broadcastSummary = CADStateManager.shared.broadcastsById[broadcastNumber]
        if broadcastSummary != nil {
            reloadFromModel()
        }
    }
    
    // MARK: - Generated properties

    /// Return the loaded details
    open var broadcastDetails: CADBroadcastType? {
        return taskItemDetails as? CADBroadcastType
    }

    /// Return the loaded details or the summary if available
    open var broadcastDetailsOrSummary: CADBroadcastType? {
        return broadcastDetails ?? broadcastSummary
    }

    // MARK: - Methods

    open override func createViewModels() -> [TaskDetailsViewModel] {
        return [BroadcastOverviewViewModel(),
        BroadcastNarrativeViewModel()]
    }

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        // No additional information needs to be fetched
        if let broadcastSummary = broadcastSummary {
            return Promise<CADTaskListItemModelType>.value(broadcastSummary)
        }
        return Promise(error: CADStateManagerError.itemNotFound)
    }

    override open func reloadFromModel() {
        guard let broadcast = self.broadcastDetailsOrSummary else { return }

        iconImage = AssetManager.shared.image(forKey: .tabBarTasks)
        iconTintColor = .disabledGray
        color = .primaryGray
        statusText = NSLocalizedString("Broadcast", comment: "").uppercased()
        itemName = broadcast.title
        compactNavTitle = itemName
        compactTitle = statusText
        compactSubtitle = subtitleText

        viewModels.forEach {
            $0.reloadFromModel(broadcast)
        }
        super.reloadFromModel()
    }
    
}
