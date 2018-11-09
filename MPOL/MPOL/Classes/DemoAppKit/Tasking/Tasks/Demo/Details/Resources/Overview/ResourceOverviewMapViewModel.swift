//
//  ResourceOverviewMapViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class ResourceOverviewMapViewModel: TasksMapViewModel {

    public var resource: CADResourceType?

    open func reloadFromModel(_ model: CADResourceType) {
        self.resource = model
        loadTasks()
    }

    override open func loadTasks() {
        guard let resource = resource else { return }

        var annotations: [TaskAnnotation] = []
        annotations += [resource.createAnnotation()].removeNils()

        if let currentIncident = resource.currentIncident, let incident = CADStateManager.shared.incidentsById[currentIncident] {
            annotations += [incident.createAnnotation()].removeNils()
        }
        filteredAnnotations = annotations
    }

    override open func createViewController() -> TasksMapViewController {
        if let coordinate = resource?.location?.coordinate {
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(coordinate, animated : false))
            viewController.defaultZoomDistance = defaultZoomDistance
            return viewController
        }
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: false, includeUserLocation: true))
    }

    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        // Only allow selecting incidents
        return view is IncidentAnnotationView
    }
}
