//
//  ClusterTasksViewModel.swift
//  MPOLKit
//
//  Created by Trent Fitzgibbon on 29/3/18.
//  Copyright © 2018 Gridstone. All rights reserved.
//

import UIKit
import Cluster

open class ClusterTasksViewModel: CADFormCollectionViewModel<TasksListItemViewModel> {

    public init(annotationView: ClusterAnnotationView) {
        super.init()

        // Convert all the annotations to TasksListItemViewModels
        if let clusterAnnotation = annotationView.annotation as? ClusterAnnotation {
            convertAnnotationsToViewModels(annotations: clusterAnnotation.annotations)
        }

    }

    /// Convert the annotations to view models. Override for client specific annotations
    open func convertAnnotationsToViewModels(annotations: [MKAnnotation]) {
        var incidents: [TasksListItemViewModel] = []
        var resources: [TasksListItemViewModel] = []
        let incidentSource = CADClientModelTypes.taskListSources.incidentCase
        let resourceSource = CADClientModelTypes.taskListSources.resourceCase

        for annotation in annotations {
            if let incidentAnnotation = annotation as? IncidentAnnotation {
                if let incident = CADStateManager.shared.incidentsById[incidentAnnotation.identifier] {
                    incidents.append(TasksListIncidentViewModel(incident: incident,
                                                                source: incidentSource,
                                                                hasUpdates: false))
                }
            }
            if let resourceAnnotation = annotation as? ResourceAnnotation {
                if let resource = CADStateManager.shared.resourcesById[resourceAnnotation.identifier] {
                    let incident = CADStateManager.shared.incidentForResource(callsign: resource.callsign)
                    resources.append(TasksListResourceViewModel(resource: resource,
                                                                resourceSource: resourceSource,
                                                                incident: incident,
                                                                incidentSource: incidentSource))
                }
            }
        }

        if incidents.count > 0 {
            sections.append(CADFormCollectionSectionViewModel(
                title: "\(incidents.count) Incidents",
                items: incidents,
                preventCollapse: true))
        }
        if resources.count > 0 {
            sections.append(CADFormCollectionSectionViewModel(
                title: "\(resources.count) Resources",
                items: resources,
                preventCollapse: true))
        }
    }

    /// Create the view controller for this view model
    open func createViewController() -> UIViewController {
        let viewController = ClusterTasksViewController(viewModel: self)
        return viewController
    }

    // MARK: - Override

    /// The title to use in the navigation bar
    override open func navTitle() -> String {
        return "Cluster Details"
    }
}
