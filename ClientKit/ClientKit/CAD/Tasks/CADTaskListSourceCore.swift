//
//  CADTaskListSourceCore.swift
//  ClientKit
//
//  Created by Trent Fitzgibbon on 22/2/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import Foundation
import MPOLKit

/// PSCore implementation of enum representing a source of items in the task list
public enum CADTaskListSourceCore: Int, CADTaskListSourceType {
    case incident = 0
    case patrol = 1
    case broadcast = 2
    case resource = 3

    /// All cases, in order of display
    public static var allCases: [CADTaskListSourceCore] {
        return [
            CADTaskListSourceCore.incident,
            CADTaskListSourceCore.patrol,
            CADTaskListSourceCore.broadcast,
            CADTaskListSourceCore.resource
        ]
    }

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

    /// The list of model items of this type
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

    // Returns a list of model items that are filtered based on current settings
    public func filteredItems(filterViewModel: TaskMapFilterViewModel) -> [CADTaskListItemModelType] {
        switch self {
        case .incident:
            return CADStateManager.shared.incidents.filter { incident in
                // TODO: remove this once filtered by CAD system
                if !filterViewModel.showResultsOutsidePatrolArea && incident.patrolGroup != CADStateManager.shared.patrolGroup {
                    return false
                }

                let priorityFilter = filterViewModel.priorities.contains(where: { $0 == incident.grade })
                let resourcedFilter = filterViewModel.resourcedIncidents.contains(where: { $0 == incident.status })

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

                let isTasked = resource.currentIncident != nil
                let isDuress = resource.status.isDuress

                return filterViewModel.taskedResources.tasked && isTasked ||
                    filterViewModel.taskedResources.untasked && !isTasked ||
                isDuress
            }
        }
    }

    // Return all annotations of this type based on the current filter and source selection
    public func filteredAnnotations(filterViewModel: TaskMapFilterViewModel, selectedSource: CADTaskListSourceType) -> [TaskAnnotation] {
        if showItems(filterViewModel: filterViewModel) || selectedSource == self {
            return filteredItems(filterViewModel: filterViewModel).flatMap {
                return $0.createAnnotation()
            }
        }
        return []
    }

    // Whether to show items given the current filter
    public func showItems(filterViewModel: TaskMapFilterViewModel) -> Bool {
        switch self {
        case .incident:
            return filterViewModel.showIncidents
        case .patrol:
            return filter.showPatrol
        case .broadcast:
            return filter.showBroadcasts
        case .resource:
            return filter.showResources
        }
    }

    /// Return the source bar item of this type based on the current filter
    func sourceItem(filterViewModel: TaskMapFilterViewModel) -> SourceItem {
        // TODO: calculate colors based on priorities
        let count = modelItems.count
        let color = .secondaryGray
        /*
 sourceItemForType(type: .incident,  count: filteredIncidents.count, color: .orangeRed),
 sourceItemForType(type: .patrol,    count: filteredPatrols.count, color: .secondaryGray),
 sourceItemForType(type: .broadcast, count: filteredBroadcasts.count, color: .secondaryGray),
 sourceItemForType(type: .resource,  count: filteredResources.count, color: .orangeRed)
*/
        return SourceItem(title: title, shortTitle: shortTitle, state: .loaded(count: UInt(count), color: color))
    }

    /// Update the content of the list based on sectioning the current filtered items
    public func updateListContent(listViewModel: TasksListViewModel, filterViewModel: TaskMapFilterViewModel) {
        switch type {
        case .incident:
            // Set other sections first, as updates triggered when sections changes
            let filteredIncidents = filteredItems(filterViewModel: filterViewModel)
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

    /// Maps sync models to view models
    public func taskListSections(for incidents: [CADIncidentType], filter: ((CADIncidentType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
        var isShowingCurrentIncident = false

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
    public func taskListSections(for patrols: [CADPatrolType], filter: ((CADPatrolType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {

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
    public func taskListSections(for broadcasts: [CADBroadcastType], filter: ((CADBroadcastType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {

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
    public func taskListSections(for resources: [CADResourceType], filter: ((CADResourceType) -> Bool)?) -> [CADFormCollectionSectionViewModel<TasksListItemViewModel>] {
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
