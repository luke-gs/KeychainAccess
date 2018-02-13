//
//  IncidentOverviewMapViewModel.swift
//  MPOLKit
//
//  Created by Kyle May on 7/12/17.
//  Copyright © 2017 Gridstone. All rights reserved.
//

import UIKit
import MapKit

open class IncidentOverviewMapViewModel: TasksMapViewModel {

    private let incidentNumber: String
    
    public init(incidentNumber: String) {
        self.incidentNumber = incidentNumber
    }
    
    override open func loadTasks() {
        guard let incident = CADStateManager.shared.incidentsById[incidentNumber] else { return }
        let resources = CADStateManager.shared.resourcesForIncident(incidentNumber: incidentNumber)
        
        var annotations: [TaskAnnotation] = []
        annotations += taskAnnotations(for: [incident])
        annotations += taskAnnotations(for: resources)
        
        filteredAnnotations = annotations
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let incidentLocation = CADStateManager.shared.incidentsById[incidentNumber]?.location {
            let location = CLLocation(latitude: CLLocationDegrees(incidentLocation.latitude), longitude: CLLocationDegrees(incidentLocation.longitude))
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(location, animated : false))
            viewController.defaultZoomDistance = defaultZoomDistance
            return viewController
        }
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: false, includeUserLocation: true))
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        // Only allow selecting resources
        return view is ResourceAnnotationView
    }
    
    open override func shouldCluster() -> Bool {
        return false
    }
}
