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

/// Protocol for notifying UI of updated view model data
public protocol TasksListContainerViewModelDelegate: class {

    // Called when source items are updated
    func updateSourceItems()
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksListContainerViewModelDelegate?

    // MARK: - Properties
    
    /// Ordered array of incident statuses for the list to follow
    open let incidentSortOrder: [SyncDetailsIncident.Status] = [.current, .assigned, .resourced, .unresourced]

    // Child view models
    open let headerViewModel: TasksListHeaderViewModel
    open let listViewModel: TasksListViewModel

    /// The search filter text
    open var searchText: String? {
        didSet {
            if searchText != oldValue {
                updateSections()
            }
        }
    }

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

                // Show/hide add button
                let type = TaskListType(rawValue: selectedSourceIndex)!
                headerViewModel.setAddButtonVisible(type == .incident)
            }
        }
    }

    // MARK: - Initialization

    public init(headerViewModel: TasksListHeaderViewModel, listViewModel: TasksListViewModel) {

        self.headerViewModel = headerViewModel
        self.listViewModel = listViewModel

        updateSections()

        // Link header view model sources with us
        self.headerViewModel.containerViewModel = self

        // Observe sync changes
        NotificationCenter.default.addObserver(self, selector: #selector(syncChanged), name: .CADSyncChanged, object: nil)
        
        /// Observe book-on changes to show assigned incidents
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADBookOnChanged, object: nil)

    }

    @objc open func syncChanged() {
        updateSections()
    }
    
    @objc open func bookOnChanged() {
        updateSections()
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

    func sourceItemForType(type: TaskListType, count: Int, color: UIColor) -> SourceItem {
        return SourceItem(title: type.title, shortTitle: type.shortTitle, state: .loaded(count: UInt(count), color: color))
    }

    /// Update the task list data
    open func updateSections() {
        let type = TaskListType(rawValue: selectedSourceIndex)!

        if let splitViewModel = splitViewModel {

            // Load filtered data once
            let filteredIncidents = splitViewModel.filteredIncidents
            let filteredResources = splitViewModel.filteredResources

            // Apply filtered data to sources and sections
            switch type {
            case .incident:
                listViewModel.sections = taskListSections(for: filteredIncidents)
            case .patrol:
                // TODO: Get from sync
                listViewModel.sections = []
            case .broadcast:
                // TODO: Get from sync
                listViewModel.sections = []
            case .resource:
                listViewModel.sections = taskListSections(for: filteredResources)
            }

            // Update the source items status
            // TODO: calculate colors based on priorities
            sourceItems = [
                sourceItemForType(type: .incident,  count: filteredIncidents.count, color: .orangeRed),
                sourceItemForType(type: .patrol,    count: 0, color: .secondaryGray),
                sourceItemForType(type: .broadcast, count: 0, color: .secondaryGray),
                sourceItemForType(type: .resource,  count: filteredResources.count, color: .orangeRed)
            ]
        } else {
            listViewModel.sections = []
            sourceItems = [
                sourceItemForType(type: .incident,  count: 0, color: .secondaryGray),
                sourceItemForType(type: .patrol,    count: 0, color: .secondaryGray),
                sourceItemForType(type: .broadcast, count: 0, color: .secondaryGray),
                sourceItemForType(type: .resource,  count: 0, color: .secondaryGray)
            ]
        }
        delegate?.updateSourceItems()
    }
    
    /// Maps sync models to view models
    open func taskListSections(for incidents: [SyncDetailsIncident]) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var sectionedIncidents: [String: Array<SyncDetailsIncident>] = [:]

        // Map incidents to sections
        for incident in incidents {
            let status = incident.status.rawValue
            if sectionedIncidents[status] == nil {
                sectionedIncidents[status] = []
            }

            // Apply search text filter to type or address
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [incident.type, incident.location?.fullAddress].removeNils().filter {
                    return $0.lowercased().contains(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedIncidents[status]?.append(incident)
                }
            } else {
                sectionedIncidents[status]?.append(incident)
            }
        }
  
        let sortedIncidents = incidentSortOrder.map { status -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            guard let incidents = sectionedIncidents[status.rawValue] else { return nil }
            
            let taskViewModels = incidents.map { incident in
                return TasksListIncidentViewModel(incident: incident, hasUpdates: true)
            }
            return CADFormCollectionSectionViewModel(title: "\(incidents.count) \(status)",
                items: taskViewModels
            )
        }
            
        return sortedIncidents.removeNils()
    }
    
    /// Maps sync models to view models
    open func taskListSections(for resources: [SyncDetailsResource]) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        // Map resources to sections
        let duress = NSLocalizedString("Duress", comment: "")
        let tasked = NSLocalizedString("Tasked", comment: "")
        let untasked = NSLocalizedString("Untasked", comment: "")
        
        var sectionedResources: [String: Array<SyncDetailsResource>] = [
            duress: [],
            tasked: [],
            untasked: []
        ]
        
        for resource in resources {
            // Apply search text filter to type or address
            var shouldAppend: Bool = false
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [resource.callsign].removeNils().filter {
                    return $0.lowercased().contains(searchText)
                }
                if !matchedValues.isEmpty {
                    shouldAppend = true
                }
            } else {
                shouldAppend = true
            }

            if shouldAppend {
                if resource.status == .duress {
                    sectionedResources[duress]?.append(resource)
                } else if resource.currentIncident != nil {
                    sectionedResources[tasked]?.append(resource)
                } else {
                    sectionedResources[untasked]?.append(resource)
                }
            }
        }
        
        // Make view models from sections
        return sectionedResources.map { arg -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            let (section, resources) = arg
            
            // Don't add duress section if there is no duress
            if section == duress && resources.isEmpty {
                return nil
            }
            
            let taskViewModels: [TasksListResourceViewModel] = resources.map { resource in
                let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                return TasksListResourceViewModel(resource: resource, incident: incident)
            }
            
            var title = "\(resources.count) \(section)"
            
            if section == duress {
                title = String.localizedStringWithFormat(NSLocalizedString("%d Resource(s)", comment: ""), resources.count) + " In Duress"
            }
            
            

            return CADFormCollectionSectionViewModel(title: title, items: taskViewModels)
        }.removeNils()
    }

}
