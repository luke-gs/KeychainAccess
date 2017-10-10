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
        return TasksListViewController(viewModel: self)
    }

    /// Lazy var for creating view model content
    private lazy var data: [CADFormCollectionSectionViewModel<TasksListItemViewModel>] = {
        return [CADFormCollectionSectionViewModel(title: "Responding to",
                                                  items: [TasksListItemViewModel(title: "Assault (2)",
                                                                                 subtitle: "188 Smith St",
                                                                                 caption: "AS4205 : MP0001529",
                                                                                 boxText: "P1",
                                                                                 boxColor: .red,
                                                                                 boxFilled: true)])
        ]
    }()

    // MARK: - Override

    override open func sections() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return data
    }

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
}
