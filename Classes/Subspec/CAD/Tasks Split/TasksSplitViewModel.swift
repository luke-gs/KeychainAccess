//
//  TasksSplitViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 9/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

open class TasksSplitViewModel {

    /// Container view model
    public let containerViewModel: TasksListContainerViewModel

    public init(containerViewModel: TasksListContainerViewModel) {
        self.containerViewModel = containerViewModel
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksSplitViewController(viewModel: self)
    }

    public func createMasterViewController() -> UIViewController {
        return containerViewModel.createViewController()
    }

    public func createDetailViewController() -> UIViewController {
        return TasksMapViewController()
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

}
