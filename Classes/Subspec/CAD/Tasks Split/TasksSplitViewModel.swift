//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksSplitViewModel {

    // View models
    public let tasksListViewModel: TasksListViewModel
    public let tasksListHeaderViewModel: TasksListHeaderViewModel

    public init(tasksListViewModel: TasksListViewModel, tasksListHeaderViewModel: TasksListHeaderViewModel) {
        self.tasksListViewModel = tasksListViewModel
        self.tasksListHeaderViewModel = tasksListHeaderViewModel
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksSplitViewController(viewModel: self)
    }

    public func createMasterViewControllerHeaderRegular() -> UIViewController {
        return tasksListHeaderViewModel.createRegularViewController()
    }

    public func createMasterViewControllerHeaderCompact() -> UIViewController {
        return tasksListHeaderViewModel.createCompactViewController()
    }

    public func createMasterViewController() -> UIViewController {
        return TasksListContainerViewController(viewModel: self)
    }

    public func createDetailViewController() -> UIViewController {
        return TasksMapViewController()
    }

    public func createTasksListViewController() -> UIViewController {
        let tasksListViewController = tasksListViewModel.createViewController()
        tasksListViewController.userInterfaceStyle = .dark
        return tasksListViewController
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

}
