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

    public weak var splitViewModel: TasksSplitViewModel?

    // MARK: - Properties

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
        
        /// Observe book-on changes to show assigned incidents
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADBookOnChanged, object: nil)

    }

    @objc open func syncChanged() {
        self.updateSections()
    }
    
    @objc open func bookOnChanged() {
        updateSections()
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
        let type = TaskListType(rawValue: selectedSourceIndex)!
        
        if let splitViewModel = self.splitViewModel {
            switch type {
            case .incident:
                listViewModel.sections = taskListSections(for: splitViewModel.filteredIncidents)
            case .patrol:
                // TODO: Get from sync
                listViewModel.sections = []
            case .broadcast:
                // TODO: Get from sync
                listViewModel.sections = []
            case .resource:
                listViewModel.sections = taskListSections(for: splitViewModel.filteredResources)
            }
        } else {
            listViewModel.sections = []
        }
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
        
        // Make view models from sections
        return sectionedIncidents.map { arg in
            let (status, incidents) = arg
            
            let taskViewModels = incidents.map { incident in
                return TasksListItemViewModel(incident: incident, hasUpdates: true)
            }
            return CADFormCollectionSectionViewModel(title: "\(incidents.count) \(status)", items: taskViewModels)
        }.sorted { first, second in
            return first.title.contains(SyncDetailsIncident.Status.current.rawValue)
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
                if resource.currentIncident != nil {
                    sectionedResources[tasked]?.append(resource)
                } else {
                    sectionedResources[untasked]?.append(resource)
                }
            }
        }
        
        // Make view models from sections
        return sectionedResources.map { arg -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            let (section, resources) = arg
            
            let taskViewModels: [TasksListItemViewModel] = resources.map { resource in
                let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                return TasksListItemViewModel(resource: resource, incident: incident, hasUpdates: true)
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

