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

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    public var sourceItems: [SourceItem] = [] {
        didSet {
            tasksListHeaderViewModel.sourceItems = sourceItems
        }
    }

    public init(tasksListViewModel: TasksListViewModel, tasksListHeaderViewModel: TasksListHeaderViewModel) {
        self.tasksListViewModel = tasksListViewModel
        self.tasksListHeaderViewModel = tasksListHeaderViewModel
        updateSourceItems()
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

    /// Update the source items status
    public func updateSourceItems() {
        // TODO: populate counts from network
        let incidents = SourceItem(title: "Incidents", shortTitle: "INCI", state: .loaded(count: 6, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))
        let patrol = SourceItem(title: "Patrol", shortTitle: "PATR", state: .loaded(count: 1, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let broadcast = SourceItem(title: "Broadcast", shortTitle: "BCST", state: .loaded(count: 4, color: #colorLiteral(red: 0.5215686275, green: 0.5254901961, blue: 0.5529411765, alpha: 1)))
        let resources = SourceItem(title: "Resources", shortTitle: "RESO", state: .loaded(count: 9, color: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1)))
        sourceItems = [incidents, patrol, broadcast, resources]
    }

}
