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
                splitViewModel?.mapViewModel.loadTasks()
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
        return CADStateManager.shared.syncDetails().then { _ -> Void in
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
        
        if let filter = self.splitViewModel?.filterViewModel, let sync = CADStateManager.shared.lastSync {
            switch type {
            case .incident:
                let filteredIncidents = sync.incidents.filter { incident in
                    let priorityFilter = filter.priorities.contains(incident.grade)
                    let resourcedFilter = filter.resourcedIncidents.contains(incident.status)
                    
                    // If status is not in filter options always show
                    let isOther = incident.status != .resourced && incident.status != .unresourced
                    
                    return isOther || (priorityFilter && resourcedFilter)
                }
                
                listViewModel.sections = taskListSections(for: filteredIncidents)
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
    
    func taskListSections(for incidents: [SyncDetailsIncident]) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var sectionedIncidents: [String: Array<SyncDetailsIncident>] = [:]

        for incident in incidents {
            let status = incident.status.rawValue
            if sectionedIncidents[status] == nil {
                sectionedIncidents[status] = []
            }
            
            sectionedIncidents[status]?.append(incident)
        }
        
        var sections: [CADFormCollectionSectionViewModel<TasksListItemViewModel>] = []
        for (status, incidents) in sectionedIncidents {
            let taskViewModels = incidents.map { incident in
                return TasksListItemViewModel(title: "\(incident.incidentType ?? "") \(incident.resourceCount > 0 ? String(incident.resourceCount) : "")",
                    subtitle: incident.location.fullAddress,
                    caption: incident.incidentNumber, // TODO: Find out what second number is
                    status: nil, // TODO: Remove value
                    priority: incident.grade.rawValue,
                    description: incident.details,
                    resources: nil, // TODO: Something else
                    badgeTextColor: incident.grade.badgeColors.text,
                    badgeFillColor: incident.grade.badgeColors.fill,
                    badgeBorderColor: incident.grade.badgeColors.border,
                    hasUpdates: false) // TODO: Calculate dynamically
            }
            sections.append(CADFormCollectionSectionViewModel(title: "\(incidents.count) \(status)", items: taskViewModels))
        }
        
        return sections
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
            return []
        case .patrol:
            return SampleData.patrols()
        case .broadcast:
            return SampleData.broadcasts()
        case .resource:
            return SampleData.resources()
        }
    }
    
    
    
    static func patrols() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Assigned",
                                              items: [TasksListItemViewModel(title: "Traffic Management",
                                                                             subtitle: "188 Smith St",
                                                                             caption: "AS4205  :  MP0001529",
                                                                             badgeTextColor: UIColor.clear,
                                                                             badgeFillColor: UIColor.clear,
                                                                             badgeBorderColor: UIColor.clear,
                                                                             hasUpdates: false)])
        ]
    }
    
    static func broadcasts() -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        return [
            CADFormCollectionSectionViewModel(title: "1 Alert",
                                              items: [TasksListItemViewModel(title: "Impaired Driver",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "BC0997  :  10:16",
                                                                             badgeTextColor: UIColor.clear,
                                                                             badgeFillColor: UIColor.clear,
                                                                             badgeBorderColor: UIColor.clear,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "1 Event",
                                              items: [TasksListItemViewModel(title: "Lawful Protest March",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0962  :  09:00 - 12:00",
                                                                             badgeTextColor: UIColor.clear,
                                                                             badgeFillColor: UIColor.clear,
                                                                             badgeBorderColor: UIColor.clear,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "2 BOLF",
                                              items: [TasksListItemViewModel(title: "Vehicle: TNS448",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC0995  :  1 day ago",
                                                                             badgeTextColor: UIColor.clear,
                                                                             badgeFillColor: UIColor.clear,
                                                                             badgeBorderColor: UIColor.clear,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "Vehicle: XNR106",
                                                                             subtitle: "Melbourne",
                                                                             caption: "BC1004  :  4 days ago",
                                                                             badgeTextColor: UIColor.clear,
                                                                             badgeFillColor: UIColor.clear,
                                                                             badgeBorderColor: UIColor.clear,
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
                                                                             badgeTextColor: .black,
                                                                             badgeFillColor: .orangeRed,
                                                                             badgeBorderColor: .orangeRed,
                                                                             hasUpdates: false)]),
            CADFormCollectionSectionViewModel(title: "7 Tasked",
                                              items: [TasksListItemViewModel(title: "P03 (3)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "Proceeding",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             badgeTextColor: .black,
                                                                             badgeFillColor: .orangeRed,
                                                                             badgeBorderColor: .orangeRed,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "P12 (1)",
                                                                             subtitle: "Fitzroy",
                                                                             caption: "At Incident",
                                                                             status: "Tasked",
                                                                             priority: "P1",
                                                                             badgeTextColor: .black,
                                                                             badgeFillColor: .orangeRed,
                                                                             badgeBorderColor: .orangeRed,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "F05 (4)",
                                                                             subtitle: "Abbotsford",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             badgeTextColor: .primaryGray,
                                                                             badgeFillColor: .primaryGray,
                                                                             badgeBorderColor: .clear,
                                                                             hasUpdates: false),
                                                      TasksListItemViewModel(title: "K14 (2)",
                                                                             subtitle: "Collingwood",
                                                                             caption: "Processing",
                                                                             status: "Tasked",
                                                                             priority: "P3",
                                                                             badgeTextColor: .primaryGray,
                                                                             badgeFillColor: .primaryGray,
                                                                             badgeBorderColor: .clear,
                                                                             hasUpdates: false)])
        ]
    }

}

