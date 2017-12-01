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
            case .patrol: listViewModel.sections = []
            case .broadcast: listViewModel.sections = []
            case .resource:
                let filteredResources = sync.resources.filter { resource in
                    let isTasked = resource.incidentNumber != nil
                    
                    // TODO: Duress check
                    return filter.taskedResources.tasked && isTasked || filter.taskedResources.untasked && !isTasked
                }
                listViewModel.sections = taskListSections(for: filteredResources)
            }
        } else {
            listViewModel.sections = []
        }
        delegate?.sectionsUpdated()
    }
    
    /// Maps sync models to view models
    func taskListSections(for incidents: [SyncDetailsIncident]) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var sectionedIncidents: [String: Array<SyncDetailsIncident>] = [:]

        // Map incidents to sections
        for incident in incidents {
            let status = incident.status.rawValue
            if sectionedIncidents[status] == nil {
                sectionedIncidents[status] = []
            }
            
            sectionedIncidents[status]?.append(incident)
        }
        
        // Make view models from sections
        return sectionedIncidents.map { arg in
            let (status, incidents) = arg
            
            let taskViewModels = incidents.map { incident in
                return TasksListItemViewModel(identifier: incident.incidentNumber,
                    title: "\(incident.incidentType ?? "") \(incident.resourceCountString)",
                    subtitle: incident.location.fullAddress,
                    caption: incident.incidentNumber, // TODO: Find out what second number is
                    priority: incident.grade.rawValue,
                    description: incident.details,
                    resources: nil, // TODO: Get resources
                    badgeTextColor: incident.grade.badgeColors.text,
                    badgeFillColor: incident.grade.badgeColors.fill,
                    badgeBorderColor: incident.grade.badgeColors.border,
                    hasUpdates: false) // TODO: Calculate dynamically
            }
            return CADFormCollectionSectionViewModel(title: "\(incidents.count) \(status)", items: taskViewModels)
        }
    }
    
    /// Maps sync models to view models
    func taskListSections(for resources: [SyncDetailsResource]) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        // Map resources to sections
        let tasked = NSLocalizedString("Tasked", comment: "")
        let untasked = NSLocalizedString("Untasked", comment: "")
        
        var sectionedResources: [String: Array<SyncDetailsResource>] = [
            tasked: [],
            untasked: []
        ]
        
        for resource in resources {
            if resource.incidentNumber != nil {
                sectionedResources[tasked]?.append(resource)
            } else {
                sectionedResources[untasked]?.append(resource)
            }
        }
        
        // Make view models from sections
        return sectionedResources.map { arg -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            let (section, resources) = arg
            
            let taskViewModels: [TasksListItemViewModel] = resources.map { resource in
                let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                
                return TasksListItemViewModel(identifier: resource.callsign,
                    title: "\(resource.callsign ?? "") \(resource.officerCountString ?? "")",
                    subtitle: resource.location.suburb,
                    caption: resource.status.title,
                    priority: incident?.grade.rawValue,
                    description: incident?.details,
                    badgeTextColor: incident?.grade.badgeColors.text,
                    badgeFillColor: incident?.grade.badgeColors.fill,
                    badgeBorderColor: incident?.grade.badgeColors.border,
                    hasUpdates: false) // TODO: Calculate dynamically
            }
            if resources.count > 0 {
                return CADFormCollectionSectionViewModel(title: "\(resources.count) \(section)", items: taskViewModels)
            } else {
                return nil
            }
        }.removeNils()
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
}

