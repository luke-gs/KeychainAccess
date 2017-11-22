//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit

/// Enum for all task types
public enum TaskListType: Int {
    case incident
    case patrol
    case broadcast
    case resource

    var title: String {
        switch self {
        case .incident:
            return NSLocalizedString("Incidents", comment: "Incidents navigation title")
        case .patrol:
            return NSLocalizedString("Patrol",    comment: "Patrol navigation title")
        case .broadcast:
            return NSLocalizedString("Broadcast", comment: "Broadcast navigation title")
        case .resource:
            return NSLocalizedString("Resources", comment: "Resources navigation title")
        }
    }

    var shortTitle: String {
        switch self {
        case .incident:
            return NSLocalizedString("INCI", comment: "Incidents short title")
        case .patrol:
            return NSLocalizedString("PATR", comment: "Patrol short title")
        case .broadcast:
            return NSLocalizedString("BCST", comment: "Broadcast short title")
        case .resource:
            return NSLocalizedString("RESO", comment: "Resources short title")
        }
    }
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    // MARK: - Properties

    // Child view models
    open let headerViewModel: TasksListHeaderViewModel
    open let listViewModel: TasksListViewModel

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    open var sourceItems: [SourceItem] = [] {
        didSet {
            if sourceItems != oldValue {
                headerViewModel.sourceItems = sourceItems
            }
        }
    }

    /// The selected source index
    open var selectedSourceIndex: Int = 0 {
        didSet {
            if selectedSourceIndex != oldValue {
                headerViewModel.selectedSourceIndex = selectedSourceIndex
                updateSections()
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel

        updateSourceItems()
        updateSections()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self
    }

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        return TasksListContainerViewController(viewModel: self)
    }

    // MARK: - Public methods

    /// Content title shown when no results
    open func noContentTitle() -> String? {
        return NSLocalizedString("No Tasks Found", comment: "")
    }

    open func noContentSubtitle() -> String? {
        return nil
    }

    open func loadingTitle() -> String? {
        return NSLocalizedString("Please wait", comment: "")
    }

    // Refresh all tasks list data
    open func refreshTaskList() -> Promise<Void> {
        return CADStateManager.shared.syncSummaries().then { _ -> Void in
        }
    }

    // MARK: - Internal methods

    /// Update the source items status
    open func updateSourceItems() {

        // TODO: Map network models to view models
        sourceItems = SampleData.sourceItems()
        selectedSourceIndex = 0
    }

    /// Update the task list data
    open func updateSections() {

        // TODO: Map network models to view models
        let type = TaskListType(rawValue: selectedSourceIndex)!
        listViewModel.sections = SampleData.sectionsForType(type)
    }

}

public class SampleData {

    static func sourceItemForType(type: TaskListType, count: UInt, color: UIColor) -> SourceItem {
        return SourceItem(title: type.title, shortTitle: type.shortTitle, state: .loaded(count: count, color: color))
    }

    static func sourceItems() -> [SourceItem] {
        return [
            sourceItemForType(type: .incident,  count: 6, color: .orangeRed),
            sourceItemForType(type: .patrol,    count: 1, color: .secondaryGray),
            sourceItemForType(type: .broadcast, count: 4, color: .secondaryGray),
            sourceItemForType(type: .resource,  count: 9, color: .orangeRed)
        ]
    }

    static func sectionsForType(_ type: TaskListType) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        switch type {
        case .incident:
            return SampleData.incidents()
        case .patrol:
            return SampleData.patrols()
        case .broadcast:
            return SampleData.broadcasts()
        case .resource:
            return SampleData.resources()
        }
    }

    static func incidents() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "Responding to",
                                              items: [TasksListItemViewModel(title: "Assault (2)",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
                                                                             boxText: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             boxText: "P2",
                                                                             boxColor: .sunflowerYellow,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Trespassing (1)",
                                                                             subtitle: "16 Easey Street",
                                                                             caption: "AS4217  :  MP0001540",
                                                                             boxText: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false)]),
            CADFormCollectionSectionViewModel(title: "2 Unassigned",
                                              items: [TasksListItemViewModel(title: "Vandalismn",
                                                                             subtitle: "12 Vere Street",
                                                                             caption: "AS4224  :  MP0001551",
                                                                             boxText: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false),
                                                      TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             boxText: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false)])
        ]
    }

    static func patrols() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Traffic Management",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)])
        ]
    }

    static func broadcasts() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Alert",
                                              items: [TasksListItemViewModel(title: "Impaired Driver",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "BC0997  :  10:16",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "1 Event",
                                              items: [TasksListItemViewModel(title: "Lawful Protest March",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0962  :  09:00 - 12:00",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "2 BOLF",
                                              items: [TasksListItemViewModel(title: "Vehicle: TNS448",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0995  :  1 day ago",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Vehicle: XNR106",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC1004  :  4 days ago",
                                                                             boxText: "",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)])
        ]
    }

    static func resources() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Duress",
                                              items: [TasksListItemViewModel(title: "P08 (2)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "In Duress 2:45",
                                                                             boxText: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "7 Tasked",
                                              items: [TasksListItemViewModel(title: "P03 (3)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "Proceeding",
                                                                             boxText: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "P12 (1)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "At Incident",
                                                                             boxText: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "F05 (4)",
                                                                             subtitle: "Abbotsford",
                                                                             caption: "Processing",
                                                                             boxText: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false),
                                                      TasksListItemViewModel(title: "K14 (2)",
                                                                             subtitle: "Collingwood",
                                                                             caption: "Processing",
                                                                             boxText: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false)])
        ]
    }

}
