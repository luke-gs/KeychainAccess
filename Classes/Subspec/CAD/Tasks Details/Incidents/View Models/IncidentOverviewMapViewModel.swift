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
        return TasksMapViewController(viewModel: self, initialLoadZoomStyle: .annotations(animated: false))
    }
    
    open override func canSelectAnnotationView(_ view: MKAnnotationView) -> Bool {
        // Only allow selecting resources
        return view is ResourceAnnotationView
    }
}
