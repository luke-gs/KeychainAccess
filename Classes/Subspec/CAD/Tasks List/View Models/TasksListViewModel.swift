//
//  TasksListViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// View model for the task list in CAD. A task may be from different sources:
/// * Incidents
/// * Resources
/// * Patrol
/// * Broadcast
public class TasksListViewModel: CADFormCollectionViewModel<TasksListItemViewModel> {

    /// Create the view controller for this view model
    public func createViewController() -> TasksListViewController {
        let tasksListViewController = TasksListViewController(viewModel: self)
        tasksListViewController.userInterfaceStyle = .dark
        delegate = tasksListViewController
        return tasksListViewController
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

    /// Content title shown when no results
    override open func noContentTitle() -> String? {
        return NSLocalizedString("No Tasks Found", comment: "")
    }

    override open func noContentSubtitle() -> String? {
        return nil
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
