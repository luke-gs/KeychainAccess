//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksSplitViewModel {

    private let tasksListViewModel: TasksListViewModel

    public init() {
        tasksListViewModel = TasksListViewModel()
    }

    /// Create the view controller for this view model
    public func createViewController() -> TasksSplitViewController {
        return TasksSplitViewController(viewModel: self)
    }

    public func createTasksListViewController() -> UIViewController {
        let tasksListViewController = tasksListViewModel.createViewController()
        tasksListViewController.userInterfaceStyle = .dark
        return tasksListViewController
    }

    public func createMapViewController() -> UIViewController {
        let mapViewController = TasksMapViewController()
        return mapViewController
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

}
