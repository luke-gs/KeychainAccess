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

    /// The optional summary loaded during construction
    open var patrolSummary: CADPatrolType?

    // MARK: - Init

    public init(patrolNumber: String) {
        super.init(taskItemIdentifier: patrolNumber)

        self.navTitle = NSLocalizedString("Patrol details", comment: "")
        self.subtitleText = "#\(patrolNumber)"

        // Load the summary if available
        patrolSummary = CADStateManager.shared.patrolsById[patrolNumber]
        if patrolSummary != nil {
            reloadFromModel()
        }
    }
    
    // MARK: - Generated properties

    /// Return the loaded details
    open var patrolDetails: CADPatrolType? {
        return taskItemDetails as? CADPatrolType
    }

    /// Return the loaded details or the summary if available
    open var patrolDetailsOrSummary: CADPatrolType? {
        return patrolDetails ?? patrolSummary
    }

    // MARK: - Methods

    open override func createViewModels() -> [TaskDetailsViewModel] {
        return [
            PatrolOverviewViewModel(),
            PatrolAssociationsViewModel(),
            PatrolNarrativeViewModel()
        ]
    }

    open override func createViewController() -> UIViewController {
        let vc = TaskItemSidebarSplitViewController(viewModel: self)
        delegate = vc
        return vc
    }

    open override func loadTaskItem() -> Promise<CADTaskListItemModelType> {
        // No additional information needs to be fetched
        if let patrolSummary = patrolSummary {
            return Promise<CADTaskListItemModelType>.value(patrolSummary)
        }
        return Promise(error: CADStateManagerError.itemNotFound)
    }

    override open func reloadFromModel() {
        guard let patrol = self.patrolDetailsOrSummary else { return }

        iconImage = AssetManager.shared.image(forKey: .tabBarTasks)
        iconTintColor = .disabledGray
        color = .primaryGray
        statusText = NSLocalizedString("Patrol", comment: "").uppercased()
        itemName = patrol.type
        compactNavTitle = itemName
        compactTitle = statusText
        compactSubtitle = subtitleText

        viewModels.forEach {
            $0.reloadFromModel(patrol)
        }
        super.reloadFromModel()
    }
    
}
