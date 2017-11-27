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

/// Delegate protocol for updating UI
public protocol TasksListContainerViewModelDelegate: class {
    /// Called when the sections data is updated
    func sectionsUpdated()
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    public weak var splitViewModel: TasksSplitViewModel?

    /// Delegate for UI updates
    open weak var delegate: TasksListContainerViewModelDelegate?

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
                splitViewModel?.mapViewModel.applyFilter()
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

        // Observe sync changes
        NotificationCenter.default.addObserver(self, selector: #selector(syncChanged), name: .CADSyncChanged, object: nil)
    }

    @objc open func syncChanged() {
        self.updateSections()
    }

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let vc = TasksListContainerViewController(viewModel: self)
        delegate = vc
        return vc
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

    open func loadingSubtitle() -> String? {
        return NSLocalizedString("We’re retrieving your tasks now", comment: "")
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
        delegate?.sectionsUpdated()
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
                                                                             subtitle: "188 Smith Street, Fitzroy VIC 3065",
                                                                             caption: "AS4205  •  MP0001529",
                                                                             status: "Current Incident",
                                                                             priority: "P1",
                                                                             description: "An armed group of men are currently barricaded within the lobby of Orion Central Bank, Collingwood. Communication channels has yet to be established.",
                                                                             resources: [
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P24 (2)",
                                                                                                               statusText: "At Incident",
                                                                                                               tintColor: nil,
                                                                                                               useBoldStatusText: false),
                                                                                
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P12 (1)",
                                                                                                               statusText: "Proceeding 1:25",
                                                                                                               tintColor: nil,
                                                                                                               useBoldStatusText: false)
                                                                             ],
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true,
                                                                             hasUpdates: false)
            ]),
            
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Trespassing (1)",
                                                                             subtitle: "16 Easey Street, Collingwood VIC 3066",
                                                                             caption: "AS4217  •  MP0001540",
                                                                             status: "Assigned",
                                                                             priority: "P3",
                                                                             description: "Building owner has reported that a group of individuals have forcefully entered the premises and are now refusing to leave. There have been recent",

                                                                             resources: [
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P22 (1)",
                                                                                                               statusText: "Proceeding 3:30",
                                                                                                               tintColor: nil,
                                                                                                               useBoldStatusText: false)
                                                                             ],
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false,
                                                                             hasUpdates: true)
            ]),
            
            
            CADFormCollectionSectionViewModel(title: "2 Unresourced",
                                              items: [TasksListItemViewModel(title: "Vandalism",
                                                                             subtitle: "160 Vere Street, Collingwood VIC 3066",
                                                                             caption: "AS4224  •  MP0001548",
                                                                             status: "Unresourced",
                                                                             priority: "P4",
                                                                             description: "Multiple letterboxes that belong to a group of units have been damaged with what witnesses have described to be a baseball bat. Offenders have fled on foot and are thought to be residing in the area.",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false,
                                                                             hasUpdates: false),
                                                      
                                                      TasksListItemViewModel(title: "Traffic Crash",
                                                                             subtitle: "41 Victoria Parade, Fitzroy VIC 3065",
                                                                             caption: "AS4227  •  MP0001551",
                                                                             status: "Unresourced",
                                                                             priority: "P3",
                                                                             description: "A multi-vehicle collision has occured outside St. Vincent’s Hospital. No injuries have been reported but traffic has been reduced from 3 to 1 lane due to wreckage. Officers are required on scene to re-direct traffic.",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false,
                                                                             hasUpdates: false)
            ]),
            
            CADFormCollectionSectionViewModel(title: "2 Resourced",
                                              items: [TasksListItemViewModel(title: "Domestic Violence (2)",
                                                                             subtitle: "57 Bell Street, Fitzroy VIC 3065",
                                                                             caption: "AS4203  :  MP0001517",
                                                                             status: "Resourced",
                                                                             priority: "P2",
                                                                             description: "Multiple witnesses have reported a couple arguing in public and disturbing the peace. They appear to be either intoxicated or under the influence of an illicit drugs",
                                                                             resources: [
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P08 (2)",
                                                                                                               statusText: "Duress",
                                                                                                               tintColor: .orangeRed,
                                                                                                               useBoldStatusText: true),
                                                                                
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P03 (3)",
                                                                                                               statusText: "Proceeding 0:47",
                                                                                                               tintColor: nil,
                                                                                                               useBoldStatusText: false),
                                                                                
                                                                                TasksListItemResourceViewModel(image: AssetManager.shared.image(forKey: .resourceCar),
                                                                                                               resourceTitle: "P14 (2)",
                                                                                                               statusText: "Proceeding 2:41",
                                                                                                               tintColor: nil,
                                                                                                               useBoldStatusText: false),
                                                                             ],
                                                                             boxColor: .sunflowerYellow,
                                                                             boxFilled: true,
                                                                             hasUpdates: false),
                                                      
                                                      TasksListItemViewModel(title: "Public Nuisance (1)",
                                                                             subtitle: "27 Lansdowne Street, East Melbourne VIC 3002",
                                                                             caption: "AS4012  •  MP00001528",
                                                                             status: "Resourced",
                                                                             priority: "P3",
                                                                             description: "A group of intoxicated individuals are verbally abusing patrons as they enter and leave",
                                                                             boxColor: .secondaryGray,
                                                                             boxFilled: false,
                                                                             hasUpdates: false),
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
                                                                             boxFilled: true,
                                                                             hasUpdates: false)])
        ]
    }

    static func broadcasts() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Alert",
                                              items: [TasksListItemViewModel(title: "Impaired Driver",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "BC0997  :  10:16",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "1 Event",
                                              items: [TasksListItemViewModel(title: "Lawful Protest March",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0962  :  09:00 - 12:00",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "2 BOLF",
                                              items: [TasksListItemViewModel(title: "Vehicle: TNS448",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0995  :  1 day ago",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "Vehicle: XNR106",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC1004  :  4 days ago",
                                                                             boxColor: UIColor.clear,
                                                                             boxFilled: true,
                                                                             hasUpdates: false)])
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
                                                                             boxFilled: true,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "7 Tasked",
                                              items: [TasksListItemViewModel(title: "P03 (3)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "Proceeding",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "P12 (1)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "At Incident",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             boxColor: .orangeRed,
                                                                             boxFilled: true,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "F05 (4)",
                                                                             subtitle: "Abbotsford",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "K14 (2)",
                                                                             subtitle: "Collingwood",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             boxColor: .brightBlue,
                                                                             boxFilled: false,
                                                                             hasUpdates: false)])
        ]
    }

}
