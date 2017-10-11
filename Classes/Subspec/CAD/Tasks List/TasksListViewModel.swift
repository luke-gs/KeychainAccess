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
                                                                                 caption: "AS4205  :  MP0001529",
                                                                                 boxText: "P1",
                                                                                 boxColor: #colorLiteral(red: 0.9294117647, green: 0.3019607843, blue: 0.2392156863, alpha: 1),
                                                                                 boxFilled: true),
                                                          TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                                 subtitle: "57 Bell Street",
                                                                                 caption: "AS4203  :  MP0001517",
                                                                                 boxText: "P2",
                                                                                 boxColor: #colorLiteral(red: 0.9764705882, green: 0.8039215686, blue: 0.2745098039, alpha: 1),
                                                                                 boxFilled: true),
                                                          TasksListItemViewModel(title: "Trespassing (1)",
                                                                                 subtitle: "16 Easey Street",
                                                                                 caption: "AS4217  :  MP0001540",
                                                                                 boxText: "P3",
                                                                                 boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                                 boxFilled: false)]),
                CADFormCollectionSectionViewModel(title: "2 Unassigned",
                                                  items: [TasksListItemViewModel(title: "Vandalismn",
                                                                                 subtitle: "12 Vere Street",
                                                                                 caption: "AS4224  :  MP0001551",
                                                                                 boxText: "P3",
                                                                                 boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                                 boxFilled: false),
                                                          TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                                 subtitle: "57 Bell Street",
                                                                                 caption: "AS4203  :  MP0001517",
                                                                                 boxText: "P3",
                                                                                 boxColor: #colorLiteral(red: 0.1647058824, green: 0.4823529412, blue: 0.9647058824, alpha: 1),
                                                                                 boxFilled: false)])
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
