//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import CoreLocation

open class TasksSplitViewModel {
    // FIXME: Temporary, remove later
    private let locationManager = CLLocationManager()
    

    // View models
    private let tasksListViewModel: TasksListViewModel
    private let tasksListHeaderViewModel: TasksListHeaderViewModel

    public init() {
        tasksListViewModel = TasksListViewModel()
        tasksListHeaderViewModel = TasksListHeaderViewModel()
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

    public func createTasksListViewController() -> UIViewController {
        let tasksListViewController = tasksListViewModel.createViewController()
        tasksListViewController.userInterfaceStyle = .dark
        return tasksListViewController
    }

    public func createMapViewController() -> UIViewController {
        let mapViewController = TasksMapViewController(withLocationManager: locationManager)
        return mapViewController
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

}
