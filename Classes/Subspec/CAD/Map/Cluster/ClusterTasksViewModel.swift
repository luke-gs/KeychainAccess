//
//  ClusterTasksViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

open class ClusterTasksViewModel: CADFormCollectionViewModel<TasksListItemViewModel> {

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let viewController = ClusterTasksViewController(viewModel: self)
        return viewController
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return ""
    }

    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return nil
    }

    override open func noContentSubtitle() -> String? {
        return nil
    }

    open func patrolGroupSectionTitle() -> String {
        if let patrolGroup = CADStateManager.shared.patrolGroup {
            return "\(patrolGroup) area"
        } else {
            return ""
        }
    }

    open func otherSectionTitle() -> String {
        return NSLocalizedString("Other areas", comment: "")
    }

    open func showsUpdatesIndicator(at section: Int) -> Bool {
        if let sectionViewModel = sections[ifExists: section] {
            for item in sectionViewModel.items {
                if (item as? TasksListIncidentViewModel)?.hasUpdates == true {
                    return true
                }
            }
        }
        return false
    }
}
