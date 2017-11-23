//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit

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

    public weak var splitViewModel: TasksSplitViewModel?

    // MARK: - Properties

    // Child view models
    public let headerViewModel: TasksListHeaderViewModel
    public let listViewModel: TasksListViewModel

    /// The tasks source items, which are basically the different kinds of tasks (not backend sources)
    public var sourceItems: [SourceItem] = [] {
        didSet {
            if sourceItems != oldValue {
                headerViewModel.sourceItems = sourceItems
            }
        }
    }

    /// The selected source index
    public var selectedSourceIndex: Int = 0 {
        didSet {
            if selectedSourceIndex != oldValue {
                headerViewModel.selectedSourceIndex = selectedSourceIndex
                updateListData()
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel

        updateSourceItems()
        updateListData()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self
    }

    /// Create the view controller for this view model
    public func createViewController() -> UIViewController {
        return TasksListContainerViewController(viewModel: self)
    }

    // MARK: - Public methods

    /// Update the source items status
    public func updateSourceItems() {

        // TODO: populate counts from network
        sourceItems = SampleData.sourceItems()
        selectedSourceIndex = 0
    }

    /// Update the task list data
    public func updateListData() {

        // TODO: fetch from network
        let type = TaskListType(rawValue: selectedSourceIndex)!
        
        let sections = SampleData.sectionsForType(type)
        
        if let filter = self.splitViewModel?.filterViewModel {
            switch type {
            case .incident:
                listViewModel.sections = sections.map { section in
                    let items = section.items.filter { item in
                        
                        // TODO: Replace with enum when model classes created
                        let priorityFilter = filter.priorities.contains(item.priority ?? "")
                        let resourcedFilter = filter.resourcedIncidents.contains(item.status ?? "")
                        
                        // If status is not in filter options always show
                        let isOther = item.status != "Resourced" && item.status != "Unresourced"
                        
                        return isOther || (priorityFilter && resourcedFilter)
                    }
                    return CADFormCollectionSectionViewModel(title: section.title, items: items)
                }
            case .patrol: listViewModel.sections = sections
            case .broadcast: listViewModel.sections = sections
            case .resource:
                listViewModel.sections = sections.map { section in
                    let items = section.items.filter { item in
                        // TODO: Replace with enum when model classes created
                        let taskedFilter = filter.taskedResources.contains(item.status ?? "")
                        
                        // If status is not in filter options always show
                        let isOther = item.status != "Tasked" && item.status != "Untasked"
                        
                        return isOther || taskedFilter
                    }
                    return CADFormCollectionSectionViewModel(title: section.title, items: items)
                }
            }
        } else {
            listViewModel.sections = sections
        }
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
            CADFormCollectionSectionViewModel(title: "Current Incident",
                                              items: [TasksListItemViewModel(title: "Assault (2)",
                                                                             subtitle: "188 Smith Street, Fitzroy",
                                                                             caption: "AS4205  •  MP0001529",
                                                                             status: "Current Incident",
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true)
            ]),
            
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Trespassing (1)",
                                                                             subtitle: "16 Easey Street, Collingwood",
                                                                             caption: "AS4217  •  MP0001540",
                                                                             status: "Assigned",
                                                                             priority: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false)
            ]),
            
            
            CADFormCollectionSectionViewModel(title: "2 Unresourced",
                                              items: [TasksListItemViewModel(title: "Vandalism",
                                                                             subtitle: "160 Vere Street, Collingwood",
                                                                             caption: "AS4224  •  MP0001548",
                                                                             status: "Unresourced",
                                                                             priority: "P4",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false),
                                                      
                                                      TasksListItemViewModel(title: "Traffic Crash",
                                                                             subtitle: "41 Victoria Parade, Fitzroy",
                                                                             caption: "AS4227  •  MP0001551",
                                                                             status: "Unresourced",
                                                                             priority: "P3",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false)
            ]),
            
            CADFormCollectionSectionViewModel(title: "2 Resourced",
                                              items: [TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street, Fitzroy",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             status: "Resourced",
                                                                             priority: "P2",
                                                                             boxColor: .sunflowerYellow,
                                                                             boxFilled: true),
                                                      
                                                      TasksListItemViewModel(title: "Public Nuisance (1)",
                                                                             subtitle: "AS4012  •  MP00001528",
                                                                             caption: "27 Lansdowne Street, East Melbourne",
                                                                             status: "Resourced",
                                                                             priority: "P3",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false),
                                                      ]),
            
        ]
        
    }
    
    static func patrols() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Traffic Management",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
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
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "1 Event",
                                              items: [TasksListItemViewModel(title: "Lawful Protest March",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0962  :  09:00 - 12:00",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "2 BOLF",
                                              items: [TasksListItemViewModel(title: "Vehicle: TNS448",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0995  :  1 day ago",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "Vehicle: XNR106",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC1004  :  4 days ago",
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
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true)]),
            CADFormCollectionSectionViewModel(title: "7 Tasked",
                                              items: [TasksListItemViewModel(title: "P03 (3)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "Proceeding",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "P12 (1)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "At Incident",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true),
                                                      TasksListItemViewModel(title: "F05 (4)",
                                                                             subtitle: "Abbotsford",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false),
                                                      TasksListItemViewModel(title: "K14 (2)",
                                                                             subtitle: "Collingwood",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false)])
        ]
    }

}
