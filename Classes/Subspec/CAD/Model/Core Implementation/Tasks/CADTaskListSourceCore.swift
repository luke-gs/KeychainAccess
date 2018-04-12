//
//  CADTaskListSourceCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation

/// PSCore implementation of enum representing a source of items in the task list
public enum CADTaskListSourceCore: Int, CADTaskListSourceType {
    case incident = 0
    case patrol = 1
    case broadcast = 2
    case resource = 3

    /// All cases, in order of display
    public static var allCases: [CADTaskListSourceType] {
        return [
            CADTaskListSourceCore.incident,
            CADTaskListSourceCore.patrol,
            CADTaskListSourceCore.broadcast,
            CADTaskListSourceCore.resource
        ]
    }

    /// The case used for incident specific UI
    public static var incidentCase: CADTaskListSourceType = CADTaskListSourceCore.incident

    /// The case used for resource specific UI
    public static var resourceCase: CADTaskListSourceType = CADTaskListSourceCore.resource

    /// The default title to show
    public var title: String {
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

    /// The short title to show in the source bar
    public var shortTitle: String {
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

    /// Return the source bar item of this type based on the current filter
    public func sourceItem(filterViewModel: TasksMapFilterViewModel) -> SourceItem {
        let count = modelItems.count
        var color: UIColor? = nil

        switch self {
        case .incident:
            // Set the color of the source item based on incident priorities
            if let incidents = self.modelItems as? [CADIncidentType] {
                color = incidents.highestPriorityColor()
            }
        case .resource:
            // Set the color of the source item based on resource duress
            if let resources = self.modelItems as? [CADResourceType] {
                color = resources.highestAlertColor()
            }
        default:
            break
        }
        return SourceItem(title: title, shortTitle: shortTitle, state: .loaded(count: UInt(count), color: color))
    }

    /// Return the list of all model items of this type
    public var modelItems: [CADTaskListItemModelType] {
        switch self {
        case .incident:
            return CADStateManager.shared.incidents
        case .patrol:
            return CADStateManager.shared.patrols
        case .broadcast:
            return CADStateManager.shared.broadcasts
        case .resource:
            return CADStateManager.shared.resources
        }
    }

    // Returns a list of model items that are filtered based on current filter settings
    public func filteredItems(filterViewModel: TasksMapFilterViewModel) -> [CADTaskListItemModelType] {
        switch self {
        case .incident:
            return CADStateManager.shared.incidents.filter { incident in
                // TODO: remove this once filtered by CAD system
                if !filterViewModel.showResultsOutsidePatrolArea && incident.patrolGroup != CADStateManager.shared.patrolGroup {
                    return false
                }

                let priorityFilter: Bool
                let resourcedFilter: Bool

                if let filterViewModel = filterViewModel as? TasksMapFilterViewModelCore {
                    priorityFilter = filterViewModel.priorities.contains(where: { $0 == incident.grade })
                    resourcedFilter = filterViewModel.resourcedIncidents.contains(where: { $0 == incident.status })
                } else {
                    priorityFilter = true
                    resourcedFilter = true
                }
                
                // If status is not in filter options always show
                let isOther = !incident.status.isFilterable
                let isCurrent = incident.status == CADClientModelTypes.incidentStatus.currentCase

                var hasResourceInDuress: Bool = false

                for resource in CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier) {
                    if resource.status.isDuress {
                        hasResourceInDuress = true
                        break
                    }
                }
                return isCurrent || hasResourceInDuress || (priorityFilter && (resourcedFilter || isOther))
            }
        case .patrol:
            return CADStateManager.shared.patrols.filter { patrol in
                // TODO: remove this once filtered by CAD system
                if !filterViewModel.showResultsOutsidePatrolArea && patrol.patrolGroup != CADStateManager.shared.patrolGroup {
                    return false
                }
                return true
            }
        case .broadcast:
            return CADStateManager.shared.broadcasts
        case .resource:
            return CADStateManager.shared.resources.filter { resource in
                // TODO: remove this once filtered by CAD system
                if !filterViewModel.showResultsOutsidePatrolArea && resource.patrolGroup != CADStateManager.shared.patrolGroup {
                    return false
                }

                // Ignore off duty resources
                guard resource.status.shownOnMap else { return false }

                let isDuress = resource.status.isDuress
                
                if let filterViewModel = filterViewModel as? TasksMapFilterViewModelCore {
                    let isTasked = resource.currentIncident != nil

                    return filterViewModel.taskedResources.tasked && isTasked ||
                        filterViewModel.taskedResources.untasked && !isTasked ||
                    isDuress
                } else {
                    return isDuress
                }
            }
        }
    }

    // Return all annotations of this type based on the current filter and source selection
    public func filteredAnnotations(filterViewModel: TasksMapFilterViewModel, selectedSource: CADTaskListSourceType) -> [TaskAnnotation] {
        if shouldShowType(filterViewModel: filterViewModel) || selectedSource == self {
            return filteredItems(filterViewModel: filterViewModel).compactMap {
                return $0.createAnnotation()
            }
        }
        return []
    }

    /// Return the sectioned task list content for current filter and optional search text
    public func sectionedListContent(filterViewModel: TasksMapFilterViewModel, searchText: String?) -> [[CADFormCollectionSectionViewModel<TasksListItemViewModel>]] {

        let filteredItems = self.filteredItems(filterViewModel: filterViewModel)
        switch self {
        case .incident:
            guard let incidents = filteredItems as? [CADIncidentType] else { return [] }
            return [
                taskListSections(for: incidents, filter: { (incident) -> Bool in
                    return incident.patrolGroup == CADStateManager.shared.patrolGroup
                }, searchText: searchText),
                taskListSections(for: incidents, filter: { (incident) -> Bool in
                    return incident.patrolGroup != CADStateManager.shared.patrolGroup
                }, searchText: searchText)
            ]
        case .patrol:
            guard let patrols = filteredItems as? [CADPatrolType] else { return [] }
            return [taskListSections(for: patrols, filter: nil, searchText: searchText)]
        case .broadcast:
            guard let broadcasts = filteredItems as? [CADBroadcastType] else { return [] }
            return [taskListSections(for: broadcasts, filter: nil, searchText: searchText)]
        case .resource:
            guard let resources = filteredItems as? [CADResourceType] else { return [] }
            return [
                taskListSections(for: resources, filter: { (incident) -> Bool in
                    return incident.patrolGroup == CADStateManager.shared.patrolGroup
                }, searchText: searchText),
                taskListSections(for: resources, filter: { (incident) -> Bool in
                    return incident.patrolGroup != CADStateManager.shared.patrolGroup
                }, searchText: searchText)
            ]
        }
    }

    /// Whether items of this type can be created
    public var canCreate: Bool {
        switch self {
        case .incident:
            return true
        default:
            return false
        }
    }

    /// The annotation view type to use for prioritising items on map
    public var annotationViewType: MKAnnotationView.Type? {
        switch self {
        case .incident:
            return IncidentAnnotationView.self
        case .resource:
            return ResourceAnnotationView.self
        default:
            return nil
        }
    }

    /// Create the view model for an item of this type with given id
    public func createItemViewModel(identifier: String) -> TaskItemViewModel? {
        switch self {
        case .incident:
            if let incident = CADStateManager.shared.incidentsById[identifier] {
                // Show details of our resource if we are assigned to incident
                let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: incident.identifier)
                var resource: CADResourceType? = nil
                if let currentResource = CADStateManager.shared.currentResource {
                    resource = resources.contains(where: { $0 == currentResource }) ? currentResource : nil
                }
                return IncidentTaskItemViewModel(incident: incident, resource: resource)
            }
        case .patrol:
            if let patrol = CADStateManager.shared.patrolsById[identifier] {
                return PatrolTaskItemViewModel(patrol: patrol)
            }
        case .broadcast:
            if let broadcast = CADStateManager.shared.broadcastsById[identifier] {
                return BroadcastTaskItemViewModel(broadcast: broadcast)
            }
        case .resource:
            if let resource = CADStateManager.shared.resourcesById[identifier] {
                return ResourceTaskItemViewModel(resource: resource)
            }
        }
        return nil
    }


    // MARK: - Internal

    /// Return the sectioned incidents for given filter and search text
    public func taskListSections(for incidents: [CADIncidentType], filter: ((CADIncidentType) -> Bool)?, searchText: String?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var sectionedIncidents: [String: Array<CADIncidentType>] = [:]

        // Map incidents to sections
        for incident in incidents {
            if let filter = filter {
                guard filter(incident) else { continue }
            }

            let status = incident.status.rawValue
            if sectionedIncidents[status] == nil {
                sectionedIncidents[status] = []
            }

            // Apply search text filter to type, primary code, secondary code or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [incident.type, incident.incidentNumber, incident.secondaryCode, incident.location?.suburb].removeNils().filter {
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

            let taskViewModels = incidents.map { incident in
                return TasksListIncidentViewModel(incident: incident, source: CADTaskListSourceCore.incident, hasUpdates: true)
            }
            return CADFormCollectionSectionViewModel(
                title: "\(incidents.count) \(status)",
                items: taskViewModels,
                preventCollapse: (status == CADClientModelTypes.incidentStatus.currentCase))

        }.removeNils()

        return sortedIncidents
    }

    /// Return the sectioned patrols for given filter and search text
    public func taskListSections(for patrols: [CADPatrolType], filter: ((CADPatrolType) -> Bool)?, searchText: String?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {

        var sectionedPatrols: [String: Array<CADPatrolType>] = [:]

        // Map incidents to sections
        for patrol in patrols {
            if let filter = filter {
                guard filter(patrol) else { continue }
            }

            let status = patrol.status.title
            if sectionedPatrols[status] == nil {
                sectionedPatrols[status] = []
            }

            // Apply search text filter to type, identifier, or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [patrol.type, patrol.identifier, patrol.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedPatrols[status]?.append(patrol)
                }
            } else {
                sectionedPatrols[status]?.append(patrol)
            }
        }

        let orderedSections = CADPatrolStatusCore.allCases
        return orderedSections.compactMap { category -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in

            let key = category.title
            if let value = sectionedPatrols[key] {
                let taskViewModels: [TasksListBasicViewModel] = value.map { patrol in
                    return TasksListBasicViewModel(patrol: patrol, source: CADTaskListSourceCore.patrol)
                }
                if !taskViewModels.isEmpty {
                    return CADFormCollectionSectionViewModel(title: "\(value.count) \(key)", items: taskViewModels)
                }
            }
            return nil
        }
    }

    /// Return the sectioned broadcasts for given filter and search text
    public func taskListSections(for broadcasts: [CADBroadcastType], filter: ((CADBroadcastType) -> Bool)?, searchText: String?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {

        var sectionedBroadcasts: [String: Array<CADBroadcastType>] = [:]

        // Map incidents to sections
        for broadcast in broadcasts {
            if let filter = filter {
                guard filter(broadcast) else { continue }
            }

            let type = broadcast.type.title
            if sectionedBroadcasts[type] == nil {
                sectionedBroadcasts[type] = []
            }

            // Apply search text filter to title, identifier or suburb
            if let searchText = searchText?.lowercased(), !searchText.isEmpty {
                let matchedValues = [broadcast.title, broadcast.identifier, broadcast.location?.suburb].removeNils().filter {
                    return $0.lowercased().hasPrefix(searchText)
                }
                if !matchedValues.isEmpty {
                    sectionedBroadcasts[type]?.append(broadcast)
                }
            } else {
                sectionedBroadcasts[type]?.append(broadcast)
            }
        }

        let orderedSections = CADBroadcastCategoryCore.allCases
        return orderedSections.compactMap { category -> CADFormCollectionSectionViewModel<TasksListItemViewModel>? in

            let key = category.title
            if let value = sectionedBroadcasts[key] {
                let taskViewModels: [TasksListBasicViewModel] = value.map { broadcast in
                    return TasksListBasicViewModel(broadcast: broadcast, source: CADTaskListSourceCore.broadcast)
                }
                if !taskViewModels.isEmpty {
                    let title = category.pluralTitle(count: value.count)
                    return CADFormCollectionSectionViewModel(title: title, items: taskViewModels)
                }
            }
            return nil
        }
    }

    /// Return the sectioned resources for given filter and search text
    public func taskListSections(for resources: [CADResourceType], filter: ((CADResourceType) -> Bool)?, searchText: String?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {

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
                if resource.status.isDuress {
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
                return TasksListResourceViewModel(resource: resource, resourceSource: CADTaskListSourceCore.resource, incident: incident, incidentSource: CADTaskListSourceCore.incident)
            }

            var title = "\(resources.count) \(section)"
            if section == duress {
                title = String.localizedStringWithFormat(NSLocalizedString("%d Resource(s)", comment: ""), resources.count) + " In Duress"
            }
            return CADFormCollectionSectionViewModel(title: title,
                                                     items: taskViewModels,
                                                     preventCollapse: (section == duress))

        }.removeNils()

        return sections
    }

    // Whether to show items given the current filter
    public func shouldShowType(filterViewModel: TasksMapFilterViewModel) -> Bool {
        return filterViewModel.showsType(self)
    }

}

// Convenience extension to get highest priority incident grade
extension Array where Element == CADIncidentType {

    func highestPriority() -> CADIncidentGradeType? {
        let priorities = self.map { return $0.grade }
        let sortedGrades = CADClientModelTypes.incidentGrade.allCases
        let sortedPriorities = priorities.sorted { (lhs, rhs) in
            let lhsIndex = sortedGrades.index(where: { $0 == lhs })
            let rhsIndex = sortedGrades.index(where: { $0 == rhs })
            return lhsIndex ?? 0 < rhsIndex ?? 0
        }
        return sortedPriorities.first
    }

    func highestPriorityColor() -> UIColor? {
        if let highestPriority = highestPriority() as? CADIncidentGradeCore {
            switch highestPriority {
            case .p1:
                return .orangeRed
            case .p2:
                return .sunflowerYellow
            case .p3, .p4:
                return nil
            }
        }
        return nil
    }
}

// Convenience extension to get highest priority incident grade
extension Array where Element == CADResourceType {

    func highestAlertColor() -> UIColor? {
        let duressResources = self.compactMap { return $0.status == CADResourceStatusCore.duress ? $0 : nil }
        if duressResources.count > 0 {
            return .orangeRed
        } else {
            return nil
        }
    }
}
