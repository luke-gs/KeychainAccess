//
//  TasksListContainerViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 13/10/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import PromiseKit
import MapKit

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
    
    var annotationType: MKAnnotationView.Type? {
        switch self {
        case .incident:
            return IncidentAnnotationView.self
        case .resource:
            return ResourceAnnotationView.self
        default:
            return nil
        }
    }
}

/// Protocol for notifying UI of updated view model data
public protocol TasksListContainerViewModelDelegate: class {

    // Called when source items are updated
    func updateSourceItems()

    // Called when selected source changes
    func updateSelectedSourceIndex()
}

/// View model for the task list container, which is the parent of the header and list view models
///
/// This view model owns the sources and current source selection, so changes can be applied to both the header and list
///
open class TasksListContainerViewModel {

    public weak var splitViewModel: TasksSplitViewModel?
    public weak var delegate: TasksListContainerViewModelDelegate?

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
                let type = TaskListType(rawValue: selectedSourceIndex)

                headerViewModel.selectedSourceIndex = selectedSourceIndex
                splitViewModel?.mapViewModel.loadTasks()
                if let annotationType = type?.annotationType {
                    splitViewModel?.mapViewModel.priorityAnnotationType = annotationType
                }
                updateSections()

                // Show/hide add button
                headerViewModel.setAddButtonVisible(type == .incident)

                delegate?.updateSelectedSourceIndex()
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
        
        /// Observe book-on and callsign changes to show assigned incidents
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADBookOnChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bookOnChanged), name: .CADCallsignChanged, object: nil)

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
            let filteredPatrols = splitViewModel.filteredPatrols
            let filteredBroadcasts = splitViewModel.filteredBroadcasts
            let filteredResources = splitViewModel.filteredResources

            // Apply filtered data to sources and sections
            switch type {
            case .incident:
                // Set other sections first, as updates triggered when sections changes
                listViewModel.otherSections = taskListSections(for: filteredIncidents, filter: { (incident) -> Bool in
                    return incident.patrolGroup != CADStateManager.shared.patrolGroup
                })
                listViewModel.sections = taskListSections(for: filteredIncidents, filter: { (incident) -> Bool in
                    return incident.patrolGroup == CADStateManager.shared.patrolGroup
                })
            case .patrol:
                listViewModel.sections = taskListSections(for: filteredPatrols, filter: nil)
            case .broadcast:
                listViewModel.sections = taskListSections(for: filteredBroadcasts, filter: nil)
            case .resource:
                listViewModel.otherSections = taskListSections(for: filteredResources, filter: { (resource) -> Bool in
                    return resource.patrolGroup != CADStateManager.shared.patrolGroup
                })
                listViewModel.sections = taskListSections(for: filteredResources, filter: { (resource) -> Bool in
                    return resource.patrolGroup == CADStateManager.shared.patrolGroup
                })
            }

            // Update the source items status
            // TODO: calculate colors based on priorities
            sourceItems = [
                sourceItemForType(type: .incident,  count: filteredIncidents.count, color: .orangeRed),
                sourceItemForType(type: .patrol,    count: filteredPatrols.count, color: .secondaryGray),
                sourceItemForType(type: .broadcast, count: filteredBroadcasts.count, color: .secondaryGray),
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
    open func taskListSections(for incidents: [CADIncidentType], filter: ((CADIncidentType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var isShowingCurrentIncident = false

        var sectionedIncidents: [String: Array<CADIncidentType>] = [:]

        // Map incidents to sections
        for incident in incidents {
            if let filter = filter {
                guard filter(incident) else { continue }
            }

            let status = incident.statusType.rawValue
            if sectionedIncidents[status] == nil {
                sectionedIncidents[status] = []
            }

            // Apply search text filter to type, primary code, secondary code or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [incident.type, incident.identifier, incident.secondaryCode, incident.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedIncidents[status]?.append(incident)
                }
            } else {
                sectionedIncidents[status]?.append(incident)
            }
        }
  
        let sortedIncidents = CADClientModelTypes.incidentStatus.allCases.map { status -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            guard let incidents = sectionedIncidents[status.rawValue], !incidents.isEmpty else { return nil }
            
            if status == CADClientModelTypes.incidentStatus.currentCase {
                isShowingCurrentIncident = true
            }
            
            let taskViewModels = incidents.map { incident in
                return TasksListIncidentViewModel(incident: incident, hasUpdates: true)
            }
            return CADFormCollectionSectionViewModel(title: "\(incidents.count) \(status)",
                items: taskViewModels
            )
        }.removeNils()
        
        if isShowingCurrentIncident {
            listViewModel.indexesForNonCollapsibleSections.insert(0)
        } else {
            listViewModel.indexesForNonCollapsibleSections.remove(0)
        }
        
        
        return sortedIncidents
    }
    
    /// Maps sync models to view models
    open func taskListSections(for patrols: [CADPatrolType], filter: ((CADPatrolType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        
        var sectionedPatrols: [String: Array<CADPatrolType>] = [:]
        
        // Map incidents to sections
        for patrol in patrols {
            if let filter = filter {
                guard filter(patrol) else { continue }
            }
            
            let status = patrol.status.rawValue
            if sectionedPatrols[status] == nil {
                sectionedPatrols[status] = []
            }
            
            // Apply search text filter to type, identifier, subtype, or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [patrol.type, patrol.identifier, patrol.subtype, patrol.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedPatrols[status]?.append(patrol)
                }
            } else {
                sectionedPatrols[status]?.append(patrol)
            }
        }
        
        return sectionedPatrols.map { (arg) -> CADFormCollectionSectionViewModel<TasksListItemViewModel> in
            
            let (key, value) = arg
            
            let taskViewModels: [TasksListBasicViewModel] = value.map { patrol in
                return TasksListBasicViewModel(patrol: patrol)
            }
            
            return CADFormCollectionSectionViewModel(title: "\(value.count) \(key)", items: taskViewModels)
        }
    }
    
    /// Maps sync models to view models
    open func taskListSections(for broadcasts: [CADBroadcastType], filter: ((CADBroadcastType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        
        var sectionedBroadcasts: [String: Array<CADBroadcastType>] = [:]
        
        // Map incidents to sections
        for broadcast in broadcasts {
            if let filter = filter {
                guard filter(broadcast) else { continue }
            }
            
            let type = broadcast.type.rawValue
            if sectionedBroadcasts[type] == nil {
                sectionedBroadcasts[type] = []
            }
            
            // Apply search text filter to title, identifier, type, or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [broadcast.title, broadcast.identifier, broadcast.type.rawValue, broadcast.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedBroadcasts[type]?.append(broadcast)
                }
            } else {
                sectionedBroadcasts[type]?.append(broadcast)
            }
        }
        
        return sectionedBroadcasts.map { (arg) -> CADFormCollectionSectionViewModel<TasksListItemViewModel> in
            
            let (key, value) = arg
            
            let taskViewModels: [TasksListBasicViewModel] = value.map { broadcast in
                return TasksListBasicViewModel(broadcast: broadcast)
            }
            
            return CADFormCollectionSectionViewModel(title: "\(value.count) \(key)", items: taskViewModels)
        }
    }
    
    /// Maps sync models to view models
    open func taskListSections(for resources: [CADResourceType], filter: ((CADResourceType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var isShowingDuress = false
        
        // Map resources to sections
        let duress = NSLocalizedString("Duress", comment: "")
        let tasked = NSLocalizedString("Tasked", comment: "")
        let untasked = NSLocalizedString("Untasked", comment: "")
        
        var sectionedResources: [String: Array<CADResourceType>] = [
            duress: [],
            tasked: [],
            untasked: []
        ]
        
        for resource in resources {
            if let filter = filter {
                guard filter(resource) else { continue }
            }

            // Apply search text filter to type or address
            var shouldAppend: Bool = false
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [resource.callsign, resource.type.rawValue, resource.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    shouldAppend = true
                }
            } else {
                shouldAppend = true
            }

            if shouldAppend {
                if resource.statusType.isDuress {
                    sectionedResources[duress]?.append(resource)
                } else if resource.currentIncident != nil {
                    sectionedResources[tasked]?.append(resource)
                } else {
                    sectionedResources[untasked]?.append(resource)
                }
            }
        }
        
        // Make view models from sections
        let sections = sectionedResources.map { arg -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in
            let (section, resources) = arg
            
            
            // Don't add section if section is empty
            if resources.isEmpty {
                return nil
            }
            
            let taskViewModels: [TasksListResourceViewModel] = resources.map { resource in
                let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                return TasksListResourceViewModel(resource: resource, incident: incident)
            }
            
            var title = "\(resources.count) \(section)"
            
            if section == duress {
                isShowingDuress = true
                title = String.localizedStringWithFormat(NSLocalizedString("%d Resource(s)", comment: ""), resources.count) + " In Duress"
            }
            
            return CADFormCollectionSectionViewModel(title: title, items: taskViewModels)
        }.removeNils()
        
        if isShowingDuress {
            listViewModel.indexesForNonCollapsibleSections.insert(0)
        } else {
            listViewModel.indexesForNonCollapsibleSections.remove(0)
        }
        
        return sections
    }

}
