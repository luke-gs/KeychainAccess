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
    
    open func createViewController(startingMapRegion: MKCoordinateRegion?) -> MapViewController {
        return TasksMapViewController(viewModel: self, initialLoadZoomStyle: .annotations(animated: true), startingRegion: startingMapRegion)
    }
}
