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
    
    public let callsign: String
    
    public init(callsign: String) {
        self.callsign = callsign
    }
    
    override open func loadTasks() {
        guard let resource = CADStateManager.shared.resourcesById[callsign] else { return }
        
        var annotations: [TaskAnnotation] = []
        annotations += [resource.createAnnotation()].removeNils()
        
        if let currentIncident = resource.currentIncident, let incident = CADStateManager.shared.incidentsById[currentIncident] {
            annotations += [incident.createAnnotation()].removeNils()
        }
        
        filteredAnnotations = annotations
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        // Only allow selecting incidents
        return view is IncidentAnnotationView
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let coordinate = CADStateManager.shared.resourcesById[callsign]?.location?.coordinate {
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(coordinate, animated : false))
            viewController.defaultZoomDistance = defaultZoomDistance
            return viewController
        }
        return TasksMapViewController(viewModel: self, annotationsInitialLoadZoomStyle: (animated: false, includeUserLocation: true))
    }
}
