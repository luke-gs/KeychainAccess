//
//  ClusterTasksViewModelCore.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 3/4/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit

/// Core implementation of ClusterTasksViewModel
open class ClusterTasksViewModelCore: ClusterTasksViewModel {

    open override func convertAnnotationsToViewModels(annotations: [MKAnnotation]) {

        var viewModelsByType: [Int: [TasksListItemViewModel]] = [:]
        CADTaskListSourceCore.allCases.forEach { viewModelsByType[$0.rawValue] = [] }

        for annotation in annotations {
            if let incidentAnnotation = annotation as? IncidentAnnotation {
                if let incident = CADStateManager.shared.incidentsById[incidentAnnotation.identifier] {
                    let viewModel = TasksListIncidentViewModel(incident: incident,
                                                               source: CADTaskListSourceCore.incident,
                                                               hasUpdates: false)
                    viewModelsByType[CADTaskListSourceCore.incident.rawValue]?.append(viewModel)
                }
            }
            if let patrolAnnotation = annotation as? PatrolAnnotation {
                if let patrol = CADStateManager.shared.patrolsById[patrolAnnotation.identifier] {
                    let viewModel = TasksListBasicViewModel(patrol: patrol,
                                                            source: CADTaskListSourceCore.patrol)
                    viewModelsByType[CADTaskListSourceCore.patrol.rawValue]?.append(viewModel)
                }
            }
            if let broadcastAnnotation = annotation as? BroadcastAnnotation {
                if let broadcast = CADStateManager.shared.broadcastsById[broadcastAnnotation.identifier] {
                    let viewModel = TasksListBasicViewModel(broadcast: broadcast,
                                                            source: CADTaskListSourceCore.broadcast)
                    viewModelsByType[CADTaskListSourceCore.broadcast.rawValue]?.append(viewModel)
                }
            }
            if let resourceAnnotation = annotation as? ResourceAnnotation {
                if let resource = CADStateManager.shared.resourcesById[resourceAnnotation.identifier] {
                    let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                    let viewModel = TasksListResourceViewModel(resource: resource,
                                                               resourceSource: CADTaskListSourceCore.resource,
                                                               incident: incident,
                                                               incidentSource: CADTaskListSourceCore.incident)
                    viewModelsByType[CADTaskListSourceCore.resource.rawValue]?.append(viewModel)
                }
            }
        }

        sections = CADTaskListSourceCore.allCases.compactMap { type in
            guard let type = type as? CADTaskListSourceCore else { return nil }
            if let items = viewModelsByType[type.rawValue], items.count > 0 {
                let title = titleForType(type, count: items.count)
                return CADFormCollectionSectionViewModel(title: title, items: items)
            }
            return nil
        }
    }

    open func titleForType(_ type: CADTaskListSourceCore, count: Int) -> String {
        switch type {
        case .incident:
            return String.localizedStringWithFormat(NSLocalizedString("%d Incident(s)", comment: ""), count)
        case .patrol:
            return String.localizedStringWithFormat(NSLocalizedString("%d Patrol(s)", comment: ""), count)
        case .broadcast:
            return String.localizedStringWithFormat(NSLocalizedString("%d Broadcast(s)", comment: ""), count)
        case .resource:
            return String.localizedStringWithFormat(NSLocalizedString("%d Resource(s)", comment: ""), count)
        }
    }
}
