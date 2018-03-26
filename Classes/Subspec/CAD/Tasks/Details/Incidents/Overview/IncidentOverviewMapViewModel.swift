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
        annotations += [incident.createAnnotation()].removeNils()
        annotations += resources.map { $0.createAnnotation() }.removeNils()
        
        filteredAnnotations = annotations
    }
    
    override open func createViewController() -> TasksMapViewController {
        if let coordinate = CADStateManager.shared.incidentsById[incidentNumber]?.location?.coordinate {
            let viewController = TasksMapViewController(viewModel: self, initialLoadZoomStyle: .coordinate(coordinate, animated : false))
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
    
    open override func allowsInteraction() -> Bool {
        return false
    }
}
