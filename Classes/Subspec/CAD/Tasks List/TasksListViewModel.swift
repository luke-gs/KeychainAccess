//
//  TasksListViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 10/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

/// Internal view model for handling the sections of the collection view
private struct TasksListSectionViewModel {
    let title: String
    let items: [TasksListItemViewModel]
}

/// Generic view model for the task list in CAD.
///
/// A task may be from different sources, likes Incidents, Resources, Patrol and Broadcast
public class TasksListViewModel {

    private var collapsedSections: Set<Int> = []

    private var sections: [TasksListSectionViewModel] {
        return [
            TasksListSectionViewModel(title: "Responding to",
                                      items: [TasksListItemViewModel(title: "Assault (2)",
                                                                     subtitle: "188 Smith St",
                                                                     caption: "AS4205 : MP0001529",
                                                                     boxText: "P1",
                                                                     boxColor: .red,
                                                                     boxFilled: true)])
        ]
    }

    public func createViewController() -> TasksListViewController {
        return TasksListViewController(viewModel: self)
    }

    /// The title to use in the navigation bar
    public func navTitle() -> String {
        return NSLocalizedString("Tasks", comment: "Tasks navigation title")
    }

    /// Content title shown when no results
    public func noContentTitle() -> String? {
        return NSLocalizedString("No Tasks Found", comment: "")
    }

    public func noContentSubtitle() -> String? {
        return nil
    }

    // MARK: - Data Source

    public func numberOfSections() -> Int {
        return sections.count
    }

    public func numberOfItems(for section: Int) -> Int {
        if let sectionViewModel = sections[ifExists: section], !collapsedSections.contains(section) {
            return sectionViewModel.items.count
        }
        return 0
    }

    public func item(at indexPath: IndexPath) -> TasksListItemViewModel? {
        if let sectionViewModel = sections[ifExists: indexPath.section] {
            return sectionViewModel.items[ifExists: indexPath.row]
        }
        return nil
    }

    // MARK: - Group Headers

    public func isHeaderExpanded(at section: Int) -> Bool {
        return !collapsedSections.contains(section)
    }

    public func toggleHeaderExpanded(at section: Int) {
        if let itemIndex = collapsedSections.index(of: section) {
            collapsedSections.remove(at: itemIndex)
        } else {
            collapsedSections.insert(section)
        }
    }

    public func headerText(at section: Int) -> String? {
        if let sectionViewModel = sections[ifExists: section] {
            return sectionViewModel.title.uppercased()
        }
        return nil
    }
}
